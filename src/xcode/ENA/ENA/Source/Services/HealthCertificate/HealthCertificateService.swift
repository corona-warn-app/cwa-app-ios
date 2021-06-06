//
// 🦠 Corona-Warn-App
//

import UIKit
import OpenCombine
import HealthCertificateToolkit

class HealthCertificateService {

	// MARK: - Init

	init(
		store: HealthCertificateStoring,
		client: Client,
		appConfiguration: AppConfigurationProviding
	) {
		#if DEBUG
		if isUITesting {
			self.store = MockTestStore()
			self.client = ClientMock()
			self.appConfiguration = CachedAppConfigurationMock()

			setup()

			// check launch arguments ->
			if LaunchArguments.healthCertificate.firstHealthCertificate.boolValue {
				registerVaccinationCertificate(base45: HealthCertificate.firstBase45Mock)
			} else if LaunchArguments.healthCertificate.firstAndSecondHealthCertificate.boolValue {
				registerVaccinationCertificate(base45: HealthCertificate.firstBase45Mock)
				registerVaccinationCertificate(base45: HealthCertificate.lastBase45Mock)
			}

			return
		}
		#endif

		self.store = store
		self.client = client
		self.appConfiguration = appConfiguration

		setup()
	}

	// MARK: - Internal

	private(set) var healthCertifiedPersons = CurrentValueSubject<[HealthCertifiedPerson], Never>([])
	private(set) var testCertificateRequests = CurrentValueSubject<[TestCertificateRequest], Never>([])

	@discardableResult
	func registerVaccinationCertificate(
		base45: Base45
	) -> Result<HealthCertifiedPerson, HealthCertificateServiceError.VaccinationRegistrationError> {
		Log.info("[HealthCertificateService] Registering health certificate from payload: \(private: base45)", log: .api)

		do {
			let healthCertificate = try HealthCertificate(base45: base45)

			guard let vaccinationEntry = healthCertificate.vaccinationEntry else {
				return .failure(.noVaccinationEntry)
			}

			let healthCertifiedPerson = healthCertifiedPersons.value.first(where: { !$0.vaccinationCertificates.isEmpty }) ??
				healthCertifiedPersons.value.first(where: { $0.name?.standardizedName == healthCertificate.name.standardizedName && $0.dateOfBirth == healthCertificate.dateOfBirth }) ??
				HealthCertifiedPerson(healthCertificates: [])

			let isDuplicate = healthCertifiedPerson.healthCertificates
				.contains(where: { $0.vaccinationEntry?.uniqueCertificateIdentifier == vaccinationEntry.uniqueCertificateIdentifier })
			if isDuplicate {
				return .failure(.vaccinationCertificateAlreadyRegistered)
			}

			let hasDifferentName = healthCertifiedPerson.healthCertificates
				.contains(where: { $0.name.standardizedName != healthCertificate.name.standardizedName })
			if hasDifferentName {
				return .failure(.nameMismatch)
			}

			let hasDifferentDateOfBirth = healthCertifiedPerson.healthCertificates
				.contains(where: { $0.dateOfBirth != healthCertificate.dateOfBirth })
			if hasDifferentDateOfBirth {
				return .failure(.dateOfBirthMismatch)
			}

			healthCertifiedPerson.healthCertificates.append(healthCertificate)
			healthCertifiedPerson.healthCertificates.sort(by: <)

			if !healthCertifiedPersons.value.contains(healthCertifiedPerson) {
				healthCertifiedPersons.value.append(healthCertifiedPerson)
			}

			return .success((healthCertifiedPerson))
		} catch let error as CertificateDecodingError {
			return .failure(.decodingError(error))
		} catch {
			return .failure(.other(error))
		}
	}

	@discardableResult
	func registerHealthCertificate(
		base45: Base45
	) -> Result<HealthCertifiedPerson, HealthCertificateServiceError.RegistrationError> {
		Log.info("[HealthCertificateService] Registering health certificate from payload: \(private: base45)", log: .api)

		do {
			let healthCertificate = try HealthCertificate(base45: base45)

			let healthCertifiedPerson = healthCertifiedPersons.value
				.first(where: {
					$0.healthCertificates.first?.name.standardizedName == healthCertificate.name.standardizedName &&
					$0.healthCertificates.first?.dateOfBirthDate == healthCertificate.dateOfBirthDate
				}) ?? HealthCertifiedPerson(healthCertificates: [])

			let isDuplicate = healthCertifiedPerson.healthCertificates
				.contains(where: {
					$0.vaccinationEntry?.uniqueCertificateIdentifier == healthCertificate.vaccinationEntry?.uniqueCertificateIdentifier ||
					$0.testEntry?.uniqueCertificateIdentifier == healthCertificate.testEntry?.uniqueCertificateIdentifier
				})
			if isDuplicate {
				return .failure(.certificateAlreadyRegistered)
			}

			healthCertifiedPerson.healthCertificates.append(healthCertificate)
			healthCertifiedPerson.healthCertificates.sort(by: <)

			if !healthCertifiedPersons.value.contains(healthCertifiedPerson) {
				healthCertifiedPersons.value.append(healthCertifiedPerson)
			}

			return .success((healthCertifiedPerson))
		} catch let error as CertificateDecodingError {
			return .failure(.decodingError(error))
		} catch {
			return .failure(.other(error))
		}
	}

	func removeHealthCertificate(_ healthCertificate: HealthCertificate) {
		for healthCertifiedPerson in healthCertifiedPersons.value {
			if let index = healthCertifiedPerson.healthCertificates.firstIndex(of: healthCertificate) {
				healthCertifiedPerson.healthCertificates.remove(at: index)

				if healthCertifiedPerson.healthCertificates.isEmpty {
					healthCertifiedPersons.value.removeAll(where: { $0 == healthCertifiedPerson })
				}

				break
			}
		}
	}

