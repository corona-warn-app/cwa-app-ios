////
// 🦠 Corona-Warn-App
//

import Foundation
import OpenCombine
import UIKit

// swiftlint:disable:next type_body_length
class CoronaTestService {

	typealias VoidResultHandler = (Result<Void, CoronaTestServiceError>) -> Void
	typealias RegistrationResultHandler = (Result<String, CoronaTestServiceError>) -> Void
	typealias TestResultHandler = (Result<TestResult, CoronaTestServiceError>) -> Void
	typealias CoronaTestHandler = (Result<CoronaTest, CoronaTestServiceError>) -> Void
	typealias SubmissionTANResultHandler = (Result<String, CoronaTestServiceError>) -> Void

	// MARK: - Init

	init(
		client: Client,
		store: CoronaTestStoring & CoronaTestStoringLegacy & WarnOthersTimeIntervalStoring,
		appConfiguration: AppConfigurationProviding,
		notificationCenter: UserNotificationCenter = UNUserNotificationCenter.current()
	) {
		#if DEBUG
		if isUITesting {
			self.client = ClientMock()
			self.store = MockTestStore()
			self.appConfiguration = CachedAppConfigurationMock()

			self.notificationCenter = notificationCenter

			self.fakeRequestService = FakeRequestService(client: client)
			self.warnOthersReminder = WarnOthersReminder(store: store)

			setup()

			pcrTest = mockPCRTest
			antigenTest = mockAntigenTest

			return
		}
		#endif

		self.client = client
		self.store = store
		self.appConfiguration = appConfiguration

		self.notificationCenter = notificationCenter

		self.fakeRequestService = FakeRequestService(client: client)
		self.warnOthersReminder = WarnOthersReminder(store: store)

		setup()
	}

	// MARK: - Protocol CoronaTestServiceProviding

	@DidSetPublished var pcrTest: PCRTest?
	@DidSetPublished var antigenTest: AntigenTest?

	@DidSetPublished var antigenTestIsOutdated: Bool = false

	@DidSetPublished var pcrTestResultIsLoading: Bool = false
	@DidSetPublished var antigenTestResultIsLoading: Bool = false

	var hasAtLeastOneShownPositiveOrSubmittedTest: Bool {
		pcrTest?.positiveTestResultWasShown == true || pcrTest?.keysSubmitted == true ||
			antigenTest?.positiveTestResultWasShown == true || antigenTest?.keysSubmitted == true
	}

	func coronaTest(ofType type: CoronaTestType) -> CoronaTest? {
		switch type {
		case .pcr:
			return pcrTest.map { .pcr($0) }
		case .antigen:
			return antigenTest.map { .antigen($0) }
		}
	}

