////
// 🦠 Corona-Warn-App
//

import UIKit
import Contacts
import OpenCombine

final class HealthCertifiedPersonViewModel {

	// MARK: - Init

	init(
		cclService: CCLServable,
		healthCertificateService: HealthCertificateService,
		healthCertifiedPerson: HealthCertifiedPerson,
		healthCertificateValueSetsProvider: VaccinationValueSetsProviding,
		dismiss: @escaping () -> Void,
		didTapBoosterNotification: @escaping (HealthCertifiedPerson) -> Void,
		didTapValidationButton: @escaping (HealthCertificate, @escaping (Bool) -> Void) -> Void,
		showInfoHit: @escaping () -> Void,
		didTapUpdateNotification: @escaping () -> Void
	) {
		self.cclService = cclService
		self.healthCertificateService = healthCertificateService
		self.healthCertifiedPerson = healthCertifiedPerson
		self.healthCertificateValueSetsProvider = healthCertificateValueSetsProvider

		self.didTapBoosterNotification = didTapBoosterNotification
		self.didTapValidationButton = didTapValidationButton
		self.showInfo = showInfoHit
		self.didTapUpdateNotification = didTapUpdateNotification

		self.boosterNotificationCellModel = BoosterNotificationCellModel(healthCertifiedPerson: healthCertifiedPerson, cclService: cclService)
		self.admissionStateCellModel = AdmissionStateCellModel(healthCertifiedPerson: healthCertifiedPerson, cclService: cclService)
		self.vaccinationStateCellModel = VaccinationStateCellModel(healthCertifiedPerson: healthCertifiedPerson, cclService: cclService)
		
		constructHealthCertificateCellViewModels(for: healthCertifiedPerson)

		healthCertifiedPerson.objectDidChange
			.receive(on: DispatchQueue.main.ocombine)
			.sink { [weak self] person in
				self?.constructHealthCertificateCellViewModels(for: person)
				
				guard !person.healthCertificates.isEmpty else {
					// Prevent trigger reload if we the person was removed before because we removed their last certificate.
					self?.triggerReload = false
					dismiss()
					return
				}

				self?.triggerReload = true
			}
			.store(in: &subscriptions)

		healthCertifiedPerson.$gradientType
			.sink { [weak self] in
				self?.gradientType = $0
			}
			.store(in: &subscriptions)

		// load certificate value sets
		healthCertificateValueSetsProvider.latestVaccinationCertificateValueSets()
			.sink(
				receiveCompletion: { _ in },
				receiveValue: { _ in }
			)
			.store(in: &subscriptions)
	}

	// MARK: - Internal

	enum TableViewSection: Int, CaseIterable {
		case header
		case qrCode
		case boosterNotification
		case admissionState
		case vaccinationState
		case person
		case certificates

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

	var headerCellViewModel: HealthCertificateSimpleTextCellViewModel {
		let centerParagraphStyle = NSMutableParagraphStyle()
		centerParagraphStyle.alignment = .center
		centerParagraphStyle.lineSpacing = 4.0

		let attributedTitle = NSAttributedString(
			string: AppStrings.HealthCertificate.Person.title,
			attributes: [
				.font: UIFont.enaFont(for: .body),
				.foregroundColor: UIColor.enaColor(for: .textContrast),
				.paragraphStyle: centerParagraphStyle
			]
		)

		let attributedSubtitle = NSAttributedString(
			string: healthCertifiedPerson.name?.fullName ?? "",
			attributes: [
				.font: UIFont.enaFont(for: .headline),
				.foregroundColor: UIColor.enaColor(for: .textContrast),
				.paragraphStyle: centerParagraphStyle
			]
		)

		return HealthCertificateSimpleTextCellViewModel(
			backgroundColor: .clear,
			textAlignment: .center,
			attributedText: [attributedTitle, attributedSubtitle]
				.joined(with: "\n"),
			topSpace: 14.0,
			font: .enaFont(for: .headline),
			accessibilityTraits: .staticText
		)
	}

	let healthCertifiedPerson: HealthCertifiedPerson

	let boosterNotificationCellModel: BoosterNotificationCellModel
	let admissionStateCellModel: AdmissionStateCellModel
	let vaccinationStateCellModel: VaccinationStateCellModel

