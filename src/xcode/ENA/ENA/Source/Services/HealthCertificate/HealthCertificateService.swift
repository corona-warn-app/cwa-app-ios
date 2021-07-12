//
// 🦠 Corona-Warn-App
//

import UIKit
import OpenCombine
import HealthCertificateToolkit

// swiftlint:disable:next type_body_length
class HealthCertificateService {

	// MARK: - Init

	// swiftlint:disable:next cyclomatic_complexity
	init(
		store: HealthCertificateStoring,
		client: Client,
		appConfiguration: AppConfigurationProviding,
		digitalCovidCertificateAccess: DigitalCovidCertificateAccessProtocol = DigitalCovidCertificateAccess()
	) {

		#if DEBUG
		if isUITesting {
			self.store = MockTestStore()
			self.client = ClientMock()
			self.appConfiguration = CachedAppConfigurationMock()
			self.digitalCovidCertificateAccess = digitalCovidCertificateAccess

			setup()

			// check launch arguments ->
			if LaunchArguments.healthCertificate.firstHealthCertificate.boolValue {
				registerHealthCertificate(base45: HealthCertificate.firstBase45Mock)
			} else if LaunchArguments.healthCertificate.firstAndSecondHealthCertificate.boolValue {
				registerHealthCertificate(base45: HealthCertificate.firstBase45Mock)
				registerHealthCertificate(base45: HealthCertificate.lastBase45Mock)
			}
			

			if LaunchArguments.healthCertificate.familyCertificates.boolValue {
				let testCert1 = DigitalCovidCertificateFake.makeBase45Fake(
					from: DigitalCovidCertificate.fake(
						name: .fake(familyName: "Schneider", givenName: "Andrea", standardizedFamilyName: "SCHNEIDER", standardizedGivenName: "ANDREA"),
						testEntries: [TestEntry.fake(dateTimeOfSampleCollection: "2021-04-12T16:01:00Z")]
					),
					and: CBORWebTokenHeader.fake()
				)
				if case let .success(base45) = testCert1 {
					registerHealthCertificate(base45: base45)
				}
				let testCert2 = DigitalCovidCertificateFake.makeBase45Fake(
					from: DigitalCovidCertificate.fake(
						name: .fake(familyName: "Schneider", givenName: "Toni", standardizedFamilyName: "SCHNEIDER", standardizedGivenName: "TONI"),
						testEntries: [TestEntry.fake(dateTimeOfSampleCollection: "2021-04-12T17:01:00Z")]
					),
					and: CBORWebTokenHeader.fake()
				)
				if case let .success(base45) = testCert2 {
					registerHealthCertificate(base45: base45)
				}
				let testCert3 = DigitalCovidCertificateFake.makeBase45Fake(
					from: DigitalCovidCertificate.fake(
						name: .fake(familyName: "Schneider", givenName: "Victoria", standardizedFamilyName: "SCHNEIDER", standardizedGivenName: "VICTORIA"),
						testEntries: [TestEntry.fake(dateTimeOfSampleCollection: "2021-04-13T18:01:00Z")]
					),
					and: CBORWebTokenHeader.fake()
				)
				if case let .success(base45) = testCert3 {
					registerHealthCertificate(base45: base45)
				}
				let testCert4 = DigitalCovidCertificateFake.makeBase45Fake(
					from: DigitalCovidCertificate.fake(
						name: .fake(familyName: "Schneider", givenName: "Thomas", standardizedFamilyName: "SCHNEIDER", standardizedGivenName: "THOMAS"),
						testEntries: [TestEntry.fake(dateTimeOfSampleCollection: "2021-04-15T12:01:00Z")]
					),
					and: CBORWebTokenHeader.fake()
				)
				if case let .success(base45) = testCert4 {
					registerHealthCertificate(base45: base45)
				}
			}
			if LaunchArguments.healthCertificate.testCertificateRegistered.boolValue {
				let result = DigitalCovidCertificateFake.makeBase45Fake(
					from: DigitalCovidCertificate.fake(
						name: .fake(familyName: "Schneider", givenName: "Andrea", standardizedFamilyName: "SCHNEIDER", standardizedGivenName: "ANDREA"),
						testEntries: [TestEntry.fake(dateTimeOfSampleCollection: "2021-04-12T16:01:00Z")]
					),
					and: CBORWebTokenHeader.fake()
				)
				if case let .success(base45) = result {
					registerHealthCertificate(base45: base45)
				}
			}
			
			if LaunchArguments.healthCertificate.recoveryCertificateRegistered.boolValue {
				let result = DigitalCovidCertificateFake.makeBase45Fake(
					from: DigitalCovidCertificate.fake(
						name: .fake(familyName: "Schneider", givenName: "Andrea", standardizedFamilyName: "SCHNEIDER", standardizedGivenName: "ANDREA"),
						recoveryEntries: [
						 RecoveryEntry.fake()
					 ]
				 ),
					and: CBORWebTokenHeader.fake()
				)
				if case let .success(base45) = result {
					registerHealthCertificate(base45: base45)
				}
			}

			return
		}
		#endif

		self.store = store
		self.client = client
		self.appConfiguration = appConfiguration
		self.digitalCovidCertificateAccess = digitalCovidCertificateAccess

		setup()
	}

