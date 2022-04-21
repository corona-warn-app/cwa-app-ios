////
// 🦠 Corona-Warn-App
//

import Foundation
@testable import ENA

extension UserPCRTest {

	static func mock(
		registrationToken: String? = nil,
		qrCodeHash: String? = nil,
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
	) -> UserPCRTest {
		UserPCRTest(
			registrationDate: registrationDate,
			registrationToken: registrationToken,
			qrCodeHash: qrCodeHash,
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
