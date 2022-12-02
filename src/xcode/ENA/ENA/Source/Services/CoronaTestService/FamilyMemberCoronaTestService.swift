////
// 🦠 Corona-Warn-App
//

import Foundation
import OpenCombine
import UIKit

// swiftlint:disable:next type_body_length
class FamilyMemberCoronaTestService: FamilyMemberCoronaTestServiceProviding {

	// MARK: - Init

	init(
		client: Client,
		restServiceProvider: RestServiceProviding,
		store: CoronaTestStoring,
		appConfiguration: AppConfigurationProviding,
		healthCertificateService: HealthCertificateService,
		healthCertificateRequestService: HealthCertificateRequestService,
		ppacService: PrivacyPreservingAccessControl,
		notificationCenter: UserNotificationCenter = UNUserNotificationCenter.current(),
		recycleBin: RecycleBin
	) {
		#if DEBUG
		if isUITesting {
			self.client = ClientMock()
			if LaunchArguments.exposureSubmission.isFetchingSubmissionTan.boolValue {
				self.restServiceProvider = .registrationTokenServiceProvider
			} else {
				self.restServiceProvider = .coronaTestServiceProvider
			}
			self.store = MockTestStore()
			self.appConfiguration = CachedAppConfigurationMock()

			self.healthCertificateService = healthCertificateService
			self.healthCertificateRequestService = healthCertificateRequestService
			self.ppacService = ppacService
			self.notificationCenter = notificationCenter
			self.recycleBin = recycleBin

			self.fakeRequestService = FakeRequestService(restServiceProvider: restServiceProvider, ppacService: ppacService, appConfiguration: appConfiguration)
			setup()

			if LaunchArguments.familyMemberTest.fakeOverview.boolValue {
				coronaTests.value = createMockedTestsForOverview()
			} else {
				coronaTests.value = [mockPCRTest, mockAntigenTest].compactMap { $0 }
			}
			return
		}
		#endif

		self.client = client
		self.restServiceProvider = restServiceProvider
		self.store = store
		self.appConfiguration = appConfiguration
		self.healthCertificateService = healthCertificateService
		self.healthCertificateRequestService = healthCertificateRequestService
		self.ppacService = ppacService
		self.notificationCenter = notificationCenter
		self.recycleBin = recycleBin

		self.fakeRequestService = FakeRequestService(restServiceProvider: restServiceProvider, ppacService: ppacService, appConfiguration: appConfiguration)

		healthCertificateRequestService.didRegisterTestCertificate
			.sink { [weak self] certificateIdentifier, testCertificateRequest in
				self?.setUniqueCertificateIdentifier(certificateIdentifier, from: testCertificateRequest)
			}
			.store(in: &subscriptions)

		setup()
	}

	#if DEBUG

	convenience init(
		client: Client,
		store: CoronaTestStoring,
		appConfiguration: AppConfigurationProviding,
		healthCertificateService: HealthCertificateService,
		healthCertificateRequestService: HealthCertificateRequestService,
		ppacService: PrivacyPreservingAccessControl,
		notificationCenter: UserNotificationCenter = UNUserNotificationCenter.current(),
		recycleBin: RecycleBin
	) {
		self.init(
			client: client,
			restServiceProvider: .coronaTestServiceProvider,
			store: store,
			appConfiguration: appConfiguration,
			healthCertificateService: healthCertificateService,
			healthCertificateRequestService: healthCertificateRequestService,
			ppacService: ppacService,
			notificationCenter: notificationCenter,
			recycleBin: recycleBin
		)
	}

	#endif

	// MARK: - Protocol FamilyMemberCoronaTestServiceProviding

	var coronaTests = CurrentValueSubject<[FamilyMemberCoronaTest], Never>([])

	var unseenNewsCount: Int {
		coronaTests.value
			.filter { $0.hasUnseenNews }
			.count
	}

	func upToDateTest(for coronaTest: FamilyMemberCoronaTest) -> FamilyMemberCoronaTest? {
		coronaTests.value.first { $0.qrCodeHash == coronaTest.qrCodeHash }
	}
	
