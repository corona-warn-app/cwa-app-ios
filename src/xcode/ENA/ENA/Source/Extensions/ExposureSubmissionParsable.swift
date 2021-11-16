//
// 🦠 Corona-Warn-App
//

import Foundation
import ExposureNotification

// MARK: - ExposureSubmissionErrorTransformable protocol.

/// This protocol ensures that a given ErrorType can be transformed into an
/// `ExposureSubmissionError`.
/// For the future, if other transformations are needed, it is advised to create
/// A corresponding protocol specific to the destination error type.
protocol ExposureSubmissionErrorTransformable {
	func toExposureSubmissionError() -> ExposureSubmissionError
}

// MARK: - ENError: ExposureSubmissionErrorTransformable extension.

extension ENError: ExposureSubmissionErrorTransformable {
	func toExposureSubmissionError() -> ExposureSubmissionError {
		switch code {

		case .unsupported:
			return .unsupported
		case .internal:
			return .internal
		case .rateLimited:
			return .rateLimited
		case .notEnabled:
			return .enNotEnabled
		case .notAuthorized:
			return .notAuthorized
		default:
			return .other(localizedDescription)
		}
	}
}

// MARK: - ExposureNotificationError: ExposureSubmissionErrorTransformable extension.

extension ExposureNotificationError: ExposureSubmissionErrorTransformable {
	func toExposureSubmissionError() -> ExposureSubmissionError {
		switch self {
		case .exposureNotificationRequired,
			 .exposureNotificationAuthorization,
			 .exposureNotificationUnavailable,
			 .notResponding:
			return .enNotEnabled
		case .apiMisuse, .unknown:
			return .other("ENErrorCodeAPIMisuse")
		}
	}
}

// MARK: - SubmissionError: ExposureSubmissionErrorTransformable extension.

extension SubmissionError: ExposureSubmissionErrorTransformable {
	func toExposureSubmissionError() -> ExposureSubmissionError {
		switch self {
		case .invalidTan:
			return .invalidTan
		case .invalidPayloadOrHeaders:
			return .invalidPayloadOrHeaders
		case .requestCouldNotBeBuilt:
			return .requestCouldNotBeBuilt
		case let .serverError(code):
			return .serverError(code)
		default:
			return .other(localizedDescription)
		}
	}
}

// MARK: - URLSession.Response.Failure: ExposureSubmissionErrorTransformable extension.

extension URLSessionError: ExposureSubmissionErrorTransformable {

	func toExposureSubmissionError() -> ExposureSubmissionError {
		switch self {
		case let .httpError(localizedDescription, _):
			return .httpError(localizedDescription)
		case .invalidResponse:
			return .invalidResponse
		case .regTokenNotExist:
			return .regTokenNotExist
		case .qrDoesNotExist:
			return .qrDoesNotExist
		case .noResponse:
			return .noResponse
		case .noNetworkConnection:
			return .noNetworkConnection
		case let .serverError(code):
			return .serverError(code)
		case .notModified:
			return .serverError(304)
		case .fakeResponse:
			return .fakeResponse
		case .invalidRequest:
			return .invalidRequest
		}
	}
}
