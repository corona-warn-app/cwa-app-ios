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
				registerHealthCertificate(base45: HealthCertificate.firstBase45Mock)
			} else if LaunchArguments.healthCertificate.firstAndSecondHealthCertificate.boolValue {
				registerHealthCertificate(base45: HealthCertificate.firstBase45Mock)
				registerHealthCertificate(base45: HealthCertificate.lastBase45Mock)
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
	func registerHealthCertificate(
		base45: Base45
	) -> Result<HealthCertifiedPerson, HealthCertificateServiceError.RegistrationError> {
		Log.info("[HealthCertificateService] Registering health certificate from payload: \(private: base45)", log: .api)

		do {
			let healthCertificate = try HealthCertificate(base45: base45)

			guard let vaccinationCertificate = healthCertificate.vaccinationCertificates.first else {
				return .failure(.noVaccinationEntry)
			}

			let healthCertifiedPerson = healthCertifiedPersons.value.first ?? HealthCertifiedPerson(healthCertificates: [])

			let isDuplicate = healthCertifiedPerson.healthCertificates
				.contains(where: { $0.vaccinationCertificates.first?.uniqueCertificateIdentifier == vaccinationCertificate.uniqueCertificateIdentifier })
			if isDuplicate {
				return .failure(.vaccinationCertificateAlreadyRegistered)
			}

			let hasDifferentName = healthCertifiedPerson.healthCertificates
				.contains(where: { $0.name.standardizedName != healthCertificate.name.standardizedName })
			if hasDifferentName {
				return .failure(.nameMismatch)
			}

			let hasDifferentDateOfBirth = healthCertifiedPerson.healthCertificates
				.contains(where: { $0.dateOfBirthDate != healthCertificate.dateOfBirthDate })
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

	func registerTestCertificateRequest(
		coronaTestType: CoronaTestType,
		registrationToken: String,
		registrationDate: Date
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
		executeTestCertificateRequest(testCertificateRequest)
	}

	func executeTestCertificateRequest(_ testCertificateRequest: TestCertificateRequest, completion: ((Result<Void, HealthCertificateServiceError.TestCertificateRequestError>) -> Void)? = nil) {
		do {
			let rsaKeyPair = try testCertificateRequest.rsaKeyPair ?? DCCRSAKeyPair()
			testCertificateRequest.rsaKeyPair = rsaKeyPair

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
							publicKey: rsaKeyPair.publicKeyForBackend,
							completion: { result in
								switch result {
								case .success():
									testCertificateRequest.rsaPublicKeyRegistered = true
									DispatchQueue.global().asyncAfter(deadline: .now() + waitAfterPublicKeyRegistrationInSeconds) {
										self.requestDigitalCovidCertificate(for: testCertificateRequest, completion: completion)
									}
								case .failure(let registrationError) where registrationError == .tokenAlreadyAssigned:
									testCertificateRequest.rsaPublicKeyRegistered = true
									DispatchQueue.global().asyncAfter(deadline: .now() + waitAfterPublicKeyRegistrationInSeconds) {
										self.requestDigitalCovidCertificate(for: testCertificateRequest, completion: completion)
									}
								case .failure(let registrationError):
									testCertificateRequest.requestExecutionFailed = true
									completion?(.failure(.publicKeyRegistrationFailed(registrationError)))
								}
							}
						)
					} else if testCertificateRequest.encryptedDEK == nil || testCertificateRequest.encryptedCOSE == nil {
						self.requestDigitalCovidCertificate(for: testCertificateRequest, completion: completion)
					}
				}
				.store(in: &subscriptions)
		} catch let error as HealthCertificateServiceError.TestCertificateRequestError {
			testCertificateRequest.requestExecutionFailed = true
			completion?(.failure(.other(error)))
		} catch {
			testCertificateRequest.requestExecutionFailed = true
			completion?(.failure(.other(error)))
		}
	}

	private func requestDigitalCovidCertificate(
		for testCertificateRequest: TestCertificateRequest,
		retryOn202: Bool = true,
		completion: ((Result<Void, HealthCertificateServiceError.TestCertificateRequestError>) -> Void)? = nil) {
		client.getDigitalCovid19Certificate(
			registrationToken: testCertificateRequest.registrationToken,
			isFake: false
		) { result in
			switch result {
			case .success(let dccResponse):
				<#code#>
			case .failure(let error):
				<#code#>
			}
		}
	}

	private func assembleDigitalCovidCertificate(encryptedDEK: String, encryptedCOSE: String, completion: ((Result<Void, HealthCertificateServiceError.TestCertificateRequestError>) -> Void)? = nil) {

	}

	func updatePublishersFromStore() {
		Log.info("[HealthCertificateService] Updating publishers from store", log: .api)

		healthCertifiedPersons.value = store.healthCertifiedPersons
		testCertificateRequests.value = store.testCertificateRequests
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
					self?.executeTestCertificateRequest($0)
				}
			}
			.store(in: &subscriptions)
	}

}
