//
// Corona-Warn-App
//
// SAP SE and all other contributors
// copyright owners license this file to you under the Apache
// License, Version 2.0 (the "License"); you may not use this
// file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing,
// software distributed under the License is distributed on an
// "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
// KIND, either express or implied.  See the License for the
// specific language governing permissions and limitations
// under the License.
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
