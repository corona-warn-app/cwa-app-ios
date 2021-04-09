////
// 🦠 Corona-Warn-App
//

import Foundation
import OpenCombine

enum CoronaTestServiceError: Error, Equatable {
	case responseFailure(URLSession.Response.Failure)
	case unknownTestResult
	case testExpired
	case noRegistrationToken
	case noCoronaTestOfRequestedType
}

class CoronaTestService {

	typealias VoidResultHandler = (Result<Void, CoronaTestServiceError>) -> Void
	typealias RegistrationResultHandler = (Result<String, CoronaTestServiceError>) -> Void
	typealias TestResultHandler = (Result<TestResult, CoronaTestServiceError>) -> Void
	typealias CoronaTestHandler = (Result<CoronaTest, CoronaTestServiceError>) -> Void
	typealias SubmissionTANResultHandler = (Result<String, CoronaTestServiceError>) -> Void

	// MARK: - Init

	init(
		client: Client,
		store: CoronaTestStoring & CoronaTestStoringLegacy & WarnOthersTimeIntervalStoring
	) {
		self.client = client
		self.store = store

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
			}
			.store(in: &subscriptions)
	}

	// MARK: - Protocol CoronaTestServiceProviding

	@OpenCombine.Published var pcrTest: PCRTest?
	@OpenCombine.Published var antigenTest: AntigenTest?

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
		getRegistrationToken(
			forKey: ENAHasher.sha256(guid),
			withType: "GUID",
			completion: { [weak self] result in
				switch result {
				case .success(let registrationToken):
					self?.pcrTest = PCRTest(
						registrationToken: registrationToken,
						registrationDate: Date(),
						testResult: .pending,
						testResultReceivedDate: nil,
						positiveTestResultWasShown: false,
						isSubmissionConsentGiven: isSubmissionConsentGiven,
						submissionTAN: nil,
						keysSubmitted: false,
						journalEntryCreated: false
					)

					// because this block is only called in QR submission
					Analytics.collect(.testResultMetadata(.registerNewTestMetadata(Date(), registrationToken)))
					Analytics.collect(.keySubmissionMetadata(.submittedWithTeletan(false)))

					self?.getTestResult(for: .pcr, duringRegistration: true) { result in
						completion(result)
					}
				case .failure(let error):
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
		getRegistrationToken(
			forKey: teleTAN,
			withType: "TELETAN",
			completion: { [weak self] result in
				self?.fakeRequestService.fakeVerificationAndSubmissionServerRequest()

				switch result {
				case .success(let registrationToken):
					self?.pcrTest = PCRTest(
						registrationToken: registrationToken,
						registrationDate: Date(),
						testResult: .positive,
						testResultReceivedDate: nil,
						positiveTestResultWasShown: true,
						isSubmissionConsentGiven: isSubmissionConsentGiven,
						submissionTAN: nil,
						keysSubmitted: false,
						journalEntryCreated: false
					)

					completion(.success(()))
				case .failure(let error):
					completion(.failure(error))
				}
			}
		)
	}

	func registerAntigenTestAndGetResult(
		with guid: String,
		pointOfCareConsentDate: Date,
		name: String?,
		birthday: String?,
		isSubmissionConsentGiven: Bool,
		completion: @escaping TestResultHandler
	) {
		getRegistrationToken(
			forKey: ENAHasher.sha256(guid),
			withType: "GUID",
			completion: { [weak self] result in
				switch result {
				case .success(let registrationToken):
					self?.antigenTest = AntigenTest(
						registrationToken: registrationToken,
						pointOfCareConsentDate: pointOfCareConsentDate,
						testedPerson: TestedPerson(name: name, birthday: birthday),
						testResult: .pending,
						testResultReceivedDate: nil,
						positiveTestResultWasShown: false,
						isSubmissionConsentGiven: false,
						submissionTAN: nil,
						keysSubmitted: false,
						journalEntryCreated: false
					)

					self?.getTestResult(for: .antigen, duringRegistration: true) { result in
						completion(result)
					}

					self?.fakeRequestService.fakeSubmissionServerRequest()
				case .failure(let error):
					completion(.failure(error))

					self?.fakeRequestService.fakeVerificationAndSubmissionServerRequest()
				}
			}
		)
	}

	func updateTestResult(for coronaTestType: CoronaTestType, completion: @escaping TestResultHandler) {
		getTestResult(for: coronaTestType, duringRegistration: false) { result in
			self.fakeRequestService.fakeVerificationAndSubmissionServerRequest {
				completion(result)
			}
		}
	}

	func getSubmissionTAN(for coronaTestType: CoronaTestType, completion: @escaping SubmissionTANResultHandler) {
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
				completion(.failure(.responseFailure(error)))
			case let .success(submissionTAN):
				switch coronaTestType {
				case .pcr:
					self.pcrTest?.submissionTAN = submissionTAN
					self.pcrTest?.registrationToken = nil
				case .antigen:
					self.antigenTest?.submissionTAN = submissionTAN
					self.antigenTest?.registrationToken = nil
				}

				completion(.success(submissionTAN))
			}
		}
	}

	func removeTest(_ coronaTestType: CoronaTestType) {
		switch coronaTestType {
		case .pcr:
			pcrTest = nil
		case .antigen:
			antigenTest = nil
		}

		warnOthersReminder.cancelNotifications(for: coronaTestType)
	}

	func evaluateShowingTest(ofType coronaTestType: CoronaTestType) {
		switch coronaTestType {
		case .pcr where pcrTest?.testResult == .positive:
			pcrTest?.positiveTestResultWasShown = true
		case .antigen where antigenTest?.testResult == .positive:
			antigenTest?.positiveTestResultWasShown = true
		default:
			break
		}

		DeadmanNotificationManager(coronaTestService: self).resetDeadmanNotification()

		if coronaTest(ofType: coronaTestType)?.isSubmissionConsentGiven == true {
			warnOthersReminder.scheduleNotifications(for: coronaTestType)
		}
	}

	func updatePublishersFromStore() {
		if pcrTest != store.pcrTest {
			pcrTest = store.pcrTest
		}

		if antigenTest != store.antigenTest {
			antigenTest = store.antigenTest
		}
	}

	func migrate() {
		if store.registrationToken != nil || store.lastSuccessfulSubmitDiagnosisKeyTimestamp != nil, let testRegistrationTimestamp = store.devicePairingConsentAcceptTimestamp {
			pcrTest = PCRTest(
				registrationToken: store.registrationToken,
				registrationDate: Date(timeIntervalSince1970: TimeInterval(testRegistrationTimestamp)),
				testResult: .pending,
				testResultReceivedDate: store.testResultReceivedTimeStamp.map { Date(timeIntervalSince1970: TimeInterval($0)) },
				positiveTestResultWasShown: store.positiveTestResultWasShown,
				isSubmissionConsentGiven: store.isSubmissionConsentGiven,
				submissionTAN: store.tan,
				keysSubmitted: store.lastSuccessfulSubmitDiagnosisKeyTimestamp != nil,
				journalEntryCreated: false
			)
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

	private let fakeRequestService: FakeRequestService
	private let warnOthersReminder: WarnOthersReminder

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
		duringRegistration: Bool,
		_ completion: @escaping TestResultHandler
	) {
		guard let coronaTest = coronaTest(ofType: coronaTestType) else {
			completion(.failure(.noCoronaTestOfRequestedType))
			return
		}

		guard let registrationToken = coronaTest.registrationToken else {
			completion(.failure(.noRegistrationToken))
			return
		}

		client.getTestResult(forDevice: registrationToken, isFake: false) { [weak self] result in
			guard let self = self else { return }

			switch result {
			case let .failure(error):
				completion(.failure(.responseFailure(error)))
			case let .success(testResult):
				guard let testResult = TestResult(serverResponse: testResult) else {
					completion(.failure(.unknownTestResult))
					return
				}

				Analytics.collect(.testResultMetadata(.updateTestResult(testResult, registrationToken)))

				switch coronaTestType {
				case .pcr:
					self.pcrTest?.testResult = testResult
				case .antigen:
					self.antigenTest?.testResult = testResult
				}

				switch testResult {
				case .positive, .negative, .invalid:
					if coronaTest.testResultReceivedDate == nil {
						switch coronaTestType {
						case .pcr:
							self.pcrTest?.testResultReceivedDate = Date()
						case .antigen:
							self.antigenTest?.testResultReceivedDate = Date()
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

}
