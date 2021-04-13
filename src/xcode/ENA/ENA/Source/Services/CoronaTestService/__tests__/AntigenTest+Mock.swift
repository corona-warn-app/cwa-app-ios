////
// 🦠 Corona-Warn-App
//

import Foundation
@testable import ENA

extension AntigenTest {

	static func mock(
		registrationToken: String? = nil,
		pointOfCareConsentDate: Date = Date(),
		testedPerson: TestedPerson = TestedPerson(name: nil, birthday: nil),
		testResult: TestResult = .pending,
		testResultReceivedDate: Date? = nil,
		positiveTestResultWasShown: Bool = false,
		isSubmissionConsentGiven: Bool = false,
		submissionTAN: String? = nil,
		keysSubmitted: Bool = false,
		journalEntryCreated: Bool = false
	) -> AntigenTest {
		AntigenTest(
			pointOfCareConsentDate: pointOfCareConsentDate,
			registrationToken: registrationToken,
			testedPerson: testedPerson,
			testResult: testResult,
			testResultReceivedDate: testResultReceivedDate,
			positiveTestResultWasShown: positiveTestResultWasShown,
			isSubmissionConsentGiven: isSubmissionConsentGiven,
			submissionTAN: submissionTAN,
			keysSubmitted: keysSubmitted,
			journalEntryCreated: journalEntryCreated
		)
	}

}