	func registerPCRTestAndGetResult(
		guid: String,
		isSubmissionConsentGiven: Bool,
		completion: @escaping TestResultHandler
	) {
		Log.info("[CoronaTestService] Registering PCR test (guid: \(private: guid, public: "GUID ID"), isSubmissionConsentGiven: \(isSubmissionConsentGiven))", log: .api)

		getRegistrationToken(
			forKey: ENAHasher.sha256(guid),
			withType: "GUID",
			completion: { [weak self] result in
				switch result {
				case .success(let registrationToken):
					self?.pcrTest = PCRTest(
						registrationDate: Date(),
						registrationToken: registrationToken,
						testResult: .pending,
						finalTestResultReceivedDate: nil,
						positiveTestResultWasShown: false,
						isSubmissionConsentGiven: isSubmissionConsentGiven,
						submissionTAN: nil,
						keysSubmitted: false,
						journalEntryCreated: false
					)

					Log.info("[CoronaTestService] PCR test registered: \(private: String(describing: self?.pcrTest), public: "PCR Test result")", log: .api)

					Analytics.collect(.testResultMetadata(.registerNewTestMetadata(Date(), registrationToken)))
					Analytics.collect(.keySubmissionMetadata(.submittedWithTeletan(false)))

					self?.getTestResult(for: .pcr, duringRegistration: true) { result in
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

	func registerPCRTest(
		teleTAN: String,
		isSubmissionConsentGiven: Bool,
		completion: @escaping VoidResultHandler
	) {
		Log.info("[CoronaTestService] Registering PCR test (teleTAN: \(private: teleTAN, public: "teleTAN ID"), isSubmissionConsentGiven: \(isSubmissionConsentGiven))", log: .api)

		getRegistrationToken(
			forKey: teleTAN,
			withType: "TELETAN",
			completion: { [weak self] result in
				self?.fakeRequestService.fakeVerificationAndSubmissionServerRequest()

				switch result {
				case .success(let registrationToken):
					self?.pcrTest = PCRTest(
						registrationDate: Date(),
						registrationToken: registrationToken,
						testResult: .positive,
						finalTestResultReceivedDate: Date(),
						positiveTestResultWasShown: true,
						isSubmissionConsentGiven: isSubmissionConsentGiven,
						submissionTAN: nil,
						keysSubmitted: false,
						journalEntryCreated: false
					)

					Log.info("[CoronaTestService] PCR test registered: \(private: String(describing: self?.pcrTest), public: "PCR Test result")", log: .api)

					Analytics.collect(.keySubmissionMetadata(.submittedWithTeletan(true)))

					completion(.success(()))
				case .failure(let error):
					Log.error("[CoronaTestService] PCR test registration failed: \(error.localizedDescription)", log: .api)

					completion(.failure(error))
				}
			}
		)
	}
	
	func registerPCRTestAndGetResult(
		teleTAN: String,
		isSubmissionConsentGiven: Bool,
		completion: @escaping TestResultHandler
	) {
		registerPCRTest(teleTAN: teleTAN, isSubmissionConsentGiven: isSubmissionConsentGiven) { result in
			switch result {
			case .success:
				completion(.success(.positive))
			case .failure(let error):
				completion(.failure(error))
			}
		}
	}

	func registerAntigenTestAndGetResult(
		with hash: String,
		pointOfCareConsentDate: Date,
		firstName: String?,
		lastName: String?,
		dateOfBirth: String?,
		isSubmissionConsentGiven: Bool,
		completion: @escaping TestResultHandler
	) {
		Log.info("[CoronaTestService] Registering antigen test (hash: \(hash), pointOfCareConsentDate: \(pointOfCareConsentDate), firstName: \(String(describing: firstName)), lastName: \(String(describing: lastName)), dateOfBirth: \(String(describing: dateOfBirth)), isSubmissionConsentGiven: \(isSubmissionConsentGiven))", log: .api)

		getRegistrationToken(
			forKey: ENAHasher.sha256(hash),
			withType: "GUID",
			completion: { [weak self] result in
				switch result {
				case .success(let registrationToken):
					self?.antigenTest = AntigenTest(
						pointOfCareConsentDate: pointOfCareConsentDate,
						registrationDate: Date(),
						registrationToken: registrationToken,
						testedPerson: TestedPerson(firstName: firstName, lastName: lastName, dateOfBirth: dateOfBirth),
						testResult: .pending,
						finalTestResultReceivedDate: nil,
						positiveTestResultWasShown: false,
						isSubmissionConsentGiven: isSubmissionConsentGiven,
						submissionTAN: nil,
						keysSubmitted: false,
						journalEntryCreated: false
					)
					Log.info("[CoronaTestService] Antigen test registered: \(private: String(describing: self?.antigenTest), public: "Antigen test result")", log: .api)

					self?.getTestResult(for: .antigen, duringRegistration: true) { result in
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

	func updateTestResults(force: Bool = true, presentNotification: Bool, completion: @escaping VoidResultHandler) {
		let group = DispatchGroup()
		var errors = [CoronaTestServiceError]()

		for coronaTestType in CoronaTestType.allCases {
			group.enter()

			updateTestResult(for: coronaTestType, force: force, presentNotification: presentNotification) { result in
				switch result {
				case .failure(let error):
					Log.error(error.localizedDescription, log: .api)
					errors.append(error)
				case .success:
					break
				}

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
		for coronaTestType: CoronaTestType,
		force: Bool = true,
		presentNotification: Bool = false,
		completion: @escaping TestResultHandler
	) {
		Log.info("[CoronaTestService] Updating test result (coronaTestType: \(coronaTestType))", log: .api)

		getTestResult(for: coronaTestType, force: force, duringRegistration: false, presentNotification: presentNotification) { result in
			self.fakeRequestService.fakeVerificationAndSubmissionServerRequest {
				completion(result)
			}
		}
	}

	func getSubmissionTAN(for coronaTestType: CoronaTestType, completion: @escaping SubmissionTANResultHandler) {
		Log.info("[CoronaTestService] Getting submission tan (coronaTestType: \(coronaTestType))", log: .api)

		guard let coronaTest = coronaTest(ofType: coronaTestType) else {
			completion(.failure(.noCoronaTestOfRequestedType))
			return
		}

		if let submissionTAN = coronaTest.submissionTAN {
			completion(.success(submissionTAN))
			return
		}

		guard let registrationToken = coronaTest.registrationToken else {
			completion(.failure(.noRegistrationToken))
			return
		}

		client.getTANForExposureSubmit(forDevice: registrationToken, isFake: false) { result in
			switch result {
			case let .failure(error):
				Log.error("[CoronaTestService] Getting submission tan failed: \(error.localizedDescription)", log: .api)

				completion(.failure(.responseFailure(error)))
			case let .success(submissionTAN):
				switch coronaTestType {
				case .pcr:
					self.pcrTest?.submissionTAN = submissionTAN
					self.pcrTest?.registrationToken = nil

					Log.info("[CoronaTestService] Received submission tan for PCR test: \(private: String(describing: self.pcrTest), public: "PCR Test result")", log: .api)
				case .antigen:
					self.antigenTest?.submissionTAN = submissionTAN
					self.antigenTest?.registrationToken = nil

					Log.info("[CoronaTestService] Received submission tan for antigen test: \(private: String(describing: self.antigenTest), public: "TAN for antigen test")", log: .api)
				}

				completion(.success(submissionTAN))
			}
		}
	}

	func removeTest(_ coronaTestType: CoronaTestType) {
		Log.info("[CoronaTestService] Removing test (coronaTestType: \(coronaTestType)", log: .api)

		switch coronaTestType {
		case .pcr:
			pcrTest = nil
		case .antigen:
			antigenTest = nil
		}

		warnOthersReminder.cancelNotifications(for: coronaTestType)
	}

	func evaluateShowingTest(ofType coronaTestType: CoronaTestType) {
		Log.info("[CoronaTestService] Evaluating showing test (coronaTestType: \(coronaTestType))", log: .api)

		switch coronaTestType {
		case .pcr where pcrTest?.testResult == .positive:
			pcrTest?.positiveTestResultWasShown = true

			Log.info("[CoronaTestService] Positive PCR test result was shown", log: .api)
		case .antigen where antigenTest?.testResult == .positive:
			antigenTest?.positiveTestResultWasShown = true

			Log.info("[CoronaTestService] Positive antigen test result was shown", log: .api)
		default:
			break
		}

		DeadmanNotificationManager(coronaTestService: self).resetDeadmanNotification()

		if let coronaTest = coronaTest(ofType: coronaTestType), !coronaTest.isSubmissionConsentGiven,
			coronaTest.positiveTestResultWasShown, !coronaTest.keysSubmitted {
			warnOthersReminder.scheduleNotifications(for: coronaTestType)
		}
	}

	func updatePublishersFromStore() {
		Log.info("[CoronaTestService] Updating publishers from store", log: .api)

		if pcrTest != store.pcrTest {
			pcrTest = store.pcrTest

			Log.info("[CoronaTestService] PCR test updated from store", log: .api)
		}

		if antigenTest != store.antigenTest {
			antigenTest = store.antigenTest

			Log.info("[CoronaTestService] Antigen test updated from store", log: .api)
		}
	}

	func migrate() {
		let keysSubmitted = store.lastSuccessfulSubmitDiagnosisKeyTimestamp != nil
		if store.registrationToken != nil || keysSubmitted, let testRegistrationTimestamp = store.devicePairingConsentAcceptTimestamp {
			// The registration token is set to nil after submission, therefore we cannot fetch the result from the server and need
			// to infer a positive test result when keys were submitted. If the positive test result was shown we also can confidently set it to .positive.
			// For all other cases we set it to .pending and fetch the actual test result afterwards, as we did not store it in v2.0 and earlier.
			let testResult: TestResult = keysSubmitted || store.positiveTestResultWasShown ? .positive : .pending

			// In v2.0 and earlier the `positiveTestResultWasShown` property was reset on submission,
			// from v2.1 we keep it set to true even after the submission.
			let positiveTestResultWasShown = store.positiveTestResultWasShown || keysSubmitted

			pcrTest = PCRTest(
				registrationDate: Date(timeIntervalSince1970: TimeInterval(testRegistrationTimestamp)),
				registrationToken: store.registrationToken,
				testResult: testResult,
				finalTestResultReceivedDate: store.testResultReceivedTimeStamp.map { Date(timeIntervalSince1970: TimeInterval($0)) },
				positiveTestResultWasShown: positiveTestResultWasShown,
				isSubmissionConsentGiven: store.isSubmissionConsentGiven,
				submissionTAN: store.tan,
				keysSubmitted: keysSubmitted,
				journalEntryCreated: false
			)

			Log.info("[CoronaTestService] Migrated preexisting PCR test: \(private: String(describing: pcrTest), public: "PCR Test result")", log: .api)
		} else {
			Log.info("[CoronaTestService] No migration required (store.registrationToken: \(private: String(describing: store.registrationToken), public: "registration token ID"), store.lastSuccessfulSubmitDiagnosisKeyTimestamp: \(String(describing: store.lastSuccessfulSubmitDiagnosisKeyTimestamp)), store.devicePairingConsentAcceptTimestamp: \(String(describing: store.devicePairingConsentAcceptTimestamp))", log: .api)
		}

		store.registrationToken = nil
		store.teleTan = nil
		store.tan = nil
		store.testGUID = nil
		store.devicePairingConsentAccept = false
		store.devicePairingConsentAcceptTimestamp = nil
		store.devicePairingSuccessfulTimestamp = nil
		store.testResultReceivedTimeStamp = nil
		store.testRegistrationDate = nil
		store.lastSuccessfulSubmitDiagnosisKeyTimestamp = nil
		store.positiveTestResultWasShown = false
		store.isSubmissionConsentGiven = false
	}

	// MARK: - Private

	private let client: Client
	private var store: CoronaTestStoring & CoronaTestStoringLegacy
	private let appConfiguration: AppConfigurationProviding
	private let notificationCenter: UserNotificationCenter

	private let fakeRequestService: FakeRequestService
	private let warnOthersReminder: WarnOthersReminder

	private var outdatedStateTimer: Timer?
	private var antigenTestOutdatedDate: Date?

	private var subscriptions = Set<AnyCancellable>()

	private func setup() {
		updatePublishersFromStore()

		$pcrTest
			.sink { [weak self] pcrTest in
				self?.store.pcrTest = pcrTest

				if pcrTest?.keysSubmitted == true {
					self?.warnOthersReminder.cancelNotifications(for: .pcr)
				}
			}
			.store(in: &subscriptions)

		$antigenTest
			.sink { [weak self] antigenTest in
				self?.store.antigenTest = antigenTest

				if antigenTest?.keysSubmitted == true {
					self?.warnOthersReminder.cancelNotifications(for: .antigen)
				}

				self?.antigenTestIsOutdated = false
				self?.antigenTestOutdatedDate = nil

				if let antigenTest = antigenTest {
					self?.setupOutdatedPublisher(for: antigenTest)
				}
			}
			.store(in: &subscriptions)
	}

	func getRegistrationToken(
		forKey key: String,
		withType type: String,
		completion: @escaping RegistrationResultHandler
	) {
		client.getRegistrationToken(forKey: key, withType: type, isFake: false) { result in
			switch result {
			case let .failure(error):
				completion(.failure(.responseFailure(error)))
			case let .success(registrationToken):
				completion(.success(registrationToken))
			}
		}
	}

	// swiftlint:disable:next cyclomatic_complexity
	private func getTestResult(
		for coronaTestType: CoronaTestType,
		force: Bool = true,
		duringRegistration: Bool,
		presentNotification: Bool = false,
		_ completion: @escaping TestResultHandler
	) {
		Log.info("[CoronaTestService] Getting test result (coronaTestType: \(coronaTestType), duringRegistration: \(duringRegistration))", log: .api)

		guard let coronaTest = coronaTest(ofType: coronaTestType) else {
			Log.error("[CoronaTestService] Getting test result failed: No corona test of requested type", log: .api)

			completion(.failure(.noCoronaTestOfRequestedType))
			return
		}

		guard let registrationToken = coronaTest.registrationToken else {
			Log.error("[CoronaTestService] Getting test result failed: No registration token", log: .api)

			completion(.failure(.noRegistrationToken))
			return
		}

		guard force || coronaTest.finalTestResultReceivedDate == nil else {
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

		switch coronaTestType {
		case .pcr:
			pcrTestResultIsLoading = true
		case .antigen:
			antigenTestResultIsLoading = true
		}

		client.getTestResult(forDevice: registrationToken, isFake: false) { [weak self] result in
			guard let self = self else { return }

			switch coronaTestType {
			case .pcr:
				self.pcrTestResultIsLoading = false
			case .antigen:
				self.antigenTestResultIsLoading = false
			}

			#if DEBUG
			if isUITesting {
				completion(
					self.mockTestResultResponse(for: coronaTestType).flatMap { .success($0) } ??
					self.mockTestResult(for: coronaTestType).flatMap { .success($0) } ??
						.failure(.noCoronaTestOfRequestedType)
				)

				return
			}
			#endif

			switch result {
			case let .failure(error):
				Log.error("[CoronaTestService] Getting test result failed: \(error.localizedDescription)", log: .api)

				// For error code 400 (.qrDoesNotExist) we set the test result to expired
				if error == .qrDoesNotExist {
					Log.info("[CoronaTestService] Error Code 400 when getting test result, setting expired test result", log: .api)

					switch coronaTestType {
					case .pcr:
						self.pcrTest?.testResult = .expired
					case .antigen:
						self.antigenTest?.testResult = .expired
					}

					// For tests older than 21 days this should not be handled as an error
					if ageInDays >= 21 {
						Log.info("[CoronaTestService] Test older than 21 days, no error is returned", log: .api)

						completion(.success(.expired))
					} else {
						Log.error("[CoronaTestService] Test younger than 21 days, error is returned", log: .api)

						completion(.failure(.responseFailure(error)))
					}
				} else {
					completion(.failure(.responseFailure(error)))
				}
			case let .success(rawTestResult):
				guard let testResult = TestResult(serverResponse: rawTestResult) else {
					Log.error("[CoronaTestService] Getting test result failed: Unknown test result \(rawTestResult)", log: .api)

					completion(.failure(.unknownTestResult))
					return
				}

				Log.info("[CoronaTestService] Got test result (coronaTestType: \(coronaTestType), testResult: \(testResult))", log: .api)

				Analytics.collect(.testResultMetadata(.updateTestResult(testResult, registrationToken)))

				switch coronaTestType {
				case .pcr:
					self.pcrTest?.testResult = testResult
				case .antigen:
					self.antigenTest?.testResult = testResult
				}

				switch testResult {
				case .positive, .negative, .invalid:
					if coronaTest.finalTestResultReceivedDate == nil {
						switch coronaTestType {
						case .pcr:
							self.pcrTest?.finalTestResultReceivedDate = Date()
						case .antigen:
							self.antigenTest?.finalTestResultReceivedDate = Date()
						}

						if presentNotification {
							Log.info("[CoronaTestService] Triggering Notification (coronaTestType: \(coronaTestType), testResult: \(testResult))", log: .api)

							// We attach the test result and type to determine which screen to show when user taps the notification
							self.notificationCenter.presentNotification(
								title: AppStrings.LocalNotifications.testResultsTitle,
								body: AppStrings.LocalNotifications.testResultsBody,
								identifier: ActionableNotificationIdentifier.testResult.identifier,
								info: [
									ActionableNotificationIdentifier.testResult.identifier: testResult.rawValue,
									ActionableNotificationIdentifier.testResultType.identifier: coronaTestType.rawValue
								]
							)
						}
					}

					if coronaTestType == .pcr && duringRegistration {
						Analytics.collect(.keySubmissionMetadata(.setHoursSinceHighRiskWarningAtTestRegistration))
						Analytics.collect(.keySubmissionMetadata(.setDaysSinceMostRecentDateAtRiskLevelAtTestRegistration))
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
	}

	private func setupOutdatedPublisher(for antigenTest: AntigenTest) {
		// Only rapid antigen tests with a negative test result can become outdated
		guard antigenTest.testResult == .negative else {
			return
		}

		appConfiguration.appConfiguration()
			.sink { [weak self] in
				let hoursToDeemTestOutdated = $0.coronaTestParameters.coronaRapidAntigenTestParameters.hoursToDeemTestOutdated
				guard
					hoursToDeemTestOutdated != 0,
					let outdatedDate = Calendar.current.date(byAdding: .hour, value: Int(hoursToDeemTestOutdated), to: antigenTest.pointOfCareConsentDate)
				else {
					return
				}

				if Date() >= outdatedDate {
					self?.antigenTestIsOutdated = true
				} else {
					self?.antigenTestOutdatedDate = outdatedDate
					self?.scheduleOutdatedStateTimer()
				}
			}
			.store(in: &subscriptions)
	}

	private func scheduleOutdatedStateTimer() {
		outdatedStateTimer?.invalidate()
		NotificationCenter.default.removeObserver(self, name: UIApplication.didEnterBackgroundNotification, object: nil)
		NotificationCenter.default.removeObserver(self, name: UIApplication.didBecomeActiveNotification, object: nil)

		guard let antigenTestOutdatedDate = antigenTestOutdatedDate else {
			return
		}

		// Schedule new timer.
		NotificationCenter.default.addObserver(self, selector: #selector(invalidateTimer), name: UIApplication.didEnterBackgroundNotification, object: nil)
		NotificationCenter.default.addObserver(self, selector: #selector(refreshUpdateTimerAfterResumingFromBackground), name: UIApplication.didBecomeActiveNotification, object: nil)

		outdatedStateTimer = Timer(fireAt: antigenTestOutdatedDate, interval: 0, target: self, selector: #selector(updateFromTimer), userInfo: nil, repeats: false)

		guard let outdatedStateTimer = outdatedStateTimer else { return }
		RunLoop.current.add(outdatedStateTimer, forMode: .common)
	}

	@objc
	private func invalidateTimer() {
		outdatedStateTimer?.invalidate()
	}

	@objc
	private func refreshUpdateTimerAfterResumingFromBackground() {
		updateFromTimer()
		scheduleOutdatedStateTimer()
	}

	@objc
	private func updateFromTimer() {
		guard let antigenTestOutdatedDate = antigenTestOutdatedDate else {
			return
		}

		antigenTestIsOutdated = Date() >= antigenTestOutdatedDate
	}

	#if DEBUG

	private var mockPCRTest: PCRTest? {
		if let testResult = mockTestResult(for: .pcr) {
			return PCRTest(
				registrationDate: Date(),
				registrationToken: "asdf",
				testResult: testResult,
				finalTestResultReceivedDate: testResult == .pending ? nil : Date(),
				positiveTestResultWasShown: UserDefaults.standard.string(forKey: "pcrPositiveTestResultWasShown") == "YES",
				isSubmissionConsentGiven: UserDefaults.standard.string(forKey: "isPCRSubmissionConsentGiven") == "YES",
				submissionTAN: nil,
				keysSubmitted: UserDefaults.standard.string(forKey: "pcrKeysSubmitted") == "YES",
				journalEntryCreated: false
			)
		} else {
			return nil
		}
	}

	private var mockAntigenTest: AntigenTest? {
		if let testResult = mockTestResult(for: .antigen) {
			return AntigenTest(
				pointOfCareConsentDate: Date(),
				registrationDate: Date(),
				registrationToken: "zxcv",
				testedPerson: TestedPerson(firstName: "Erika", lastName: "Mustermann", dateOfBirth: "1964-08-12"),
				testResult: testResult,
				finalTestResultReceivedDate: testResult == .pending ? nil : Date(),
				positiveTestResultWasShown: UserDefaults.standard.string(forKey: "antigenPositiveTestResultWasShown") == "YES",
				isSubmissionConsentGiven: UserDefaults.standard.string(forKey: "isAntigenSubmissionConsentGiven") == "YES",
				submissionTAN: nil,
				keysSubmitted: UserDefaults.standard.string(forKey: "antigenKeysSubmitted") == "YES",
				journalEntryCreated: false
			)
		} else {
			return nil
		}
	}

	private func mockTestResult(for coronaTestType: CoronaTestType) -> TestResult? {
		switch coronaTestType {
		case .pcr:
			return UserDefaults.standard.string(forKey: "pcrTestResult").flatMap { TestResult(stringValue: $0) }
		case .antigen:
			return UserDefaults.standard.string(forKey: "antigenTestResult").flatMap { TestResult(stringValue: $0) }
		}
	}

	private func mockTestResultResponse(for coronaTestType: CoronaTestType) -> TestResult? {
		switch coronaTestType {
		case .pcr:
			return UserDefaults.standard.string(forKey: "pcrTestResultResponse").flatMap { TestResult(stringValue: $0) }
		case .antigen:
			return UserDefaults.standard.string(forKey: "antigenTestResultResponse").flatMap { TestResult(stringValue: $0) }
		}
	}

	#endif

	// swiftlint:disable:next file_length
}
