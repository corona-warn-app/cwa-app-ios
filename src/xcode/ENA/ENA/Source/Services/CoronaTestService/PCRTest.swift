////
// 🦠 Corona-Warn-App
//

import Foundation

protocol PCRTest {

	// MARK: - Internal

	var registrationDate: Date { get }
	var registrationToken: String? { get }
	var qrCodeHash: String? { get }

	var testResult: TestResult { get }
	var finalTestResultReceivedDate: Date? { get }
	var positiveTestResultWasShown: Bool { get }
	
	var certificateSupportedByPointOfCare: Bool { get }
	var certificateConsentGiven: Bool { get }
	var certificateRequested: Bool { get }
	
	var uniqueCertificateIdentifier: String? { get }

}
