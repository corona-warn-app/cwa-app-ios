//
// 🦠 Corona-Warn-App
//

import Foundation

protocol ErrorTextKeyProviding: Error {
	/// The Text Key aims which error codes share the same error message.
	var textKey: String { get }
}

protocol ErrorCodeProviding: Error {
	/// Error Code
	var description: String { get }
}

enum SRSServerError: Error {
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

extension SRSServerError: ErrorCodeProviding {
	var description: String {
		switch self {
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

extension SRSServerError: ErrorTextKeyProviding {
	var textKey: String {
		switch self {
		case .srsOTPClientError:
			return "CALL_HOTLINE"
		case .srsOTPNetworkError:
			return "NO_NETWORK"
		case .srsOTPServerError:
			return "TRY_AGAIN_LATER"
		case .srsOTP400:
			return "CALL_HOTLINE"
		case .srsOTP401:
			return "CALL_HOTLINE"
		case .srsOTP403:
			return "CALL_HOTLINE"
		case .srsSUBClientError:
			return "CALL_HOTLINE"
		case .srsSUBNoNetwork:
			return "NO_NETWORK"
		case .srsSUBServerError:
			return "TRY_AGAIN_LATER"
		case .srsSUB400:
			return "CALL_HOTLINE"
		case .srsSUB403:
			return "CALL_HOTLINE"
		}
	}
}
