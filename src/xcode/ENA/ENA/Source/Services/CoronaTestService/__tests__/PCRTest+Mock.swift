////
// 🦠 Corona-Warn-App
//

import Foundation
@testable import ENA

extension PCRTest {

	static func mock(
		registrationToken: String? = nil,
		registrationDate: Date = Date(),
		testResult: TestResult = .pending,
		testResultReceivedDate: Date? = nil,
		positiveTestResultWasShown: Bool = false,
		isSubmissionConsentGiven: Bool = false,
		submissionTAN: String? = nil,
		keysSubmitted: Bool = false,
		journalEntryCreated: Bool = false
	) -> PCRTest {
		PCRTest(
			registrationDate: registrationDate,
			registrationToken: registrationToken,
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
