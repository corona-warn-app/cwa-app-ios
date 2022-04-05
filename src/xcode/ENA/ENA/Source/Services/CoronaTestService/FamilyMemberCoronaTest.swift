////
// 🦠 Corona-Warn-App
//

import Foundation

enum FamilyMemberCoronaTest: Equatable, Codable, Hashable, RecycleBinIdentifiable {

	case pcr(FamilyMemberPCRTest)
	case antigen(FamilyMemberAntigenTest)

	var displayName: String {
		switch self {
		case .pcr(let pcrTest):
			return pcrTest.displayName
		case .antigen(let antigenTest):
			return antigenTest.displayName
		}
	}

	var registrationDate: Date {
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
				self = .pcr(pcrTest)
			case .antigen(var antigenTest):
				antigenTest.registrationToken = newValue
				self = .antigen(antigenTest)
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

	var isNew: Bool {
		get {
			switch self {
			case .pcr(let pcrTest):
				return pcrTest.isNew
			case .antigen(let antigenTest):
				return antigenTest.isNew
			}
		}
		set {
			switch self {
			case .pcr(var pcrTest):
				pcrTest.isNew = newValue
				self = .pcr(pcrTest)
			case .antigen(var antigenTest):
				antigenTest.isNew = newValue
				self = .antigen(antigenTest)
			}
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
				self = .pcr(pcrTest)
			case .antigen(var antigenTest):
				antigenTest.testResult = newValue
				self = .antigen(antigenTest)
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
				self = .antigen(antigenTest)
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
				self = .pcr(pcrTest)
			case .antigen(var antigenTest):
				antigenTest.finalTestResultReceivedDate = newValue
				self = .antigen(antigenTest)
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
				self = .pcr(pcrTest)
			case .antigen(var antigenTest):
				antigenTest.testResultWasShown = newValue
				self = .antigen(antigenTest)
			}
		}
	}

	var certificateSupportedByPointOfCare: Bool {
		switch self {
		case .pcr(let pcrTest):
			return pcrTest.certificateSupportedByPointOfCare
		case .antigen(let antigenTest):
			return antigenTest.certificateSupportedByPointOfCare
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
				self = .pcr(pcrTest)
			case .antigen(var antigenTest):
				antigenTest.certificateRequested = newValue
				self = .antigen(antigenTest)
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
				self = .pcr(pcrTest)
			case .antigen(var antigenTest):
				antigenTest.uniqueCertificateIdentifier = newValue
				self = .antigen(antigenTest)
			}
		}
	}

	var isOutdated: Bool {
		get {
			switch self {
			case .pcr:
				return false
			case .antigen(let antigenTest):
				return antigenTest.isOutdated
			}
		}
		set {
			switch self {
			case .pcr:
				break
			case .antigen(var antigenTest):
				antigenTest.isOutdated = newValue
				self = .antigen(antigenTest)
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
				self = .pcr(pcrTest)
			case .antigen(var antigenTest):
				antigenTest.isLoading = newValue
				self = .antigen(antigenTest)
			}
		}
	}

	var hasUnseenNews: Bool {
		isNew || (!testResultWasShown && finalTestResultReceivedDate != nil)
	}

	// MARK: - Protocol RecycleBinIdentifiable

	var recycleBinIdentifier: String {
		return String(hashValue)
	}

}
