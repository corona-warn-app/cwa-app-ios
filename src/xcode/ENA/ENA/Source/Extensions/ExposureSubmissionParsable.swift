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
