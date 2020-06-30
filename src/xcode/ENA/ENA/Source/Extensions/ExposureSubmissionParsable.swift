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

// MARK: - ExposureSubmissionErrorParsable protocol.

/// This protocol ensures that a given ErrorType can be transformed into an
/// `ExposureSubmissionError`.
protocol ExposureSubmissionErrorParsable {
	associatedtype ErrorType

	static func parseError(_ error: ErrorType) -> ExposureSubmissionError
}

// MARK: - ENError: ExposureSubmissionErrorParsable extension.

extension ENError: ExposureSubmissionErrorParsable {
	typealias ErrorType = ENError

	static func parseError(_ error: ENError) -> ExposureSubmissionError {
		switch error.code {
		case .notEnabled:
			return .enNotEnabled
		case .notAuthorized:
			return .notAuthorized
		default:
			return .other(error.localizedDescription)
		}
	}
}

// MARK: - ExposureNotificationError: ExposureSubmissionErrorParsable extension.

extension ExposureNotificationError: ExposureSubmissionErrorParsable {
	typealias ErrorType = ExposureNotificationError

	static func parseError(_ error: ExposureNotificationError) -> ExposureSubmissionError {
		switch error {
		case .exposureNotificationRequired,
			 .exposureNotificationAuthorization,
			 .exposureNotificationUnavailable:
			return .enNotEnabled
		case .apiMisuse, .unknown:
			return .other("ENErrorCodeAPIMisuse")
		}
	}
}

// MARK: - SubmissionError: ExposureSubmissionErrorParsable extension.

extension SubmissionError: ExposureSubmissionErrorParsable {
	typealias ErrorType = SubmissionError

	static func parseError(_ error: SubmissionError) -> ExposureSubmissionError {
		switch error {
		case .invalidTan:
			return .invalidTan
		case let .serverError(code):
			return .serverError(code)
		default:
			return .other(error.localizedDescription)
		}
	}
}

// MARK: - URLSession.Response.Failure: ExposureSubmissionErrorParsable extension.

extension URLSession.Response.Failure: ExposureSubmissionErrorParsable {
	typealias ErrorType = URLSession.Response.Failure

	static func parseError(_ error: URLSession.Response.Failure) -> ExposureSubmissionError {
		switch error {
		case let .httpError(wrapped):
			return .httpError(wrapped.localizedDescription)
		case .invalidResponse:
			return .invalidResponse
		case .teleTanAlreadyUsed:
			return .teleTanAlreadyUsed
		case .qRAlreadyUsed:
			return .qRAlreadyUsed
		case .regTokenNotExist:
			return .regTokenNotExist
		case .noResponse:
			return .noResponse
		case let .serverError(code):
			return .serverError(code)
		}
	}
}
