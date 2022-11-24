//
// 🦠 Corona-Warn-App
//

import Foundation

protocol SRSErrorAlertProviding: Error {
	/// The SRS Error Alert type aims to share error message based on error codes.
	/// The type is optional, because there are error cases of error enums, that hasn't a relationship to SRS
	var srsErrorAlert: SRSErrorAlert? { get }
}

protocol ErrorCodeProviding: Error {
	typealias ErrorCode = String
	/// Error Code
	var description: ErrorCode { get }
}

enum SRSError: Error, Equatable {
	case ppacError(PPACError)
	case otpError(OTPError)

	case srsOTPClientError
	case srsOTPNetworkError
	case srsOTPServerError
	case srsOTP400
	case srsOTP401
	case srsOTP403

	case srsSUBClientError
	case srsSUBNoNetwork
	case srsSUBServerError
	case srsSUB400
	case srsSUB403
}

extension SRSError: ErrorCodeProviding {
	var description: String {
		switch self {
		case .ppacError(let ppacError):
			return "ppacError: \(ppacError.description)"
		case .otpError(let otpError):
			return "otpError: \(otpError.description)"
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

extension SRSError: SRSErrorAlertProviding {
	var srsErrorAlert: SRSErrorAlert? {
		switch self {
		case .ppacError(let ppacError):
			return ppacError.srsErrorAlert
		case .otpError(let otpError):
			return otpError.srsErrorAlert
		case .srsOTPClientError, .srsOTP400, .srsOTP401, .srsOTP403, .srsSUBClientError, .srsSUB400, .srsSUB403:
			return .callHotline
		case .srsOTPNetworkError, .srsSUBNoNetwork:
			return .noNetwork
		case .srsOTPServerError, .srsSUBServerError:
			return .tryAgainLater
		}
	}
}
