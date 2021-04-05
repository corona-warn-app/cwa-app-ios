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
		store: CoronaTestStoring
	) {
		self.client = client
		self.store = store

		self.fakeRequestService = FakeRequestService(client: client)

		updatePublishersFromStore()
	}

	// MARK: - Protocol CoronaTestServiceProviding

	var pcrTestPublisher = OpenCombine.CurrentValueSubject<PCRTest?, Never>(nil)
	var antigenTestPublisher = OpenCombine.CurrentValueSubject<AntigenTest?, Never>(nil)

	func coronaTest(ofType type: CoronaTestType) -> CoronaTest? {
		switch type {
		case .pcr:
			return pcrTestPublisher.value.map { .pcr($0) }
		case .antigen:
			return antigenTestPublisher.value.map { .antigen($0) }
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
			completion: { result in
				switch result {
				case .success(let registrationToken):
					self.storePCRTest(withRegistrationToken: registrationToken, isSubmissionConsentGiven: isSubmissionConsentGiven)

					// because this block is only called in QR submission
					Analytics.collect(.testResultMetadata(.registerNewTestMetadata(Date(), registrationToken)))
					Analytics.collect(.keySubmissionMetadata(.submittedWithTeletan(false)))

					self.getTestResult(for: .pcr, duringRegistration: true) { result in
						completion(result)
					}
				case .failure(let error):
					completion(.failure(error))

					self.fakeRequestService.fakeVerificationAndSubmissionServerRequest()
				}
			}
		)
	}

	func registerPCRTest(
		teleTAN: String,
		isSubmissionConsentGiven: Bool,
		completion: @escaping CoronaTestHandler
	) {
		getRegistrationToken(
			forKey: teleTAN,
			withType: "TELETAN",
			completion: { result in
				self.fakeRequestService.fakeVerificationAndSubmissionServerRequest()

				switch result {
				case .success(let registrationToken):
					let pcrTest = self.storePCRTest(withRegistrationToken: registrationToken, isSubmissionConsentGiven: isSubmissionConsentGiven)
					completion(.success(.pcr(pcrTest)))
				case .failure(let error):
					completion(.failure(error))
				}
			}
		)
	}

	func registerAntigenTestAndGetResult(
		with guid: String,
		pointOfCareConsentTimestamp: Date,
		name: String?,
		birthday: String?,
		isSubmissionConsentGiven: Bool,
		completion: @escaping TestResultHandler
	) {
		getRegistrationToken(
			forKey: ENAHasher.sha256(guid),
			withType: "GUID", // tbd, tech spec missing
			completion: { [weak self] result in
				switch result {
				case .success(let registrationToken):
					self?.store.antigenTest = AntigenTest(
						registrationToken: registrationToken,
						testedPerson: TestedPerson(name: name, birthday: birthday),
						pointOfCareConsentDate: pointOfCareConsentTimestamp,
						testResult: .pending,
						testResultReceivedDate: nil,
						positiveTestResultWasShown: false,
						isSubmissionConsentGiven: false,
						submissionTAN: nil,
						keysSubmitted: false,
						journalEntryCreated: false
					)
					self?.updatePublishersFromStore()

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
				switch coronaTest {
				case .pcr(let pcrTest):
					self.store.pcrTest = PCRTest(
						registrationToken: pcrTest.registrationToken,
						testRegistrationDate: pcrTest.testRegistrationDate,
						testResult: pcrTest.testResult,
						testResultReceivedDate: pcrTest.testResultReceivedDate,
						positiveTestResultWasShown: pcrTest.positiveTestResultWasShown,
						isSubmissionConsentGiven: pcrTest.isSubmissionConsentGiven,
						submissionTAN: submissionTAN,
						keysSubmitted: pcrTest.keysSubmitted,
						journalEntryCreated: pcrTest.journalEntryCreated
					)

				case .antigen(let antigenTest):
					self.store.antigenTest = AntigenTest(
						registrationToken: antigenTest.registrationToken,
						testedPerson: antigenTest.testedPerson,
						pointOfCareConsentDate: antigenTest.pointOfCareConsentDate,
						testResult: antigenTest.testResult,
						testResultReceivedDate: antigenTest.testResultReceivedDate,
						positiveTestResultWasShown: antigenTest.positiveTestResultWasShown,
						isSubmissionConsentGiven: antigenTest.isSubmissionConsentGiven,
						submissionTAN: submissionTAN,
						keysSubmitted: antigenTest.keysSubmitted,
						journalEntryCreated: antigenTest.journalEntryCreated
					)
				}

				self.updatePublishersFromStore()

				completion(.success(submissionTAN))
			}
		}
	}

	func removeTest(_ coronaTestType: CoronaTestType) {
		switch coronaTestType {
		case .pcr:
			store.pcrTest = nil
		case .antigen:
			store.antigenTest = nil
		}

		updatePublishersFromStore()
	}

	func updatePublishersFromStore() {
		if pcrTestPublisher.value != store.pcrTest {
			pcrTestPublisher.value = store.pcrTest
		}

		if antigenTestPublisher.value != store.antigenTest {
			antigenTestPublisher.value = store.antigenTest
		}
	}

	// MARK: - Private

	private let client: Client
	private var store: CoronaTestStoring

	private let fakeRequestService: FakeRequestService

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

	@discardableResult
	private func storePCRTest(
		withRegistrationToken registrationToken: String,
		isSubmissionConsentGiven: Bool
	) -> PCRTest {
		let pcrTest = PCRTest(
			registrationToken: registrationToken,
			testRegistrationDate: Date(),
			testResult: .pending,
			testResultReceivedDate: nil,
			positiveTestResultWasShown: false,
			isSubmissionConsentGiven: isSubmissionConsentGiven,
			submissionTAN: nil,
			keysSubmitted: false,
			journalEntryCreated: false
		)

		self.store.pcrTest = pcrTest

		updatePublishersFromStore()

		return pcrTest
	}

	// swiftlint:disable:next cyclomatic_complexity
	private func getTestResult(
		for coronaTestType: CoronaTestType,
		duringRegistration: Bool,
		_ completion: @escaping TestResultHandler
	) {
		guard let coronaTest = coronaTest(ofType: coronaTestType), let registrationToken = coronaTest.registrationToken else {
			completion(.failure(.noRegistrationToken))
			return
		}

		client.getTestResult(forDevice: registrationToken, isFake: false) { result in
			switch result {
			case let .failure(error):
				completion(.failure(.responseFailure(error)))
			case let .success(testResult):
				guard let testResult = TestResult(rawValue: testResult) else {
					completion(.failure(.unknownTestResult))
					return
				}

				Analytics.collect(.testResultMetadata(.updateTestResult(testResult, registrationToken)))

				switch coronaTestType {
				case .pcr:
					self.store.pcrTest?.testResult = testResult
				case .antigen:
					self.store.antigenTest?.testResult = testResult
				}

				switch testResult {
				case .positive, .negative, .invalid:
					if coronaTest.testResultReceivedDate == nil {
						switch coronaTestType {
						case .pcr:
							self.store.pcrTest?.testResultReceivedDate = Date()
						case .antigen:
							self.store.antigenTest?.testResultReceivedDate = Date()
						}
					}

					if coronaTestType == .pcr {
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

					switch coronaTestType {
					case .pcr:
						self.store.pcrTest?.registrationToken = nil
					case .antigen:
						self.store.antigenTest?.registrationToken = nil
					}
				}
			}

			self.updatePublishersFromStore()
		}
	}

}