	@OpenCombine.Published private(set) var gradientType: GradientView.GradientType = .lightBlue
	@OpenCombine.Published private(set) var triggerReload: Bool = false
	@OpenCombine.Published private(set) var updateError: Error?

	var qrCodeCellViewModel: HealthCertificateQRCodeCellViewModel {
		guard let mostRelevantHealthCertificate = healthCertifiedPerson.mostRelevantHealthCertificate
			else {
			fatalError("Cell cannot be shown without a health certificate")
		}

		return HealthCertificateQRCodeCellViewModel(
			mode: .overview,
			healthCertificate: mostRelevantHealthCertificate,
			accessibilityText: AppStrings.HealthCertificate.Person.QRCodeImageDescription,
			onValidationButtonTap: { [weak self] healthCertificate, loadingStateHandler in
				self?.didTapValidationButton(healthCertificate, loadingStateHandler)
			},
			onCovPassCheckInfoButtonTap: { [ weak self] in
				self?.showInfo()
			}
		)
	}

	var boosterNotificationIsVisible: Bool {
		healthCertifiedPerson.dccWalletInfo?.boosterNotification.visible ?? false
	}

	var vaccinationStateIsVisible: Bool {
		healthCertifiedPerson.dccWalletInfo?.vaccinationState.visible ?? false
	}
	
	var admissionStateIsVisible: Bool {
		healthCertifiedPerson.dccWalletInfo?.admissionState.visible ?? false
	}

	var preferredPersonCellModel: PreferredPersonCellModel {
		PreferredPersonCellModel(
			healthCertifiedPerson: healthCertifiedPerson
		)
	}

	func numberOfItems(in section: TableViewSection) -> Int {
		switch section {
		case .header:
			return 1
		case .qrCode:
			return 1
		case .boosterNotification:
			return boosterNotificationIsVisible ? 1 : 0
		case .admissionState:
			return admissionStateIsVisible ? 1 : 0
		case .vaccinationState:
			return vaccinationStateIsVisible ? 1 : 0
		case .person:
			return 1
		case .certificates:
			return healthCertifiedPerson.healthCertificates.count
		}
	}

	func heightForFooter(in section: TableViewSection) -> CGFloat {
		switch section {
		case .certificates:
			return 12
		default:
			return 0
		}
	}

	func healthCertificateCellViewModel(row: Int) -> HealthCertificateCellViewModel {
		return healthCertificateCellViewModels[row]
	}

	func healthCertificate(for indexPath: IndexPath) -> HealthCertificate? {
		guard TableViewSection.map(indexPath.section) == .certificates else {
			return nil
		}

		return healthCertificateCellViewModels[safe: indexPath.row]?.healthCertificate
	}

	func canEditRow(at indexPath: IndexPath) -> Bool {
		return TableViewSection.map(indexPath.section) == .certificates
	}

	func didTapBoosterNotificationCell() {
		didTapBoosterNotification(healthCertifiedPerson)
	}

	func attemptToRestoreDecodingFailedHealthCertificates() {
		healthCertifiedPerson.attemptToRestoreDecodingFailedHealthCertificates()
	}

	// MARK: - Private

	private let cclService: CCLServable
	private let healthCertificateService: HealthCertificateService
	private let healthCertificateValueSetsProvider: VaccinationValueSetsProviding

	private let didTapBoosterNotification: (HealthCertifiedPerson) -> Void
	private let didTapValidationButton: (HealthCertificate, @escaping (Bool) -> Void) -> Void
	private let showInfo: () -> Void
	private let didTapUpdateNotification: () -> Void
	private var subscriptions = Set<AnyCancellable>()

	private var healthCertificateCellViewModels = [HealthCertificateCellViewModel]()
	
	private func constructHealthCertificateCellViewModels(for person: HealthCertifiedPerson) {
		let sortedHealthCertificates = person.healthCertificates.sorted(by: >)
		healthCertificateCellViewModels = sortedHealthCertificates.map {
			HealthCertificateCellViewModel(
				healthCertificate: $0,
				healthCertifiedPerson: person
			)
		}
	}
}
