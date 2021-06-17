////
// 🦠 Corona-Warn-App
//

import Foundation
@testable import ENA

extension AntigenTest {

	static func mock(
		registrationToken: String? = nil,
		pointOfCareConsentDate: Date = Date(),
		registrationDate: Date? = nil,
		testedPerson: TestedPerson = TestedPerson(firstName: nil, lastName: nil, dateOfBirth: nil),
		testResult: TestResult = .pending,
		finalTestResultReceivedDate: Date? = nil,
		positiveTestResultWasShown: Bool = false,
		isSubmissionConsentGiven: Bool = false,
		submissionTAN: String? = nil,
		keysSubmitted: Bool = false,
		journalEntryCreated: Bool = false,
		certificateSupportedByPointOfCare: Bool = false,
		certificateConsentGiven: Bool = false,
		certificateRequested: Bool = false
	) -> AntigenTest {
		AntigenTest(
			pointOfCareConsentDate: pointOfCareConsentDate,
			registrationDate: registrationDate,
			registrationToken: registrationToken,
			testedPerson: testedPerson,
			testResult: testResult,
			finalTestResultReceivedDate: finalTestResultReceivedDate,
			positiveTestResultWasShown: positiveTestResultWasShown,
			isSubmissionConsentGiven: isSubmissionConsentGiven,
			submissionTAN: submissionTAN,
			keysSubmitted: keysSubmitted,
			journalEntryCreated: journalEntryCreated,
			certificateSupportedByPointOfCare: certificateSupportedByPointOfCare,
			certificateConsentGiven: certificateConsentGiven,
			certificateRequested: certificateRequested
		)
	}

}