	func registerPCRTestAndGetResult(
		for displayName: String,
		guid: String,
		qrCodeHash: String,
		certificateConsent: TestCertificateConsent,
		completion: @escaping RegistrationResultHandler
	) {
		var certificateConsentGiven = false
		var dateOfBirthKey: String?
		if case let .given(givenDateOfBirth) = certificateConsent,
		   let dateOfBirthString = givenDateOfBirth,
		   let generatedDateOfBirthKey = hashedKey(dateOfBirthString: dateOfBirthString, guid: guid) {
			certificateConsentGiven = true
			dateOfBirthKey = generatedDateOfBirthKey
		}

		Log.info("[FamilyMemberCoronaTestService] Registering PCR test (guid: \(private: guid, public: "GUID ID"), certificateConsentGiven: \(certificateConsentGiven)), dateOfBirthKey: \(private: String(describing: dateOfBirthKey))", log: .api)

		getRegistrationToken(
			forKey: ENAHasher.sha256(guid),
			withType: .guid,
			dateOfBirthKey: dateOfBirthKey,
			completion: { [weak self] result in
				switch result {
				case .success(let registrationToken):
					let coronaTest: FamilyMemberCoronaTest = .pcr(
						FamilyMemberPCRTest(
							displayName: displayName,
							registrationDate: Date(),
							registrationToken: registrationToken,
							qrCodeHash: qrCodeHash,
							isNew: true,
							testResult: .pending,
							finalTestResultReceivedDate: nil,
							certificateSupportedByPointOfCare: true,
							certificateConsentGiven: certificateConsentGiven,
							certificateRequested: false,
							isLoading: false
						)
					)

					self?.coronaTests.value.append(coronaTest)

					Log.info("[FamilyMemberCoronaTestService] PCR test registered: \(private: coronaTest)", log: .api)

					self?.getTestResult(for: coronaTest, duringRegistration: true) { testResult in
						switch testResult {
						case .success:
							guard let updatedCoronaTest = self?.upToDateTest(for: coronaTest) else {
								completion(.failure(.noCoronaTestOfRequestedType))
								return
							}
							completion(.success(updatedCoronaTest))
						case .failure(let error):
							completion(.failure(error))
						}
					}
				case .failure(let error):
					Log.error("[FamilyMemberCoronaTestService] PCR test registration failed: \(error.localizedDescription)", log: .api)

					completion(.failure(error))

					self?.fakeRequestService.fakeVerificationAndSubmissionServerRequest()
				}
			}
		)
	}

	func registerAntigenTestAndGetResult(
		for displayName: String,
		with hash: String,
		qrCodeHash: String,
		pointOfCareConsentDate: Date,
		certificateSupportedByPointOfCare: Bool,
		certificateConsent: TestCertificateConsent,
		completion: @escaping RegistrationResultHandler
	) {
		Log.info("[FamilyMemberCoronaTestService] Registering antigen test (hash: \(private: hash), pointOfCareConsentDate: \(private: pointOfCareConsentDate)", log: .api)

		getRegistrationToken(
			forKey: ENAHasher.sha256(hash),
			withType: .guid,
			dateOfBirthKey: nil,
			completion: { [weak self] result in
				switch result {
				case .success(let registrationToken):
					var certificateConsentGiven = false
					if case .given = certificateConsent {
						certificateConsentGiven = true
					}

					let coronaTest: FamilyMemberCoronaTest = .antigen(
						FamilyMemberAntigenTest(
							displayName: displayName,
							pointOfCareConsentDate: pointOfCareConsentDate,
							registrationDate: Date(),
							registrationToken: registrationToken,
							qrCodeHash: qrCodeHash,
							isNew: true,
							testResult: .pending,
							finalTestResultReceivedDate: nil,
							certificateSupportedByPointOfCare: certificateSupportedByPointOfCare,
							certificateConsentGiven: certificateConsentGiven,
							certificateRequested: false,
							isOutdated: false,
							isLoading: false
						)
					)

					self?.coronaTests.value.append(coronaTest)

					Log.info("[FamilyMemberCoronaTestService] Antigen test registered: \(private: coronaTest)", log: .api)

					self?.getTestResult(for: coronaTest, duringRegistration: true) { testResult in
						self?.scheduleOutdatedStateTimer()
						switch testResult {
						case .success:
							guard let updatedCoronaTest = self?.upToDateTest(for: coronaTest) else {
								completion(.failure(.noCoronaTestOfRequestedType))
								return
							}
							completion(.success(updatedCoronaTest))
						case .failure(let error):
							completion(.failure(error))
						}
					}

					self?.fakeRequestService.fakeSubmissionServerRequest()
				case .failure(let error):
					Log.error("[FamilyMemberCoronaTestService] Antigen test registration failed: \(error.localizedDescription)", log: .api)

					completion(.failure(error))

					self?.fakeRequestService.fakeVerificationAndSubmissionServerRequest()
				}
			}
		)
	}
	
