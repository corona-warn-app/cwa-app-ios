//
// 🦠 Corona-Warn-App
//

import Foundation
import OpenCombine

enum OnBehalfCheckinSubmissionError: LocalizedError {
	case registrationTokenError(URLSession.Response.Failure)
	case submissionTANError(URLSession.Response.Failure)
	case submissionError(SubmissionError)

	var errorDescription: String? {
		switch self {
		case .registrationTokenError(let failure):
			switch failure {
			case .teleTanAlreadyUsed, .qrAlreadyUsed:
				return "\(AppStrings.OnBehalfCheckinSubmission.Error.invalidTAN) (REGTOKEN_OB_CLIENT_ERROR)"
			case .serverError(let statusCode) where (400...409).contains(statusCode):
				return "\(AppStrings.OnBehalfCheckinSubmission.Error.invalidTAN) (REGTOKEN_OB_CLIENT_ERROR)"
			case .serverError(let statusCode) where (500...509).contains(statusCode):
				return "\(AppStrings.OnBehalfCheckinSubmission.Error.tryAgain) (REGTOKEN_OB_SERVER_ERROR)"
			case .noNetworkConnection:
				return "\(AppStrings.OnBehalfCheckinSubmission.Error.noNetwork) (REGTOKEN_OB_NO_NETWORK)"
			default:
				return "\(AppStrings.OnBehalfCheckinSubmission.Error.tryAgain) (\(failure))"
			}
		case .submissionTANError(let failure):
			switch failure {
			case .serverError(let statusCode) where (400...409).contains(statusCode):
				return "\(AppStrings.OnBehalfCheckinSubmission.Error.failed) (TAN_OB_CLIENT_ERROR)"
			case .serverError(let statusCode) where (500...509).contains(statusCode):
				return "\(AppStrings.OnBehalfCheckinSubmission.Error.tryAgain) (TAN_OB_SERVER_ERROR)"
			case .noNetworkConnection:
				return "\(AppStrings.OnBehalfCheckinSubmission.Error.noNetwork) (TAN_OB_NO_NETWORK)"
			default:
				return "\(AppStrings.OnBehalfCheckinSubmission.Error.tryAgain) (\(failure))"
			}
		case .submissionError(let submissionError):
			switch submissionError {
			case .invalidPayloadOrHeaders, .invalidTan:
				return "\(AppStrings.OnBehalfCheckinSubmission.Error.failed) (TAN_OB_CLIENT_ERROR)"
			case .serverError(let statusCode) where (400...409).contains(statusCode):
				return "\(AppStrings.OnBehalfCheckinSubmission.Error.failed) (TAN_OB_CLIENT_ERROR)"
			case .serverError(let statusCode) where (500...509).contains(statusCode):
				return "\(AppStrings.OnBehalfCheckinSubmission.Error.tryAgain) (TAN_OB_SERVER_ERROR)"
			case .other(.noNetworkConnection):
				return "\(AppStrings.OnBehalfCheckinSubmission.Error.noNetwork) (TAN_OB_NO_NETWORK)"
			default:
				return "\(AppStrings.OnBehalfCheckinSubmission.Error.tryAgain) (\(submissionError))"
			}
		}
	}
}
