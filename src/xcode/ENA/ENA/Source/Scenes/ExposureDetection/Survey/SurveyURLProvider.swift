////
// 🦠 Corona-Warn-App
//

import Foundation
import OpenCombine

protocol SurveyURLProvidable {
	func getURL(_ completion: @escaping (Result<URL, SurveyConsentError>) -> Void)
}

final class SurveyURLProvider: SurveyURLProvidable {

	// MARK: - Init

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
		#if DEBUG
		if isUITesting {
			// Provide a dummy URL in case of UI-Testing
			guard let dummyURL = URL(string: "https:///www.sap.com") else {
				return
			}
			return completion(.success(dummyURL))
		}
		#endif
		
		Log.info("Request Survey URL.", log: .survey)
		getPPACToken(completion: completion)
	}

	// MARK: - Private

	private let configurationProvider: AppConfigurationProviding
	private let ppacService: PPACService
	private let otpService: OTPService
	private var subscriptions = [AnyCancellable]()

	private func getPPACToken(completion: @escaping (Result<URL, SurveyConsentError>) -> Void) {
		Log.info("Request PPAC token.", log: .survey)

		ppacService.getPPACToken { [weak self] result in
			switch result {
			case .success(let ppacToken):
				Log.info("Successfully created PPAC token.", log: .survey)
				self?.getOTP(for: ppacToken, completion: completion)
			case .failure(let ppacError):
				Log.error("Failed to create PPAC token with error: \(ppacError)", log: .survey)
				completion(.failure(SurveyConsentError(ppacError: ppacError)))
			}
		}
	}

	private func getOTP(for ppacToken: PPACToken, completion: @escaping (Result<URL, SurveyConsentError>) -> Void) {
		Log.info("Request OTP token.", log: .survey)

		otpService.getOTP(ppacToken: ppacToken) { [weak self] result in
			switch result {
			case .success(let otp):
				Log.info("Successfully created survey OTP.", log: .survey)
				self?.createSurveyURL(with: otp, completion: completion)
			case .failure(let otpError):
				Log.error("Failed to create survey OTP with error: \(otpError)", log: .survey)
				completion(.failure(SurveyConsentError(otpError: otpError)))
			}
		}
	}

	private func createSurveyURL(with otp: String, completion: @escaping (Result<URL, SurveyConsentError>) -> Void) {
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
