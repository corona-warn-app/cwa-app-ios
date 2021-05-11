////
// 🦠 Corona-Warn-App
//

import UIKit
import Contacts
import OpenCombine

final class HealthCertifiedPersonViewModel {

	// MARK: - Init

	init(
		healthCertificateService: HealthCertificateServiceProviding,
		healthCertifiedPerson: HealthCertifiedPerson,
		vaccinationValueSetsProvider: VaccinationValueSetsProvider,
		dismiss: @escaping () -> Void
	) {
		self.healthCertificateService = healthCertificateService
		self.healthCertifiedPerson = healthCertifiedPerson
		self.vaccinationValueSetsProvider = vaccinationValueSetsProvider

		// setup gradient update
		healthCertifiedPerson.$hasValidProofCertificate
			.sink { [weak self] in
				self?.gradientType = $0 ? .blueOnly : .solidGrey
			}
			.store(in: &subscriptions)

		healthCertifiedPerson.objectDidChange
			.sink { [weak self] healthCertifiedPerson in
				guard !healthCertifiedPerson.healthCertificates.isEmpty else {
					dismiss()
					return
				}

				self?.triggerReload = true
			}
			.store(in: &subscriptions)

		// load certificate value sets
		vaccinationValueSetsProvider.latestVaccinationCertificateValueSets()
			.sink(
				receiveCompletion: { _ in },
				receiveValue: { _ in }
			)
			.store(in: &subscriptions)
	}

	// MARK: - Internal

	enum TableViewSection: Int, CaseIterable {
		case header
		case incompleteVaccination
		case qrCode
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

	let headerCellViewModel: HealthCertificateSimpleTextCellViewModel = {
		HealthCertificateSimpleTextCellViewModel(
			backgroundColor: .clear,
			textColor: .enaColor(for: .textContrast),
			textAlignment: .center,
			text: "Digitaler Impfnachweis",
			topSpace: 42.0,
			font: .enaFont(for: .headline),
			accessibilityTraits: .header
		)
	}()

	let incompleteVaccinationCellViewModel: HealthCertificateSimpleTextCellViewModel = {
		let attributedName = NSAttributedString(
			string: "SARS-CoV-2\nImpfung",
			attributes: [
				.font: UIFont.enaFont(for: .title1),
				.foregroundColor: UIColor.enaColor(for: .textPrimary1)
			]
		)

		let attributedDetails = NSAttributedString(
			string: "Unvollständiger Impfschutz",
			attributes: [
				.font: UIFont.enaFont(for: .body),
				.foregroundColor: UIColor.enaColor(for: .textPrimary1)
			]
		)

		return HealthCertificateSimpleTextCellViewModel(
			backgroundColor: .enaColor(for: .background),
			attributedText: [attributedName, attributedDetails].joined(with: "\n"),
			topSpace: 18.0,
			font: .enaFont(for: .headline),
			boarderColor: .enaColor(for: .hairline),
			accessibilityTraits: .staticText
		)
	}()

	@OpenCombine.Published private(set) var gradientType: GradientView.GradientType = .solidGrey
	@OpenCombine.Published private(set) var triggerReload: Bool = false
	@OpenCombine.Published private(set) var updateError: Error?

	var qrCodeCellViewModel: HealthCertificateQRCodeCellViewModel {
		guard let proofCertificate = healthCertifiedPerson.proofCertificate else {
			fatalError("Cell cannot be shown without a proof certificate")
		}

		return HealthCertificateQRCodeCellViewModel(proofCertificate: proofCertificate)
	}

	var personCellViewModel: HealthCertificateSimpleTextCellViewModel {
		let attributedName = NSAttributedString(
			string: healthCertifiedPerson.fullName ?? "",
			attributes: [
				.font: UIFont.enaFont(for: .headline),
				.foregroundColor: UIColor.enaColor(for: .textPrimary1)
			]
		)

		let attributedDetails = NSAttributedString(
			string: dateOfBirth ?? "",
			attributes: [
				.font: UIFont.enaFont(for: .body),
				.foregroundColor: UIColor.enaColor(for: .textPrimary1)
			]
		)

		return HealthCertificateSimpleTextCellViewModel(
			backgroundColor: .enaColor(for: .background),
			attributedText: [attributedName, attributedDetails].joined(with: "\n"),
			topSpace: 18.0,
			font: .enaFont(for: .headline),
			boarderColor: .enaColor(for: .hairline),
			accessibilityTraits: .staticText
		)
	}

	func numberOfItems(in section: TableViewSection) -> Int {
		switch section {
		case .header:
			return 1
		case .incompleteVaccination:
			return !healthCertifiedPerson.hasValidProofCertificate ? 1 : 0
		case .qrCode:
			return healthCertifiedPerson.hasValidProofCertificate ? 1 : 0
		case .person:
			return 1
		case .certificates:
			return healthCertifiedPerson.healthCertificates.count
		}
	}

	func healthCertificateCellViewModel(row: Int) -> HealthCertificateCellViewModel {
		HealthCertificateCellViewModel(
			healthCertificate: healthCertifiedPerson.healthCertificates[row],
			gradientType: gradientType
		)
	}

	func healthCertificate(for indexPath: IndexPath) -> HealthCertificate? {
		guard TableViewSection.map(indexPath.section) == .certificates,
			  healthCertifiedPerson.healthCertificates.indices.contains(indexPath.row) else {
			return nil
		}
		return healthCertifiedPerson.healthCertificates[indexPath.row]
	}

	func updateProofCertificate(trigger: FetchProofCertificateTrigger) {
		healthCertificateService.updateProofCertificate(
			for: healthCertifiedPerson,
			trigger: trigger,
			completion: { [weak self] result in
				if case .failure(let error) = result {
					self?.updateError = error
				}
			}
		)
	}

	func canEditRow(at indexPath: IndexPath) -> Bool {
		return TableViewSection.map(indexPath.section) == .certificates
	}

	func removeHealthCertificate(at indexPath: IndexPath) {
		guard TableViewSection.map(indexPath.section) == .certificates else {
			return
		}

		healthCertificateService.removeHealthCertificate(healthCertifiedPerson.healthCertificates[indexPath.row])
	}

	// MARK: - Private

	private let healthCertifiedPerson: HealthCertifiedPerson
	private let healthCertificateService: HealthCertificateServiceProviding
	private let vaccinationValueSetsProvider: VaccinationValueSetsProvider
	private var subscriptions = Set<AnyCancellable>()

	private var dateOfBirth: String? {
		guard
			let dateOfBirthString = healthCertifiedPerson.dateOfBirth,
			let dateOfBirthDate = ISO8601DateFormatter.contactDiaryFormatter.date(from: dateOfBirthString)
		else {
			return nil
		}

		return String(
			format: AppStrings.ExposureSubmission.AntigenTest.Profile.dateOfBirthFormatText,
			DateFormatter.localizedString(from: dateOfBirthDate, dateStyle: .medium, timeStyle: .none)
		)
	}

}