	func registerAndExecuteTestCertificateRequest(
		coronaTestType: CoronaTestType,
		registrationToken: String,
		registrationDate: Date,
		retryExecutionIfCertificateIsPending: Bool
	) {
		Log.info("[HealthCertificateService] Registering test certificate request: (coronaTestType: \(coronaTestType), registrationToken: \(private: registrationToken), registrationDate: \(registrationDate))", log: .api)

		if testCertificateRequests.value.contains(where: { $0.coronaTestType == coronaTestType && $0.registrationToken == registrationToken }) {
			Log.info("[HealthCertificateService] Test certificate request (coronaTestType: \(coronaTestType), registrationToken: \(private: registrationToken), registrationDate: \(registrationDate)) already registered", log: .api)
			return
		}

		let testCertificateRequest = TestCertificateRequest(
			coronaTestType: coronaTestType,
			registrationToken: registrationToken,
			registrationDate: registrationDate
		)

		testCertificateRequests.value.append(testCertificateRequest)
		executeTestCertificateRequest(
			testCertificateRequest,
			retryIfCertificateIsPending: retryExecutionIfCertificateIsPending
		)
	}

	func executeTestCertificateRequest(
		_ testCertificateRequest: TestCertificateRequest,
		retryIfCertificateIsPending: Bool,
		completion: ((Result<Void, HealthCertificateServiceError.TestCertificateRequestError>) -> Void)? = nil
	) {
		testCertificateRequest.isLoading = true

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

					if !testCertificateRequest.rsaPublicKeyRegistered {
						self.client.dccRegisterPublicKey(
							isFake: false,
							token: testCertificateRequest.registrationToken,
							publicKey: publicKey,
							completion: { result in
								switch result {
								case .success():
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
									testCertificateRequest.requestExecutionFailed = true
									testCertificateRequest.isLoading = false
									completion?(.failure(.publicKeyRegistrationFailed(registrationError)))
								}
							}
						)
					} else if testCertificateRequest.encryptedDEK == nil || testCertificateRequest.encryptedCOSE == nil {
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
		} catch let error as HealthCertificateServiceError.TestCertificateRequestError {
			testCertificateRequest.requestExecutionFailed = true
			testCertificateRequest.isLoading = false
			completion?(.failure(.other(error)))
		} catch {
			testCertificateRequest.requestExecutionFailed = true
			testCertificateRequest.isLoading = false
			completion?(.failure(.other(error)))
		}
	}

	func updatePublishersFromStore() {
		Log.info("[HealthCertificateService] Updating publishers from store", log: .api)

		healthCertifiedPersons.value = store.healthCertifiedPersons
		testCertificateRequests.value = store.testCertificateRequests
	}

	func remove(testCertificateRequest: TestCertificateRequest) {
		testCertificateRequest.rsaKeyPair?.removeFromKeychain()
		if let index = testCertificateRequests.value.firstIndex(of: testCertificateRequest) {
			testCertificateRequests.value.remove(at: index)
		}
	}

	// MARK: - Private

	private let store: HealthCertificateStoring
	private let client: Client
	private let appConfiguration: AppConfigurationProviding

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

		subscribeToNotifications()
	}

	private func updateHealthCertifiedPersonSubscriptions(for healthCertifiedPersons: [HealthCertifiedPerson]) {
		healthCertifiedPersonSubscriptions = []

		healthCertifiedPersons.forEach { healthCertifiedPerson in
			healthCertifiedPerson.objectDidChange
				.sink { [weak self] _ in
					guard let self = self else { return }
					// Trigger publisher to inform subscribers and update store
					self.healthCertifiedPersons.value = self.healthCertifiedPersons.value
				}
				.store(in: &healthCertifiedPersonSubscriptions)
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
		client.getDigitalCovid19Certificate(
			registrationToken: testCertificateRequest.registrationToken,
			isFake: false
		) { [weak self] result in
			switch result {
			case .success(let dccResponse):
				self?.assembleDigitalCovidCertificate(
					for: testCertificateRequest,
					rsaKeyPair: rsaKeyPair,
					encryptedDEK: dccResponse.dek,
					encryptedCOSE: dccResponse.dcc,
					completion: completion
				)
			case .failure(let error) where error == .dccPending && retryIfCertificateIsPending:
				DispatchQueue.global().asyncAfter(deadline: .now() + waitForRetryInSeconds) {
					self?.requestDigitalCovidCertificate(
						for: testCertificateRequest,
						rsaKeyPair: rsaKeyPair,
						retryIfCertificateIsPending: false,
						waitForRetryInSeconds: waitForRetryInSeconds,
						completion: completion
					)
				}
			case .failure(let error):
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
		guard let encryptedDEKData = Data(base64Encoded: encryptedDEK) else {
			testCertificateRequest.requestExecutionFailed = true
			completion?(.failure(.base64DecodingFailed))
			return
		}

		do {
			let decodedDEK = try rsaKeyPair.decrypt(encryptedDEKData)
			let result = DigitalGreenCertificateAccess().convertToBase45(from: encryptedCOSE, with: decodedDEK)

			switch result {
			case .success(let healthCertificateBase45):
				registerHealthCertificate(base45: healthCertificateBase45)
				remove(testCertificateRequest: testCertificateRequest)
				completion?(.success(()))
			case .failure(let error):
				testCertificateRequest.requestExecutionFailed = true
				completion?(.failure(.assemblyFailed(error)))
			}
		} catch {
			testCertificateRequest.requestExecutionFailed = true
			completion?(.failure(.decryptionFailed(error)))
		}
	}

}
