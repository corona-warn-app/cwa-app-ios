////
// 🦠 Corona-Warn-App
//

import UIKit
import OpenCombine

final class HealthCertificateViewModel {

	// MARK: - Init

	init(
		healthCertifiedPerson: HealthCertifiedPerson,
		healthCertificate: HealthCertificateData,
		vaccinationValueSetsProvider: VaccinationValueSetsProvider
	) {
		self.healthCertificate = healthCertificate
		self.vaccinationValueSetsProvider = vaccinationValueSetsProvider
		self.qrCodeCellViewModel = HealthCertificateQRCodeCellViewModel(healthCertificate: healthCertificate)

		healthCertifiedPerson.$hasValidProofCertificate
			.sink { [weak self] isValid in
				self?.gradientType = isValid ? .lightBlue : .solidGrey
			}
			.store(in: &subscriptions)

		// load certificate value sets
		vaccinationValueSetsProvider.latestVaccinationCertificateValueSets()
			.sink(
				receiveCompletion: { result in
					switch result {
					case .finished:
						break
					case .failure(let error):
						if case CachingHTTPClient.CacheError.dataVerificationError = error {
							Log.error("Signature verification error.", log: .vaccination, error: error)
						}
						Log.error("Could not fetch Vaccination value sets protobuf.", log: .vaccination, error: error)
					}
				}, receiveValue: { [weak self] valueSets in
					self?.valueSets = valueSets
					self?.setupHealthCertificateKeyValueCellViewModel()
				}
			)
			.store(in: &subscriptions)

	}

	// MARK: - Internal

	enum TableViewSection: Int, CaseIterable {
		case headline
		case qrCode
		case topCorner
		case details
		case bottomCorner

		static var numberOfSections: Int {
			allCases.count
		}

		static func map(_ section: Int) -> TableViewSection? {
			guard let section = TableViewSection(rawValue: section) else {
				Log.error("unknown TableViewSection", log: .vaccination)
				return nil
			}
			return section
		}
	}

	@OpenCombine.Published private(set) var gradientType: GradientView.GradientType = .solidGrey
	@OpenCombine.Published private(set) var healthCertificateKeyValueCellViewModel: [HealthCertificateKeyValueCellViewModel] = []

	var headlineCellViewModel: HealthCertificateSimpleTextCellViewModel {
		let centerParagraphStyle = NSMutableParagraphStyle()
		centerParagraphStyle.alignment = .center
		centerParagraphStyle.lineSpacing = 10.0

		var attributedName: NSAttributedString?
		if let vaccinationCertificate = healthCertificate.vaccinationCertificates.first {
			attributedName = NSAttributedString(
				string: String(format: AppStrings.HealthCertificate.Details.vaccinationCount, vaccinationCertificate.doseNumber, vaccinationCertificate.totalSeriesOfDoses),
				attributes: [
					.font: UIFont.enaFont(for: .headline),
					.foregroundColor: UIColor.enaColor(for: .textContrast),
					.paragraphStyle: centerParagraphStyle
				]
			)
		}

		let attributedDetails = NSAttributedString(
			string: AppStrings.HealthCertificate.Details.certificate,
			attributes: [
				.font: UIFont.enaFont(for: .body),
				.foregroundColor: UIColor.enaColor(for: .textContrast),
				.paragraphStyle: centerParagraphStyle
			]
		)

		return HealthCertificateSimpleTextCellViewModel(
			backgroundColor: .clear,
			textAlignment: .center,
			attributedText: [attributedName, attributedDetails]
				.compactMap { $0 }
				.joined(with: "\n"),
			topSpace: 18.0,
			font: .enaFont(for: .headline),
			accessibilityTraits: .staticText
		)
	}

	let qrCodeCellViewModel: HealthCertificateQRCodeCellViewModel

	func numberOfItems(in section: TableViewSection) -> Int {
		switch section {
		case .headline:
			return healthCertificate.vaccinationCertificates.isEmpty ? 0 : 1
		case .details:
			return healthCertificateKeyValueCellViewModel.count
		default:
			return healthCertificateKeyValueCellViewModel.isEmpty ? 0 : 1
		}
	}

	// MARK: - Private

	private enum valueSetType: String {
		case vp
		case mp
		case ma
	}

