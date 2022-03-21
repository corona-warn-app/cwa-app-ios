//
// 🦠 Corona-Warn-App
//

import Foundation

protocol CoronaTest: Codable {

	var registrationDate: Date? { get }
	var registrationToken: String? { get }
	var qrCodeHash: String? { get }

	var testResult: TestResult { get }
	var testDate: Date { get }
	var finalTestResultReceivedDate: Date? { get }
	var positiveTestResultWasShown: Bool { get }

	var certificateConsentGiven: Bool { get }
	var certificateRequested: Bool { get }

	var type: CoronaTestType { get }

	var pcrTest: PCRTest? { get }
	var antigenTest: AntigenTest? { get }

	var uniqueCertificateIdentifier: String? { get }

}
