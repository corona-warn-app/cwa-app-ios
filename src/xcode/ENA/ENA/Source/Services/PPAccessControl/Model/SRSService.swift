//
// 🦠 Corona-Warn-App
//

import Foundation
import OpenCombine

protocol SRSSSubmitting {

	typealias SRSAuthenticationResponse = (Result<String, SRSError>) -> Void
	typealias SRSSubmissionResponse = (Result<String, ELSError>) -> Void

	func submit(completion: @escaping SRSSubmissionResponse)
}

final class SRSService: SRSSSubmitting {
	
	// MARK: - Init
	
	init(
		restServicerProvider: RestServiceProviding,
		store: SRSProviding,
		ppacService: PrivacyPreservingAccessControl,
		otpService: OTPServiceProviding,
		configurationProvider: AppConfigurationProviding
	) {
		self.restServicerProvider = restServicerProvider
		self.store = store
		self.ppacService = ppacService
		self.otpService = otpService
		self.configurationProvider = configurationProvider
	}
	
	// MARK: - Private
	
	private let restServicerProvider: RestServiceProviding
	private let store: SRSProviding
	private let ppacService: PrivacyPreservingAccessControl
	private let otpService: OTPServiceProviding
	private let configurationProvider: AppConfigurationProviding
	private var subscriptions = [AnyCancellable]()

	private func authenticate(completion: @escaping SRSAuthenticationResponse) {
		// first get ppac token for SRS
		configurationProvider.appConfiguration().sink { appConfiguration in
			let timeSinceOnboardingInHours = Int(appConfiguration.selfReportParameters.common.timeSinceOnboardingInHours)
			let timeBetweenSubmissionsInDays = Int(appConfiguration.selfReportParameters.common.timeBetweenSubmissionsInDays)
			self.ppacService.getPPACTokenSRS(
				timeSinceOnboardingInHours: timeSinceOnboardingInHours,
				timeBetweenSubmissionsInDays: timeBetweenSubmissionsInDays,
				completion: { [weak self] result in
					guard let self = self else { return }
					switch result {
					case let .success(ppacToken):
						Log.debug("Successfully retrieved for SRS a ppac token. Proceed for otp.")
						// then get otp token for SRS (without restrictions for api token)
						self.otpService.getOTPSrs(ppacToken: ppacToken, completion: { result in
							switch result {
							case let .success(otpSRS):
								Log.debug("Successfully retrieved for SRS an otp.")
								// now we can submit our log with valid otp.
								completion(.success(otpSRS))
							case let .failure(otpError):
                                guard case let .srsRestServiceError(srsServiceError) = otpError else {
                                    completion(.failure(.srsOTPClientError))
                                        return
                                }
                                Log.error("Could not obtain otp for srs.", log: .srs, error: srsServiceError)
								completion(.failure(srsServiceError))
							}
						})
					case let .failure(ppacError):
						Log.error("Could not obtain ppac token for srs.", log: .srs, error: ppacError)
						completion(.failure(.ppacError(ppacError)))
					}
			 })
		}.store(in: &subscriptions)
	}
	
	// MARK: - Protocol SRSSSubmitting
	
	func submit(completion: @escaping SRSSubmissionResponse) {
		
	}
	
	
}
