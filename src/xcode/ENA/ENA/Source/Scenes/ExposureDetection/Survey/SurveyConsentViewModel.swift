////
// 🦠 Corona-Warn-App
//

import UIKit

final class SurveyConsentViewModel {

	// MARK: - Internal

	var dynamicTableViewModel: DynamicTableViewModel {
		var model = DynamicTableViewModel([])

		// Image, title and consent description.

		model.add(
			.section(
				header: .image(
					UIImage(
						imageLiteralResourceName: "Illu_Survey_Consent"),
						accessibilityLabel: AppStrings.SurveyConsent.imageDescription,
						accessibilityIdentifier: AccessibilityIdentifiers.SurveyConsent.titleImage,
						height: 185
				),
				cells: [
					.title1(
						text: AppStrings.SurveyConsent.title,
						accessibilityIdentifier: AccessibilityIdentifiers.SurveyConsent.title
					),
					.body(
						text: AppStrings.SurveyConsent.body1
					),
					.body(
						text: AppStrings.SurveyConsent.body2
					),
					.body(
						text: AppStrings.SurveyConsent.body3
					)
				]
			)
		)

		// Legal

		model.add(
			.section(cells: [
				.acknowledgement(
					title: NSAttributedString(string: AppStrings.SurveyConsent.title),
					description: NSAttributedString(
						string: AppStrings.SurveyConsent.body1 + "\n\n" + AppStrings.SurveyConsent.body2
					),
					bulletPoints: [
						NSAttributedString(string: AppStrings.SurveyConsent.legalBullet1),
						NSAttributedString(string: AppStrings.SurveyConsent.legalBullet2)
					],
					accessibilityIdentifier: AccessibilityIdentifiers.ExposureSubmissionQRInfo.acknowledgementTitle
				)
			])
		)

		// More legal details

		model.add(
			.section(separators: .all, cells: [
				.body(
					text: AppStrings.SurveyConsent.legalDetailsButtonTitle,
					accessibilityIdentifier: AccessibilityIdentifiers.SurveyConsent.legalDetailsButton,
					accessibilityTraits: UIAccessibilityTraits.button,
					action: .push(model: privacyDetailsModel, withTitle: ""),
					configure: { _, cell, _ in
						cell.accessoryType = .disclosureIndicator
						cell.selectionStyle = .default
					})
			])
		)

		return model
	}

	// MARK: - Private

	private var privacyDetailsModel = DynamicTableViewModel([
		.section(
			cells: [
				.title1(
					text: AppStrings.SurveyConsent.legalDetailsTitle,
					accessibilityIdentifier: AccessibilityIdentifiers.SurveyConsent.title
				),
				.body(
					text: AppStrings.SurveyConsent.legalDetailsBody
				)
			]
		)
	])
}
