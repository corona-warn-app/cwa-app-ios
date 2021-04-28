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
					title: NSAttributedString(
						string: AppStrings.ExposureSubmission.AntigenTest.Information.legal.title,
						attributes: [NSAttributedString.Key.font: UIFont.enaFont(for: .title2)]
					),
					subheadline1: nil,
					bulletPoints1: [
						bulletPointCellWithRegularText(text: AppStrings.ExposureSubmission.AntigenTest.Information.legal.text01),
						bulletPointCellWithRegularText(text: AppStrings.ExposureSubmission.AntigenTest.Information.legal.text02),
						bulletPointCellWithRegularText(text: AppStrings.ExposureSubmission.AntigenTest.Information.legal.text03),
						bulletPointCellWithRegularText(text: AppStrings.ExposureSubmission.AntigenTest.Information.legal.text04),
						bulletPointCellWithRegularText(text: AppStrings.ExposureSubmission.AntigenTest.Information.legal.text05),
						bulletPointCellWithRegularText(text: AppStrings.ExposureSubmission.AntigenTest.Information.legal.text06),
						bulletPointCellWithRegularText(text: AppStrings.ExposureSubmission.AntigenTest.Information.legal.text07)
					],
					subheadline2: nil,
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

	private func bulletPointCellWithRegularText(text: String) -> NSMutableAttributedString {
		return NSMutableAttributedString(string: "\(text)", attributes: normalTextAttribute)
	}

	private func bulletPointCellWithBoldHeadline(title: String, text: String) -> NSMutableAttributedString {
		let bulletPoint = NSMutableAttributedString(string: "\(title)" + "\n\t", attributes: boldTextAttribute)
		bulletPoint.append(NSAttributedString(string: text, attributes: normalTextAttribute))
		return bulletPoint
	}

	private func bulletPointCellWithBoldText(text: String) -> NSMutableAttributedString {
		return NSMutableAttributedString(string: "\(text)", attributes: boldTextAttribute)
	}

}
