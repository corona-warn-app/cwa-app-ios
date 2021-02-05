////
// 🦠 Corona-Warn-App
//

import UIKit
import OpenCombine

enum SurveyConsentError: Error {

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

	case tryAgainLater
	case tryAgainNextMonth
	case deviceNotSupported
	case changeDeviceTime
	case alreadyParticipated

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

	init(
		configurationProvider: AppConfigurationProviding,
		ppacService: PPACService,
		otpService: OTPService
	) {
		self.configurationProvider = configurationProvider
		self.ppacService = ppacService
		self.otpService = otpService
	}

	// MARK: - Internal

	func getURL(_ completion: @escaping (Result<URL, SurveyConsentError>) -> Void) {
		getPPACToken(completion: completion)
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

	private let configurationProvider: AppConfigurationProviding
	private let ppacService: PPACService
	private let otpService: OTPService
	private var subscriptions = [AnyCancellable]()

	private func getPPACToken(completion: @escaping (Result<URL, SurveyConsentError>) -> Void) {
		ppacService.getPPACToken { [weak self] result in
			switch result {
			case .success(let ppacToken):
				self?.getOTP(for: ppacToken, completion: completion)
			case .failure(let ppacError):
				completion(.failure(SurveyConsentError(ppacError: ppacError)))
			}
		}
	}

	private func getOTP(for ppacToken: PPACToken, completion: @escaping (Result<URL, SurveyConsentError>) -> Void) {
		otpService.getOTP(ppacToken: ppacToken) { [weak self] result in
			switch result {
			case .success(let otp):
				self?.createSurveyURL(with: otp, completion: completion)
			case .failure(let otpError):
				completion(.failure(SurveyConsentError(otpError: otpError)))
			}
		}
	}

	private func createSurveyURL(with otp: String, completion: @escaping (Result<URL, SurveyConsentError>) -> Void) {
		configurationProvider.appConfiguration().sink { configuration in
			let baseURLString = configuration.eventDrivenUserSurveyParameters.common.surveyOnHighRiskURL
			let queryParameterName = configuration.eventDrivenUserSurveyParameters.common.otpQueryParameterName
			if let surveyURL = URL(string: baseURLString + "?\(queryParameterName)=\(otp)") {
				completion(.success(surveyURL))
			} else {
				completion(.failure(.tryAgainLater))
			}
		}.store(in: &subscriptions)
	}

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
