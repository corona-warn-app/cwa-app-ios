////
// 🦠 Corona-Warn-App
//

import Foundation

struct FamilyMemberPCRTest: Equatable, Hashable {

	// MARK: - Internal

	var displayName: String

	var registrationDate: Date
	var registrationToken: String?
	var qrCodeHash: String
	var isNew: Bool

	var testResult: TestResult
	var finalTestResultReceivedDate: Date?
	var testResultWasShown: Bool
	
	var certificateSupportedByPointOfCare: Bool
	var certificateConsentGiven: Bool
	var certificateRequested: Bool
	
	var uniqueCertificateIdentifier: String?

	var isLoading: Bool

}

extension FamilyMemberPCRTest: Codable {

	// MARK: - Protocol Codable

	enum CodingKeys: String, CodingKey {
		case displayName
		case registrationDate
		case registrationToken
		case qrCodeHash
		case isNew
		case testResult
		case finalTestResultReceivedDate
		case testResultWasShown
		case certificateSupportedByPointOfCare
		case certificateConsentGiven
		case certificateRequested
		case uniqueCertificateIdentifier
	}

	init(from decoder: Decoder) throws {
		let container = try decoder.container(keyedBy: CodingKeys.self)

		displayName = try container.decode(String.self, forKey: .displayName)

		registrationDate = try container.decode(Date.self, forKey: .registrationDate)
		registrationToken = try container.decodeIfPresent(String.self, forKey: .registrationToken)
		qrCodeHash = try container.decode(String.self, forKey: .qrCodeHash)
		isNew = try container.decode(Bool.self, forKey: .isNew)

		testResult = try container.decode(TestResult.self, forKey: .testResult)
		finalTestResultReceivedDate = try container.decodeIfPresent(Date.self, forKey: .finalTestResultReceivedDate)
		testResultWasShown = try container.decode(Bool.self, forKey: .testResultWasShown)
		
		certificateSupportedByPointOfCare = try container.decodeIfPresent(Bool.self, forKey: .certificateSupportedByPointOfCare) ?? false
		certificateConsentGiven = try container.decodeIfPresent(Bool.self, forKey: .certificateConsentGiven) ?? false
		certificateRequested = try container.decodeIfPresent(Bool.self, forKey: .certificateRequested) ?? false
		
		uniqueCertificateIdentifier = try container.decodeIfPresent(String.self, forKey: .uniqueCertificateIdentifier)

		isLoading = false
	}

}
