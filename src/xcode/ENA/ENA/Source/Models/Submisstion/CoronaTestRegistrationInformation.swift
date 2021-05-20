////
// 🦠 Corona-Warn-App
//

import Foundation
// swiftlint:disable pattern_matching_keywords
enum QRCodeError: Error, Equatable {
	case invalidTestCode(RatError)
}
enum RatError {
	case invalidPayload
	case invalidHash
	case invalidTimeStamp
	case invalidTestedPersonInformation
	case hashMismatch
}

enum CoronaTestRegistrationInformation {
	case pcr(String)
	case antigen(AntigenTestInformation)
	case teleTAN(String) // tan string
	
	// we cant declare the enum type to Int because we have properties inside the cases
	
	var testType: CoronaTestType {
		switch self {
		case .pcr, .teleTAN:
			return .pcr
		case .antigen:
			return .antigen
		}
	}
}

extension CoronaTestRegistrationInformation: Equatable {
	static func == (lhs: CoronaTestRegistrationInformation, rhs: CoronaTestRegistrationInformation) -> Bool {
		switch (lhs, rhs) {
		case (.pcr(let lhsGuid), .pcr(let rhsGuid)):
			return lhsGuid == rhsGuid
		case (.antigen(let lhsAntigenTestInformation), .antigen(let rhsAntigenTestInformation)):
			return lhsAntigenTestInformation == rhsAntigenTestInformation
		case (.teleTAN(let lhsTAN), .teleTAN(let thsTAN)):
			return lhsTAN == thsTAN
		default:
			return false
		}
	}
}
