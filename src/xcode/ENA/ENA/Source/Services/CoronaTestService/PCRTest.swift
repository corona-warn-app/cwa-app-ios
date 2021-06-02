////
// 🦠 Corona-Warn-App
//

import Foundation

struct PCRTest: Equatable {

	// MARK: - Internal

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

extension PCRTest: Codable {

	// MARK: - Protocol Codable

	enum CodingKeys: String, CodingKey {
		case registrationDate
		case registrationToken
		case testResult
		case finalTestResultReceivedDate
		case positiveTestResultWasShown
		case isSubmissionConsentGiven
		case submissionTAN
		case keysSubmitted
		case journalEntryCreated
		case certificateConsentGiven
		case certificateCreated
	}

	init(from decoder: Decoder) throws {
		let container = try decoder.container(keyedBy: CodingKeys.self)

		registrationDate = try container.decode(Date.self, forKey: .registrationDate)
		registrationToken = try container.decodeIfPresent(String.self, forKey: .registrationToken)

		testResult = try container.decode(TestResult.self, forKey: .testResult)
		finalTestResultReceivedDate = try container.decodeIfPresent(Date.self, forKey: .finalTestResultReceivedDate)
		positiveTestResultWasShown = try container.decode(Bool.self, forKey: .positiveTestResultWasShown)

		isSubmissionConsentGiven = try container.decode(Bool.self, forKey: .isSubmissionConsentGiven)
		submissionTAN = try container.decodeIfPresent(String.self, forKey: .submissionTAN)
		keysSubmitted = try container.decode(Bool.self, forKey: .keysSubmitted)

		journalEntryCreated = try container.decode(Bool.self, forKey: .journalEntryCreated)

		certificateConsentGiven = try container.decodeIfPresent(Bool.self, forKey: .certificateConsentGiven) ?? false
		certificateCreated = try container.decodeIfPresent(Bool.self, forKey: .certificateCreated) ?? false
	}

}