	func registerRapidPCRTestAndGetResult(
		for displayName: String,
		with hash: String,
		qrCodeHash: String,
		pointOfCareConsentDate: Date,
		certificateSupportedByPointOfCare: Bool,
		certificateConsent: TestCertificateConsent,
		completion: @escaping RegistrationResultHandler
	) {
		Log.info("[FamilyMemberCoronaTestService] Registering RapidPCR test (hash: \(private: hash), pointOfCareConsentDate: \(private: pointOfCareConsentDate))", log: .api)

		getRegistrationToken(
			forKey: ENAHasher.sha256(hash),
			withType: .guid,
			dateOfBirthKey: nil,
			completion: { [weak self] result in
				switch result {
				case .success(let registrationToken):
					var certificateConsentGiven = false
					if case .given = certificateConsent {
						certificateConsentGiven = true
					}

					let coronaTest: FamilyMemberCoronaTest = .pcr(
						FamilyMemberPCRTest(
							displayName: displayName,
							registrationDate: Date(),
							registrationToken: registrationToken,
							qrCodeHash: qrCodeHash,
							isNew: true,
							testResult: .pending,
							finalTestResultReceivedDate: nil,
							certificateSupportedByPointOfCare: certificateSupportedByPointOfCare,
							certificateConsentGiven: certificateConsentGiven,
							certificateRequested: false,
							isLoading: false
						)
					)

					self?.coronaTests.value.append(coronaTest)

					Log.info("[FamilyMemberCoronaTestService] RapidPCR test registered: \(private: coronaTest)", log: .api)

					self?.getTestResult(for: coronaTest, duringRegistration: true) { testResult in
						switch testResult {
						case .success:
							guard let updatedCoronaTest = self?.upToDateTest(for: coronaTest) else {
								completion(.failure(.noCoronaTestOfRequestedType))
								return
							}
							completion(.success(updatedCoronaTest))
						case .failure(let error):
							completion(.failure(error))
						}
					}

					self?.fakeRequestService.fakeSubmissionServerRequest()
				case .failure(let error):
					Log.error("[FamilyMemberCoronaTestService] RapidPCR test registration failed: \(error.localizedDescription)", log: .api)

					completion(.failure(error))

					self?.fakeRequestService.fakeVerificationAndSubmissionServerRequest()
				}
			}
		)
	}
	
	func reregister(coronaTest: FamilyMemberCoronaTest) {
		coronaTests.value.append(coronaTest)
	}

	func updateTestResults(presentNotification: Bool, completion: @escaping VoidResultHandler) {
		Log.info("[FamilyMemberCoronaTestService] Update all test results. presentNotification: \(presentNotification)", log: .api)

		let group = DispatchGroup()
		var errors = [CoronaTestServiceError]()

		for coronaTest in coronaTests.value {
			group.enter()
			Log.info("[FamilyMemberCoronaTestService] Dispatch group entered in updateTestResults for (coronaTest: \(private: coronaTest))")
			
			updateTestResult(for: coronaTest, presentNotification: presentNotification) { result in
				switch result {
				case .failure(let error):
					Log.error(error.localizedDescription, log: .api)
					errors.append(error)
				case .success:
					break
				}

				Log.info("[FamilyMemberCoronaTestService] Dispatch group exited in updateTestResults for (coronaTest: \(private: coronaTest))")
				group.leave()
			}
		}

		group.notify(queue: .main) {
			if let error = errors.first {
				completion(.failure(error))
			} else {
				completion(.success(()))
			}
		}
	}

