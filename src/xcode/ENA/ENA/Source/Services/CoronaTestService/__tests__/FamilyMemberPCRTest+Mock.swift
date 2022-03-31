////
// 🦠 Corona-Warn-App
//

import Foundation
@testable import ENA

extension FamilyMemberPCRTest {

	static func mock(
		displayName: String = "",
		registrationDate: Date = Date(),
		registrationToken: String? = nil,
		qrCodeHash: String = "",
		isNew: Bool = false,
		testResult: TestResult = .pending,
		finalTestResultReceivedDate: Date? = Date(),
		testResultWasShown: Bool = false,
		isSubmissionConsentGiven: Bool = false,
		submissionTAN: String? = nil,
		keysSubmitted: Bool = false,
		journalEntryCreated: Bool = false,
		certificateSupportedByPointOfCare: Bool = false,
		certificateConsentGiven: Bool = false,
		certificateRequested: Bool = false,
		uniqueCertificateIdentifier: String? = nil,
		isLoading: Bool = false
	) -> FamilyMemberPCRTest {
		FamilyMemberPCRTest(
			displayName: displayName,
			registrationDate: registrationDate,
			registrationToken: registrationToken,
			qrCodeHash: qrCodeHash,
			isNew: isNew,
			testResult: testResult,
			finalTestResultReceivedDate: finalTestResultReceivedDate,
			testResultWasShown: testResultWasShown,
			certificateSupportedByPointOfCare: certificateSupportedByPointOfCare,
			certificateConsentGiven: certificateConsentGiven,
			certificateRequested: certificateRequested,
			uniqueCertificateIdentifier: uniqueCertificateIdentifier,
			isLoading: isLoading
		)
	}

}
