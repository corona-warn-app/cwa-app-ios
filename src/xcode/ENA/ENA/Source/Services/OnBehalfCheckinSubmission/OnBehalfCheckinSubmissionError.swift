//
// 🦠 Corona-Warn-App
//

import Foundation
import OpenCombine

enum OnBehalfCheckinSubmissionError: LocalizedError, Equatable {
	case teleTanError(ServiceError<TeleTanError>)
	case registrationTokenError(ServiceError<RegistrationTokenError>)
	case submissionError(SubmissionError)

	var errorDescription: String? {
		switch self {
		case .teleTanError(let failure):
			switch failure {
			case .receivedResourceError(let teleTanError):
				switch teleTanError {
				case .teleTanAlreadyUsed, .qrAlreadyUsed:
					return "\(AppStrings.OnBehalfCheckinSubmission.Error.invalidTAN) (REGTOKEN_OB_CLIENT_ERROR)"
				}
			case .transportationError(let transportationError):
				if let error = transportationError as NSError?,
				   error.domain == NSURLErrorDomain,
				   error.code == NSURLErrorNotConnectedToInternet {
					return "\(AppStrings.OnBehalfCheckinSubmission.Error.noNetwork) (REGTOKEN_OB_NO_NETWORK)"
				} else {
					return "\(AppStrings.OnBehalfCheckinSubmission.Error.noNetwork) (UNKOWN)"
				}
			case .unexpectedServerError(let statusCode) where (400...409).contains(statusCode):
				return "\(AppStrings.OnBehalfCheckinSubmission.Error.invalidTAN) (REGTOKEN_OB_CLIENT_ERROR)"
			case .unexpectedServerError(let statusCode) where (500...509).contains(statusCode):
				return "\(AppStrings.OnBehalfCheckinSubmission.Error.tryAgain) (REGTOKEN_OB_SERVER_ERROR)"
			default:
				return "\(AppStrings.OnBehalfCheckinSubmission.Error.tryAgain) (\(failure))"
			}
		case .registrationTokenError(let failure):
			switch failure {
			case .transportationError(let transportationError):
				if let error = transportationError as NSError?,
				   error.domain == NSURLErrorDomain,
				   error.code == NSURLErrorNotConnectedToInternet {
					return "\(AppStrings.OnBehalfCheckinSubmission.Error.noNetwork) (TAN_OB_NO_NETWORK)"
				} else {
					return "\(AppStrings.OnBehalfCheckinSubmission.Error.noNetwork) (UNKOWN)"
				}
			case .unexpectedServerError(let statusCode) where (400...409).contains(statusCode):
				return "\(AppStrings.OnBehalfCheckinSubmission.Error.failed) (TAN_OB_CLIENT_ERROR)"
			case .unexpectedServerError(let statusCode) where (500...509).contains(statusCode):
				return "\(AppStrings.OnBehalfCheckinSubmission.Error.tryAgain) (TAN_OB_SERVER_ERROR)"
			default:
				return "\(AppStrings.OnBehalfCheckinSubmission.Error.tryAgain) (\(failure))"
			}
		case .submissionError(let submissionError):
			switch submissionError {
			case .invalidPayloadOrHeaders, .invalidTan:
				return "\(AppStrings.OnBehalfCheckinSubmission.Error.failed) (SUBMISSION_OB_CLIENT_ERROR)"
			case .serverError(let statusCode) where (400...409).contains(statusCode),
				 .other(.serverError(let statusCode)) where (400...409).contains(statusCode):
				return "\(AppStrings.OnBehalfCheckinSubmission.Error.failed) (SUBMISSION_OB_CLIENT_ERROR)"
			case .serverError(let statusCode) where (500...509).contains(statusCode),
				 .other(.serverError(let statusCode)) where (500...509).contains(statusCode):
				return "\(AppStrings.OnBehalfCheckinSubmission.Error.tryAgain) (SUBMISSION_OB_SERVER_ERROR)"
			case .other(.noNetworkConnection):
				return "\(AppStrings.OnBehalfCheckinSubmission.Error.noNetwork) (SUBMISSION_OB_NO_NETWORK)"
			default:
				return "\(AppStrings.OnBehalfCheckinSubmission.Error.tryAgain) (\(submissionError))"
			}
		}
	}
}
