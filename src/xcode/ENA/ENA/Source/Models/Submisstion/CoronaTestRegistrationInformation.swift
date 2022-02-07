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

enum CoronaTestRegistrationInformation: Equatable {
	case pcr(guid: String, qrCodeHash: String)
	case rapidPCR(qrCodeInformation: AntigenTestQRCodeInformation, qrCodeHash: String)
	case antigen(qrCodeInformation: AntigenTestQRCodeInformation, qrCodeHash: String)
	case teleTAN(tan: String)
	
	// we cant declare the enum type to Int because we have properties inside the cases
	
	var testType: CoronaTestType {
		switch self {
		case .pcr, .rapidPCR, .teleTAN:
			return .pcr
		case .antigen:
			return .antigen
		}
	}
}
