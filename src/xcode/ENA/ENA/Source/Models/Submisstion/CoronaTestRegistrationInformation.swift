////
// 🦠 Corona-Warn-App
//

import Foundation

enum QRCodeError: Error, Equatable {
	case invalidTestCode(RatError)

	var localizedDescription: String {
		switch self {
		case .invalidTestCode(let ratError):
			switch ratError {
			case .invalidPayload:
				return "Unsupported encoding. Supported encodings are base64 and base64url"
			case .invalidHash:
				return "Hash is invalid"
			case .invalidTimeStamp:
				return "Timestamp is invalid"
			case .invalidTestedPersonInformation:
				return "QRCode contains incomplete personal data"
			case .hashMismatch:
				return "Enerated hash doesn't match QRCode hash"
			}
		}
	}
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
	case antigen(qrCodeInformation: AntigenTestQRCodeInformation, qrCodeHash: String)
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