	func updateTestResult(
		for coronaTest: FamilyMemberCoronaTest,
		presentNotification: Bool = false,
		completion: @escaping TestResultHandler
	) {
		Log.info("[FamilyMemberCoronaTestService] Updating test result (coronaTest: \(private: coronaTest)), presentNotification: \(presentNotification)", log: .api)

		getTestResult(for: coronaTest, duringRegistration: false, presentNotification: presentNotification) { [weak self] result in
			Log.info("[FamilyMemberCoronaTestService] Received test result from getTestResult: \(private: result)")
			
			guard let self = self else {
				completion(result)
				Log.warning("[FamilyMemberCoronaTestService] Could not get self, skipping fakeRequestService call")
				return
			}

			self.fakeRequestService.fakeVerificationAndSubmissionServerRequest {
				completion(result)
			}
		}
	}

	func moveAllTestsToBin() {
		for coronaTest in coronaTests.value {
			moveTestToBin(coronaTest)
		}
	}

	func moveTestToBin(_ coronaTest: FamilyMemberCoronaTest) {
		Log.info("[FamilyMemberCoronaTestService] Moving test to bin (coronaTest: \(private: coronaTest)", log: .api)

		recycleBin.moveToBin(.familyMemberCoronaTest(coronaTest))

		removeTest(coronaTest)
	}

	func removeTest(_ coronaTest: FamilyMemberCoronaTest) {
		guard let index = coronaTests.value.firstIndex(where: { $0.qrCodeHash == coronaTest.qrCodeHash }) else {
			return
		}

		coronaTests.value.remove(at: index)
	}

	func evaluateShowing(of coronaTest: FamilyMemberCoronaTest, keepMarkedAsNew: Bool) {
		Log.info("[FamilyMemberCoronaTestService] Evaluating showing test (coronaTest: \(private: coronaTest))", log: .api)

		guard let updatedCoronaTest = upToDateTest(for: coronaTest) else {
			return
		}

		let wasNew = updatedCoronaTest.isNew

		coronaTests.value.modify(coronaTest) {
			$0.isNew = wasNew ? keepMarkedAsNew : false
			$0.testResultIsNew = false
		}
	}

	func evaluateShowingAllTests() {
		Log.info("[FamilyMemberCoronaTestService] Evaluating showing all tests", log: .api)

		coronaTests.value.forEach {
			evaluateShowing(of: $0, keepMarkedAsNew: false)
		}
	}

	func updatePublishersFromStore() {
		Log.info("[FamilyMemberCoronaTestService] Updating publishers from store", log: .api)

		if coronaTests.value != store.familyMemberTests {
			coronaTests.value = store.familyMemberTests

			Log.info("[FamilyMemberCoronaTestService] Family member tests updated from store", log: .api)
		}
	}
	
	func healthCertificateTuple(for uniqueCertificateIdentifier: String) -> (certificate: HealthCertificate, certifiedPerson: HealthCertifiedPerson)? {
		var healthTuple: (certificate: HealthCertificate, certifiedPerson: HealthCertifiedPerson)?

		self.healthCertificateService.healthCertifiedPersons.forEach { healthCertifiedPerson in
			healthCertifiedPerson.healthCertificates.forEach { healthCertificate in
				if healthCertificate.uniqueCertificateIdentifier == uniqueCertificateIdentifier {
					healthTuple = (certificate: healthCertificate, certifiedPerson: healthCertifiedPerson)
				}
			}
		}

		return healthTuple
	}
	
	// MARK: - Private

	private let client: Client
	private let restServiceProvider: RestServiceProviding
	private var store: CoronaTestStoring
	private let appConfiguration: AppConfigurationProviding
	private let healthCertificateService: HealthCertificateService
	private let healthCertificateRequestService: HealthCertificateRequestService
	private let notificationCenter: UserNotificationCenter
	private let recycleBin: RecycleBin
	private let serialQueue = AsyncOperation.serialQueue(named: "FamilyMemberCoronaTestService.serialQueue")

	private let ppacService: PrivacyPreservingAccessControl
	private let fakeRequestService: FakeRequestService

	private var outdatedStateTimer: Timer?

	private var subscriptions = Set<AnyCancellable>()

