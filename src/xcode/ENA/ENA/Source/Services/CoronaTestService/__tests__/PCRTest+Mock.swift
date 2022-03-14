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
		finalTestResultReceivedDate: Date? = nil,
		positiveTestResultWasShown: Bool = false,
		isSubmissionConsentGiven: Bool = false,
		submissionTAN: String? = nil,
		keysSubmitted: Bool = false,
		journalEntryCreated: Bool = false,
		certificateSupportedByPointOfCare: Bool = false,
		certificateConsentGiven: Bool = false,
		certificateRequested: Bool = false,
		uniqueCertificateIdentifier: String? = nil
	) -> PCRTest {
		PCRTest(
			registrationDate: registrationDate,
			registrationToken: registrationToken,
			testResult: testResult,
			finalTestResultReceivedDate: finalTestResultReceivedDate,
			positiveTestResultWasShown: positiveTestResultWasShown,
			isSubmissionConsentGiven: isSubmissionConsentGiven,
			submissionTAN: submissionTAN,
			keysSubmitted: keysSubmitted,
			journalEntryCreated: journalEntryCreated,
			certificateSupportedByPointOfCare: certificateSupportedByPointOfCare,
			certificateConsentGiven: certificateConsentGiven,
			certificateRequested: certificateRequested,
			uniqueCertificateIdentifier: uniqueCertificateIdentifier
		)
	}

}
