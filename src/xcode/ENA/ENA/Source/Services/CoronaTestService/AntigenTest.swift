////
// 🦠 Corona-Warn-App
//

import Foundation

protocol AntigenTest {

	// MARK: - Internal

	// The date of when the consent was provided by the tested person at the Point of Care.
	var pointOfCareConsentDate: Date { get }
	// The date of when the test sample was collected.
	var sampleCollectionDate: Date? { get }
	var registrationDate: Date? { get }
	var registrationToken: String? { get }
	var qrCodeHash: String? { get }

	var testedPerson: TestedPerson { get }

	var testResult: TestResult { get }
	var finalTestResultReceivedDate: Date? { get }
	var positiveTestResultWasShown: Bool { get }

	var certificateSupportedByPointOfCare: Bool { get }
	var certificateConsentGiven: Bool { get }
	var certificateRequested: Bool { get }

	var uniqueCertificateIdentifier: String? { get }

	var testDate: Date { get }

}

extension AntigenTest {

	var testDate: Date {
		return sampleCollectionDate ?? pointOfCareConsentDate
	}

}
