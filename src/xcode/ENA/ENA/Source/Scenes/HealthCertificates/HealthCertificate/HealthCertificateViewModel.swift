//
// 🦠 Corona-Warn-App
//

import UIKit
import OpenCombine
import HealthCertificateToolkit

final class HealthCertificateViewModel {

	// MARK: - Init

	init(
		healthCertifiedPerson: HealthCertifiedPerson,
		healthCertificate: HealthCertificate,
		vaccinationValueSetsProvider: VaccinationValueSetsProviding,
		markAsSeenOnDisappearance: Bool,
		showInfoHit: @escaping () -> Void
	) {
		self.healthCertifiedPerson = healthCertifiedPerson
		self.healthCertificate = healthCertificate
		self.vaccinationValueSetsProvider = vaccinationValueSetsProvider
		self.markAsSeenOnDisappearance = markAsSeenOnDisappearance
		self.showInfo = showInfoHit

		updateHealthCertificateKeyValueCellViewModels()
		updateGradient()
		updateFooterView()

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

		healthCertifiedPerson.$gradientType
			.dropFirst()
			.sink { [weak self] _ in
				self?.updateGradient()
			}
			.store(in: &subscriptions)

		healthCertifiedPerson.$dccWalletInfo
			.dropFirst()
			.sink { [weak self] _ in
				self?.updateGradient()
			}
			.store(in: &subscriptions)

		healthCertificate.$validityState
			.dropFirst()
			.sink { [weak self] _ in
				self?.updateGradient()
				self?.updateFooterView()
			}
			.store(in: &subscriptions)

		healthCertificate.objectDidChange
			.sink { [weak self] _ in
				self?.triggerReload = true
			}
			.store(in: &subscriptions)
	}

	// MARK: - Internal

	enum TableViewSection: Int, CaseIterable {
		case headline
		case qrCode
		case topCorner
		case details
		case bottomCorner
		case expirationDate
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

	var qrCodeCellViewModel: HealthCertificateQRCodeCellViewModel {
		HealthCertificateQRCodeCellViewModel(
			mode: .details,
			healthCertificate: healthCertificate,
			accessibilityText: AppStrings.HealthCertificate.Details.QRCodeImageDescription,
			onCovPassCheckInfoButtonTap: { [weak self] in
				self?.showInfo()
			}
		)
	}

	var expirationDateCellViewModel: HealthCertificateExpirationDateCellViewModel {
		let formattedDate = DateFormatter.localizedString(from: healthCertificate.expirationDate, dateStyle: .medium, timeStyle: .short)
		return HealthCertificateExpirationDateCellViewModel(
			headline: AppStrings.HealthCertificate.Details.expirationDateTitle,
			expirationDate: String(format: AppStrings.HealthCertificate.Details.expirationDatePlaceholder, formattedDate) ,
			content: AppStrings.HealthCertificate.Details.expirationDateDetails
		)
	}

