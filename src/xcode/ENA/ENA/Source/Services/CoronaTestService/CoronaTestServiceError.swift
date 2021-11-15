////
// 🦠 Corona-Warn-App
//

import Foundation

enum CoronaTestServiceError: LocalizedError, Equatable {
	case responseFailure(URLSession.Response.Failure)
	case serviceError(ServiceError<TeleTanError>)
	case unknownTestResult
	case testExpired
	case noRegistrationToken
	case noCoronaTestOfRequestedType
	case malformedDateOfBirthKey

	var errorDescription: String? {
		switch self {
		case let .responseFailure(responseFailure):
			return responseFailure.errorDescription
		case .noRegistrationToken:
			return AppStrings.ExposureSubmissionError.noRegistrationToken
		case .testExpired:
			return AppStrings.ExposureSubmission.qrCodeExpiredAlertText
		default:
			Log.error("\(self)", log: .api)
			return AppStrings.ExposureSubmissionError.defaultError
		}
	}
}
