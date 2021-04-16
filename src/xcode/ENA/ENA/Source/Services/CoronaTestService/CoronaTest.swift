////
// 🦠 Corona-Warn-App
//

import Foundation

enum CoronaTestType: Int, CaseIterable {
	case pcr
	case antigen
}

enum CoronaTest: Equatable {

	case pcr(PCRTest)
	case antigen(AntigenTest)

	var registrationToken: String? {
		switch self {
		case .pcr(let pcrTest):
			return pcrTest.registrationToken
		case .antigen(let antigenTest):
			return antigenTest.registrationToken
		}
	}

	var testResult: TestResult {
		switch self {
		case .pcr(let pcrTest):
			return pcrTest.testResult
		case .antigen(let antigenTest):
			return antigenTest.testResult
		}
	}

	var testDate: Date {
		switch self {
		case .pcr(let pcrTest):
			return pcrTest.registrationDate
		case .antigen(let antigenTest):
			return antigenTest.pointOfCareConsentDate
		}
	}

	var finalTestResultReceivedDate: Date? {
		switch self {
		case .pcr(let pcrTest):
			return pcrTest.finalTestResultReceivedDate
		case .antigen(let antigenTest):
			return antigenTest.finalTestResultReceivedDate
		}
	}

	var positiveTestResultWasShown: Bool {
		switch self {
		case .pcr(let pcrTest):
			return pcrTest.positiveTestResultWasShown
		case .antigen(let antigenTest):
			return antigenTest.positiveTestResultWasShown
		}
	}

	var isSubmissionConsentGiven: Bool {
		switch self {
		case .pcr(let pcrTest):
			return pcrTest.isSubmissionConsentGiven
		case .antigen(let antigenTest):
			return antigenTest.isSubmissionConsentGiven
		}
	}

	var submissionTAN: String? {
		switch self {
		case .pcr(let pcrTest):
			return pcrTest.submissionTAN
		case .antigen(let antigenTest):
			return antigenTest.submissionTAN
		}
	}

	var keysSubmitted: Bool {
		switch self {
		case .pcr(let pcrTest):
			return pcrTest.keysSubmitted
		case .antigen(let antigenTest):
			return antigenTest.keysSubmitted
		}
	}

	var journalEntryCreated: Bool {
		switch self {
		case .pcr(let pcrTest):
			return pcrTest.journalEntryCreated
		case .antigen(let antigenTest):
			return antigenTest.journalEntryCreated
		}
	}

	var type: CoronaTestType {
		switch self {
		case .pcr:
			return .pcr
		case .antigen:
			return .antigen
		}
	}

	var pcrTest: PCRTest? {
		switch self {
		case .pcr(let test):
			return test
		case .antigen:
			return nil
		}
	}
	
	var antigenTest: AntigenTest? {
		switch self {
		case .pcr:
			return nil
		case .antigen(let test):
			return test
		}
	}

}

struct PCRTest: Equatable, Codable {

	var registrationDate: Date
	var registrationToken: String?

	var testResult: TestResult
	var finalTestResultReceivedDate: Date?
	var positiveTestResultWasShown: Bool

	var isSubmissionConsentGiven: Bool
	// Can only be used once to submit, cached here in case submission fails
	var submissionTAN: String?
	var keysSubmitted: Bool

	var journalEntryCreated: Bool

}

struct AntigenTest: Equatable, Codable {

	// The date of when the consent was provided by the tested person at the Point of Care.
	var pointOfCareConsentDate: Date
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
