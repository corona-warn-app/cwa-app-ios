////
// 🦠 Corona-Warn-App
//

import Foundation

enum CoronaTestServiceError: LocalizedError, Equatable {
	case responseFailure(URLSession.Response.Failure)
	case teleTanError(ServiceError<TeleTanError>) // Rename to teleTanServiceError ?
	case registrationTokenError(ServiceError<RegistrationTokenError>)
	case testResultError(ServiceError<TestResultError>)
	case testExpired
	case noRegistrationToken
	case noCoronaTestOfRequestedType
	case malformedDateOfBirthKey

	var errorDescription: String? {
		switch self {
		case let .responseFailure(responseFailure):
			return responseFailure.localizedDescription
		case .noRegistrationToken:
			return AppStrings.ExposureSubmissionError.noRegistrationToken
		case .testExpired:
			return AppStrings.ExposureSubmission.qrCodeExpiredAlertText
		case .teleTanError(let serviceError):
			switch serviceError {
			case .transportationError:
				return AppStrings.ExposureSubmissionError.noNetworkConnection
			case .unexpectedServerError(let errorCode):
				return "\(AppStrings.ExposureSubmissionError.other)\(errorCode)\(AppStrings.ExposureSubmissionError.otherend)"
			case .receivedResourceError(let receivedResourceError):
				return receivedResourceError.localizedDescription
			case .invalidResponseType:
				return AppStrings.ExposureSubmissionError.noResponse
			case .resourceError, .invalidResponse:
				return AppStrings.ExposureSubmissionError.invalidResponse
			case .invalidRequestError, .trustEvaluationError, .fakeResponse, .noReceiveModelToInterruptLoading, .wrongResourceType:
				return AppStrings.ExposureSubmissionError.defaultError + "\n(\(String(describing: self)))"
			}
		case .registrationTokenError(let registrationTokenError):
			switch registrationTokenError {
			case .transportationError:
				return AppStrings.ExposureSubmissionError.noNetworkConnection
			case .unexpectedServerError(let errorCode):
				return "\(AppStrings.ExposureSubmissionError.other)\(errorCode)\(AppStrings.ExposureSubmissionError.otherend)"
			case .receivedResourceError(let receivedResourceError):
				return receivedResourceError.localizedDescription
			case .invalidResponseType:
				return AppStrings.ExposureSubmissionError.noResponse
			case .resourceError, .invalidResponse:
				return AppStrings.ExposureSubmissionError.invalidResponse
			case .invalidRequestError, .trustEvaluationError, .fakeResponse, .noReceiveModelToInterruptLoading, .wrongResourceType:
				return AppStrings.ExposureSubmissionError.defaultError + "\n(\(String(describing: self)))"
			}
		case .testResultError(let testResultError):
			return testResultError.errorDescription
		case .noCoronaTestOfRequestedType, .malformedDateOfBirthKey:
			Log.error("\(self)", log: .api)
			return AppStrings.ExposureSubmissionError.defaultError + "\n(\(String(describing: self)))"
		}
	}
}
