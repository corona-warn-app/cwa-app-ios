////
// 🦠 Corona-Warn-App
//

import Foundation

struct PCRTest: Equatable, Codable {

	var registrationDate: Date
	var registrationToken: String?

	var testResult: TestResult
	var finalTestResultReceivedDate: Date?
	var positiveTestResultWasShown: Bool

	var isSubmissionConsentGiven: Bool
	// Can only be used once to submit, cached here in case submission fails
	var submissionTAN: String?
	var keysSubmitted: Bool

	var journalEntryCreated: Bool

	var certificateConsentGiven: Bool
	var certificateCreated: Bool

}
