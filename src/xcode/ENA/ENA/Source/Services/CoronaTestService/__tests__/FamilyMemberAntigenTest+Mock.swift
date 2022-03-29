////
// 🦠 Corona-Warn-App
//

import Foundation
@testable import ENA

extension FamilyMemberAntigenTest {

	static func mock(
		displayName: String = "",
		pointOfCareConsentDate: Date = Date(),
		sampleCollectionDate: Date? = nil,
		registrationDate: Date = Date(),
		registrationToken: String? = nil,
		qrCodeHash: String = "",
		isNew: Bool = false,
		testResult: TestResult = .pending,
		finalTestResultReceivedDate: Date? = nil,
		testResultWasShown: Bool = false,
		certificateSupportedByPointOfCare: Bool = false,
		certificateConsentGiven: Bool = false,
		certificateRequested: Bool = false,
		uniqueCertificateIdentifier: String? = nil,
		isOutdated: Bool = false,
		isLoading: Bool = false
	) -> FamilyMemberAntigenTest {
		FamilyMemberAntigenTest(
			displayName: displayName,
			pointOfCareConsentDate: pointOfCareConsentDate,
			sampleCollectionDate: sampleCollectionDate,
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
			isOutdated: isOutdated,
			isLoading: isLoading
		)
	}

}