	private let healthCertificate: HealthCertificateData
	private let vaccinationValueSetsProvider: VaccinationValueSetsProvider
	private let dateFormatter: DateFormatter = {
		let dateFormatter = DateFormatter()
		dateFormatter.dateFormat = "YYYY-MM-dd"
		return dateFormatter
	}()

	private var valueSets: SAP_Internal_Dgc_ValueSets?
	private var subscriptions = Set<AnyCancellable>()

	private func setupHealthCertificateKeyValueCellViewModel() {
		// person cell - always visible
		var dateOfBirth: String = ""
		if let date = dateFormatter.date(from: healthCertificate.dateOfBirth) {
			dateOfBirth = DateFormatter.localizedString(from: date, dateStyle: .medium, timeStyle: .none)
		}
		let nameCellViewModel = HealthCertificateKeyValueCellViewModel(
			key: healthCertificate.name.fullName,
			value: String(format: AppStrings.HealthCertificate.Details.dateOfBirth, dateOfBirth),
			topSpace: 2.0
		)

		// all vaccinationCertificate cell data - optional values
		let vaccinationCertificate = healthCertificate.vaccinationCertificates.first
		var dateCellViewModel: HealthCertificateKeyValueCellViewModel?
		if	let dateString = vaccinationCertificate?.dateOfVaccination,
			let date = dateFormatter.date(from: dateString) {
			dateCellViewModel = HealthCertificateKeyValueCellViewModel(
				key: AppStrings.HealthCertificate.Details.dateOfVaccination,
				value: DateFormatter.localizedString(from: date, dateStyle: .medium, timeStyle: .none)
			)
		}

		var vaccinationCellViewModel: HealthCertificateKeyValueCellViewModel?
		if let valueSet = valueSet(by: .mp),
		   let key = vaccinationCertificate?.vaccineMedicinalProduct {
			let value = determineValue(key: key, valueSet: valueSet)
			vaccinationCellViewModel = HealthCertificateKeyValueCellViewModel(
				key: AppStrings.HealthCertificate.Details.vaccine,
				value: value
			)
		}

		var manufacturerCellViewModel: HealthCertificateKeyValueCellViewModel?
		if let valueSet = valueSet(by: .ma),
		   let key = vaccinationCertificate?.marketingAuthorizationHolder {
			let value = determineValue(key: key, valueSet: valueSet)
			manufacturerCellViewModel = HealthCertificateKeyValueCellViewModel(
				key: AppStrings.HealthCertificate.Details.manufacture,
				value: value
			)
		}

		let issuerCellViewModel = HealthCertificateKeyValueCellViewModel(
			key: AppStrings.HealthCertificate.Details.issuer,
			value: vaccinationCertificate?.certificateIssuer
		)

		var countryCellViewModel: HealthCertificateKeyValueCellViewModel?
		if	let countryCode = vaccinationCertificate?.countryOfVaccination,
			let country = Country(countryCode: countryCode) {
			countryCellViewModel = HealthCertificateKeyValueCellViewModel(
				key: AppStrings.HealthCertificate.Details.country,
				value: country.localizedName
			)
		}

		let certificateNumberCellViewModel = HealthCertificateKeyValueCellViewModel(
			key: AppStrings.HealthCertificate.Details.identifier,
			value: vaccinationCertificate?.uniqueCertificateIdentifier,
			isBottomSeparatorHidden: true,
			bottomSpace: 2.0
		)

		healthCertificateKeyValueCellViewModel = [
			nameCellViewModel,
			dateCellViewModel,
			vaccinationCellViewModel,
			manufacturerCellViewModel,
			issuerCellViewModel,
			countryCellViewModel,
			certificateNumberCellViewModel
		]
		.compactMap { $0 }
	}

	private func valueSet(by type: valueSetType) -> SAP_Internal_Dgc_ValueSet? {
		guard let valueSets = valueSets else {
			Log.error("tried to read from unavailable valuesets", log: .vaccination)
			return nil
		}
		switch type {
		case .vp:
			return valueSets.hasVp ? valueSets.vp : nil
		case .mp:
			return valueSets.hasMp ? valueSets.mp : nil
		case .ma:
			return valueSets.hasMa ? valueSets.ma : nil
		}
	}

	private func determineValue(key: String, valueSet: SAP_Internal_Dgc_ValueSet) -> String {
		for item in valueSet.items where item.key == key {
			return item.displayText
		}
		return key
	}

}