	// MARK: - Internal

	private(set) var healthCertifiedPersons = CurrentValueSubject<[HealthCertifiedPerson], Never>([])
	private(set) var testCertificateRequests = CurrentValueSubject<[TestCertificateRequest], Never>([])
	private(set) var unseenTestCertificateCount = CurrentValueSubject<Int, Never>(0)

	@discardableResult
	func registerHealthCertificate(
		base45: Base45
	) -> Result<(HealthCertifiedPerson, HealthCertificate), HealthCertificateServiceError.RegistrationError> {
		Log.info("[HealthCertificateService] Registering health certificate from payload: \(private: base45)", log: .api)

		do {
			let healthCertificate = try HealthCertificate(base45: base45)

			let healthCertifiedPerson = healthCertifiedPersons.value
				.first(where: {
					$0.healthCertificates.first?.name.standardizedName == healthCertificate.name.standardizedName &&
					$0.healthCertificates.first?.dateOfBirthDate == healthCertificate.dateOfBirthDate
				}) ?? HealthCertifiedPerson(healthCertificates: [])

			if healthCertificate.hasTooManyEntries {
				Log.error("[HealthCertificateService] Registering health certificate failed: certificate has too many entries", log: .api)
				return .failure(.certificateHasTooManyEntries)
			}

			let isDuplicate = healthCertifiedPerson.healthCertificates
				.contains(where: {
					$0.uniqueCertificateIdentifier == healthCertificate.uniqueCertificateIdentifier
				})
			if isDuplicate {
				Log.error("[HealthCertificateService] Registering health certificate failed:  certificate already registered", log: .api)
				return .failure(.certificateAlreadyRegistered(healthCertificate.type))
			}

			healthCertifiedPerson.healthCertificates.append(healthCertificate)
			healthCertifiedPerson.healthCertificates.sort(by: <)

			if !healthCertifiedPersons.value.contains(healthCertifiedPerson) {
				Log.info("[HealthCertificateService] Successfully registered health certificate for a new person", log: .api)
				healthCertifiedPersons.value = (healthCertifiedPersons.value + [healthCertifiedPerson]).sorted()
				updateGradients()
			} else {
				Log.info("[HealthCertificateService] Successfully registered health certificate for a person with other existing certificates", log: .api)
			}

			return .success((healthCertifiedPerson, healthCertificate))
		} catch let error as CertificateDecodingError {
			Log.error("[HealthCertificateService] Registering health certificate failed with .decodingError: \(error.localizedDescription)", log: .api)
			return .failure(.decodingError(error))
		} catch {
			return .failure(.other(error))
		}
	}

	func removeHealthCertificate(_ healthCertificate: HealthCertificate) {
		for healthCertifiedPerson in healthCertifiedPersons.value {
			if let index = healthCertifiedPerson.healthCertificates.firstIndex(of: healthCertificate) {
				healthCertifiedPerson.healthCertificates.remove(at: index)

				Log.info("[HealthCertificateService] Removed health certificate at index \(index)", log: .api)

				if healthCertifiedPerson.healthCertificates.isEmpty {
					healthCertifiedPersons.value = healthCertifiedPersons.value
						.filter { $0 != healthCertifiedPerson }
						.sorted()
					updateGradients()

					Log.info("[HealthCertificateService] Removed health certified person", log: .api)
				}

				break
			}
		}
	}

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

		testCertificateRequests.value.append(testCertificateRequest)
		unseenTestCertificateCount.value += 1

