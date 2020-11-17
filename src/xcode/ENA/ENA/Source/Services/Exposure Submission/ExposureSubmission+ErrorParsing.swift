//
// 🦠 Corona-Warn-App
//

import Foundation
import ExposureNotification

// MARK: - Extension for error parsing support.

extension ExposureSubmissionService {
	/// This method attempts to parse all different types of incoming errors, regardless
	/// whether internal or external, and transform them to an `ExposureSubmissionError`
	/// used for interpretation in the frontend.
	/// If the error cannot be parsed to the expected error/failure types `ENError`, `ExposureNotificationError`,
	/// `ExposureNotificationError`, `SubmissionError`, or `URLSession.Response.Failure`,
	/// an unknown error is returned. Therefore, if this method returns `.unknown`,
	/// examine the incoming `Error` closely.
	func parseError(_ error: Error) -> ExposureSubmissionError {

		if let enError = error as? ENError {
			return enError.toExposureSubmissionError()
		}

		if let exposureNotificationError = error as? ExposureNotificationError {
			return exposureNotificationError.toExposureSubmissionError()
		}

		if let submissionError = error as? SubmissionError {
			return submissionError.toExposureSubmissionError()
		}

		if let urlFailure = error as? URLSession.Response.Failure {
			return urlFailure.toExposureSubmissionError()
		}

		return .unknown
	}
}
