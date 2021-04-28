////
// 🦠 Corona-Warn-App
//

import UIKit

struct AntigenTestProfileInformationViewModel {

	// MARK: - Init

	init(
		store: AntigenTestProfileStoring
	) {
		self.store = store
	}

	// MARK: - Overrides

	// MARK: - Protocol <#Name#>

	// MARK: - Public

	// MARK: - Internal

	let title: String = AppStrings.ExposureSubmission.AntigenTest.Information.title

	func markScreenSeen() {
		#if DEBUG
		#else
		store.antigenTestProfileInfoScreenShown = true
		#endif
	}

	var dynamicTableViewModel: DynamicTableViewModel {
		DynamicTableViewModel([

			// Illustration with information text and bullet icons with text
			.section(
				header:
					.image(
						UIImage(
							imageLiteralResourceName: "Illu_Antigentest_Profil"
						),
						accessibilityLabel: AppStrings.ExposureSubmission.AntigenTest.Information.imageDescription,
						accessibilityIdentifier: AccessibilityIdentifiers.ExposureSubmission.AntigetTest.Information.imageDescription,
						height: 144.0
					),
				cells: [
					.title2(
						text: AppStrings.ExposureSubmission.AntigenTest.Information.descriptionTitle,
						accessibilityIdentifier: AccessibilityIdentifiers.ExposureSubmission.AntigetTest.Information.descriptionTitle
					),
					.subheadline(
						text: AppStrings.ExposureSubmission.AntigenTest.Information.descriptionSubHeadline,
						accessibilityIdentifier: AccessibilityIdentifiers.ExposureSubmission.AntigetTest.Information.descriptionSubHeadline
					),
					.space(
						height: 15.0,
						color: .enaColor(for: .background)
					)
				]
			),
			// Legal text
			.section(cells: [
				.legalExtended(
					title: NSAttributedString(string: AppStrings.Checkins.Information.legalHeadline01),
					subheadline1: NSAttributedString(string: AppStrings.Checkins.Information.legalSubHeadline01),
					bulletPoints1: [
						bulletPointCellWithBoldHeadline(title: AppStrings.Checkins.Information.legalText01bold, text: AppStrings.Checkins.Information.legalText01normal),
						bulletPointCellWithBoldText(text: AppStrings.Checkins.Information.legalText02),
						bulletPointCellWithBoldText(text: AppStrings.Checkins.Information.legalText03)
						],
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
						action: .execute { _, _ in
//							presentDisclaimer()
						},
						configure: { _, cell, _ in
							cell.accessoryType = .disclosureIndicator
							cell.selectionStyle = .default
						})
				]
			)
		])
	}


	// MARK: - Private

	private let store: AntigenTestProfileStoring

	private let boldTextAttribute: [NSAttributedString.Key: Any] = [
		NSAttributedString.Key.font: UIFont.enaFont(for: .body, weight: .bold)
	]
	private let normalTextAttribute: [NSAttributedString.Key: Any] = [
		NSAttributedString.Key.font: UIFont.enaFont(for: .body)
	]

	private func bulletPointCellWithBoldHeadline(title: String, text: String) -> NSMutableAttributedString {
		let bulletPoint = NSMutableAttributedString(string: "\(title)" + "\n\t", attributes: boldTextAttribute)
		bulletPoint.append(NSAttributedString(string: text, attributes: normalTextAttribute))
		return bulletPoint
	}

	private func bulletPointCellWithBoldText(text: String) -> NSMutableAttributedString {
		return NSMutableAttributedString(string: "\(text)", attributes: boldTextAttribute)
	}

}
