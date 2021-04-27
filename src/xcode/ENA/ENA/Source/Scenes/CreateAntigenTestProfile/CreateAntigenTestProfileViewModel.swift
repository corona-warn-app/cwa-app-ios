////
// 🦠 Corona-Warn-App
//

import UIKit
import OpenCombine

final class CreateAntigenTestProfileViewModel {

	// MARK: - Init
	init(
		store: AntigenTestProfileStoring
	) {
		self.store = store
		self.antigenTestProfile = AntigenTestProfile()

		// this is only for coordinator testing, remove later
		antigenTestProfile.firstName = "Max"
	}

	// MARK: - Overrides

	// MARK: - Protocol <#Name#>

	// MARK: - Public

	// MARK: - Internal
	@OpenCombine.Published var antigenTestProfile: AntigenTestProfile

	let title: String = "Schnelltest-Profil"

	var isSaveButtonEnabled: Bool {
		return
			!(antigenTestProfile.firstName?.isEmpty ?? true) ||
			!(antigenTestProfile.lastName?.isEmpty ?? true) ||
			(antigenTestProfile.dateOfBirth != nil) ||
			!(antigenTestProfile.addressLine?.isEmpty ?? true) ||
			!(antigenTestProfile.zipCode?.isEmpty ?? true) ||
			!(antigenTestProfile.city?.isEmpty ?? true) ||
			!(antigenTestProfile.phoneNumber?.isEmpty ?? true) ||
			!(antigenTestProfile.email?.isEmpty ?? true)
	}
	
	var dynamicTableViewModel: DynamicTableViewModel {
		DynamicTableViewModel([

			// Illustration with information text and bullet icons with text
			.section(
				header:
					.image(
						UIImage(
							imageLiteralResourceName: "Illu_Event_Attendee"
						),
						accessibilityLabel: AppStrings.Checkins.Information.imageDescription,
						accessibilityIdentifier: AccessibilityIdentifiers.Checkin.Information.imageDescription
					),
				cells: [
					.title2(
						text: AppStrings.Checkins.Information.descriptionTitle,
						accessibilityIdentifier: AccessibilityIdentifiers.Checkin.Information.descriptionTitle
					),
					.subheadline(
						text: AppStrings.Checkins.Information.descriptionSubHeadline,
						accessibilityIdentifier: AccessibilityIdentifiers.Checkin.Information.descriptionSubHeadline
					),
					.space(
						height: 15.0,
						color: .enaColor(for: .background)
					),
					.icon(
						UIImage(imageLiteralResourceName: "Icons_CheckInRiskStatus"),
						text: .string(AppStrings.Checkins.Information.itemRiskStatusTitle),
						alignment: .top
					),
					.space(
						height: 15.0,
						color: .enaColor(for: .background)
					),
					.icon(
						UIImage(imageLiteralResourceName: "Icons_Diary_Deleted_Automatically"),
						text: .string(AppStrings.Checkins.Information.itemTimeTitle),
						alignment: .top
					)
				]
			)
			/*,
			// Legal text
			.section(cells: [
				.legalExtended(
					title: NSAttributedString(string: AppStrings.Checkins.Information.legalHeadline01),
					subheadline1: NSAttributedString(string: AppStrings.Checkins.Information.legalSubHeadline01),
					bulletPoints1: [],
					subheadline2: NSAttributedString(string: AppStrings.Checkins.Information.legalSubHeadline02),
					accessibilityIdentifier: AccessibilityIdentifiers.Checkin.Information.acknowledgementTitle,
					configure: { _, cell, _ in
						cell.backgroundColor = .enaColor(for: .background)
					}
				)
			]),
			// Disclaimer cell
			.section(
				separators: .all,
				cells: [
					.body(
						text: AppStrings.Checkins.Information.dataPrivacyTitle,
						style: DynamicCell.TextCellStyle.label,
						accessibilityIdentifier: AccessibilityIdentifiers.Checkin.Information.dataPrivacyTitle,
						accessibilityTraits: UIAccessibilityTraits.link,
						action: .execute { _, _ in },
						configure: { _, cell, _ in
							cell.accessoryType = .disclosureIndicator
							cell.selectionStyle = .default
						})
				]
			)*/
		])
	}

	func save() {
		store.antigenTestProfile = antigenTestProfile
	}

	// MARK: - Private

	private let store: AntigenTestProfileStoring

}
