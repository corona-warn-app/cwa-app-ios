////
// 🦠 Corona-Warn-App
//

import Foundation

enum FamilyMemberCoronaTest: Equatable, Codable, Hashable, RecycleBinIdentifiable {

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
		get {
			switch self {
			case .pcr(let pcrTest):
				return pcrTest.registrationToken
			case .antigen(let antigenTest):
				return antigenTest.registrationToken
			}
		}
		set {
			switch self {
			case .pcr(var pcrTest):
				pcrTest.registrationToken = newValue
			case .antigen(var antigenTest):
				antigenTest.registrationToken = newValue
			}
		}
	}

	var qrCodeHash: String {
		switch self {
		case .pcr(let pcrTest):
			return pcrTest.qrCodeHash
		case .antigen(let antigenTest):
			return antigenTest.qrCodeHash
		}
	}

	var testResult: TestResult {
		get {
			switch self {
			case .pcr(let pcrTest):
				return pcrTest.testResult
			case .antigen(let antigenTest):
				return antigenTest.testResult
			}
		}
		set {
			switch self {
			case .pcr(var pcrTest):
				pcrTest.testResult = newValue
			case .antigen(var antigenTest):
				antigenTest.testResult = newValue
			}
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

	var sampleCollectionDate: Date? {
		get {
			switch self {
			case .pcr:
				return nil
			case .antigen(let antigenTest):
				return antigenTest.sampleCollectionDate
			}
		}
		set {
			switch self {
			case .pcr:
				break
			case .antigen(var antigenTest):
				antigenTest.sampleCollectionDate = newValue
			}
		}
	}

	var finalTestResultReceivedDate: Date? {
		get {
			switch self {
			case .pcr(let pcrTest):
				return pcrTest.finalTestResultReceivedDate
			case .antigen(let antigenTest):
				return antigenTest.finalTestResultReceivedDate
			}
		}
		set {
			switch self {
			case .pcr(var pcrTest):
				pcrTest.finalTestResultReceivedDate = newValue
			case .antigen(var antigenTest):
				antigenTest.finalTestResultReceivedDate = newValue
			}
		}
	}

	var testResultWasShown: Bool {
		get {
			switch self {
			case .pcr(let pcrTest):
				return pcrTest.testResultWasShown
			case .antigen(let antigenTest):
				return antigenTest.testResultWasShown
			}
		}
		set {
			switch self {
			case .pcr(var pcrTest):
				pcrTest.testResultWasShown = newValue
			case .antigen(var antigenTest):
				antigenTest.testResultWasShown = newValue
			}
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
		get {
			switch self {
			case .pcr(let pcrTest):
				return pcrTest.certificateRequested
			case .antigen(let antigenTest):
				return antigenTest.certificateRequested
			}
		}
		set {
			switch self {
			case .pcr(var pcrTest):
				pcrTest.certificateRequested = newValue
			case .antigen(var antigenTest):
				antigenTest.certificateRequested = newValue
			}
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

	var pcrTest: FamilyMemberPCRTest? {
		switch self {
		case .pcr(let test):
			return test
		case .antigen:
			return nil
		}
	}

	var antigenTest: FamilyMemberAntigenTest? {
		switch self {
		case .pcr:
			return nil
		case .antigen(let test):
			return test
		}
	}

	var uniqueCertificateIdentifier: String? {
		get {
			switch self {
			case .pcr(let pcrTest):
				return pcrTest.uniqueCertificateIdentifier
			case .antigen(let antigenTest):
				return antigenTest.uniqueCertificateIdentifier
			}
		}
		set {
			switch self {
			case .pcr(var pcrTest):
				pcrTest.uniqueCertificateIdentifier = newValue
			case .antigen(var antigenTest):
				antigenTest.uniqueCertificateIdentifier = newValue
			}
		}
	}

	var isLoading: Bool {
		get {
			switch self {
			case .pcr(let pcrTest):
				return pcrTest.isLoading
			case .antigen(let antigenTest):
				return antigenTest.isLoading
			}
		}
		set {
			switch self {
			case .pcr(var pcrTest):
				pcrTest.isLoading = newValue
			case .antigen(var antigenTest):
				antigenTest.isLoading = newValue
			}
		}
	}

	// MARK: - Protocol RecycleBinIdentifiable

	var recycleBinIdentifier: String {
		return String(hashValue)
	}

}
