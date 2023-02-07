////
// 🦠 Corona-Warn-App
//

import Foundation

struct UserAntigenTest: Equatable, Hashable, Codable {

	// MARK: - Init

	init(
		pointOfCareConsentDate: Date,
		sampleCollectionDate: Date? = nil,
		registrationDate: Date? = nil,
		registrationToken: String? = nil,
		qrCodeHash: String? = nil,
		testedPerson: TestedPerson,
		testResult: TestResult,
		finalTestResultReceivedDate: Date? = nil,
		positiveTestResultWasShown: Bool,
		isSubmissionConsentGiven: Bool,
		submissionTAN: String? = nil,
		keysSubmitted: Bool,
		journalEntryCreated: Bool,
		certificateSupportedByPointOfCare: Bool,
		certificateConsentGiven: Bool,
		certificateRequested: Bool,
		uniqueCertificateIdentifier: String? = nil
	) {
		self.pointOfCareConsentDate = pointOfCareConsentDate
		self.sampleCollectionDate = sampleCollectionDate
		self.registrationDate = registrationDate
		self.registrationToken = registrationToken
		self.qrCodeHash = qrCodeHash
		self.testedPerson = testedPerson
		self.testResult = testResult
		self.finalTestResultReceivedDate = finalTestResultReceivedDate
		self.positiveTestResultWasShown = positiveTestResultWasShown
		self.isSubmissionConsentGiven = isSubmissionConsentGiven
		self.submissionTAN = submissionTAN
		self.keysSubmitted = keysSubmitted
		self.journalEntryCreated = journalEntryCreated
		self.certificateSupportedByPointOfCare = certificateSupportedByPointOfCare
		self.certificateConsentGiven = certificateConsentGiven
		self.certificateRequested = certificateRequested
		self.uniqueCertificateIdentifier = uniqueCertificateIdentifier
	}

	// MARK: - Protocol Codable

	enum CodingKeys: String, CodingKey {
		case pointOfCareConsentDate
		case sampleCollectionDate
		case registrationDate
		case registrationToken
		case qrCodeHash
		case testedPerson
		case testResult
		case finalTestResultReceivedDate
		case positiveTestResultWasShown
		case isSubmissionConsentGiven
		case submissionTAN
		case keysSubmitted
		case journalEntryCreated
		case certificateSupportedByPointOfCare
		case certificateConsentGiven
		case certificateRequested
		case uniqueCertificateIdentifier
	}

	init(from decoder: Decoder) throws {
		let container = try decoder.container(keyedBy: CodingKeys.self)

		pointOfCareConsentDate = try container.decode(Date.self, forKey: .pointOfCareConsentDate)
		sampleCollectionDate = try container.decodeIfPresent(Date.self, forKey: .sampleCollectionDate)
		registrationDate = try container.decodeIfPresent(Date.self, forKey: .registrationDate)
		registrationToken = try container.decodeIfPresent(String.self, forKey: .registrationToken)
		qrCodeHash = try container.decodeIfPresent(String.self, forKey: .qrCodeHash)

		testedPerson = try container.decode(TestedPerson.self, forKey: .testedPerson)

		testResult = try container.decode(TestResult.self, forKey: .testResult)
		finalTestResultReceivedDate = try container.decodeIfPresent(Date.self, forKey: .finalTestResultReceivedDate)
		positiveTestResultWasShown = try container.decode(Bool.self, forKey: .positiveTestResultWasShown)

		isSubmissionConsentGiven = try container.decode(Bool.self, forKey: .isSubmissionConsentGiven)
		submissionTAN = try container.decodeIfPresent(String.self, forKey: .submissionTAN)
		keysSubmitted = try container.decode(Bool.self, forKey: .keysSubmitted)

		journalEntryCreated = try container.decode(Bool.self, forKey: .journalEntryCreated)

		certificateSupportedByPointOfCare = try container.decodeIfPresent(Bool.self, forKey: .certificateSupportedByPointOfCare) ?? false
		certificateConsentGiven = try container.decodeIfPresent(Bool.self, forKey: .certificateConsentGiven) ?? false
		certificateRequested = try container.decodeIfPresent(Bool.self, forKey: .certificateRequested) ?? false

		uniqueCertificateIdentifier = try container.decodeIfPresent(String.self, forKey: .uniqueCertificateIdentifier)
	}

	// MARK: - Internal

	// The date of when the consent was provided by the tested person at the Point of Care.
	var pointOfCareConsentDate: Date
	// The date of when the test sample was collected.
	var sampleCollectionDate: Date?
	var registrationDate: Date?
	var registrationToken: String?
	var qrCodeHash: String?

	var testedPerson: TestedPerson

	var testResult: TestResult
	var finalTestResultReceivedDate: Date?
	var positiveTestResultWasShown: Bool

	var isSubmissionConsentGiven: Bool
	// Can only be used once to submit, cached here in case submission fails
	var submissionTAN: String?
	var keysSubmitted: Bool

	var journalEntryCreated: Bool

	var certificateSupportedByPointOfCare: Bool
	var certificateConsentGiven: Bool
	var certificateRequested: Bool

	var uniqueCertificateIdentifier: String?

	var testDate: Date {
		return sampleCollectionDate ?? pointOfCareConsentDate
	}

	mutating func set(uniqueCertificateIdentifier: String) {
		self.uniqueCertificateIdentifier = uniqueCertificateIdentifier
	}
}
