//
// 🦠 Corona-Warn-App
//

import UIKit
import OpenCombine
import HealthCertificateToolkit

class HealthCertificateRequestService {

	// MARK: - Init

	init(
		store: HealthCertificateStoring,
		client: Client,
		appConfiguration: AppConfigurationProviding,
		digitalCovidCertificateAccess: DigitalCovidCertificateAccessProtocol = DigitalCovidCertificateAccess(),
		healthCertificateService: HealthCertificateService
	) {
		#if DEBUG
		if isUITesting {
			let store = MockTestStore()

			self.store = store
			self.client = ClientMock()
			self.appConfiguration = CachedAppConfigurationMock(store: store)
			self.digitalCovidCertificateAccess = digitalCovidCertificateAccess
			self.healthCertificateService = healthCertificateService

			setup()

			return
		}
		#endif

		self.store = store
		self.client = client
		self.appConfiguration = appConfiguration
		self.digitalCovidCertificateAccess = digitalCovidCertificateAccess
		self.healthCertificateService = healthCertificateService

		setup()
	}

	// MARK: - Internal

	@DidSetPublished private(set) var testCertificateRequests = [TestCertificateRequest]() {
		didSet {
			Log.debug("Did set testCertificateRequests.")

			if initialTestCertificateRequestsReadFromStore {
				store.testCertificateRequests = testCertificateRequests
			}

			updateTestCertificateRequestSubscriptions(for: testCertificateRequests)
		}
	}

	let didRegisterTestCertificate = PassthroughSubject<(String, TestCertificateRequest), Never>()

	func registerAndExecuteTestCertificateRequest(
		coronaTestType: CoronaTestType,
		registrationToken: String,
		registrationDate: Date,
		retryExecutionIfCertificateIsPending: Bool,
		labId: String?,
		completion: ((Result<Void, HealthCertificateServiceError.TestCertificateRequestError>) -> Void)? = nil
	) {
		Log.info("[HealthCertificateService] Registering test certificate request: (coronaTestType: \(coronaTestType), registrationToken: \(private: registrationToken), registrationDate: \(registrationDate), retryExecutionIfCertificateIsPending: \(retryExecutionIfCertificateIsPending)", log: .api)

		let testCertificateRequest = TestCertificateRequest(
			coronaTestType: coronaTestType,
			registrationToken: registrationToken,
			registrationDate: registrationDate,
			labId: labId
		)

		testCertificateRequests.append(testCertificateRequest)

		executeTestCertificateRequest(
			testCertificateRequest,
			retryIfCertificateIsPending: retryExecutionIfCertificateIsPending,
			completion: completion
		)
	}

	func executeTestCertificateRequest(
		_ testCertificateRequest: TestCertificateRequest,
		retryIfCertificateIsPending: Bool,
		completion: ((Result<Void, HealthCertificateServiceError.TestCertificateRequestError>) -> Void)? = nil
	) {
		Log.info("[HealthCertificateService] Executing test certificate request: \(private: testCertificateRequest)", log: .api)

		testCertificateRequest.isLoading = true

		// If we didn't retrieve a labId for a PRC test result, the lab is not supporting test certificates.
		if testCertificateRequest.coronaTestType == .pcr && testCertificateRequest.labId == nil {
			testCertificateRequest.requestExecutionFailed = true
			testCertificateRequest.isLoading = false
			completion?(.failure(.dgcNotSupportedByLab))
			return
		}

		do {
			let rsaKeyPair = try testCertificateRequest.rsaKeyPair ?? DCCRSAKeyPair(registrationToken: testCertificateRequest.registrationToken)
			testCertificateRequest.rsaKeyPair = rsaKeyPair
			let publicKey = try rsaKeyPair.publicKeyForBackend()

			appConfiguration.appConfiguration()
				.sink { [weak self] appConfig in
					self?.executeTestCertificateRequest(
						testCertificateRequest,
						appConfig: appConfig,
						rsaKeyPair: rsaKeyPair,
						publicKey: publicKey,
						retryIfCertificateIsPending: retryIfCertificateIsPending,
						completion: completion
					)
				}
				.store(in: &subscriptions)
		} catch let error as DCCRSAKeyPairError {
			Log.error("[HealthCertificateService] Key pair error occurred: \(error.localizedDescription)", log: .api)

			testCertificateRequest.requestExecutionFailed = true
			testCertificateRequest.isLoading = false
			completion?(.failure(.rsaKeyPairGenerationFailed(error)))
		} catch {
			Log.error("[HealthCertificateService] Error occurred: \(error.localizedDescription)", log: .api)

			testCertificateRequest.requestExecutionFailed = true
			testCertificateRequest.isLoading = false
			completion?(.failure(.other(error)))
		}
	}

