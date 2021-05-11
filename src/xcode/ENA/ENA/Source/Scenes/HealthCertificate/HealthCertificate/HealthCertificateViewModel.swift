////
// 🦠 Corona-Warn-App
//

import UIKit
import OpenCombine

final class HealthCertificateViewModel {

	// MARK: - Init

	init(
		healthCertifiedPerson: HealthCertifiedPerson,
		healthCertificate: HealthCertificate,
		vaccinationValueSetsProvider: VaccinationValueSetsProvider
	) {
		self.healthCertificate = healthCertificate
		self.vaccinationValueSetsProvider = vaccinationValueSetsProvider

		healthCertifiedPerson.$hasValidProofCertificate
			.sink { [weak self] isValid in
				self?.gradientType = isValid ? .blueOnly : .solidGrey
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
		case topCorner
		case details
		case bottomCorner

		static var numberOfSections: Int {
			allCases.count
		}

		static func map(_ section: Int) -> TableViewSection {
			guard let section = TableViewSection(rawValue: section) else {
				fatalError("unsupported tableView section")
			}
			return section
		}
	}

	@OpenCombine.Published private(set) var gradientType: GradientView.GradientType = .solidGrey
	@OpenCombine.Published private(set) var healthCertificateKeyValueCellViewModel: [HealthCertificateKeyValueCellViewModel] = []

	var headlineCellViewModel: HealthCertificateSimpleTextCellViewModel {
		guard let vaccinationCertificate = healthCertificate.vaccinationCertificates.first else {
			Log.error("Failed to setup certificate details without vaccinationCertificates")
			fatalError("missing vaccinationCertificates")
		}

		let centerParagraphStyle = NSMutableParagraphStyle()
		centerParagraphStyle.alignment = .center

		let attributedName = NSAttributedString(
			string: String(format: AppStrings.HealthCertificate.Details.vaccinationCount, vaccinationCertificate.doseNumber, vaccinationCertificate.totalSeriesOfDoses),
			attributes: [
				.font: UIFont.enaFont(for: .headline),
				.foregroundColor: UIColor.enaColor(for: .textContrast),
				.paragraphStyle: centerParagraphStyle
			]
		)

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
			attributedText: [attributedName, attributedDetails].joined(with: "\n"),
			topSpace: 18.0,
			font: .enaFont(for: .headline),
			accessibilityTraits: .staticText
		)
	}

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

	private let healthCertificate: HealthCertificate
	private let vaccinationValueSetsProvider: VaccinationValueSetsProvider
	private let dateFormatter: DateFormatter = {
		let dateFormatter = DateFormatter()
		dateFormatter.dateFormat = "YYYY-MM-dd"
		return dateFormatter
	}()

	private var valueSets: SAP_Internal_Dgc_ValueSets?
	private var subscriptions = Set<AnyCancellable>()

	private func setupHealthCertificateKeyValueCellViewModel() {
		var nameCellViewModel: HealthCertificateKeyValueCellViewModel?
		if let date = dateFormatter.date(from: healthCertificate.dateOfBirth) {
			nameCellViewModel = HealthCertificateKeyValueCellViewModel(
				key: healthCertificate.name.fullName,
				value: String(format: AppStrings.HealthCertificate.Details.dateOfBirth, DateFormatter.localizedString(from: date, dateStyle: .medium, timeStyle: .none))
			)
		}

		var dateCellViewModel: HealthCertificateKeyValueCellViewModel?
		if	let dateString = healthCertificate.vaccinationCertificates.first?.dateOfVaccination,
			let date = dateFormatter.date(from: dateString) {
			dateCellViewModel = HealthCertificateKeyValueCellViewModel(
				key: AppStrings.HealthCertificate.Details.dateOfVaccination,
				value: DateFormatter.localizedString(from: date, dateStyle: .medium, timeStyle: .none)
			)
		}

		var vaccinationCellViewModel: HealthCertificateKeyValueCellViewModel?
		if let valueSet = valueSet(by: .mp),
		   let key = healthCertificate.vaccinationCertificates.first?.vaccineMedicinalProduct {
			let value = determineValue(key: key, valueSet: valueSet)
			vaccinationCellViewModel = HealthCertificateKeyValueCellViewModel(
				key: AppStrings.HealthCertificate.Details.vaccine,
				value: value
			)
		}

		var manufacturerCellViewModel: HealthCertificateKeyValueCellViewModel?
		if let valueSet = valueSet(by: .ma),
		   let key = healthCertificate.vaccinationCertificates.first?.marketingAuthorizationHolder {
			let value = determineValue(key: key, valueSet: valueSet)
			manufacturerCellViewModel = HealthCertificateKeyValueCellViewModel(
				key: AppStrings.HealthCertificate.Details.manufacture,
				value: value
			)
		}

		let issuerCellViewModel = HealthCertificateKeyValueCellViewModel(
			key: AppStrings.HealthCertificate.Details.issuer,
			value: healthCertificate.vaccinationCertificates.first?.certificateIssuer
		)

		var countryCellViewModel: HealthCertificateKeyValueCellViewModel?
		if	let countryCode = healthCertificate.vaccinationCertificates.first?.countryOfVaccination,
			let country = Country(countryCode: countryCode) {
			countryCellViewModel = HealthCertificateKeyValueCellViewModel(
				key: AppStrings.HealthCertificate.Details.country,
				value: country.localizedName
			)
		}

		let certificateNumberCellViewModel = HealthCertificateKeyValueCellViewModel(
			key: AppStrings.HealthCertificate.Details.identifier,
			value: healthCertificate.vaccinationCertificates.first?.uniqueCertificateIdentifier,
			isBottomSeparatorHidden: true
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
		switch type {
		case .vp:
			return valueSets?.hasVp ?? false ? valueSets?.vp : nil
		case .mp:
			return valueSets?.hasMp ?? false ? valueSets?.mp : nil
		case .ma:
			return valueSets?.hasMa ?? false ? valueSets?.ma : nil
		}
	}

	private func determineValue(key: String, valueSet: SAP_Internal_Dgc_ValueSet) -> String {
		for item in valueSet.items where item.key == key {
			return item.displayText
		}
		return key
	}

}