	private var nextOutdatedStateUpdateDate: Date? {
		let hoursToDeemTestOutdated = appConfiguration.currentAppConfig.value
			.coronaTestParameters.coronaRapidAntigenTestParameters.hoursToDeemTestOutdated

		guard hoursToDeemTestOutdated != 0 else {
			return nil
		}

		return coronaTests.value
			.compactMap { $0.antigenTest }
			.filter { $0.testResult == .negative && !$0.isOutdated }
			.compactMap {
				Calendar.current
					.date(byAdding: .hour, value: Int(hoursToDeemTestOutdated), to: $0.testDate)
			}
			.sorted { $0 < $1 }
			.min()
	}

	private func setup() {
		updatePublishersFromStore()

		coronaTests
			.sink { [weak self] coronaTests in
				self?.store.familyMemberTests = coronaTests
			}
			.store(in: &subscriptions)

		scheduleOutdatedStateTimer()
	}

	// internal for testing
	func getRegistrationToken(
		forKey key: String,
		withType type: KeyType,
		dateOfBirthKey: String?,
		completion: @escaping RegistrationTokenResultHandler
	) {
		// Check if first char of dateOfBirthKey is a lower cased "x". If not, we fail because it is malformed. If dateOfBirthKey is nil, we pass this check.
		if let dateOfBirthKey = dateOfBirthKey {
			guard dateOfBirthKey.first == "x" else {
				completion(.failure(.malformedDateOfBirthKey))
				return
			}
		}

		let resource = TeleTanResource(
			sendModel: TeleTanSendModel(
				key: key,
				keyType: type,
				keyDob: dateOfBirthKey
			)
		)

		restServiceProvider.load(resource) { result in
			switch result {
			case .success(let model):
				completion(.success(model.registrationToken))
			case .failure(let error):
				completion(.failure(.teleTanError(error)))
			}
		}
	}

	private func hashedKey(dateOfBirthString: String, guid: String) -> String? {
		guard let dateOfBirth = ISO8601DateFormatter.justUTCDateFormatter.date(from: dateOfBirthString) else {
			return nil
		}

		let dateFormatter = DateFormatter()
		dateFormatter.timeZone = .utcTimeZone
		dateFormatter.dateFormat = "ddMMyyyy"
		let dateOfBirthString = dateFormatter.string(from: dateOfBirth)

		return "x\(ENAHasher.sha256("\(guid)\(dateOfBirthString)").dropFirst())"
	}

