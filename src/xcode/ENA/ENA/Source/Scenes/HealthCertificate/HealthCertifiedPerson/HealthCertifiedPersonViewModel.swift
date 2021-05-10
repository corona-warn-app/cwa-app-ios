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
		vaccinationValueSetsProvider: VaccinationValueSetsProvider
	) {
		self.healthCertificateService = healthCertificateService
		self.healthCertifiedPerson = healthCertifiedPerson
		self.vaccinationValueSetsProvider = vaccinationValueSetsProvider

		// setup gradient update
		healthCertifiedPerson.$proofCertificate
			.sink { [weak self] proofCertificate in
				self?.gradientType = proofCertificate != nil ? .blueOnly : .solidGrey
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

	let qrCodeCellViewModel: HealthCertificateQRCodeCellViewModel = {
		HealthCertificateQRCodeCellViewModel(
			backgroundColor: .enaColor(for: .background),
			borderColor: .enaColor(for: .hairline)
		)
	}()

	@OpenCombine.Published private(set) var gradientType: GradientView.GradientType = .solidGrey

	var healthCertificateCellViewModel: HealthCertificateCellViewModel {
		HealthCertificateCellViewModel(healthCertificate: "Dummy", type: gradientType)
	}

	var personCellViewModel: HealthCertificateSimpleTextCellViewModel {
		let attributedName = NSAttributedString(
			string: friendlyName,
			attributes: [
				.font: UIFont.enaFont(for: .headline),
				.foregroundColor: UIColor.enaColor(for: .textPrimary1)
			]
		)

		let attributedDetails = NSAttributedString(
			string: dateOfBirth,
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
		default:
			return 1
		}
	}

	func healthCertificate(for indexPath: IndexPath) -> HealthCertificate? {
		guard TableViewSection.map(indexPath.section) == .certificates,
			  healthCertifiedPerson.healthCertificates.indices.contains(indexPath.row) else {
			return nil
		}
		return healthCertifiedPerson.healthCertificates[indexPath.row]
	}

	// MARK: - Private

	private let healthCertifiedPerson: HealthCertifiedPerson
	private let healthCertificateService: HealthCertificateServiceProviding
	private let vaccinationValueSetsProvider: VaccinationValueSetsProvider
	private var subscriptions = Set<AnyCancellable>()

	private var friendlyName: String {
		var components = PersonNameComponents()
		components.givenName = "Max"
		components.familyName = "Mustermann"

		let formatter = PersonNameComponentsFormatter()
		formatter.style = .medium
		return formatter.string(from: components).trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
	}

	private var dateOfBirth: String {
		let dateOfBirth = Date(timeIntervalSince1970: 1457896523)
		return String(
			format: AppStrings.ExposureSubmission.AntigenTest.Profile.dateOfBirthFormatText,
			DateFormatter.localizedString(from: dateOfBirth, dateStyle: .medium, timeStyle: .none)
		)
	}


}
