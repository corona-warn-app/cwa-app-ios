//
// 🦠 Corona-Warn-App
//

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
	case srsSUB429
}

extension SRSError: ErrorCodeProviding {
	var description: String {
		switch self {
		case .ppacError(let ppacError):
			return ppacError.description
		case .otpError(let otpError):
			return otpError.description
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
		case .srsSUB429:
			return "SRS_SUB_429"
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
		case .srsOTPServerError, .srsSUBServerError, .srsSUB429:
			return .tryAgainLater
		}
	}
}
