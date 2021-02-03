////
// 🦠 Corona-Warn-App
//

import UIKit

final class SurveyConsentViewModel {

	// MARK: - Internal

	var dynamicTableViewModel: DynamicTableViewModel {
		var model = DynamicTableViewModel([])
		model.add(
			.section(
				header:  .image(
					UIImage(imageLiteralResourceName: "Illu_Survey_Consent"),
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

		model.add(
			.section(cells: [
				.acknowledgement(
					title: NSAttributedString(string: AppStrings.SurveyConsent.title),
					description: NSAttributedString(string: description),
					bulletPoints: bulletPoints,
					accessibilityIdentifier: AccessibilityIdentifiers.ExposureSubmissionQRInfo.acknowledgementTitle
				)
			])
		)

		return model
	}

	// MARK: - Private

	private var description: String {
		AppStrings.SurveyConsent.body1+"\n\n"+AppStrings.SurveyConsent.body2
	}

	private var bulletPoints: [NSAttributedString] {
		[
			NSAttributedString(string: AppStrings.SurveyConsent.legalBullet1),
			NSAttributedString(string: AppStrings.SurveyConsent.legalBullet2)
		]
	}
}
