////
// 🦠 Corona-Warn-App
//

import Foundation


enum QRCodeError: Error {
	case invalidTestCode
}

enum CoronaTestQRCodeInformation {
	case pcr(String)
	case antigen(AntigenTestInformation)
	
	// we cant declare the enum type to Int because we have properties inside the cases
	
	var testType: CoronaTestType {
		switch self {
		case .pcr:
			return .pcr
		case .antigen:
			return .antigen
		}
	}
}

extension CoronaTestQRCodeInformation: Equatable {
	static func == (lhs: CoronaTestQRCodeInformation, rhs: CoronaTestQRCodeInformation) -> Bool {
		switch lhs {
		case .pcr(let lhsGuid):
			switch rhs {
			case .pcr(let rhsGuid):
				return lhsGuid == rhsGuid
			default:
				return false
			}
		case .antigen(let lhsAntigenTestInformation):
			switch rhs {
			case .antigen(let rhsAntigenTestInformation):
				return lhsAntigenTestInformation == rhsAntigenTestInformation
			default:
				return false
			}
		}
	}
}
