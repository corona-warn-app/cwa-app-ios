//
// 🦠 Corona-Warn-App
//


import Foundation
import OpenCombine

protocol SRSServiceProviding {

	typealias SRSAuthenticationResponse = (Result<String, SRSError>) -> Void
	typealias SRSPerquisiteChecksResponse = (Result<Void, SRSPreconditionError>) -> Void

	func checkSRSFlowPrerequisites(completion: @escaping SRSPerquisiteChecksResponse)
	func authenticate(completion: @escaping SRSAuthenticationResponse)
}

final class SRSService: SRSServiceProviding {
	
	// MARK: - Init
	
	init(
		restServicerProvider: RestServiceProviding,
		store: SRSProviding,
		ppacService: PrivacyPreservingAccessControl,
		otpService: OTPServiceProviding,
		configurationProvider: AppConfigurationProviding
	) {
		#if DEBUG
		if isUITesting {
			let mockTestStore = MockTestStore()
			let restServiceProviderStub = RestServiceProviderStub()
			let ppacServiceMock = PPACServiceMock(
				store: mockTestStore,
				deviceCheck: PPACDeviceCheckMock(true, deviceToken: "device-token-mock")
			)
			let cachedAppConfigurationMock = CachedAppConfigurationMock(store: mockTestStore)
			self.restServicerProvider = restServiceProviderStub
			self.store = mockTestStore
			self.ppacService = ppacServiceMock
			self.otpService = OTPServiceMock(
				store: mockTestStore,
				client: ClientMock(),
				restServiceProvider: restServiceProviderStub,
				riskProvider: MockRiskProvider(),
				ppacService: ppacServiceMock,
				appConfiguration: cachedAppConfigurationMock
			)
			self.configurationProvider = cachedAppConfigurationMock
			return
		}
		#endif

		self.restServicerProvider = restServicerProvider
		self.store = store
		self.ppacService = ppacService
		self.otpService = otpService
		self.configurationProvider = configurationProvider
	}
	
	// MARK: - Protocol SRSSubmitting
	
	func authenticate(completion: @escaping SRSAuthenticationResponse) {
		// first get ppac token for SRS
		self.ppacService.getPPACTokenSRS { [weak self] result in
			guard let self = self else { return }
			switch result {
			case let .success(ppacToken):
				Log.debug("Successfully retrieved for SRS a ppac token. Proceed for otp.")
				// then get otp token for SRS (without restrictions for api token)
				self.otpService.getOTPSrs(ppacToken: ppacToken) { result in
					switch result {
					case let .success(otpSRS):
						Log.debug("Successfully authenticated ppac and SRS OTP: \(private: otpSRS, public: "--OTP Value--") for els. Proceed with uploading error log file.")
						
						// now we can submit our log with valid otp.
						completion(.success(otpSRS))
					case let .failure(otpError):
						Log.error("Could not obtain otp for srs.", log: .els, error: otpError)
						completion(.failure(.otpError(otpError)))
					}
				}
			case let .failure(ppacError):
				Log.error("Could not obtain ppac token for srs.", log: .srs, error: ppacError)
				completion(.failure(.ppacError(ppacError)))
			}
		}
	}

	func checkSRSFlowPrerequisites(completion: @escaping SRSPerquisiteChecksResponse) {
		configurationProvider.appConfiguration().sink { appConfiguration in
			let timeSinceOnboardingInHours = Int(appConfiguration.selfReportParameters.common.timeSinceOnboardingInHours)
			let timeBetweenSubmissionsInDays = Int(appConfiguration.selfReportParameters.common.timeBetweenSubmissionsInDays)
			self.ppacService.checkSRSFlowPrerequisites(
				minTimeSinceOnboardingInHours: timeSinceOnboardingInHours,
				minTimeBetweenSubmissionsInDays: timeBetweenSubmissionsInDays,
				completion: completion)
		}.store(in: &subscriptions)

	}

	// MARK: - Private
	
	private let restServicerProvider: RestServiceProviding
	private let store: SRSProviding
	private let ppacService: PrivacyPreservingAccessControl
	private let otpService: OTPServiceProviding
	private let configurationProvider: AppConfigurationProviding
	private var subscriptions = [AnyCancellable]()
	
}
