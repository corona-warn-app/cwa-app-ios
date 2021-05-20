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

enum CoronaTestQRCodeInformation {
	case pcr(String)
	case antigen(AntigenTestInformation)
	case pcrTeleTAN(String) // tan string
	
	// we cant declare the enum type to Int because we have properties inside the cases
	
	var testType: CoronaTestType {
		switch self {
		case .pcr, .pcrTeleTAN:
			return .pcr
		case .antigen:
			return .antigen
		}
	}
}

extension CoronaTestQRCodeInformation: Equatable {
	static func == (lhs: CoronaTestQRCodeInformation, rhs: CoronaTestQRCodeInformation) -> Bool {
		switch (lhs, rhs) {
		case (.pcr(let lhsGuid), .pcr(let rhsGuid)):
			return lhsGuid == rhsGuid
		case (.antigen(let lhsAntigenTestInformation), .antigen(let rhsAntigenTestInformation)):
			return lhsAntigenTestInformation == rhsAntigenTestInformation
		case (.pcrTeleTAN(let lhsTAN), .pcrTeleTAN(let thsTAN)):
			return lhsTAN == thsTAN
		default:
			return false
		}
	}
}
