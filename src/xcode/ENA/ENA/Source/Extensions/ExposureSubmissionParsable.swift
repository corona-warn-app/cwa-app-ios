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

// MARK: - ExposureSubmissionErrorTransformable protocol.

/// This protocol ensures that a given ErrorType can be transformed into an
/// `ExposureSubmissionError`.
/// For the future, if other transformations are needed, it is advised to create
/// a corrseponding protocol specific to the destination error type.
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
			 .exposureNotificationUnavailable:
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
		case let .serverError(code):
			return .serverError(code)
		default:
			return .other(localizedDescription)
		}
	}
}

// MARK: - URLSession.Response.Failure: ExposureSubmissionErrorTransformable extension.

extension URLSession.Response.Failure: ExposureSubmissionErrorTransformable {
	func toExposureSubmissionError() -> ExposureSubmissionError {
		switch self {
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
