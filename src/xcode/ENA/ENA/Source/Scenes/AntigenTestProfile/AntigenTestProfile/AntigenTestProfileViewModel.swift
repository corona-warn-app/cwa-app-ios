////
// 🦠 Corona-Warn-App
//

import Foundation
import UIKit
import Contacts

struct AntigenTestProfileViewModel {

	// MARK: - Init
	
	init(
		store: AntigenTestProfileStoring
	) {
		guard let antigenTestProfile = store.antigenTestProfile else {
			fatalError("We can't init without a valid antigenTestProfile stored")
		}
		self.store = store
		self.antigenTestProfile = antigenTestProfile
	}

	// MARK: - Internal

	let headerCellViewModel: SimpleTextCellViewModel = {
		SimpleTextCellViewModel(
			backgroundColor: .clear,
			textColor: .enaColor(for: .textContrast),
			textAlignment: .center,
			text: AppStrings.ExposureSubmission.AntigenTest.Profile.headerText,
			topSpace: 42.0,
			font: .enaFont(for: .headline),
			accessibilityTraits: .header
		)
	}()

	let noticeCellViewModel: SimpleTextCellViewModel = {
		SimpleTextCellViewModel(
			backgroundColor: .enaColor(for: .background),
			textColor: .enaColor(for: .textPrimary1 ),
			textAlignment: .left,
			text: AppStrings.ExposureSubmission.AntigenTest.Profile.noticeText,
			topSpace: 18.0,
			font: .enaFont(for: .subheadline),
			borderColor: .enaColor(for: .hairline),
			accessibilityTraits: .staticText
		)
	}()

	var qrCodeCellViewModel: QRCodeCellViewModel {
		QRCodeCellViewModel(
			antigenTestProfile: antigenTestProfile,
			backgroundColor: .enaColor(for: .background),
			borderColor: .enaColor(for: .hairline)
		)
	}

	var numberOfSections: Int {
		TableViewSection.allCases.count
	}

	var profileCellViewModel: SimpleTextCellViewModel {
		let paragraphStyle = NSMutableParagraphStyle()
		paragraphStyle.alignment = .left

		let attributedName = NSAttributedString(
			string: friendlyName,
			attributes: [
				.font: UIFont.enaFont(for: .headline),
				.foregroundColor: UIColor.enaColor(for: .textPrimary1),
				.paragraphStyle: paragraphStyle
			]
		)

		let attributedDetails = NSAttributedString(
			string: [
				dateOfBirth,
				formattedAddress,
				antigenTestProfile.phoneNumber,
				antigenTestProfile.email
			]
				.compactMap({ $0 }).joined(separator: "\n"),
			attributes: [
				.font: UIFont.enaFont(for: .body),
				.foregroundColor: UIColor.enaColor(for: .textPrimary1),
				.paragraphStyle: paragraphStyle
			]
		)

		return SimpleTextCellViewModel(
			backgroundColor: .enaColor(for: .background),
			attributedText: [attributedName, attributedDetails].joined(with: "\n"),
			topSpace: 18.0,
			font: .enaFont(for: .headline),
			borderColor: .enaColor(for: .hairline),
			accessibilityTraits: .staticText
		)
	}

	func deleteProfile() {
		store.antigenTestProfile = nil
	}

	mutating func refreshProfile() {
		guard let antigenTestProfile = store.antigenTestProfile else {
			fatalError("We can't refresh without a valid antigenTestProfile stored")
		}
		self.antigenTestProfile = antigenTestProfile
	}

	func numberOfItems(in section: TableViewSection) -> Int {
		switch section {
		default:
			return 1
		}
	}

	enum TableViewSection: Int, CaseIterable {
		case header
		case qrCode
		case notice
		case profile

		static func map(_ section: Int) -> TableViewSection {
			guard let section = TableViewSection(rawValue: section) else {
				fatalError("unsupported tableView section")
			}
			return section
		}
	}
	
	static func dateOfBirthFormatter() -> DateFormatter {
		let dateFormatter = DateFormatter()
		dateFormatter.timeZone = .utcTimeZone
		dateFormatter.dateStyle = .medium
		dateFormatter.timeStyle = .none
		return dateFormatter
	}

	// MARK: - Private

	private let store: AntigenTestProfileStoring
	private var antigenTestProfile: AntigenTestProfile
	private let dateOfBirthFormatter = AntigenTestProfileViewModel.dateOfBirthFormatter()
	
	private var friendlyName: String {
		var components = PersonNameComponents()
		components.givenName = antigenTestProfile.firstName
		components.familyName = antigenTestProfile.lastName

		let formatter = PersonNameComponentsFormatter()
		formatter.style = .medium
		return formatter.string(from: components).trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
	}

	private var dateOfBirth: String? {
		guard let dateOfBirth = antigenTestProfile.dateOfBirth else {
			return nil
		}
		
		return String(
			format: AppStrings.ExposureSubmission.AntigenTest.Profile.dateOfBirthFormatText,
			dateOfBirthFormatter.string(from: dateOfBirth)
		)
	}

	private var formattedAddress: String {
		let address = CNMutablePostalAddress()
		address.street = antigenTestProfile.addressLine ?? ""
		address.city = antigenTestProfile.city ?? ""
		address.postalCode = antigenTestProfile.zipCode ?? ""
		return CNPostalAddressFormatter().string(from: address)
	}

}
