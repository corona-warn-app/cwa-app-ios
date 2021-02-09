////
// 🦠 Corona-Warn-App
//

import UIKit

enum SurveyConsentError: Error {

	case tryAgainLater
	case tryAgainNextMonth
	case deviceNotSupported
	case changeDeviceTime
	case alreadyParticipated

	// MARK: - Init

	init(ppacError: PPACError) {
		switch ppacError {
		case .generationFailed, .timeUnverified:
			self = .tryAgainLater
		case .deviceNotSupported:
			self = .deviceNotSupported
		case .timeIncorrect:
			self = .changeDeviceTime
		}
	}

	init(otpError: OTPError) {
		switch otpError {
		case .generalError, .invalidResponseError, .internalServerError, .otherServerError, .apiTokenExpired, .deviceTokenInvalid, .deviceTokenRedeemed, .deviceTokenSyntaxError:
			self = .tryAgainLater
		case .apiTokenAlreadyIssued, .otpAlreadyUsedThisMonth:
			self = .tryAgainNextMonth
		case .apiTokenQuotaExceeded:
			self = .alreadyParticipated
		}
	}

	// MARK: - Internal

	var description: String {
		switch self {
		case .tryAgainLater:
			return AppStrings.SurveyConsent.errorTryAgainLater
		case .tryAgainNextMonth:
			return AppStrings.SurveyConsent.errorTryAgainNextMonth
		case .deviceNotSupported:
			return AppStrings.SurveyConsent.errorDeviceNotSupported
		case .changeDeviceTime:
			return AppStrings.SurveyConsent.errorChangeDeviceTime
		case .alreadyParticipated:
			return AppStrings.SurveyConsent.errorAlreadyParticipated
		}
	}
}

final class SurveyConsentViewModel {

	// MARK: - Init

	init(
		surveyURLProvider: SurveyURLProvidable
	) {
		self.surveyURLProvider = surveyURLProvider
	}

	// MARK: - Internal

	func getURL(_ completion: @escaping (Result<URL, SurveyConsentError>) -> Void) {
		surveyURLProvider.getURL(completion)
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

	private let surveyURLProvider: SurveyURLProvidable

	private var privacyDetailsModel: DynamicTableViewModel {
		
		var model = DynamicTableViewModel([])
		model.add(
			.section(
				cells: [
					.title1(
						text: AppStrings.SurveyConsent.legalDetailsTitle,
						accessibilityIdentifier: AccessibilityIdentifiers.SurveyConsent.title
					)]
			)
		)

		model.add(
			.section(
				cells: [
					.acknowledgement(
						title: NSAttributedString(string: AppStrings.SurveyConsent.legalDetailsHeader1),
						description: NSAttributedString(string: AppStrings.SurveyConsent.legalDetailsBody1)
					)
				])
		)
		
		model.add(
			.section(
				cells: [
					.headline(
						text: AppStrings.SurveyConsent.legalDetailsHeader2,
						accessibilityIdentifier: AccessibilityIdentifiers.SurveyConsent.title
					),
					.body(
						text: AppStrings.SurveyConsent.legalDetailsBody2
					)
				])
		)
		return model
	}
	
	let urlString: String?
	
	init(urlString: String?) {
		self.urlString = urlString
	}
}
