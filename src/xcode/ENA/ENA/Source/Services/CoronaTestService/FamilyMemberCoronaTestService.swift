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
		notificationCenter: UserNotificationCenter = UNUserNotificationCenter.current(),
		recycleBin: RecycleBin,
		badgeWrapper: HomeBadgeWrapper
	) {
		#if DEBUG
		if isUITesting {
			self.client = ClientMock()
			if LaunchArguments.exposureSubmission.isFetchingSubmissionTan.boolValue {
				self.restServiceProvider = .exposureSubmissionServiceProvider
			} else {
				self.restServiceProvider = .coronaTestServiceProvider
			}
			self.store = MockTestStore()
			self.appConfiguration = CachedAppConfigurationMock()

			self.healthCertificateService = healthCertificateService
			self.healthCertificateRequestService = healthCertificateRequestService
			self.notificationCenter = notificationCenter
			self.recycleBin = recycleBin
			self.badgeWrapper = badgeWrapper

			self.fakeRequestService = FakeRequestService(client: client, restServiceProvider: restServiceProvider)

			setup()

			coronaTests.value = [mockPCRTest, mockAntigenTest].compactMap { $0 }

			return
		}
		#endif

		self.client = client
		self.restServiceProvider = restServiceProvider
		self.store = store
		self.appConfiguration = appConfiguration
		self.healthCertificateService = healthCertificateService
		self.healthCertificateRequestService = healthCertificateRequestService
		self.notificationCenter = notificationCenter
		self.recycleBin = recycleBin
		self.badgeWrapper = badgeWrapper

		self.fakeRequestService = FakeRequestService(client: client, restServiceProvider: restServiceProvider)

		// TODO: Won't work if both services register the same closure
		healthCertificateRequestService.didRegisterTestCertificate = setUniqueCertificateIdentifier

		setup()
	}

	#if DEBUG

	convenience init(
		client: Client,
		store: CoronaTestStoring,
		eventStore: EventStoringProviding,
		diaryStore: DiaryStoring,
		appConfiguration: AppConfigurationProviding,
		healthCertificateService: HealthCertificateService,
		healthCertificateRequestService: HealthCertificateRequestService,
		notificationCenter: UserNotificationCenter = UNUserNotificationCenter.current(),
		recycleBin: RecycleBin,
		badgeWrapper: HomeBadgeWrapper
	) {
		self.init(
			client: client,
			restServiceProvider: .coronaTestServiceProvider,
			store: store,
			appConfiguration: appConfiguration,
			healthCertificateService: healthCertificateService,
			healthCertificateRequestService: healthCertificateRequestService,
			notificationCenter: notificationCenter,
			recycleBin: recycleBin,
			badgeWrapper: badgeWrapper
		)
	}

	#endif

	// MARK: - Protocol FamilyMemberCoronaTestServiceProviding

	var coronaTests = CurrentValueSubject<[FamilyMemberCoronaTest], Never>([])
	
	// This function is responsible to register a PCR test from QR Code
	func registerPCRTestAndGetResult(
		for displayName: String,
		guid: String,
		qrCodeHash: String,
		isSubmissionConsentGiven: Bool,
		certificateConsent: TestCertificateConsent,
		completion: @escaping TestResultHandler
	) {
		var certificateConsentGiven = false
		var dateOfBirthKey: String?
		if case let .given(givenDateOfBirth) = certificateConsent,
		   let dateOfBirthString = givenDateOfBirth,
		   let generatedDateOfBirthKey = hashedKey(dateOfBirthString: dateOfBirthString, guid: guid) {
			certificateConsentGiven = true
			dateOfBirthKey = generatedDateOfBirthKey
		}

		Log.info("[CoronaTestService] Registering PCR test (guid: \(private: guid, public: "GUID ID"), isSubmissionConsentGiven: \(isSubmissionConsentGiven), certificateConsentGiven: \(certificateConsentGiven)), dateOfBirthKey: \(private: String(describing: dateOfBirthKey))", log: .api)

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
							testResultWasShown: false,
							certificateSupportedByPointOfCare: true,
							certificateConsentGiven: certificateConsentGiven,
							certificateRequested: false,
							isLoading: false
						)
					)

					self?.coronaTests.value.append(coronaTest)

					Log.info("[CoronaTestService] PCR test registered: \(private: coronaTest)", log: .api)

					self?.getTestResult(for: coronaTest, duringRegistration: true) { result in
						completion(result)
					}
				case .failure(let error):
					Log.error("[CoronaTestService] PCR test registration failed: \(error.localizedDescription)", log: .api)

					completion(.failure(error))

					self?.fakeRequestService.fakeVerificationAndSubmissionServerRequest()
				}
			}
		)
	}

	// swiftlint:disable:next function_parameter_count
	func registerAntigenTestAndGetResult(
		for displayName: String,
		with hash: String,
		qrCodeHash: String,
		pointOfCareConsentDate: Date,
		isSubmissionConsentGiven: Bool,
		certificateSupportedByPointOfCare: Bool,
		certificateConsent: TestCertificateConsent,
		completion: @escaping TestResultHandler
	) {
		Log.info("[CoronaTestService] Registering antigen test (hash: \(private: hash), pointOfCareConsentDate: \(private: pointOfCareConsentDate)", log: .api)

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
							testResultWasShown: false,
							certificateSupportedByPointOfCare: certificateSupportedByPointOfCare,
							certificateConsentGiven: certificateConsentGiven,
							certificateRequested: false,
							isLoading: false
						)
					)

					self?.coronaTests.value.append(coronaTest)

					Log.info("[CoronaTestService] Antigen test registered: \(private: coronaTest)", log: .api)

					self?.getTestResult(for: coronaTest, duringRegistration: true) { result in
						completion(result)
					}

					self?.fakeRequestService.fakeSubmissionServerRequest()
				case .failure(let error):
					Log.error("[CoronaTestService] Antigen test registration failed: \(error.localizedDescription)", log: .api)

					completion(.failure(error))

					self?.fakeRequestService.fakeVerificationAndSubmissionServerRequest()
				}
			}
		)
	}
	
	// swiftlint:disable:next function_parameter_count
	func registerRapidPCRTestAndGetResult(
		for displayName: String,
		with hash: String,
		qrCodeHash: String,
		pointOfCareConsentDate: Date,
		isSubmissionConsentGiven: Bool,
		certificateSupportedByPointOfCare: Bool,
		certificateConsent: TestCertificateConsent,
		completion: @escaping TestResultHandler
	) {
		Log.info("[CoronaTestService] Registering RapidPCR test (hash: \(private: hash), pointOfCareConsentDate: \(private: pointOfCareConsentDate), isSubmissionConsentGiven: \(isSubmissionConsentGiven))", log: .api)

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
							testResultWasShown: false,
							certificateSupportedByPointOfCare: certificateSupportedByPointOfCare,
							certificateConsentGiven: certificateConsentGiven,
							certificateRequested: false,
							isLoading: false
						)
					)

					self?.coronaTests.value.append(coronaTest)

					Log.info("[CoronaTestService] RapidPCR test registered: \(private: coronaTest)", log: .api)

					self?.getTestResult(for: coronaTest, duringRegistration: true) { result in
						completion(result)
					}

					self?.fakeRequestService.fakeSubmissionServerRequest()
				case .failure(let error):
					Log.error("[CoronaTestService] RapidPCR test registration failed: \(error.localizedDescription)", log: .api)

					completion(.failure(error))

					self?.fakeRequestService.fakeVerificationAndSubmissionServerRequest()
				}
			}
		)
	}
	
	func reregister(coronaTest: FamilyMemberCoronaTest) {
		coronaTests.value.append(coronaTest)
	}

	func updateTestResults(force: Bool = true, presentNotification: Bool, completion: @escaping VoidResultHandler) {
		Log.info("[CoronaTestService] Update all test results. force: \(force), presentNotification: \(presentNotification)", log: .api)

		let group = DispatchGroup()
		var errors = [CoronaTestServiceError]()

		for coronaTest in coronaTests.value {
			group.enter()
			Log.info("[CoronaTestService] Dispatch group entered in updateTestResults for (coronaTest: \(private: coronaTest))")
			
			updateTestResult(for: coronaTest, force: force, presentNotification: presentNotification) { result in
				switch result {
				case .failure(let error):
					Log.error(error.localizedDescription, log: .api)
					errors.append(error)
				case .success:
					break
				}

				Log.info("[CoronaTestService] Dispatch group exited in updateTestResults for (coronaTest: \(private: coronaTest))")
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
		force: Bool = true,
		presentNotification: Bool = false,
		completion: @escaping TestResultHandler
	) {
		Log.info("[CoronaTestService] Updating test result (coronaTest: \(private: coronaTest)), force: \(force), presentNotification: \(presentNotification)", log: .api)

		getTestResult(for: coronaTest, force: force, duringRegistration: false, presentNotification: presentNotification) { [weak self] result in
			Log.info("[CoronaTestService] Received test result from getTestResult: \(private: result)")
			
			guard let self = self else {
				completion(result)
				Log.warning("[CoronaTestService] Could not get self, skipping fakeRequestService call")
				return
			}

			self.fakeRequestService.fakeVerificationAndSubmissionServerRequest {
				completion(result)
			}
		}
	}

	func moveTestToBin(_ coronaTest: FamilyMemberCoronaTest) {
		Log.info("[CoronaTestService] Moving test to bin (coronaTest: \(private: coronaTest)", log: .api)

		recycleBin.moveToBin(.familyMemberCoronaTest(coronaTest))

		removeTest(coronaTest)
	}

	func removeTest(_ coronaTest: FamilyMemberCoronaTest) {
		guard let index = coronaTests.value.firstIndex(where: { $0.qrCodeHash == coronaTest.qrCodeHash }) else {
			return
		}

		coronaTests.value.remove(at: index)
	}

	func evaluateShowing(of coronaTest: FamilyMemberCoronaTest) {
		Log.info("[CoronaTestService] Evaluating showing test (coronaTest: \(private: coronaTest))", log: .api)

		coronaTests.value.modify(coronaTest) {
			$0.testResultWasShown = true
		}
	}

	func updatePublishersFromStore() {
		Log.info("[CoronaTestService] Updating publishers from store", log: .api)

		if coronaTests.value != store.familyMemberTests {
			coronaTests.value = store.familyMemberTests

			Log.info("[CoronaTestService] Family member tests updated from store", log: .api)
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
	private let badgeWrapper: HomeBadgeWrapper
	private let serialQueue = AsyncOperation.serialQueue(named: "CoronaTestService.serialQueue")

	private let fakeRequestService: FakeRequestService

	private var outdatedStateTimer: Timer?

	private var subscriptions = Set<AnyCancellable>()

	private func setup() {
		updatePublishersFromStore()

		coronaTests
			.sink { [weak self] coronaTests in
				self?.store.familyMemberTests = coronaTests
			}
			.store(in: &subscriptions)
	}

	// internal for testing
	func getRegistrationToken(
		forKey key: String,
		withType type: KeyType,
		dateOfBirthKey: String?,
		completion: @escaping RegistrationResultHandler
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

	private func getTestResult(
		for coronaTest: FamilyMemberCoronaTest,
		force: Bool = true,
		duringRegistration: Bool,
		presentNotification: Bool = false,
		_ completion: @escaping TestResultHandler
	) {
		Log.info("[CoronaTestService] Getting test result (coronaTest: \(private: coronaTest), duringRegistration: \(duringRegistration))", log: .api)

		guard let registrationToken = coronaTest.registrationToken else {
			Log.error("[CoronaTestService] Getting test result failed: No registration token", log: .api)

			completion(.failure(.noRegistrationToken))
			return
		}

		guard force || coronaTest.finalTestResultReceivedDate == nil else {
			Log.info("[CoronaTestService] Get test result completed early because final test result is present.", log: .api)
			completion(.success(coronaTest.testResult))
			return
		}

		let registrationDate = coronaTest.registrationDate ?? coronaTest.testDate
		let ageInDays = Calendar.current.dateComponents([.day], from: registrationDate, to: Date()).day ?? 0

		guard coronaTest.testResult != .expired || ageInDays < 21 else {
			Log.error("[CoronaTestService] Expired test result older than 21 days returned", log: .api)

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
				Log.error("[CoronaTestService] Getting test result failed: \(error.localizedDescription)", log: .api)

				// For error .qrDoesNotExist we set the test result to expired
				if case let .receivedResourceError(ressourceError) = error, ressourceError == .qrDoesNotExist {
					Log.info("[CoronaTestService] Error Code 400 when getting test result, setting expired test result", log: .api)

					self.coronaTests.value.modify(coronaTest) {
						$0.testResult = .expired
					}

					// For tests older than 21 days this should not be handled as an error
					if ageInDays >= 21 {
						Log.info("[CoronaTestService] Test older than 21 days, no error is returned", log: .api)

						completion(.success(.expired))
					} else {
						Log.error("[CoronaTestService] Test younger than 21 days, error is returned", log: .api)

						completion(.failure(.testResultError(error)))
					}
				} else {
					completion(.failure(.testResultError(error)))
				}
			case let .success(response):
				let testResult = TestResult(serverResponse: response.testResult, coronaTestType: coronaTest.type)

				Log.info("[CoronaTestService] Got test result (coronaTest: \(private: coronaTest), testResult: \(testResult)), sampleCollectionDate: \(String(describing: response.sc))", log: .api)

				self.coronaTests.value.modify(coronaTest) {
					$0.testResult = testResult
					$0.sampleCollectionDate = response.sc.map {
						Date(timeIntervalSince1970: TimeInterval($0))
					}
				}

				switch testResult {
				case .positive, .negative, .invalid:
					if self.coronaTests.value.first(where: { $0.qrCodeHash == coronaTest.qrCodeHash })?.finalTestResultReceivedDate == nil {
						self.coronaTests.value.modify(coronaTest) {
							$0.finalTestResultReceivedDate = Date()
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

						if presentNotification {
							Log.info("[CoronaTestService] Triggering Notification (coronaTest: \(private: coronaTest), testResult: \(testResult))", log: .api)

							// We attach the test result and type to determine which screen to show when user taps the notification
							self.notificationCenter.presentNotification(
								title: AppStrings.LocalNotifications.testResultsTitle,
								body: AppStrings.LocalNotifications.testResultsBody,
								identifier: ActionableNotificationIdentifier.testResult.identifier,
								info: [
									ActionableNotificationIdentifier.testResult.identifier: testResult.rawValue,
									ActionableNotificationIdentifier.familyTestResultTestIdentifier.identifier: coronaTest.qrCodeHash
								]
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
					testResultWasShown: LaunchArguments.test.pcr.positiveTestResultWasShown.boolValue,
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
					testResultWasShown: true,
					certificateSupportedByPointOfCare: false,
					certificateConsentGiven: false,
					certificateRequested: false,
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
			return LaunchArguments.test.pcr.testResult.stringValue.flatMap { TestResult(stringValue: $0, coronaTestType: .pcr) }
		case .antigen:
			return LaunchArguments.test.antigen.testResult.stringValue.flatMap { TestResult(stringValue: $0, coronaTestType: .antigen) }
		}
	}

	func mockHealthCertificateTuple() -> (certificate: HealthCertificate, certifiedPerson: HealthCertifiedPerson)? {
		guard let certificate = self.healthCertificateService.healthCertifiedPersons[0].testCertificates.first else { return nil }
		let certifiedPerson = self.healthCertificateService.healthCertifiedPersons[0]
		
		return (certificate: certificate, certifiedPerson: certifiedPerson)
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