	@DidSetPublished private(set) var gradientType: GradientView.GradientType = .lightBlue
	@DidSetPublished private(set) var isPrimaryFooterButtonEnabled: Bool = true
	@DidSetPublished private(set) var triggerReload: Bool = false
	@DidSetPublished private(set) var healthCertificateKeyValueCellViewModel: [HealthCertificateKeyValueCellViewModel] = []

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
		case .expirationDate:
			return 1
		case .additionalInfo:
			return additionalInfoCellViewModels.count
		}
	}

	func markAsSeen() {
		if markAsSeenOnDisappearance {
			healthCertificate.isNew = false
			healthCertificate.isValidityStateNew = false
		}
	}

	// MARK: - Private

	private let healthCertifiedPerson: HealthCertifiedPerson
	private let healthCertificate: HealthCertificate
	private let vaccinationValueSetsProvider: VaccinationValueSetsProviding
	private let showInfo: () -> Void

	private let markAsSeenOnDisappearance: Bool

	private var valueSets: SAP_Internal_Dgc_ValueSets?
	private var subscriptions = Set<AnyCancellable>()

	private var nameAndDateOfBirthCellViewModel: [HealthCertificateKeyValueCellViewModel] {
		return [
			HealthCertificateKeyValueCellViewModel(
				key: "Name, Vorname / Name, First Name",
				value: healthCertificate.name.reversedFullName,
				topSpace: 0.0
			),
			HealthCertificateKeyValueCellViewModel(
				key: "Standardisierter Name, Vorname / Standardized Name, First Name",
				value: healthCertificate.name.reversedStandardizedName
			),
			HealthCertificateKeyValueCellViewModel(
				key: "Geburtsdatum / Date of Birth (YYYY-MM-DD)",
				value: DCCDateStringFormatter.formattedString(from: healthCertificate.dateOfBirth)
			)
		].compactMap { $0 }
	}

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

	private func updateVaccinationCertificateKeyValueCellViewModels(vaccinationEntry: VaccinationEntry) {
		let keyPaths: [PartialKeyPath<VaccinationEntry>] = [
			\VaccinationEntry.diseaseOrAgentTargeted,
			\VaccinationEntry.vaccineMedicinalProduct,
			\VaccinationEntry.vaccineOrProphylaxis,
			\VaccinationEntry.marketingAuthorizationHolder,
			\VaccinationEntry.doseNumberAndTotalSeriesOfDoses,
			\VaccinationEntry.dateOfVaccination,
			\VaccinationEntry.countryOfVaccination,
			\VaccinationEntry.certificateIssuer,
			\VaccinationEntry.uniqueCertificateIdentifier
		]

		let cellViewModels = keyPaths.dropLast().map {
			HealthCertificateKeyValueCellViewModel(
				key: vaccinationEntry.title(for: $0),
				value: vaccinationEntry.formattedValue(
					for: $0,
					valueSets: valueSets
				)
			)
		}

		let lastCellViewModel = keyPaths.last.flatMap {
			HealthCertificateKeyValueCellViewModel(
				key: vaccinationEntry.title(for: $0),
				value: vaccinationEntry.formattedValue(
					for: $0,
					valueSets: valueSets
				),
				isBottomSeparatorHidden: true,
				bottomSpace: 2.0
			)
		}

		healthCertificateKeyValueCellViewModel = (nameAndDateOfBirthCellViewModel + cellViewModels + [lastCellViewModel]).compactMap { $0 }
	}

	private func updateTestCertificateKeyValueCellViewModels(testEntry: TestEntry) {
		let keyPaths: [PartialKeyPath<TestEntry>] = [
			\TestEntry.diseaseOrAgentTargeted,
			\TestEntry.typeOfTest,
			\TestEntry.naaTestName,
			\TestEntry.ratTestName,
			\TestEntry.sampleCollectionDate,
			\TestEntry.testResult,
			\TestEntry.testCenter,
			\TestEntry.countryOfTest,
			\TestEntry.certificateIssuer,
			\TestEntry.uniqueCertificateIdentifier
		]

		let cellViewModels = keyPaths.dropLast().map {
			HealthCertificateKeyValueCellViewModel(
				key: testEntry.title(for: $0),
				value: testEntry.formattedValue(
					for: $0,
					valueSets: valueSets
				)
			)
		}

		let lastCellViewModel = keyPaths.last.flatMap {
			HealthCertificateKeyValueCellViewModel(
				key: testEntry.title(for: $0),
				value: testEntry.formattedValue(
					for: $0,
					valueSets: valueSets
				),
				isBottomSeparatorHidden: true,
				bottomSpace: 2.0
			)
		}

		healthCertificateKeyValueCellViewModel = (nameAndDateOfBirthCellViewModel + cellViewModels + [lastCellViewModel]).compactMap { $0 }
	}

	private func updateRecoveryCertificateKeyValueCellViewModels(recoveryEntry: RecoveryEntry) {
		let keyPaths: [PartialKeyPath<RecoveryEntry>] = [
			\RecoveryEntry.diseaseOrAgentTargeted,
			\RecoveryEntry.dateOfFirstPositiveNAAResult,
			\RecoveryEntry.countryOfTest,
			\RecoveryEntry.certificateIssuer,
			\RecoveryEntry.certificateValidFrom,
			\RecoveryEntry.certificateValidUntil,
			\RecoveryEntry.uniqueCertificateIdentifier
		]

		let cellViewModels = keyPaths.dropLast().map {
			HealthCertificateKeyValueCellViewModel(
				key: recoveryEntry.title(for: $0),
				value: recoveryEntry.formattedValue(
					for: $0,
					valueSets: valueSets
				)
			)
		}

		let lastCellViewModel = keyPaths.last.flatMap {
			HealthCertificateKeyValueCellViewModel(
				key: recoveryEntry.title(for: $0),
				value: recoveryEntry.formattedValue(
					for: $0,
					valueSets: valueSets
				),
				isBottomSeparatorHidden: true,
				bottomSpace: 2.0
			)
		}

		healthCertificateKeyValueCellViewModel = (nameAndDateOfBirthCellViewModel + cellViewModels + [lastCellViewModel]).compactMap { $0 }
	}

	private func updateGradient() {
		if healthCertificate == healthCertifiedPerson.mostRelevantHealthCertificate &&
			(healthCertificate.validityState == .valid || healthCertificate.validityState == .expiringSoon ||
				(healthCertificate.validityState == .expired && healthCertificate.type == .test)) {
			gradientType = healthCertifiedPerson.gradientType
		} else {
			gradientType = .solidGrey
		}
	}

	private func updateFooterView() {
		isPrimaryFooterButtonEnabled = healthCertificate.validityState != .blocked
	}

}
