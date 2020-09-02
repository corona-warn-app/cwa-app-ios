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

enum ExposureSubmissionError: Error, Equatable {
	case other(String)
	case noRegistrationToken
	case enNotEnabled
	case notAuthorized
	case noKeys
	case noConsent
	case noExposureConfiguration
	case invalidTan
	case invalidResponse
	case noResponse
	case teleTanAlreadyUsed
	case qRAlreadyUsed
	case regTokenNotExist
	case serverError(Int)
	case unknown
	case httpError(String)
	case `internal`
	case unsupported
	case rateLimited
	case fakeResponse
	case invalidPayloadOrHeaders
	case requestCouldNotBeBuilt
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
		case .noExposureConfiguration:
			return AppStrings.ExposureSubmissionError.noConfiguration
		case .qRAlreadyUsed:
			return AppStrings.ExposureSubmissionError.qrAlreadyUsed
		case .teleTanAlreadyUsed:
			return AppStrings.ExposureSubmissionError.teleTanAlreadyUsed
		case .regTokenNotExist:
			return AppStrings.ExposureSubmissionError.regTokenNotExist
		case .noKeys:
			return AppStrings.ExposureSubmissionError.noKeys
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
		default:
			logError(message: "\(self)")
			return AppStrings.ExposureSubmissionError.defaultError
		}
	}
}
