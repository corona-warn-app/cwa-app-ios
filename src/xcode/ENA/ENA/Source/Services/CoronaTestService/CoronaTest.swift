////
// 🦠 Corona-Warn-App
//

import Foundation

enum CoronaTestType {

	case pcr
	case antigen

}

enum CoronaTest {

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
			return pcrTest.testRegistrationDate
		case .antigen(let antigenTest):
			return antigenTest.pointOfCareConsentDate
		}
	}

	var testResultReceivedDate: Date? {
		switch self {
		case .pcr(let pcrTest):
			return pcrTest.testResultReceivedDate
		case .antigen(let antigenTest):
			return antigenTest.testResultReceivedDate
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

}

struct PCRTest: Codable, Equatable {

	var registrationToken: String?
	var testRegistrationDate: Date

	var testResult: TestResult = .pending
	var testResultReceivedDate: Date?
	var positiveTestResultWasShown: Bool
	var isSubmissionConsentGiven: Bool

	// Can only be used once to submit, cached here in case submission fails
	var submissionTAN: String?
	var keysSubmitted: Bool

	var journalEntryCreated: Bool

}

struct AntigenTest: Codable, Equatable {

	var registrationToken: String?
	var testedPerson: TestedPerson

	// The date of when the consent was provided by the tested person at the Point of Care.
	var pointOfCareConsentDate: Date

	var testResult: TestResult = .pending
	var testResultReceivedDate: Date?
	var positiveTestResultWasShown: Bool
	var isSubmissionConsentGiven: Bool

	// Can only be used once to submit, cached here in case submission fails
	var submissionTAN: String?
	var keysSubmitted: Bool

	var journalEntryCreated: Bool

}

struct TestedPerson: Codable, Equatable {

	let name: String?
	let birthday: String?

}
