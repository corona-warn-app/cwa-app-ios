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
	case deviceTokenInvalid
	case deviceTokenRedeemed
	case deviceTokenSyntaxError
	case noNetworkConnection

	var description: String {
		switch self {
		case .generalError(let error):
			if let e = error?.localizedDescription {
				return "generalError with underlying: \(e)"
			} else {
				return "generalError"
			}
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
		case .noNetworkConnection:
			return "noNetworkConnection"
		}
	}
	
	var errorDescription: String? {
		switch self {
		case .noNetworkConnection:
			return AppStrings.Common.noNetworkConnection
		default:
			return localizedDescription
		}
	}

	static func == (lhs: OTPError, rhs: OTPError) -> Bool {
		return lhs.description == rhs.description
	}
}