		executeTestCertificateRequest(
			testCertificateRequest,
			retryIfCertificateIsPending: retryExecutionIfCertificateIsPending,
			completion: completion
		)
	}

	// swiftlint:disable:next cyclomatic_complexity
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
				.sink { [weak self] in
					guard let self = self else { return }

					var waitAfterPublicKeyRegistrationInSeconds = TimeInterval($0.dgcParameters.testCertificateParameters.waitAfterPublicKeyRegistrationInSeconds)

					var waitForRetryInSeconds = TimeInterval($0.dgcParameters.testCertificateParameters.waitForRetryInSeconds)

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

						self.client.dccRegisterPublicKey(
							isFake: false,
							token: testCertificateRequest.registrationToken,
							publicKey: publicKey,
							completion: { result in
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
				.store(in: &subscriptions)
		} catch let error as DCCRSAKeyPairError {
			Log.error("[HealthCertificateService] Key pair error occured: \(error.localizedDescription)", log: .api)

			testCertificateRequest.requestExecutionFailed = true
			testCertificateRequest.isLoading = false
			completion?(.failure(.rsaKeyPairGenerationFailed(error)))
		} catch {
			Log.error("[HealthCertificateService] Error occured: \(error.localizedDescription)", log: .api)

			testCertificateRequest.requestExecutionFailed = true
			testCertificateRequest.isLoading = false
			completion?(.failure(.other(error)))
		}
	}

	func remove(testCertificateRequest: TestCertificateRequest) {
		testCertificateRequest.rsaKeyPair?.removeFromKeychain()
		if let index = testCertificateRequests.value.firstIndex(of: testCertificateRequest) {
			testCertificateRequests.value.remove(at: index)
		}
	}

	func resetUnseenTestCertificateCount() {
		unseenTestCertificateCount.value = 0
	}

	func updatePublishersFromStore() {
		Log.info("[HealthCertificateService] Updating publishers from store", log: .api)

		healthCertifiedPersons.value = store.healthCertifiedPersons
		testCertificateRequests.value = store.testCertificateRequests
		unseenTestCertificateCount.value = store.unseenTestCertificateCount
	}

	// MARK: - Private

	private let store: HealthCertificateStoring
	private let client: Client
	private let appConfiguration: AppConfigurationProviding
	private let digitalCovidCertificateAccess: DigitalCovidCertificateAccessProtocol

	private var healthCertifiedPersonSubscriptions = Set<AnyCancellable>()
	private var testCertificateRequestSubscriptions = Set<AnyCancellable>()
	private var subscriptions = Set<AnyCancellable>()

	private func setup() {
		updatePublishersFromStore()

		healthCertifiedPersons
			.sink { [weak self] in
				self?.store.healthCertifiedPersons = $0
				self?.updateHealthCertifiedPersonSubscriptions(for: $0)
			}
			.store(in: &subscriptions)

		testCertificateRequests
			.sink { [weak self] in
				self?.store.testCertificateRequests = $0
				self?.updateTestCertificateRequestSubscriptions(for: $0)
			}
			.store(in: &subscriptions)

		unseenTestCertificateCount
			.sink { [weak self] in
				self?.store.unseenTestCertificateCount = $0
			}
			.store(in: &subscriptions)

		subscribeToNotifications()
		updateGradients()
	}

	private func updateHealthCertifiedPersonSubscriptions(for healthCertifiedPersons: [HealthCertifiedPerson]) {
		healthCertifiedPersonSubscriptions = []

		healthCertifiedPersons.forEach { healthCertifiedPerson in
			healthCertifiedPerson.objectDidChange
				.sink { [weak self] healthCertifiedPerson in
					guard let self = self else { return }

					if healthCertifiedPerson.isPreferredPerson {
						// Set isPreferredPerson = false on all other persons to only have one preferred person
						self.healthCertifiedPersons.value
							.filter { $0 != healthCertifiedPerson }
							.forEach {
								$0.isPreferredPerson = false
							}
					}

					self.healthCertifiedPersons.value = self.healthCertifiedPersons.value.sorted()
					self.updateGradients()
				}
				.store(in: &healthCertifiedPersonSubscriptions)
		}
	}

	private func updateGradients() {
		let gradientTypes: [GradientView.GradientType] = [.lightBlue(withStars: true), .mediumBlue(withStars: true), .darkBlue(withStars: true)]
		self.healthCertifiedPersons.value
			.enumerated()
			.forEach { index, person in
				person.gradientType = gradientTypes[index % 3]
			}
	}

	private func updateTestCertificateRequestSubscriptions(for testCertificateRequests: [TestCertificateRequest]) {
		testCertificateRequestSubscriptions = []

		testCertificateRequests.forEach { testCertificateRequest in
			testCertificateRequest.objectDidChange
				.sink { [weak self] _ in
					guard let self = self else { return }
					// Trigger publisher to inform subscribers and update store
					self.testCertificateRequests.value = self.testCertificateRequests.value
				}
				.store(in: &testCertificateRequestSubscriptions)
		}
	}

	private func subscribeToNotifications() {
		NotificationCenter.default.ocombine
			.publisher(for: UIApplication.didBecomeActiveNotification)
			.sink { [weak self] _ in
				self?.testCertificateRequests.value.forEach {
					self?.executeTestCertificateRequest($0, retryIfCertificateIsPending: false)
				}
			}
			.store(in: &subscriptions)
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
				let registerResult = registerHealthCertificate(base45: healthCertificateBase45)

				switch registerResult {
				case .success:
					Log.info("[HealthCertificateService] Certificate assembly succeeded", log: .api)
					remove(testCertificateRequest: testCertificateRequest)
					completion?(.success(()))
				case .failure(let error):
					Log.error("[HealthCertificateService] Assembling certificate failed: Register failed: \(error.localizedDescription)", log: .api)

					testCertificateRequest.requestExecutionFailed = true
					testCertificateRequest.isLoading = false
					completion?(.failure(.registrationError(error)))
				}
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
