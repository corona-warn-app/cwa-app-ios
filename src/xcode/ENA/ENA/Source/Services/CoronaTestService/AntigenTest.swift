////
// 🦠 Corona-Warn-App
//

import Foundation

struct AntigenTest: Equatable, Codable {

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

		let outputFormatter = DateFormatter()
		outputFormatter.dateStyle = .medium
		outputFormatter.timeStyle = .none

		return outputFormatter.string(from: date)
	}

}
