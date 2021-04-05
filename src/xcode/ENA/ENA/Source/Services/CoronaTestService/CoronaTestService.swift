////
// 🦠 Corona-Warn-App
//

import Foundation
import OpenCombine

enum CoronaTestServiceError: Error {
	case responseFailure(URLSession.Response.Failure)
	case unknownTestResult
	case testExpired
	case noRegistrationToken
}

class CoronaTestService {

	typealias VoidResultHandler = (Result<Void, CoronaTestServiceError>) -> Void
	typealias RegistrationResultHandler = (Result<String, CoronaTestServiceError>) -> Void
	typealias SubmissionTANResultHandler = (Result<String, CoronaTestServiceError>) -> Void

	// MARK: - Init

	init(
		client: Client,
		store: CoronaTestStoring
	) {
		self.client = client
		self.store = store

		self.fakeRequestService = FakeRequestService(client: client)
	}

	// MARK: - Protocol CoronaTestServiceProviding

	var pcrTestPublisher = OpenCombine.CurrentValueSubject<PCRTest?, Never>(nil)
	var antigenTestPublisher = OpenCombine.CurrentValueSubject<AntigenTest?, Never>(nil)

	func registerPCRTestAndGetResult(
		guid: String,
		submissionConsentGiven: Bool,
		completion: @escaping VoidResultHandler
	) {
		getRegistrationToken(
			forKey: ENAHasher.sha256(guid),
			withType: "GUID",
			completion: { result in
				switch result {
				case .success(let registrationToken):
					let pcrTest = self.storePCRTest(withRegistrationToken: registrationToken, submissionConsentGiven: submissionConsentGiven)

					// because this block is only called in QR submission
					Analytics.collect(.testResultMetadata(.registerNewTestMetadata(Date(), registrationToken)))
					Analytics.collect(.keySubmissionMetadata(.submittedWithTeletan(false)))

					self.getTestResult(for: .pcr(pcrTest), duringRegistration: true) { result in
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
		submissionConsentGiven: Bool,
		completion: @escaping VoidResultHandler
	) {
		getRegistrationToken(
			forKey: teleTAN,
			withType: "TELETAN",
			completion: { [weak self] result in
				self?.fakeRequestService.fakeVerificationAndSubmissionServerRequest()

				switch result {
				case .success(let registrationToken):
					self?.storePCRTest(withRegistrationToken: registrationToken, submissionConsentGiven: submissionConsentGiven)
					completion(.success(()))
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
		submissionConsentGiven: Bool,
		completion: @escaping VoidResultHandler
	) {
		getRegistrationToken(
			forKey: ENAHasher.sha256(guid),
			withType: "GUID", // tbd, tech spec missing
			completion: { [weak self] result in
				switch result {
				case .success(let registrationToken):
					let antigenTest = AntigenTest(
						registrationToken: registrationToken,
						testedPerson: TestedPerson(name: name, birthday: birthday),
						pointOfCareConsentTimestamp: pointOfCareConsentTimestamp,
						testResult: nil,
						testResultReceivedDate: nil,
						submissionConsentGiven: submissionConsentGiven,
						submissionTAN: nil,
						keysSubmitted: false,
						journalEntryCreated: false
					)

					self?.store.antigenTest = antigenTest
					self?.updatePublishersFromStore()

					self?.getTestResult(for: .antigen(antigenTest), duringRegistration: true) { result in
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

	func updateTestResult(for coronaTest: CoronaTest, completion: @escaping VoidResultHandler) {
		getTestResult(for: coronaTest, duringRegistration: false) { result in
			self.fakeRequestService.fakeVerificationAndSubmissionServerRequest {
				completion(result)
			}
		}
	}

	func getSubmissionTAN(for coronaTest: CoronaTest, completion: @escaping SubmissionTANResultHandler) {
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
						testResultReceivedDate: nil,
						submissionConsentGiven: pcrTest.submissionConsentGiven,
						submissionTAN: submissionTAN,
						keysSubmitted: pcrTest.keysSubmitted,
						journalEntryCreated: pcrTest.journalEntryCreated
					)

				case .antigen(let antigenTest):
					self.store.antigenTest = AntigenTest(
						registrationToken: antigenTest.registrationToken,
						testedPerson: antigenTest.testedPerson,
						pointOfCareConsentTimestamp: antigenTest.pointOfCareConsentTimestamp,
						testResult: antigenTest.testResult,
						testResultReceivedDate: nil,
						submissionConsentGiven: antigenTest.submissionConsentGiven,
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

	func removeTest(_ coronaTest: CoronaTest) {
		switch coronaTest {
		case .pcr:
			store.pcrTest = nil
		case .antigen:
			store.antigenTest = nil
		}

		updatePublishersFromStore()
	}

	// MARK: - Private

	private let client: Client
	private var store: CoronaTestStoring

	private let fakeRequestService: FakeRequestService

	private func updatePublishersFromStore() {
		if pcrTestPublisher.value != store.pcrTest {
			pcrTestPublisher.value = store.pcrTest
		}

		if antigenTestPublisher.value != store.antigenTest {
			antigenTestPublisher.value = store.antigenTest
		}
	}

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
		submissionConsentGiven: Bool
	) -> PCRTest {
		let pcrTest = PCRTest(
			registrationToken: registrationToken,
			testRegistrationDate: Date(),
			testResult: nil,
			testResultReceivedDate: nil,
			submissionConsentGiven: submissionConsentGiven,
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
		for coronaTest: CoronaTest,
		duringRegistration: Bool,
		_ completion: @escaping VoidResultHandler
	) {
		guard let registrationToken = coronaTest.registrationToken else {
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

				switch coronaTest {
				case .pcr:
					self.store.pcrTest?.testResult = testResult
				case .antigen:
					self.store.antigenTest?.testResult = testResult
				}

				switch testResult {
				case .positive, .negative, .invalid:
					if coronaTest.testResultReceivedDate == nil {
						switch coronaTest {
						case .pcr:
							self.store.pcrTest?.testResultReceivedDate = Date()
						case .antigen:
							self.store.antigenTest?.testResultReceivedDate = Date()
						}
					}

					if case .pcr = coronaTest {
						Analytics.collect(.keySubmissionMetadata(.setHoursSinceHighRiskWarningAtTestRegistration))
						Analytics.collect(.keySubmissionMetadata(.setDaysSinceMostRecentDateAtRiskLevelAtTestRegistration))
					}

					completion(.success(()))
				case .pending:
					completion(.success(()))
				case .expired:
					if duringRegistration {
						// The .expired status is only known after the test has been registered on the server
						// so we generate an error here, even if the server returned the http result 201
						completion(.failure(.testExpired))
					} else {
						completion(.success(()))
					}

					switch coronaTest {
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
