////
// 🦠 Corona-Warn-App
//

import UIKit

struct HealthCertificateConsentViewModel {

	// MARK: - Init

	init(
		didTapDataPrivacy: @escaping () -> Void
	) {
		self.didTapDataPrivacy = didTapDataPrivacy
	}

	// MARK: - Internal

	let title: String = AppStrings.HealthCertificate.Info.title

	var dynamicTableViewModel: DynamicTableViewModel {
		DynamicTableViewModel([

			// Illustration with information text and bullet icons with text
			.section(
				header:
					.image(
						UIImage(
							imageLiteralResourceName: "Illu_Vaccination"
						),
						accessibilityLabel: AppStrings.HealthCertificate.Info.imageDescription,
						accessibilityIdentifier: AccessibilityIdentifiers.HealthCertificate.Info.imageDescription,
						height: 184.0
					),
				cells: [
					.title2(
						text: AppStrings.HealthCertificate.Info.Register.headline,
						accessibilityIdentifier: AccessibilityIdentifiers.HealthCertificate.Info.Register.headline
					),
					.attributedText(
						text: faqLinkText(),
						link: URL(string: AppStrings.Links.healthCertificateFAQ),
						accessibilityIdentifier: AccessibilityIdentifiers.ExposureDetection.guideFAQ
					),
					.space(
						height: 15.0,
						color: .enaColor(for: .background)
					),
					.icon(
						UIImage(imageLiteralResourceName: "Icons - FaceID"),
						text: .string(AppStrings.HealthCertificate.Info.Register.section01),
						alignment: .top
					),
					.space(
						height: 15.0,
						color: .enaColor(for: .background)
					),
					.icon(
						UIImage(imageLiteralResourceName: "Icons_QR5"),
						text: .string(AppStrings.HealthCertificate.Info.Register.section02),
						alignment: .top
					),
					.space(
						height: 15.0,
						color: .enaColor(for: .background)
					),
					.icon(
						UIImage(imageLiteralResourceName: "Icons_Shield"),
						text: .string(AppStrings.HealthCertificate.Info.Register.section03),
						alignment: .top
					)
				]
			),
			// Legal text
			.section(cells: [
				.legalExtended(
					title: NSAttributedString(string: AppStrings.HealthCertificate.Info.Legal.headline),
					subheadline1: NSAttributedString(
						string: AppStrings.HealthCertificate.Info.Legal.subHeadline,
						attributes: [
							.font: UIFont.preferredFont(forTextStyle: .body)
						]
					),
					bulletPoints1: [
						bulletPointCellWithBoldHeadline(
							title: AppStrings.HealthCertificate.Info.Legal.section01,
							text: AppStrings.HealthCertificate.Info.Legal.section02
						),
						bulletPointCellWithBoldText(
							text: AppStrings.HealthCertificate.Info.Legal.section03
						),
						bulletPointCellWithBoldText(
							text: AppStrings.HealthCertificate.Info.Legal.section04
						)
						],
					subheadline2: NSAttributedString(
						string: AppStrings.HealthCertificate.Info.Legal.subHeadline2,
						attributes: [
							.font: UIFont.preferredFont(forTextStyle: .body)
						]
					),
					accessibilityIdentifier: AccessibilityIdentifiers.HealthCertificate.Info.acknowledgementTitle,
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
						text: AppStrings.HealthCertificate.Info.disclaimer,
						style: DynamicCell.TextCellStyle.label,
						accessibilityIdentifier: AccessibilityIdentifiers.HealthCertificate.Info.disclaimer,
						accessibilityTraits: UIAccessibilityTraits.link,
						action: .execute { _, _ in
							didTapDataPrivacy()
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

	private let didTapDataPrivacy: () -> Void

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

	private func faqLinkText(tintColor: UIColor = .enaColor(for: .textTint)) -> NSAttributedString {
		let rawString = String(format: AppStrings.HealthCertificate.Info.Register.text, AppStrings.HealthCertificate.Info.Register.FAQLinkText)
		let string = NSMutableAttributedString(string: rawString)
		let range = string.mutableString.range(of: AppStrings.HealthCertificate.Info.Register.FAQLinkText)
		if range.location != NSNotFound {
			// Links don't work in UILabels so we fake it here. Link handling in done in view controller on cell tap.
			string.addAttribute(.foregroundColor, value: tintColor, range: range)
			string.addAttribute(.underlineColor, value: UIColor.clear, range: range)
		}
		return string
	}
}
