//
// 🦠 Corona-Warn-App
//

import Foundation

enum ExposureSubmissionError: Error, Equatable {
	case other(String)
	case noRegistrationToken
	case enNotEnabled
	case notAuthorized
	case coronaTestServiceError(CoronaTestServiceError)

	/// User has not granted access to their keys
	case keysNotShared

	/// Access to keys was granted but no keys were collected by the exposure notification framework
	case noKeysCollected

	case noSubmissionConsent
	case noCoronaTestTypeGiven
	case noCoronaTestOfGivenType
	case noDevicePairingConsent
	case noAppConfiguration
	case invalidTan
	case invalidResponse
	case noNetworkConnection
	case teleTanAlreadyUsed
	case qrAlreadyUsed
	case regTokenNotExist
	case qrDoesNotExist
	case serverError(Int)
	case unknown
	case httpError(String)
	case `internal`
	case unsupported
	case rateLimited
	case fakeResponse
	case invalidPayloadOrHeaders
	case requestCouldNotBeBuilt
	case qrExpired
	case positiveTestResultNotShown // User has never seen his positive TestResult
	case malformedDateOfBirthKey
	case invalidRequest

	/// **[Deprecated]** Legacy state to indicate no (meaningful) response was given.
	///
	/// This had multiple reasons (offline, invalid payload, etc.) and was ambiguous. Please consider another state (e.g. `invalidResponse` or `noNetworkConnection`) and refactor existing solutions!
	case noResponse
}

extension ExposureSubmissionError: LocalizedError {
	var errorDescription: String? {
		switch self {
		case let .serverError(code):
			return "\(AppStrings.ExposureSubmissionError.other)\(code)\(AppStrings.ExposureSubmissionError.otherend)"
		case let .httpError(desc):
			return "\(AppStrings.ExposureSubmissionError.httpError)\n\(desc)"
		case .invalidTan:
			return AppStrings.ExposureSubmissionError.invalidTan
		case .enNotEnabled:
			return AppStrings.ExposureSubmissionError.enNotEnabled
		case .notAuthorized:
			return AppStrings.ExposureSubmissionError.notAuthorized
		case .noRegistrationToken:
			return AppStrings.ExposureSubmissionError.noRegistrationToken
		case .invalidResponse:
			return AppStrings.ExposureSubmissionError.invalidResponse
		case .noResponse:
			return AppStrings.ExposureSubmissionError.noResponse
		case .noNetworkConnection:
			return AppStrings.ExposureSubmissionError.noNetworkConnection
		case .noAppConfiguration:
			return AppStrings.ExposureSubmissionError.noAppConfiguration
		case .qrAlreadyUsed:
			return AppStrings.ExposureSubmissionError.qrAlreadyUsed
		case .qrDoesNotExist:
			return AppStrings.ExposureSubmissionError.qrNotExist
		case .teleTanAlreadyUsed:
			return AppStrings.ExposureSubmissionError.teleTanAlreadyUsed
		case .noKeysCollected:
			return AppStrings.ExposureSubmissionError.noKeysCollected
		case .internal:
			return AppStrings.Common.enError11Description
		case .unsupported:
			return AppStrings.Common.enError5Description
		case .rateLimited:
			return AppStrings.Common.enError13Description
		case let .other(desc):
			return  "\(AppStrings.ExposureSubmissionError.other)\(desc)\(AppStrings.ExposureSubmissionError.otherend)"
		case .unknown:
			return AppStrings.ExposureSubmissionError.unknown
		case .fakeResponse:
			return "Fake request received."
		case .invalidPayloadOrHeaders:
			return "\(AppStrings.ExposureSubmissionError.errorPrefix) - Received an invalid payload or headers."
		case .requestCouldNotBeBuilt:
			return "\(AppStrings.ExposureSubmissionError.errorPrefix) - The submission request could not be built correctly."
		case .qrExpired:
			return AppStrings.ExposureSubmission.qrCodeExpiredAlertText
		default:
			Log.error("\(self)", log: .api)
			return AppStrings.ExposureSubmissionError.defaultError
		}
	}
}
