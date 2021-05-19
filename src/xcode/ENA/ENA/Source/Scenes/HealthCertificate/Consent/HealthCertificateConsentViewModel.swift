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
					.body(
						text: AppStrings.HealthCertificate.Info.description
					),
					.icon(
						UIImage(imageLiteralResourceName: "Icons_FaceID"),
						text: .string(AppStrings.HealthCertificate.Info.section01),
						alignment: .top
					),
					.icon(
						UIImage(imageLiteralResourceName: "Icons_QR5"),
						text: .string(AppStrings.HealthCertificate.Info.section02),
						alignment: .top
					),
					.icon(
						UIImage(imageLiteralResourceName: "Icons_Shield"),
						text: .string(AppStrings.HealthCertificate.Info.section03),
						alignment: .top
					)
				]
			),
			// Legal text
			.section(cells: [
				.legalExtended(
					title: NSAttributedString(string: AppStrings.HealthCertificate.Info.Legal.headline),
					subheadline1: nil,
					bulletPoints1: [
						bulletPointCellWithNormalText(
							text: AppStrings.HealthCertificate.Info.Legal.section01
						),
						bulletPointCellWithNormalText(
							text: AppStrings.HealthCertificate.Info.Legal.section02
						),
						bulletPointCellWithNormalText(
							text: AppStrings.HealthCertificate.Info.Legal.section03
						),
						bulletPointCellWithNormalText(
							text: AppStrings.HealthCertificate.Info.Legal.section04
						)
					],
					subheadline2: nil,
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

	private func bulletPointCellWithNormalText(text: String) -> NSMutableAttributedString {
		return NSMutableAttributedString(string: "\(text)", attributes: normalTextAttribute)
	}

}
