////
// 🦠 Corona-Warn-App
//

import Foundation

enum UserCoronaTest: CoronaTest, Equatable, Codable, Hashable, RecycleBinIdentifiable {

	case pcr(UserPCRTest)
	case antigen(UserAntigenTest)

	var registrationDate: Date? {
		switch self {
		case .pcr(let pcrTest):
			return pcrTest.registrationDate
		case .antigen(let antigenTest):
			return antigenTest.registrationDate
		}
	}

	var registrationToken: String? {
		switch self {
		case .pcr(let pcrTest):
			return pcrTest.registrationToken
		case .antigen(let antigenTest):
			return antigenTest.registrationToken
		}
	}

	var qrCodeHash: String? {
		switch self {
		case .pcr(let pcrTest):
			return pcrTest.qrCodeHash
		case .antigen(let antigenTest):
			return antigenTest.qrCodeHash
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
			return antigenTest.testDate
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

	var certificateConsentGiven: Bool {
		switch self {
		case .pcr(let pcrTest):
			return pcrTest.certificateConsentGiven
		case .antigen(let antigenTest):
			return antigenTest.certificateConsentGiven
		}
	}

	var certificateRequested: Bool {
		switch self {
		case .pcr(let pcrTest):
			return pcrTest.certificateRequested
		case .antigen(let antigenTest):
			return antigenTest.certificateRequested
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

	var protobufType: SAP_Internal_SubmissionPayload.SubmissionType {
		switch self {
		case .pcr:
			return .pcrTest
		case .antigen:
			return .rapidTest
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

	var uniqueCertificateIdentifier: String? {
		switch self {
		case .pcr(let test):
			return test.uniqueCertificateIdentifier
		case .antigen(let test):
			return test.uniqueCertificateIdentifier
		}
	}

	// MARK: - Protocol RecycleBinIdentifiable

	var recycleBinIdentifier: String {
		return String(hashValue)
	}

}
