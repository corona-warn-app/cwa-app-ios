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
		getPPACToken(completion: completion)
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
}
