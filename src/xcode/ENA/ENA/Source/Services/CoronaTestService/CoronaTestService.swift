////
// 🦠 Corona-Warn-App
//

import Foundation
import OpenCombine
import UIKit

enum CoronaTestServiceError: LocalizedError, Equatable {
	case responseFailure(URLSession.Response.Failure)
	case unknownTestResult
	case testExpired
	case noRegistrationToken
	case noCoronaTestOfRequestedType

	var errorDescription: String? {
		switch self {
		case let .responseFailure(responseFailure):
			return responseFailure.errorDescription
		case .noRegistrationToken:
			return AppStrings.ExposureSubmissionError.noRegistrationToken
		case .testExpired:
			return AppStrings.ExposureSubmission.qrCodeExpiredAlertText
		default:
			Log.error("\(self)", log: .api)
			return AppStrings.ExposureSubmissionError.defaultError
		}
	}
}

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
		self.client = client
		self.store = store
		self.appConfiguration = appConfiguration
		self.notificationCenter = notificationCenter

		self.fakeRequestService = FakeRequestService(client: client)
		self.warnOthersReminder = WarnOthersReminder(store: store)

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

				if let antigenTest = antigenTest {
					self?.setupOutdatedPublisher(for: antigenTest)
				} else {
					self?.antigenTestIsOutdated = false
					self?.antigenTestOutdatedDate = nil
				}
			}
			.store(in: &subscriptions)
	}

	// MARK: - Protocol CoronaTestServiceProviding

	@OpenCombine.Published var pcrTest: PCRTest?
	@OpenCombine.Published var antigenTest: AntigenTest?

	@OpenCombine.Published var antigenTestIsOutdated: Bool = false

	@OpenCombine.Published var pcrTestResultIsLoading: Bool = false
	@OpenCombine.Published var antigenTestResultIsLoading: Bool = false

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
		Log.info("[CoronaTestService] Registering PCR test (guid: \(guid), isSubmissionConsentGiven: \(isSubmissionConsentGiven))", log: .api)

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

					Log.info("[CoronaTestService] PCR test registered: \(String(describing: self?.pcrTest))", log: .api)

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
		Log.info("[CoronaTestService] Registering PCR test (teleTAN: \(teleTAN), isSubmissionConsentGiven: \(isSubmissionConsentGiven))", log: .api)

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
						finalTestResultReceivedDate: nil,
						positiveTestResultWasShown: true,
						isSubmissionConsentGiven: isSubmissionConsentGiven,
						submissionTAN: nil,
						keysSubmitted: false,
						journalEntryCreated: false
					)

					Log.info("[CoronaTestService] PCR test registered: \(String(describing: self?.pcrTest))", log: .api)

					Analytics.collect(.keySubmissionMetadata(.submittedWithTeletan(true)))

					completion(.success(()))
				case .failure(let error):
					Log.error("[CoronaTestService] PCR test registration failed: \(error.localizedDescription)", log: .api)

					completion(.failure(error))
				}
			}
		)
	}

	func registerAntigenTestAndGetResult(
		with guid: String,
		pointOfCareConsentDate: Date,
		firstName: String?,
		lastName: String?,
		dateOfBirth: String?,
		isSubmissionConsentGiven: Bool,
		completion: @escaping TestResultHandler
	) {
		Log.info("[CoronaTestService] Registering antigen test (guid: \(guid), pointOfCareConsentDate: \(pointOfCareConsentDate), firstName: \(String(describing: firstName)), lastName: \(String(describing: lastName)), dateOfBirth: \(String(describing: dateOfBirth)), isSubmissionConsentGiven: \(isSubmissionConsentGiven))", log: .api)

		getRegistrationToken(
			forKey: ENAHasher.sha256(guid),
			withType: "GUID",
			completion: { [weak self] result in
				switch result {
				case .success(let registrationToken):
					self?.antigenTest = AntigenTest(
						pointOfCareConsentDate: pointOfCareConsentDate,
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

					Log.info("[CoronaTestService] Antigen test registered: \(String(describing: self?.antigenTest))", log: .api)

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
			Log.info("[CoronaTestService] Requesting TestResult for test type \(coronaTestType)…", log: .api)

			group.enter()
			updateTestResult(for: coronaTestType, force: force) { [weak self] result in
				switch result {
				case .failure(let error):
					Log.error(error.localizedDescription, log: .api)
					errors.append(error)
				case .success(.pending), .success(.expired):
					// Do not trigger notifications for pending or expired results.
					Log.info("[CoronaTestService] TestResult pending or expired", log: .api)
				case .success(let testResult):
					Log.info("[CoronaTestService] Triggering Notification to inform user about TestResult: \(testResult.stringValue)", log: .api)

					if presentNotification {
						// We attach the test result and type to determine which screen to show when user taps the notification
						self?.notificationCenter.presentNotification(
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

	func updateTestResult(for coronaTestType: CoronaTestType, force: Bool = true, completion: @escaping TestResultHandler) {
		Log.info("[CoronaTestService] Updating test result (coronaTestType: \(coronaTestType))", log: .api)

		getTestResult(for: coronaTestType, force: force, duringRegistration: false) { result in
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

					Log.info("[CoronaTestService] Received submission tan for PCR test: \(String(describing: self.pcrTest))", log: .api)
				case .antigen:
					self.antigenTest?.submissionTAN = submissionTAN
					self.antigenTest?.registrationToken = nil

					Log.info("[CoronaTestService] Received submission tan for antigen test: \(String(describing: self.antigenTest))", log: .api)
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

		if coronaTest(ofType: coronaTestType)?.isSubmissionConsentGiven == true {
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
		if store.registrationToken != nil || store.lastSuccessfulSubmitDiagnosisKeyTimestamp != nil, let testRegistrationTimestamp = store.devicePairingConsentAcceptTimestamp {
			pcrTest = PCRTest(
				registrationDate: Date(timeIntervalSince1970: TimeInterval(testRegistrationTimestamp)),
				registrationToken: store.registrationToken,
				testResult: .pending,
				finalTestResultReceivedDate: store.testResultReceivedTimeStamp.map { Date(timeIntervalSince1970: TimeInterval($0)) },
				positiveTestResultWasShown: store.positiveTestResultWasShown,
				isSubmissionConsentGiven: store.isSubmissionConsentGiven,
				submissionTAN: store.tan,
				keysSubmitted: store.lastSuccessfulSubmitDiagnosisKeyTimestamp != nil,
				journalEntryCreated: false
			)

			Log.info("[CoronaTestService] Migrated preexisting PCR test: \(String(describing: pcrTest))", log: .api)
		} else {
			Log.info("[CoronaTestService] No migration required (store.registrationToken: \(String(describing: store.registrationToken)), store.lastSuccessfulSubmitDiagnosisKeyTimestamp: \(String(describing: store.lastSuccessfulSubmitDiagnosisKeyTimestamp)), store.devicePairingConsentAcceptTimestamp: \(String(describing: store.devicePairingConsentAcceptTimestamp))", log: .api)
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

	private func getRegistrationToken(
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

			switch result {
			case let .failure(error):
				Log.error("[CoronaTestService] Getting test result failed: \(error.localizedDescription)", log: .api)

				completion(.failure(.responseFailure(error)))
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
	func invalidateTimer() {
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

	// swiftlint:disable:next file_length
}
