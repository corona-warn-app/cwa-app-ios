////
// 🦠 Corona-Warn-App
//

import UIKit
import OpenCombine
import HealthCertificateToolkit

// swiftlint:disable:next type_body_length
final class HealthCertificateViewModel {

	// MARK: - Init

	init(
		healthCertifiedPerson: HealthCertifiedPerson?,
		healthCertificate: HealthCertificate,
		vaccinationValueSetsProvider: VaccinationValueSetsProvider
	) {
		self.healthCertificate = healthCertificate
		self.vaccinationValueSetsProvider = vaccinationValueSetsProvider
		self.qrCodeCellViewModel = HealthCertificateQRCodeCellViewModel(
			healthCertificate: healthCertificate,
			accessibilityText: AppStrings.HealthCertificate.Details.QRCodeImageDescription
		)

		if case .test = healthCertificate.type {
			gradientType = .lightBlue(withStars: true)
		} else {
			healthCertifiedPerson?.$vaccinationState
				.sink { [weak self] in
					self?.gradientType = $0.gradientType
				}
				.store(in: &subscriptions)
		}

		updateHealthCertificateKeyValueCellViewModels()

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
					self?.updateHealthCertificateKeyValueCellViewModels()
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
		case additionalInfo

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

	let qrCodeCellViewModel: HealthCertificateQRCodeCellViewModel

	@OpenCombine.Published private(set) var gradientType: GradientView.GradientType = .solidGrey
	@OpenCombine.Published private(set) var healthCertificateKeyValueCellViewModel: [HealthCertificateKeyValueCellViewModel] = []

	var headlineCellViewModel: HealthCertificateSimpleTextCellViewModel {
		let centerParagraphStyle = NSMutableParagraphStyle()
		centerParagraphStyle.alignment = .center
		centerParagraphStyle.lineSpacing = 10.0

		let title: String
		let subtitle: String
		switch healthCertificate.type {
		case .vaccination:
			title = AppStrings.HealthCertificate.Details.vaccinationCertificate
			subtitle = AppStrings.HealthCertificate.Details.euCovidCertificate
		case .test:
			title = AppStrings.HealthCertificate.Details.TestCertificate.title
			subtitle = AppStrings.HealthCertificate.Details.euCovidCertificate
		case .recovery:
			title = AppStrings.HealthCertificate.Details.RecoveryCertificate.title
			subtitle = AppStrings.HealthCertificate.Details.RecoveryCertificate.subtitle
		}

		let attributedTitle = NSAttributedString(
			string: title,
			attributes: [
				.font: UIFont.enaFont(for: .headline),
				.foregroundColor: UIColor.enaColor(for: .textContrast),
				.paragraphStyle: centerParagraphStyle
			]
		)

		let attributedSubtitle = NSAttributedString(
			string: subtitle,
			attributes: [
				.font: UIFont.enaFont(for: .body),
				.foregroundColor: UIColor.enaColor(for: .textContrast),
				.paragraphStyle: centerParagraphStyle
			]
		)

		return HealthCertificateSimpleTextCellViewModel(
			backgroundColor: .clear,
			textAlignment: .center,
			attributedText: [attributedTitle, attributedSubtitle]
				.joined(with: "\n"),
			topSpace: 16.0,
			font: .enaFont(for: .headline),
			accessibilityTraits: .staticText,
			accessibilityIdentifier: AccessibilityIdentifiers.HealthCertificate.Certificate.headline
		)
	}

	/// these strings here are on purpose not localized
	///
	var additionalInfoCellViewModels: [HealthCertificateSimpleTextCellViewModel] {
		return [
			HealthCertificateSimpleTextCellViewModel(
				backgroundColor: .enaColor(for: .cellBackground2),
				textAlignment: .left,
				// swiftlint:disable:next line_length
				text: "Diese Bescheinigung ist kein Reisedokument. Die wissenschaftlichen Erkenntnisse zu COVID-19 in den Bereichen Impfung, Testung und Genesung entwickeln sich fortlaufend weiter, auch im Hinblick auf neue besorgniserregende Virusvarianten. Bitte informieren Sie sich vor Reiseantritt über die am Zielort geltenden Gesundheitsmaßnahmen und entsprechenden Beschränkungen.\nInformationen über die in den jeweiligen EU-Ländern geltenden Einreisebestimmungen finden Sie unter\n https://reopen.europa.eu/de.",
				topSpace: 16.0,
				font: .enaFont(for: .body),
				borderColor: .enaColor(for: .hairline),
				accessibilityTraits: .staticText
			),
			HealthCertificateSimpleTextCellViewModel(
				backgroundColor: .enaColor(for: .cellBackground2),
				textAlignment: .left,
				text: "This certificate is not a travel document. The scientific evidence on COVID-19 vaccination, testing, and recovery continues to evolve, also in view of new variants of concern of the virus. Before traveling, please check the applicable public health measures and related restrictions applied at the point of destination.\nInformation on the current travel restrictions that apply to EU countries is available at\n https://reopen.europa.eu/en.",
				topSpace: 16.0,
				font: .enaFont(for: .body),
				borderColor: .enaColor(for: .hairline),
				accessibilityTraits: .staticText
			)
		]
	}

	func numberOfItems(in section: TableViewSection) -> Int {
		switch section {
		case .headline:
			return 1
		case .qrCode:
			return 1
		case .details:
			return healthCertificateKeyValueCellViewModel.count
		case .topCorner, .bottomCorner:
			return healthCertificateKeyValueCellViewModel.isEmpty ? 0 : 1
		case .additionalInfo:
			return additionalInfoCellViewModels.count
		}
	}

	// MARK: - Private

	private enum ValueSetType: String {
		case vaccineOrProphylaxis
		case vaccineMedicinalProduct
		case marketingAuthorizationHolder
		case diseaseOrAgentTargeted
		case typeOfTest
		case rapidAntigenTestNameAndManufacturer
		case testResult
	}

	private let healthCertificate: HealthCertificate
	private let vaccinationValueSetsProvider: VaccinationValueSetsProvider

	private var valueSets: SAP_Internal_Dgc_ValueSets?
	private var subscriptions = Set<AnyCancellable>()

	private func updateHealthCertificateKeyValueCellViewModels() {
		switch healthCertificate.entry {
		case .vaccination(let vaccinationEntry):
			updateVaccinationCertificateKeyValueCellViewModels(vaccinationEntry: vaccinationEntry)
		case .test(let testEntry):
			updateTestCertificateKeyValueCellViewModels(testEntry: testEntry)
		case .recovery(let recoveryEntry):
			updateRecoveryCertificateKeyValueCellViewModels(recoveryEntry: recoveryEntry)
		}
	}

	/// these strings here are on purpose not localized
	private func updateVaccinationCertificateKeyValueCellViewModels(vaccinationEntry: VaccinationEntry) {
		let nameCellViewModel = HealthCertificateKeyValueCellViewModel(
			key: "Name, Vorname / Name, First Name",
			value: healthCertificate.name.reversedFullName,
			topSpace: 0.0
		)

		let dateOfBirthCellViewModel = HealthCertificateKeyValueCellViewModel(
			key: "Geburtsdatum / Date of Birth (YYYY-MM-DD)",
			value: DCCDateStringFormatter.formatedString(from: healthCertificate.dateOfBirth)
		)

		let diseaseCellViewModel = HealthCertificateKeyValueCellViewModel(
			key: "Zielkrankheit oder -erreger / Disease or Agent Targeted",
			value: determineValue(
				key: vaccinationEntry.vaccineMedicinalProduct,
				valueSet: valueSet(by: .diseaseOrAgentTargeted)
			)
		)
		
		let vaccineCellViewModel = HealthCertificateKeyValueCellViewModel(
			key: "Impfstoff / Vaccine",
			value: determineValue(
				key: vaccinationEntry.vaccineMedicinalProduct,
				valueSet: valueSet(by: .vaccineMedicinalProduct)
			)
		)
		
		let vaccineTypeCellViewModel = HealthCertificateKeyValueCellViewModel(
			key: "Art des Impfstoffs / Vaccine Type",
			value: determineValue(
				key: vaccinationEntry.vaccineOrProphylaxis,
				valueSet: valueSet(by: .vaccineOrProphylaxis)
			)
		)

		let manufacturerCellViewModel = HealthCertificateKeyValueCellViewModel(
			key: "Hersteller / Manufacturer",
			value: determineValue(
				key: vaccinationEntry.marketingAuthorizationHolder,
				valueSet: valueSet(by: .marketingAuthorizationHolder)
			)
		)

		let vaccinationCountCellViewModel = HealthCertificateKeyValueCellViewModel(
			key: "Nummer der Impfung / Number in a series of vaccinations",
			value: String(
				format: AppStrings.HealthCertificate.Details.certificateCount,
			 vaccinationEntry.doseNumber, vaccinationEntry.totalSeriesOfDoses
		 )
		)

		let dateCellViewModel = HealthCertificateKeyValueCellViewModel(
			key: "Datum der Impfung / Date of Vaccination (YYYY-MM-DD)",
			value: DCCDateStringFormatter.formatedString(from: vaccinationEntry.dateOfVaccination)
		)

		let localizedCountryName = Country(countryCode: vaccinationEntry.countryOfVaccination)?.localizedName
		let countryCellViewModel = HealthCertificateKeyValueCellViewModel(
			key: "Land der Impfung / Member State of Vaccination",
			value: localizedCountryName ?? vaccinationEntry.countryOfVaccination
		)
		
		let issuerCellViewModel = HealthCertificateKeyValueCellViewModel(
			key: "Zertifikataussteller / Certificate Issuer ",
			value: vaccinationEntry.certificateIssuer
		)

		let certificateNumberCellViewModel = HealthCertificateKeyValueCellViewModel(
			key: "Zertifikatkennung / Unique Certificate Identifier",
			value: vaccinationEntry.uniqueCertificateIdentifier,
			isBottomSeparatorHidden: true,
			bottomSpace: 2.0
		)

		healthCertificateKeyValueCellViewModel = [
			nameCellViewModel,
			dateOfBirthCellViewModel,
			diseaseCellViewModel,
			vaccineCellViewModel,
			vaccineTypeCellViewModel,
			manufacturerCellViewModel,
			vaccinationCountCellViewModel,
			dateCellViewModel,
			countryCellViewModel,
			issuerCellViewModel,
			certificateNumberCellViewModel
		]
		.compactMap { $0 }
	}

	/// these strings here are on purpose not localized
	private func updateTestCertificateKeyValueCellViewModels(testEntry: TestEntry) {
		let nameCellViewModel = HealthCertificateKeyValueCellViewModel(
			key: "Name, Vorname / Name, First Name",
			value: healthCertificate.name.reversedFullName,
			topSpace: 2.0
		)

		let dateOfBirthCellViewModel = HealthCertificateKeyValueCellViewModel(
			key: "Geburtsdatum / Date of Birth (YYYY-MM-DD)",
			value: DCCDateStringFormatter.formatedString(from: healthCertificate.dateOfBirth)
		)

		let diseaseOrAgentTargetedCellViewModel = HealthCertificateKeyValueCellViewModel(
			key: "Zielkrankheit oder. -erreger / Disease or Agent Targeted",
			value: determineValue(
				key: testEntry.diseaseOrAgentTargeted,
				valueSet: valueSet(by: .diseaseOrAgentTargeted)
			)
		)

		let typeOfTestCellViewModel = HealthCertificateKeyValueCellViewModel(
			key: "Art des Tests / Type of Test",
			value: determineValue(
				key: testEntry.typeOfTest,
				valueSet: valueSet(by: .typeOfTest)
			)
		)

		var naaTestNameCellViewModel: HealthCertificateKeyValueCellViewModel?
		if let naaTestName = testEntry.naaTestName {
			naaTestNameCellViewModel = HealthCertificateKeyValueCellViewModel(
				key: "Produktname / Test Name",
				value: naaTestName
			)
		}

		var ratTestNameCellViewModel: HealthCertificateKeyValueCellViewModel?
		if let ratTestName = testEntry.ratTestName {
			ratTestNameCellViewModel = HealthCertificateKeyValueCellViewModel(
				key: "Testhersteller / Test Manufacturer",
				value: determineValue(
					key: ratTestName,
					valueSet: valueSet(by: .rapidAntigenTestNameAndManufacturer)
				)
			)
		}

		let customDateFormatter = DateFormatter()
		customDateFormatter.dateFormat = "yyyy-MM-dd HH:mm 'UTC' x"
		var dateTimeOfSampleCollectionCellViewModel: HealthCertificateKeyValueCellViewModel?
		if let sampleCollectionDate = testEntry.sampleCollectionDate {
			dateTimeOfSampleCollectionCellViewModel = HealthCertificateKeyValueCellViewModel(
				key: "Datum und Uhrzeit der Probenahme / Date and Time of Sample Collection (YYYY-MM-DD hh:mm Z)",
				value: customDateFormatter.string(from: sampleCollectionDate)
			)
		}

		let testResultCellViewModel = HealthCertificateKeyValueCellViewModel(
			key: "Testergebnis / Test Result",
			value: determineValue(
				key: testEntry.testResult,
				valueSet: valueSet(by: .testResult)
			)
		)

		let testCenterCellViewModel = HealthCertificateKeyValueCellViewModel(
			key: "Testzentrum oder -einrichtung / Testing Center or Facility",
			value: testEntry.testCenter
		)

		let localizedCountryName = Country(countryCode: testEntry.countryOfTest)?.localizedName
		let countryCellViewModel = HealthCertificateKeyValueCellViewModel(
			key: "Land der Testung / Member State of Test",
			value: localizedCountryName ?? testEntry.countryOfTest
		)

		let issuerCellViewModel = HealthCertificateKeyValueCellViewModel(
			key: "Zertifikataussteller / Certificate Issuer",
			value: testEntry.certificateIssuer
		)

		let certificateNumberCellViewModel = HealthCertificateKeyValueCellViewModel(
			key: "Zertifikatkennung / Unique Certificate Identifier",
			value: testEntry.uniqueCertificateIdentifier,
			isBottomSeparatorHidden: true,
			bottomSpace: 2.0
		)

		healthCertificateKeyValueCellViewModel = [
			nameCellViewModel,
			dateOfBirthCellViewModel,
			diseaseOrAgentTargetedCellViewModel,
			typeOfTestCellViewModel,
			naaTestNameCellViewModel,
			ratTestNameCellViewModel,
			dateTimeOfSampleCollectionCellViewModel,
			testResultCellViewModel,
			testCenterCellViewModel,
			countryCellViewModel,
			issuerCellViewModel,
			certificateNumberCellViewModel
		]
		.compactMap { $0 }
	}

	/// these strings here are on purpose not localized
	private func updateRecoveryCertificateKeyValueCellViewModels(recoveryEntry: RecoveryEntry) {
		let nameCellViewModel = HealthCertificateKeyValueCellViewModel(
			key: "Name, Vorname / Name, First Name",
			value: healthCertificate.name.reversedFullName,
			topSpace: 2.0
		)

		let dateOfBirthCellViewModel = HealthCertificateKeyValueCellViewModel(
			key: "Geburtsdatum / Date of Birth (YYYY-MM-DD)",
			value: DCCDateStringFormatter.formatedString(from: healthCertificate.dateOfBirth)
		)

		let diseaseOrAgentTargetedCellViewModel = HealthCertificateKeyValueCellViewModel(
			key: "Genesen von / Recovered from",
			value: determineValue(
				key: recoveryEntry.diseaseOrAgentTargeted,
				valueSet: valueSet(by: .diseaseOrAgentTargeted)
			)
		)

		let dateOfFirstPositiveNAAResultCellViewModel = HealthCertificateKeyValueCellViewModel(
			key: "Datum des ersten positiven Testergebnisses / Date of first positive test result (YYYY-MM-DD)",
			value: DCCDateStringFormatter.formatedString(from: recoveryEntry.dateOfFirstPositiveNAAResult)
		)

		let localizedCountryName = Country(countryCode: recoveryEntry.countryOfTest)?.localizedName
		let countryCellViewModel = HealthCertificateKeyValueCellViewModel(
			key: "Land der Testung / Member State of Test",
			value: localizedCountryName ?? recoveryEntry.countryOfTest
		)

		let issuerCellViewModel = HealthCertificateKeyValueCellViewModel(
			key: "Zertifikataussteller / Certificate Issuer",
			value: recoveryEntry.certificateIssuer
		)

		let certificateValidFromCellViewModel = HealthCertificateKeyValueCellViewModel(
			key: "Zertifikat gültig ab / Certificate valid from (YYYY-MM-DD) ",
			value: recoveryEntry.certificateValidFrom
		)
		
		let certificateValidUntilCellViewModel = HealthCertificateKeyValueCellViewModel(
			key: "Zertifikat gültig bis  / Certificate valid until  (YYYY-MM-DD) ",
			value: recoveryEntry.certificateValidUntil
		)
		
		let certificateNumberCellViewModel = HealthCertificateKeyValueCellViewModel(
			key: "Zertifikatkennung / Unique Certificate Identifier",
			value: recoveryEntry.uniqueCertificateIdentifier,
			isBottomSeparatorHidden: true,
			bottomSpace: 2.0
		)

		healthCertificateKeyValueCellViewModel = [
			nameCellViewModel,
			dateOfBirthCellViewModel,
			diseaseOrAgentTargetedCellViewModel,
			dateOfFirstPositiveNAAResultCellViewModel,
			countryCellViewModel,
			issuerCellViewModel,
			certificateValidFromCellViewModel,
			certificateValidUntilCellViewModel,
			certificateNumberCellViewModel
		]
		.compactMap { $0 }
	}
	
	private func valueSet(by type: ValueSetType) -> SAP_Internal_Dgc_ValueSet? {
		guard let valueSets = valueSets else {
			Log.error("tried to read from unavailable value sets", log: .vaccination)
			return nil
		}
		switch type {
		case .vaccineOrProphylaxis:
			return valueSets.hasVp ? valueSets.vp : nil
		case .vaccineMedicinalProduct:
			return valueSets.hasMp ? valueSets.mp : nil
		case .marketingAuthorizationHolder:
			return valueSets.hasMa ? valueSets.ma : nil
		case .diseaseOrAgentTargeted:
			return valueSets.hasTg ? valueSets.tg : nil
		case .typeOfTest:
			return valueSets.hasTcTt ? valueSets.tcTt : nil
		case .rapidAntigenTestNameAndManufacturer:
			return valueSets.hasTcMa ? valueSets.tcMa : nil
		case .testResult:
			return valueSets.hasTcTr ? valueSets.tcTr : nil
		}
	}

	private func determineValue(key: String, valueSet: SAP_Internal_Dgc_ValueSet?) -> String {
		let displayText = valueSet?.items
			.first { $0.key == key }
			.map { $0.displayText }

		return displayText ?? key
	}

}
