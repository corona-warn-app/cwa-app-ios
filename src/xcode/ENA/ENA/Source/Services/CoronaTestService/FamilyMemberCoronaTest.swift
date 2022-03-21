////
// 🦠 Corona-Warn-App
//

import Foundation

enum FamilyMemberCoronaTest: CoronaTest, Equatable, Codable, Hashable, RecycleBinIdentifiable {

	case pcr(FamilyMemberPCRTest)
	case antigen(FamilyMemberAntigenTest)

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