	// swiftlint:disable:next cyclomatic_complexity
	private func getTestResult(
		for coronaTest: FamilyMemberCoronaTest,
		duringRegistration: Bool,
		presentNotification: Bool = false,
		_ completion: @escaping TestResultHandler
	) {
		Log.info("[FamilyMemberCoronaTestService] Getting test result (coronaTest: \(private: coronaTest), duringRegistration: \(duringRegistration))", log: .api)

		guard upToDateTest(for: coronaTest) != nil else {
			Log.error("[CoronaTestService] Getting test result failed: No corona test of requested type", log: .api)

			completion(.failure(.noCoronaTestOfRequestedType))
			return
		}

		guard let registrationToken = coronaTest.registrationToken else {
			Log.error("[FamilyMemberCoronaTestService] Getting test result failed: No registration token", log: .api)

			completion(.failure(.noRegistrationToken))
			return
		}

		guard coronaTest.finalTestResultReceivedDate == nil else {
			Log.info("[FamilyMemberCoronaTestService] Get test result completed early because final test result is present.", log: .api)
			completion(.success(coronaTest.testResult))
			return
		}

		let registrationDate = coronaTest.registrationDate
		let ageInDays = Calendar.current.dateComponents([.day], from: registrationDate, to: Date()).day ?? 0

		guard coronaTest.testResult != .expired || ageInDays < 21 else {
			Log.error("[FamilyMemberCoronaTestService] Expired test result older than 21 days returned", log: .api)

			completion(.success(coronaTest.testResult))
			return
		}

		coronaTests.value.modify(coronaTest) {
			$0.isLoading = true
		}
		
		let operation = CoronaTestResultOperation(restService: restServiceProvider, registrationToken: registrationToken) { [weak self] result in
			guard let self = self else { return }

			self.coronaTests.value.modify(coronaTest) {
				$0.isLoading = false
			}

			#if DEBUG
			if isUITesting {
				completion(
					self.mockTestResult(for: coronaTest.type).flatMap { .success($0) } ??
						.failure(.noCoronaTestOfRequestedType)
				)

				return
			}
			#endif

			switch result {
			case let .failure(error):
				Log.error("[FamilyMemberCoronaTestService] Getting test result failed: \(error.localizedDescription)", log: .api)

				// For error .qrDoesNotExist we set the test result to expired
				if case let .receivedResourceError(ressourceError) = error, ressourceError == .qrDoesNotExist {
					Log.info("[FamilyMemberCoronaTestService] Error Code 400 when getting test result, setting expired test result", log: .api)

					self.coronaTests.value.modify(coronaTest) {
						$0.testResult = .expired
					}

					// For tests older than 21 days this should not be handled as an error
					if ageInDays >= 21 {
						Log.info("[FamilyMemberCoronaTestService] Test older than 21 days, no error is returned", log: .api)

						completion(.success(.expired))
					} else {
						Log.error("[FamilyMemberCoronaTestService] Test younger than 21 days, error is returned", log: .api)

						completion(.failure(.testResultError(error)))
					}
				} else {
					completion(.failure(.testResultError(error)))
				}
			case let .success(response):
				let testResult = TestResult(serverResponse: response.testResult, coronaTestType: coronaTest.type)

				Log.info("[FamilyMemberCoronaTestService] Got test result (coronaTest: \(private: coronaTest), testResult: \(testResult)), sampleCollectionDate: \(String(describing: response.sc))", log: .api)

				let previousTestResult = self.upToDateTest(for: coronaTest)?.testResult

				self.coronaTests.value.modify(coronaTest) {
					$0.testResult = testResult
					$0.sampleCollectionDate = response.sc.map {
						Date(timeIntervalSince1970: TimeInterval($0))
					}
				}

				switch testResult {
				case .positive, .negative, .invalid:
					if self.coronaTests.value.first(where: { $0.qrCodeHash == coronaTest.qrCodeHash })?.finalTestResultReceivedDate == nil {
						// For family member corona tests `.invalid` results should not prevent polling as there is no `force` mode to update tests that already have a result and `.invalid` results can potentially change.
						if testResult == .negative || testResult == .positive {
							self.coronaTests.value.modify(coronaTest) {
								$0.finalTestResultReceivedDate = Date()
							}
						}
						
						if testResult != previousTestResult {
							self.coronaTests.value.modify(coronaTest) {
								$0.testResultIsNew = true
							}
						}

						if testResult == .negative && coronaTest.certificateConsentGiven && !coronaTest.certificateRequested {
							self.healthCertificateRequestService.registerAndExecuteTestCertificateRequest(
								coronaTestType: coronaTest.type,
								registrationToken: registrationToken,
								registrationDate: registrationDate,
								retryExecutionIfCertificateIsPending: true,
								labId: response.labId
							)

							self.coronaTests.value.modify(coronaTest) {
								$0.certificateRequested = true
							}
						}

						if presentNotification && testResult != previousTestResult {
							Log.info("[FamilyMemberCoronaTestService] Triggering Notification (coronaTest: \(private: coronaTest), testResult: \(testResult))", log: .api)

							// We attach the test result and type to determine which screen to show when user taps the notification
							self.notificationCenter.presentNotification(
								title: AppStrings.LocalNotifications.testResultsTitle,
								body: AppStrings.LocalNotifications.testResultsBody,
								identifier: ActionableNotificationIdentifier.familyTestResult.identifier
							)
						}
					}

					completion(.success(testResult))
				case .pending:
					completion(.success(testResult))
				case .expired:
					if duringRegistration {
						// The .expired status is only known after the test has been registered on the server
						// so we generate an error here, even if the server returned the http result 201
						completion(.failure(.testExpired))
					} else {
						completion(.success(testResult))
					}
				}
			}
		}

		serialQueue.addOperation(operation)
	}

