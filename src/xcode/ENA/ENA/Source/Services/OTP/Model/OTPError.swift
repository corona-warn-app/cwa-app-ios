////
// 🦠 Corona-Warn-App
//

import Foundation

enum OTPError: Error {
	case generalError
	case invalidResponseError
	case internalServerError
	case otpAlreadyUsedThisMonth
	case otherServerError
	case apiTokenAlreadyIssued
	case apiTokenExpired
	case apiTokenQuotaExceeded
	case deviceTokenInvalid
	case deviceTokenRedeemed
	case deviceTokenSyntaxError

	var description: String {
		switch self {
		case .generalError:
			return "generalError"
		case .invalidResponseError:
			return "invalidResponseError"
		case .internalServerError:
			return "internalServerError"
		case .otpAlreadyUsedThisMonth:
			return "otpAlreadyUsedThisMonth"
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
		}
	}
}
