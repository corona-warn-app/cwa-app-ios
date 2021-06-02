////
// 🦠 Corona-Warn-App
//

import Foundation

struct AntigenTest: Equatable {

	// The date of when the consent was provided by the tested person at the Point of Care.
	var pointOfCareConsentDate: Date
	// The date of when the test sample was collected.
	var sampleCollectionDate: Date?
	var registrationDate: Date?
	var registrationToken: String?

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
	var certificateCreated: Bool

	var testDate: Date {
		return sampleCollectionDate ?? pointOfCareConsentDate
	}

}

extension AntigenTest: Codable {

	// MARK: - Protocol Codable

	enum CodingKeys: String, CodingKey {
		case pointOfCareConsentDate
		case sampleCollectionDate
		case registrationDate
		case registrationToken
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
		case certificateCreated
	}

	init(from decoder: Decoder) throws {
		let container = try decoder.container(keyedBy: CodingKeys.self)

		pointOfCareConsentDate = try container.decode(Date.self, forKey: .pointOfCareConsentDate)
		sampleCollectionDate = try container.decodeIfPresent(Date.self, forKey: .sampleCollectionDate)
		registrationDate = try container.decodeIfPresent(Date.self, forKey: .registrationDate)
		registrationToken = try container.decodeIfPresent(String.self, forKey: .registrationToken)

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
		certificateCreated = try container.decodeIfPresent(Bool.self, forKey: .certificateCreated) ?? false
	}

}

struct TestedPerson: Codable, Equatable {

	let firstName: String?
	let lastName: String?
	let dateOfBirth: String?

	var fullName: String? {
		let formatter = PersonNameComponentsFormatter()
		formatter.style = .long

		var nameComponents = PersonNameComponents()
		nameComponents.givenName = firstName
		nameComponents.familyName = lastName

		return formatter.string(from: nameComponents)
	}

	var formattedDateOfBirth: String? {
		guard let dateOfBirth = dateOfBirth else {
			return nil
		}

		let inputFormatter = ISO8601DateFormatter()
		inputFormatter.formatOptions = [.withFullDate]
		inputFormatter.timeZone = TimeZone.autoupdatingCurrent

		guard let date = inputFormatter.date(from: dateOfBirth) else {
			return nil
		}

		return DateFormatter.localizedString(from: date, dateStyle: .medium, timeStyle: .none)
	}

}
