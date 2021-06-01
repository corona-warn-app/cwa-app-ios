////
// 🦠 Corona-Warn-App
//

import Foundation

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
	case pcr(guid: String)
	case antigen(qrCodeInformation: AntigenTestQRCodeInformation)
	case teleTAN(tan: String)
	
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
		case let (.pcr(guid: lhsGuid), .pcr(guid: rhsGuid)):
			return lhsGuid == rhsGuid
		case let (.antigen(qrCodeInformation: lhsAntigenTestInformation), .antigen(qrCodeInformation: rhsAntigenTestInformation)):
			return lhsAntigenTestInformation == rhsAntigenTestInformation
		case let (.teleTAN(tan: lhsTAN), .teleTAN(tan: rhsTAN)):
			return lhsTAN == rhsTAN
		default:
			return false
		}
	}
}
