////
// 🦠 Corona-Warn-App
//

import Foundation

struct FamilyMemberPCRTest: PCRTest, Equatable, Hashable {

	// MARK: - Internal

	var registrationDate: Date
	var registrationToken: String?
	var qrCodeHash: String?

	var testResult: TestResult
	var finalTestResultReceivedDate: Date?
	var positiveTestResultWasShown: Bool
	
	var certificateSupportedByPointOfCare: Bool
	var certificateConsentGiven: Bool
	var certificateRequested: Bool
	
	var uniqueCertificateIdentifier: String?
}

extension FamilyMemberPCRTest: Codable {

	// MARK: - Protocol Codable

	enum CodingKeys: String, CodingKey {
		case registrationDate
		case registrationToken
		case qrCodeHash
		case testResult
		case finalTestResultReceivedDate
		case positiveTestResultWasShown
		case certificateSupportedByPointOfCare
		case certificateConsentGiven
		case certificateRequested
		case uniqueCertificateIdentifier
	}

	init(from decoder: Decoder) throws {
		let container = try decoder.container(keyedBy: CodingKeys.self)

		registrationDate = try container.decode(Date.self, forKey: .registrationDate)
		registrationToken = try container.decodeIfPresent(String.self, forKey: .registrationToken)
		qrCodeHash = try container.decodeIfPresent(String.self, forKey: .qrCodeHash)

		testResult = try container.decode(TestResult.self, forKey: .testResult)
		finalTestResultReceivedDate = try container.decodeIfPresent(Date.self, forKey: .finalTestResultReceivedDate)
		positiveTestResultWasShown = try container.decode(Bool.self, forKey: .positiveTestResultWasShown)
		
		certificateSupportedByPointOfCare = try container.decodeIfPresent(Bool.self, forKey: .certificateSupportedByPointOfCare) ?? false
		certificateConsentGiven = try container.decodeIfPresent(Bool.self, forKey: .certificateConsentGiven) ?? false
		certificateRequested = try container.decodeIfPresent(Bool.self, forKey: .certificateRequested) ?? false
		
		uniqueCertificateIdentifier = try container.decodeIfPresent(String
																		.self, forKey: .uniqueCertificateIdentifier)
	}

}
