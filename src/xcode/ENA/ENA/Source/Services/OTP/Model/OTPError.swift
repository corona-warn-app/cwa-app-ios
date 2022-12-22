////
// 🦠 Corona-Warn-App
//

import Foundation

enum OTPError: Error, Equatable, LocalizedError {
	case generalError(underlyingError: Error? = nil)
	case invalidResponseError
	case internalServerError
	case otpAlreadyUsedThisMonth
	case otherServerError
	case apiTokenAlreadyIssued
	case apiTokenExpired
	case apiTokenQuotaExceeded
	case deviceBlocked
	case deviceTokenInvalid
	case deviceTokenRedeemed
	case deviceTokenSyntaxError
	case noNetworkConnection

	case restServiceError(ServiceError<OTPAuthorizationError>)

    var description: String {
		switch self {
		case .generalError(let error):
			if let e = error?.localizedDescription {
				return "GENERAL_ERROR with underlying: \(e)"
			} else {
				return "GENERAL_ERROR"
			}
		case .invalidResponseError:
			return "INVALID_RESPONSE_ERROR"
		case .internalServerError:
			return "INTERNAL_SERVER_ERROR"
		case .otpAlreadyUsedThisMonth:
			return "OTP_ALREADY_USED_THIS_MONTH"
		case .otherServerError:
			return "OTHER_SERVER_ERROR"
		case .apiTokenAlreadyIssued:
			return "API_TOKEN_ALEARY_ISSUED"
		case .apiTokenExpired:
			return "API_TOKEN_EXPIRED"
		case .apiTokenQuotaExceeded:
			return "API_TOKEN_QUOTA_EXEEDED"
		case .deviceBlocked:
			return "DEVICE_BLOCKED"
		case .deviceTokenInvalid:
			return "DEVICE_TOKEN_INVALID"
		case .deviceTokenRedeemed:
			return "DEVICE_TOKEN_REDEEMED"
		case .deviceTokenSyntaxError:
			return "DEVICE_TOKEN_SYNTAX_ERROR"
		case .noNetworkConnection:
			return "NO_NETWORK_CONNECTION"
		case .restServiceError:
			return "REST_SERVICE_ERROR"
		}
    }
	
	var errorDescription: String? {
		switch self {
		case .noNetworkConnection:
			return AppStrings.Common.noNetworkConnectionDescription
		default:
			return description
		}
	}

	static func == (lhs: OTPError, rhs: OTPError) -> Bool {
		return lhs.description == rhs.description
	}
}

extension OTPError: SRSErrorAlertProviding {
	var srsErrorAlert: SRSErrorAlert? {
		switch self {
		case .apiTokenAlreadyIssued:
			return .tryAgainNextMonth
		case .apiTokenExpired, .deviceTokenInvalid, .deviceTokenSyntaxError:
			return .tryAgainLater
		case .apiTokenQuotaExceeded:
			return .submissionTooEarly
		default:
			return nil
		}
	}
}