	func remove(testCertificateRequest: TestCertificateRequest) {
		testCertificateRequest.rsaKeyPair?.removeFromKeychain()
		if let index = testCertificateRequests.firstIndex(of: testCertificateRequest) {
			testCertificateRequests.remove(at: index)
		}
	}

	// MARK: - Private

	private let store: HealthCertificateStoring
	private let client: Client
	private let appConfiguration: AppConfigurationProviding
	private let digitalCovidCertificateAccess: DigitalCovidCertificateAccessProtocol
	private let healthCertificateService: HealthCertificateService

	private var initialTestCertificateRequestsReadFromStore = false

	private var testCertificateRequestSubscriptions = Set<AnyCancellable>()
	private var subscriptions = Set<AnyCancellable>()

	private func setup() {
		updatePublishersFromStore()
		subscribeToNotifications()
	}

	private func updatePublishersFromStore() {
		Log.info("[HealthCertificateService] Updating publishers from store", log: .api)

		testCertificateRequests = store.testCertificateRequests
		initialTestCertificateRequestsReadFromStore = true
	}

	private func updateTestCertificateRequestSubscriptions(for testCertificateRequests: [TestCertificateRequest]) {
		Log.debug("Update test certificate subscriptions.")

		testCertificateRequestSubscriptions = []

		testCertificateRequests.forEach { testCertificateRequest in
			testCertificateRequest.objectDidChange
				.sink { [weak self] _ in
					guard let self = self else { return }
					// Trigger publisher to inform subscribers and update store
					self.testCertificateRequests = self.testCertificateRequests
				}
				.store(in: &testCertificateRequestSubscriptions)
		}
	}

	private func subscribeToNotifications() {
		NotificationCenter.default.ocombine
			.publisher(for: UIApplication.didBecomeActiveNotification)
			.sink { [weak self] _ in
				guard let self = self, self.healthCertificateService.isSetUp else {
					return
				}

				self.testCertificateRequests.forEach {
					self.executeTestCertificateRequest($0, retryIfCertificateIsPending: false)
				}
			}
			.store(in: &subscriptions)

		healthCertificateService.$isSetUp
			.sink { [weak self] isSetUp in
				guard isSetUp else {
					return
				}

				self?.testCertificateRequests.forEach {
					self?.executeTestCertificateRequest($0, retryIfCertificateIsPending: false)
				}
			}
			.store(in: &subscriptions)
	}

