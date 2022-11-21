//
// 🦠 Corona-Warn-App
//

import Foundation

enum SRSError: Error {
	case ppacError(PPACError)
    case otpError(OTPError)

	case srsOTPClientError
	case srsOTPNetworkError
	case srsOTPServerError
	case srsOTP400
	case srsOTP401
	case srsOTP403
    
    case otherServerError
    case apiTokenAlreadyIssued
    case apiTokenExpired
    case apiTokenQuotaExceeded
    case deviceTokenInvalid
    case deviceTokenRedeemed
    case deviceTokenSyntaxError
    
	case srsSUBClientError
	case srsSUBNoNetwork
	case srsSUBServerError
	case srsSUB400
	case srsSUB403
	
	var description: String {
		switch self {
		case .ppacError(let ppacError):
			return "ppacError: \(ppacError.description)"
		case .srsOTPClientError:
			return "SRS_OTP_CLIENT_ERROR"
		case .srsOTPNetworkError:
			return "SRS_OTP_NO_NETWORK"
		case .srsOTPServerError:
			return "SRS_OTP_SERVER_ERROR"
		case .srsOTP400:
			return "SRS_OTP_400"
		case .srsOTP401:
			return "SRS_OTP_401"
		case .srsOTP403:
			return "SRS_OTP_403"
        case .otherServerError:
            return "otherServerError"
        case .apiTokenAlreadyIssued:
            return "apiTokenAlreadyIssued"
        case .apiTokenExpired:
            return "apiTokenExpired"
        case .apiTokenQuotaExceeded:
            return "apiTokenQuotaExceeded"
        case .deviceTokenInvalid:
            return "deviceTokenInvalid"
        case .deviceTokenRedeemed:
            return "deviceTokenRedeemed"
        case .deviceTokenSyntaxError:
            return "deviceTokenSyntaxError"
		case .srsSUBClientError:
			return "SRS_SUB_CLIENT_ERROR"
		case .srsSUBNoNetwork:
			return "SRS_SUB_NO_NETWORK"
		case .srsSUBServerError:
			return "SRS_SUB_SERVER_ERROR"
		case .srsSUB400:
			return "SRS_SUB_400"
		case .srsSUB403:
			return "SRS_SUB_403"
		}
	}
}
