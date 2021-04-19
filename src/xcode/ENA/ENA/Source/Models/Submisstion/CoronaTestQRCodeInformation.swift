////
// 🦠 Corona-Warn-App
//

import Foundation
// swiftlint:disable pattern_matching_keywords
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
		switch (lhs, rhs) {
		case (.pcr(let lhsGuid), .pcr(let rhsGuid)):
			return lhsGuid == rhsGuid
		case (.antigen(let lhsAntigenTestInformation), .antigen(let rhsAntigenTestInformation)):
			return lhsAntigenTestInformation == rhsAntigenTestInformation
		case (.antigen, .pcr), (.pcr, .antigen):
			return false
		}
	}
}