	private func executeTestCertificateRequest(
		_ testCertificateRequest: TestCertificateRequest,
		appConfig: SAP_Internal_V2_ApplicationConfigurationIOS,
		rsaKeyPair: DCCRSAKeyPair,
		publicKey: String,
		retryIfCertificateIsPending: Bool,
		completion: ((Result<Void, HealthCertificateServiceError.TestCertificateRequestError>) -> Void)? = nil
	) {
		var waitAfterPublicKeyRegistrationInSeconds = TimeInterval(appConfig.dgcParameters.testCertificateParameters.waitAfterPublicKeyRegistrationInSeconds)

		var waitForRetryInSeconds = TimeInterval(appConfig.dgcParameters.testCertificateParameters.waitForRetryInSeconds)

		// 0 means the value is not set -> setting it to a default waiting time of 10 seconds
		if waitAfterPublicKeyRegistrationInSeconds == 0 {
			waitAfterPublicKeyRegistrationInSeconds = 10
		}

		if waitForRetryInSeconds == 0 {
			waitForRetryInSeconds = 10
		}

		Log.info("[HealthCertificateService] waitAfterPublicKeyRegistrationInSeconds: \(waitAfterPublicKeyRegistrationInSeconds), waitForRetryInSeconds: \(waitForRetryInSeconds)", log: .api)

		if !testCertificateRequest.rsaPublicKeyRegistered {
			Log.info("[HealthCertificateService] Registering public key …", log: .api)

			client.dccRegisterPublicKey(
				isFake: false,
				token: testCertificateRequest.registrationToken,
				publicKey: publicKey,
				completion: { [weak self] result in
					guard let self = self else { return }

					switch result {
					case .success:
						Log.info("[HealthCertificateService] Public key successfully registered", log: .api)

						testCertificateRequest.rsaPublicKeyRegistered = true
						DispatchQueue.global().asyncAfter(deadline: .now() + waitAfterPublicKeyRegistrationInSeconds) {
							self.requestDigitalCovidCertificate(
								for: testCertificateRequest,
								rsaKeyPair: rsaKeyPair,
								retryIfCertificateIsPending: retryIfCertificateIsPending,
								waitForRetryInSeconds: waitForRetryInSeconds,
								completion: completion
							)
						}
					case .failure(let registrationError) where registrationError == .tokenAlreadyAssigned:
						Log.info("[HealthCertificateService] Public key was already registered.", log: .api)

						testCertificateRequest.rsaPublicKeyRegistered = true
						testCertificateRequest.isLoading = false
						self.requestDigitalCovidCertificate(
							for: testCertificateRequest,
							rsaKeyPair: rsaKeyPair,
							retryIfCertificateIsPending: retryIfCertificateIsPending,
							waitForRetryInSeconds: waitForRetryInSeconds,
							completion: completion
						)
					case .failure(let registrationError):
						Log.error("[HealthCertificateService] Public key registration failed: \(registrationError.localizedDescription)", log: .api)

						testCertificateRequest.requestExecutionFailed = true
						testCertificateRequest.isLoading = false
						completion?(.failure(.publicKeyRegistrationFailed(registrationError)))
					}
				}
			)
		} else if let encryptedDEK = testCertificateRequest.encryptedDEK,
				  let encryptedCOSE = testCertificateRequest.encryptedCOSE {
			Log.info("[HealthCertificateService] Encrypted COSE and DEK already exist, immediately assembling certificate.", log: .api)

			self.assembleDigitalCovidCertificate(
				for: testCertificateRequest,
				rsaKeyPair: rsaKeyPair,
				encryptedDEK: encryptedDEK,
				encryptedCOSE: encryptedCOSE,
				completion: completion
			)
		} else {
			Log.info("[HealthCertificateService] Public key already registered, immediately requesting certificate.", log: .api)

			self.requestDigitalCovidCertificate(
				for: testCertificateRequest,
				rsaKeyPair: rsaKeyPair,
				retryIfCertificateIsPending: retryIfCertificateIsPending,
				waitForRetryInSeconds: waitForRetryInSeconds,
				completion: completion
			)
		}
	}

