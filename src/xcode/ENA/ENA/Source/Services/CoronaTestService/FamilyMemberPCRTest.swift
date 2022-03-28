////
// 🦠 Corona-Warn-App
//

import Foundation

struct FamilyMemberPCRTest: Equatable, Hashable, Codable {

	// MARK: - Init

	init(
		displayName: String,
		registrationDate: Date,
		registrationToken: String? = nil,
		qrCodeHash: String,
		isNew: Bool,
		testResult: TestResult,
		finalTestResultReceivedDate: Date? = nil,
		testResultWasShown: Bool,
		certificateSupportedByPointOfCare: Bool,
		certificateConsentGiven: Bool,
		certificateRequested: Bool,
		uniqueCertificateIdentifier: String? = nil,
		isLoading: Bool
	) {
		self.displayName = displayName
		self.registrationDate = registrationDate
		self.registrationToken = registrationToken
		self.qrCodeHash = qrCodeHash
		self.isNew = isNew
		self.testResult = testResult
		self.finalTestResultReceivedDate = finalTestResultReceivedDate
		self.testResultWasShown = testResultWasShown
		self.certificateSupportedByPointOfCare = certificateSupportedByPointOfCare
		self.certificateConsentGiven = certificateConsentGiven
		self.certificateRequested = certificateRequested
		self.uniqueCertificateIdentifier = uniqueCertificateIdentifier
		self.isLoading = isLoading
	}

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
