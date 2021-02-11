////
// 🦠 Corona-Warn-App
//

import UIKit

final class SurveyConsentViewModel {

	// MARK: - Init

	init(
		surveyURLProvider: SurveyURLProviding
	) {
		self.surveyURLProvider = surveyURLProvider
	}

	// MARK: - Internal

	func getURL(_ completion: @escaping (Result<URL, SurveyError>) -> Void) {
		surveyURLProvider.getURL { result in
			DispatchQueue.main.async {
				completion(result)
			}
		}
	}

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
					.headline(
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
					title: NSAttributedString(string: AppStrings.SurveyConsent.legalTitle),
					description: NSAttributedString(
						string: AppStrings.SurveyConsent.legalBody1 + "\n\n" + AppStrings.SurveyConsent.legalBody2
					),
					bulletPoints: [
						NSAttributedString(string: AppStrings.SurveyConsent.legalBullet1),
						NSAttributedString(string: AppStrings.SurveyConsent.legalBullet2),
						NSAttributedString(string: AppStrings.SurveyConsent.legalBullet3)
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

	private let surveyURLProvider: SurveyURLProviding

	private var privacyDetailsModel: DynamicTableViewModel {
		
		var model = DynamicTableViewModel([])
		model.add(
			.section(
				cells: [
					.title1(
						text: AppStrings.SurveyConsent.surveyDetailsTitle,
						accessibilityIdentifier: AccessibilityIdentifiers.SurveyConsent.title
					)]
			)
		)

		model.add(
			.section(
				cells: [
					.acknowledgement(
						title: NSAttributedString(string: AppStrings.SurveyConsent.surveyDetailsLegalHeader),
						description: NSAttributedString(
							string: AppStrings.SurveyConsent.surveyDetailsLegalBody1 + "\n" + AppStrings.SurveyConsent.surveyDetailsLegalBody2
						)
					)
				])
		)
		
		model.add(
			.section(
				cells: [
					.headline(
						text: AppStrings.SurveyConsent.surveyDetailsHeader,
						accessibilityIdentifier: AccessibilityIdentifiers.SurveyConsent.title
					),
					.body(
						text: AppStrings.SurveyConsent.surveyDetailsBody
					)
				])
		)
		return model
	}
}