	private func requestDigitalCovidCertificate(
		for testCertificateRequest: TestCertificateRequest,
		rsaKeyPair: DCCRSAKeyPair,
		retryIfCertificateIsPending: Bool,
		waitForRetryInSeconds: TimeInterval,
		completion: ((Result<Void, HealthCertificateServiceError.TestCertificateRequestError>) -> Void)?
	) {
		Log.info("[HealthCertificateService] Requesting certificate…", log: .api)

		client.getDigitalCovid19Certificate(
			registrationToken: testCertificateRequest.registrationToken,
			isFake: false
		) { [weak self] result in
			switch result {
			case .success(let dccResponse):
				Log.info("[HealthCertificateService] Certificate request succeeded", log: .api)

				self?.assembleDigitalCovidCertificate(
					for: testCertificateRequest,
					rsaKeyPair: rsaKeyPair,
					encryptedDEK: dccResponse.dek,
					encryptedCOSE: dccResponse.dcc,
					completion: completion
				)
			case .failure(let error) where error == .dccPending && retryIfCertificateIsPending:
				DispatchQueue.global().asyncAfter(deadline: .now() + waitForRetryInSeconds) {
					Log.info("[HealthCertificateService] Certificate request failed with .dccPending, retrying.", log: .api)

					self?.requestDigitalCovidCertificate(
						for: testCertificateRequest,
						rsaKeyPair: rsaKeyPair,
						retryIfCertificateIsPending: false,
						waitForRetryInSeconds: waitForRetryInSeconds,
						completion: completion
					)
				}
			case .failure(let error):
				Log.error("[HealthCertificateService] Certificate request failed with error \(error.localizedDescription)", log: .api)

				testCertificateRequest.requestExecutionFailed = true
				testCertificateRequest.isLoading = false
				completion?(.failure(.certificateRequestFailed(error)))
			}
		}
	}

	private func assembleDigitalCovidCertificate(
		for testCertificateRequest: TestCertificateRequest,
		rsaKeyPair: DCCRSAKeyPair,
		encryptedDEK: String,
		encryptedCOSE: String,
		completion: ((Result<Void, HealthCertificateServiceError.TestCertificateRequestError>) -> Void)?
	) {
		Log.info("[HealthCertificateService] Assembling certificate…", log: .api)

		guard let encryptedDEKData = Data(base64Encoded: encryptedDEK) else {
			Log.error("[HealthCertificateService] Assembling certificate failed: base64 decoding failed", log: .api)

			testCertificateRequest.requestExecutionFailed = true
			testCertificateRequest.isLoading = false
			completion?(.failure(.base64DecodingFailed))
			return
		}

		do {
			let decodedDEK = try rsaKeyPair.decrypt(encryptedDEKData)
			let result = digitalCovidCertificateAccess.convertToBase45(from: encryptedCOSE, with: decodedDEK)

			switch result {
			case .success(let healthCertificateBase45):
				healthCertificateService.registerHealthCertificate(
					base45: healthCertificateBase45,
					checkSignatureUpfront: false,
					checkMaxPersonCount: false,
					markAsNew: true,
					completion: { [weak self] registerResult in
						guard let self = self else {
							return
						}
						switch registerResult {
						case .success(let certificateResult):
							Log.info("[HealthCertificateService] Certificate assembly succeeded", log: .api)
							
							self.didRegisterTestCertificate.send((certificateResult.certificate.uniqueCertificateIdentifier, testCertificateRequest))
							
							self.remove(testCertificateRequest: testCertificateRequest)
							completion?(.success(()))
						case .failure(let error):
							Log.error("[HealthCertificateService] Assembling certificate failed: Register failed: \(error.localizedDescription)", log: .api)

							testCertificateRequest.requestExecutionFailed = true
							testCertificateRequest.isLoading = false
							completion?(.failure(.registrationError(error)))
						}
					}
				)
			case .failure(let error):
				Log.error("[HealthCertificateService] Assembling certificate failed: Conversion failed: \(error.localizedDescription)", log: .api)

				testCertificateRequest.requestExecutionFailed = true
				testCertificateRequest.isLoading = false
				completion?(.failure(.assemblyFailed(error)))
			}
		} catch {
			Log.error("[HealthCertificateService] Assembling certificate failed: DEK decryption failed: \(error.localizedDescription)", log: .api)

			testCertificateRequest.requestExecutionFailed = true
			testCertificateRequest.isLoading = false
			completion?(.failure(.decryptionFailed(error)))
		}
	}

}
