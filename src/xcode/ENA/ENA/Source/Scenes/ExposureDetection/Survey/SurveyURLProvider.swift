////
// 🦠 Corona-Warn-App
//

import Foundation
import OpenCombine

enum SurveyError: Error {

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

protocol SurveyURLProvidable {
	func getURL(_ completion: @escaping (Result<URL, SurveyError>) -> Void)
}

final class SurveyURLProvider: SurveyURLProvidable {

	// MARK: - Init

	init(
		configurationProvider: AppConfigurationProviding,
		ppacService: PPACService,
		otpService: OTPServiceProviding
	) {
		self.configurationProvider = configurationProvider
		self.ppacService = ppacService
		self.otpService = otpService
	}

	// MARK: - Internal

	func getURL(_ completion: @escaping (Result<URL, SurveyError>) -> Void) {
		Log.info("Request Survey URL.", log: .survey)
		getPPACToken(completion: completion)
	}

	// MARK: - Private

	private let configurationProvider: AppConfigurationProviding
	private let ppacService: PPACService
	private let otpService: OTPServiceProviding
	private var subscriptions = [AnyCancellable]()

	private func getPPACToken(completion: @escaping (Result<URL, SurveyError>) -> Void) {
		Log.info("Request PPAC token.", log: .survey)

		ppacService.getPPACToken { [weak self] result in
			switch result {
			case .success(let ppacToken):
				Log.info("Successfully created PPAC token.", log: .survey)
				self?.getOTP(for: ppacToken, completion: completion)
			case .failure(let ppacError):
				Log.error("Failed to create PPAC token with error: \(ppacError)", log: .survey)
				completion(.failure(SurveyError(ppacError: ppacError)))
			}
		}
	}

	private func getOTP(for ppacToken: PPACToken, completion: @escaping (Result<URL, SurveyError>) -> Void) {
		Log.info("Request OTP token.", log: .survey)

		otpService.getOTP(ppacToken: ppacToken) { [weak self] result in
			switch result {
			case .success(let otp):
				Log.info("Successfully created survey OTP.", log: .survey)
				self?.createSurveyURL(with: otp, completion: completion)
			case .failure(let otpError):
				Log.error("Failed to create survey OTP with error: \(otpError)", log: .survey)
				completion(.failure(SurveyError(otpError: otpError)))
			}
		}
	}

	private func createSurveyURL(with otp: String, completion: @escaping (Result<URL, SurveyError>) -> Void) {
		Log.info("Request surveyOnHighRiskURL and otpQueryParameterName from app config.", log: .survey)

		configurationProvider.appConfiguration().sink { configuration in
			let baseURLString = configuration.eventDrivenUserSurveyParameters.common.surveyOnHighRiskURL
			let queryParameterName = configuration.eventDrivenUserSurveyParameters.common.otpQueryParameterName
			if let surveyURL = URL(string: baseURLString + "?\(queryParameterName)=\(otp)") {
				Log.info("Successfully created survey URL.", log: .survey)
				completion(.success(surveyURL))
			} else {
				Log.error("Failed to create URL based on app config.", log: .survey)
				completion(.failure(.tryAgainLater))
			}
		}.store(in: &subscriptions)
	}
}
