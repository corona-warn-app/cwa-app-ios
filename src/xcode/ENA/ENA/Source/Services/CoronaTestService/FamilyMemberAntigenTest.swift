////
// 🦠 Corona-Warn-App
//

import Foundation

struct FamilyMemberAntigenTest: Equatable, Hashable, Codable {

	// MARK: - Init

	init(
		displayName: String,
		pointOfCareConsentDate: Date,
		sampleCollectionDate: Date? = nil,
		registrationDate: Date,
		registrationToken: String? = nil,
		qrCodeHash: String,
		isNew: Bool,
		testResultIsNew: Bool = false,
		testResult: TestResult,
		finalTestResultReceivedDate: Date? = nil,
		certificateSupportedByPointOfCare: Bool,
		certificateConsentGiven: Bool,
		certificateRequested: Bool,
		uniqueCertificateIdentifier: String? = nil,
		isOutdated: Bool,
		isLoading: Bool
	) {
		self.displayName = displayName
		self.pointOfCareConsentDate = pointOfCareConsentDate
		self.sampleCollectionDate = sampleCollectionDate
		self.registrationDate = registrationDate
		self.registrationToken = registrationToken
		self.qrCodeHash = qrCodeHash
		self.isNew = isNew
		self.testResultIsNew = testResultIsNew
		self.testResult = testResult
		self.finalTestResultReceivedDate = finalTestResultReceivedDate
		self.certificateSupportedByPointOfCare = certificateSupportedByPointOfCare
		self.certificateConsentGiven = certificateConsentGiven
		self.certificateRequested = certificateRequested
		self.uniqueCertificateIdentifier = uniqueCertificateIdentifier
		self.isOutdated = isOutdated
		self.isLoading = isLoading
	}

	// MARK: - Protocol Codable

	enum CodingKeys: String, CodingKey {
		case displayName
		case pointOfCareConsentDate
		case sampleCollectionDate
		case registrationDate
		case registrationToken
		case qrCodeHash
		case isNew
		case testResultIsNew
		case testResult
		case finalTestResultReceivedDate
		case certificateSupportedByPointOfCare
		case certificateConsentGiven
		case certificateRequested
		case uniqueCertificateIdentifier
		case isOutdated
	}
	
	enum LegacyCodingKeys: String, CodingKey {
		case testResultWasShown
	}

	init(from decoder: Decoder) throws {
		let container = try decoder.container(keyedBy: CodingKeys.self)
		let legacyContainer = try decoder.container(keyedBy: LegacyCodingKeys.self)

		displayName = try container.decode(String.self, forKey: .displayName)

		pointOfCareConsentDate = try container.decode(Date.self, forKey: .pointOfCareConsentDate)
		sampleCollectionDate = try container.decodeIfPresent(Date.self, forKey: .sampleCollectionDate)
		registrationDate = try container.decode(Date.self, forKey: .registrationDate)
		registrationToken = try container.decodeIfPresent(String.self, forKey: .registrationToken)
		qrCodeHash = try container.decode(String.self, forKey: .qrCodeHash)
		isNew = try container.decode(Bool.self, forKey: .isNew)

		testResult = try container.decode(TestResult.self, forKey: .testResult)
		finalTestResultReceivedDate = try container.decodeIfPresent(Date.self, forKey: .finalTestResultReceivedDate)

		// To migrate state, derive the value of testResultIsNew from legacy value testResultWasShown if its present.
		if let testResultWasShown = try legacyContainer.decodeIfPresent(Bool.self, forKey: .testResultWasShown) {
			testResultIsNew = try container.decodeIfPresent(Bool.self, forKey: .testResultIsNew) ?? (!testResultWasShown && finalTestResultReceivedDate != nil)
		} else {
			testResultIsNew = try container.decodeIfPresent(Bool.self, forKey: .testResultIsNew) ?? false
		}
		
		certificateSupportedByPointOfCare = try container.decodeIfPresent(Bool.self, forKey: .certificateSupportedByPointOfCare) ?? false
		certificateConsentGiven = try container.decodeIfPresent(Bool.self, forKey: .certificateConsentGiven) ?? false
		certificateRequested = try container.decodeIfPresent(Bool.self, forKey: .certificateRequested) ?? false

		uniqueCertificateIdentifier = try container.decodeIfPresent(String.self, forKey: .uniqueCertificateIdentifier)

		isOutdated = try container.decode(Bool.self, forKey: .isOutdated)

		isLoading = false
	}

	// MARK: - Internal

	var displayName: String

	// The date of when the consent was provided by the tested person at the Point of Care.
	var pointOfCareConsentDate: Date
	// The date of when the test sample was collected.
	var sampleCollectionDate: Date?
	var registrationDate: Date
	var registrationToken: String?
	var qrCodeHash: String
	var isNew: Bool
	var testResultIsNew: Bool = false

	var testResult: TestResult
	var finalTestResultReceivedDate: Date?

	var certificateSupportedByPointOfCare: Bool
	var certificateConsentGiven: Bool
	var certificateRequested: Bool

	var uniqueCertificateIdentifier: String?

	var isOutdated: Bool
	var isLoading: Bool

	var testDate: Date {
		return sampleCollectionDate ?? pointOfCareConsentDate
	}

}