	private func setUniqueCertificateIdentifier(_ uniqueCertificateIdentifier: String, from testCertificateRequest: TestCertificateRequest) {
		coronaTests.value.forEach {
			if $0.registrationToken == testCertificateRequest.registrationToken {
				coronaTests.value.modify($0) {
					$0.uniqueCertificateIdentifier = uniqueCertificateIdentifier
				}
			}
		}
	}

	private func scheduleOutdatedStateTimer() {
		outdatedStateTimer?.invalidate()
		NotificationCenter.default.removeObserver(self, name: UIApplication.didEnterBackgroundNotification, object: nil)
		NotificationCenter.default.removeObserver(self, name: UIApplication.didBecomeActiveNotification, object: nil)

		guard let nextOutdatedStateUpdateDate = nextOutdatedStateUpdateDate else {
			return
		}

		guard nextOutdatedStateUpdateDate > Date() else {
			updateOutdatedStates()
			return
		}

		// Schedule new timer.
		NotificationCenter.default.addObserver(self, selector: #selector(invalidateTimer), name: UIApplication.didEnterBackgroundNotification, object: nil)
		NotificationCenter.default.addObserver(self, selector: #selector(refreshUpdateTimerAfterResumingFromBackground), name: UIApplication.didBecomeActiveNotification, object: nil)

		outdatedStateTimer = Timer(fireAt: nextOutdatedStateUpdateDate, interval: 0, target: self, selector: #selector(updateOutdatedStates), userInfo: nil, repeats: false)

		guard let outdatedStateTimer = outdatedStateTimer else { return }
		RunLoop.current.add(outdatedStateTimer, forMode: .common)
	}

	@objc
	private func invalidateTimer() {
		outdatedStateTimer?.invalidate()
	}

	@objc
	private func refreshUpdateTimerAfterResumingFromBackground() {
		updateOutdatedStates()
		scheduleOutdatedStateTimer()
	}

	@objc
	private func updateOutdatedStates() {
		for coronaTest in coronaTests.value {
			updateOutdatedState(for: coronaTest)
		}

		scheduleOutdatedStateTimer()
	}

	private func updateOutdatedState(for coronaTest: FamilyMemberCoronaTest) {
		let hoursToDeemTestOutdated = appConfiguration.currentAppConfig.value
			.coronaTestParameters.coronaRapidAntigenTestParameters.hoursToDeemTestOutdated

		// Only rapid antigen tests with a negative test result can become outdated
		guard coronaTest.type == .antigen,
			  coronaTest.testResult == .negative,
			  hoursToDeemTestOutdated != 0,
			  let outdatedDate = Calendar.current.date(byAdding: .hour, value: Int(hoursToDeemTestOutdated), to: coronaTest.testDate) else {
			if coronaTest.isOutdated {
				coronaTests.value.modify(coronaTest) {
					$0.isOutdated = false
				}
			}

			return
		}

		let isOutdated = Date() >= outdatedDate
		if coronaTest.isOutdated != isOutdated {
			coronaTests.value.modify(coronaTest) {
				$0.isOutdated = isOutdated
			}
		}
	}

	#if DEBUG

	private var mockPCRTest: FamilyMemberCoronaTest? {
		if let testResult = mockTestResult(for: .pcr) {
			return .pcr(
				FamilyMemberPCRTest(
					displayName: "Anni",
					registrationDate: Date(),
					registrationToken: "asdf",
					qrCodeHash: "mockPCRQRCodeHash",
					isNew: false,
					testResult: testResult,
					finalTestResultReceivedDate: testResult == .pending ? nil : Date(),
					certificateSupportedByPointOfCare: true,
					certificateConsentGiven: false,
					certificateRequested: false,
					isLoading: false
				)
			)
		} else {
			return nil
		}
	}

	private var mockAntigenTest: FamilyMemberCoronaTest? {
		if let testResult = mockTestResult(for: .antigen) {
			return .antigen(
				FamilyMemberAntigenTest(
					displayName: "Paul",
					pointOfCareConsentDate: Date(),
					registrationDate: Date(),
					registrationToken: "zxcv",
					qrCodeHash: "mockAntigenQRCodeHash",
					isNew: false,
					testResult: testResult,
					finalTestResultReceivedDate: testResult == .pending ? nil : Date(),
					certificateSupportedByPointOfCare: false,
					certificateConsentGiven: false,
					certificateRequested: false,
					isOutdated: false,
					isLoading: false
				)
			)
		} else {
			return nil
		}
	}

	private func mockTestResult(for coronaTestType: CoronaTestType) -> TestResult? {
		switch coronaTestType {
		case .pcr:
			return LaunchArguments.familyMemberTest.pcr.testResult.stringValue.flatMap { TestResult(stringValue: $0, coronaTestType: .pcr) }
		case .antigen:
			return LaunchArguments.familyMemberTest.antigen.testResult.stringValue.flatMap { TestResult(stringValue: $0, coronaTestType: .antigen) }
		}
	}

	func mockHealthCertificateTuple() -> (certificate: HealthCertificate, certifiedPerson: HealthCertifiedPerson)? {
		guard let certificate = self.healthCertificateService.healthCertifiedPersons[0].testCertificates.first else { return nil }
		let certifiedPerson = self.healthCertificateService.healthCertifiedPersons[0]
		
		return (certificate: certificate, certifiedPerson: certifiedPerson)
	}

	func createMockedTestsForOverview() -> [FamilyMemberCoronaTest] {
		var familyTests: [FamilyMemberCoronaTest] = []

		familyTests.append(.antigen(FamilyMemberAntigenTest(
			displayName: "Lara",
			pointOfCareConsentDate: Date(timeIntervalSince1970: 1646588028),
			registrationDate: Date(timeIntervalSince1970: 1646588028),
			registrationToken: "1",
			qrCodeHash: "mockAntigenQRCodeHash1",
			isNew: true,
			testResult: TestResult.pending,
			finalTestResultReceivedDate: nil,
			certificateSupportedByPointOfCare: false,
			certificateConsentGiven: false,
			certificateRequested: false,
			isOutdated: false,
			isLoading: false
		)))
		familyTests.append(.antigen(FamilyMemberAntigenTest(
			displayName: "Olga",
			pointOfCareConsentDate: Date(timeIntervalSince1970: 1646588027),
			registrationDate: Date(timeIntervalSince1970: 1646588027),
			registrationToken: "2",
			qrCodeHash: "mockAntigenQRCodeHash2",
			isNew: false,
			testResult: TestResult.negative,
			finalTestResultReceivedDate: nil,
			certificateSupportedByPointOfCare: false,
			certificateConsentGiven: false,
			certificateRequested: false,
			isOutdated: false,
			isLoading: false
		)))
		familyTests.append(.antigen(FamilyMemberAntigenTest(
			displayName: "Aaron",
			pointOfCareConsentDate: Date(timeIntervalSince1970: 1646588026),
			registrationDate: Date(timeIntervalSince1970: 1646588026),
			registrationToken: "4",
			qrCodeHash: "mockAntigenQRCodeHash3",
			isNew: false,
			testResult: TestResult.positive,
			finalTestResultReceivedDate: nil,
			certificateSupportedByPointOfCare: false,
			certificateConsentGiven: false,
			certificateRequested: false,
			isOutdated: false,
			isLoading: false
		)))
		familyTests.append(.pcr(FamilyMemberPCRTest(
			displayName: "Olga",
			registrationDate: Date(timeIntervalSince1970: 1634315507),
			registrationToken: "3",
			qrCodeHash: "mockPCRQRCodeHash1",
			isNew: false,
			testResult: .positive,
			finalTestResultReceivedDate: nil,
			certificateSupportedByPointOfCare: false,
			certificateConsentGiven: false,
			certificateRequested: false,
			uniqueCertificateIdentifier: nil,
			isLoading: false
		)))
		familyTests.sort(by: { $0.registrationDate > $1.registrationDate })
		return familyTests
	}

	#endif

}

private extension Array where Element == FamilyMemberCoronaTest {

	mutating func modify(
		_ coronaTest: FamilyMemberCoronaTest,
		_ modifyElement: (inout FamilyMemberCoronaTest) -> Void
	) {
		guard let index = firstIndex(where: { $0.qrCodeHash == coronaTest.qrCodeHash }) else {
			return
		}

		var coronaTest = self[index]
		modifyElement(&coronaTest)
		self[index] = coronaTest
	}

	// swiftlint:disable:next file_length
}
