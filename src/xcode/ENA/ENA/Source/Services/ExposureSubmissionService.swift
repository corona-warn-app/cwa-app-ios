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

import ExposureNotification
import Foundation

enum DeviceRegistrationKey {
	case teleTan(String)
	case guid(String)
}

enum TestResult: Int {
	case pending = 0
	case negative = 1
	case positive = 2
	case invalid = 3
}

protocol ExposureSubmissionService {
	typealias ExposureSubmissionHandler = (_ error: ExposureSubmissionError?) -> Void
	typealias RegistrationHandler = (Result<String, ExposureSubmissionError>) -> Void
	typealias TestResultHandler = (Result<TestResult, ExposureSubmissionError>) -> Void
	typealias TANHandler = (Result<String, ExposureSubmissionError>) -> Void

	func submitExposure(with: String, completionHandler: @escaping ExposureSubmissionHandler)
	func getRegistrationToken(
		forKey deviceRegistrationKey: DeviceRegistrationKey,
		completion completeWith: @escaping RegistrationHandler
	)
	func getTANForExposureSubmit(
		hasConsent: Bool,
		completion completeWith: @escaping TANHandler
	)
	func getTestResult(_ completeWith: @escaping TestResultHandler)
	func hasRegistrationToken() -> Bool
	func deleteTest()
}

class ENAExposureSubmissionService: ExposureSubmissionService {
	let diagnosiskeyRetrieval: DiagnosisKeysRetrieval
	let client: Client
	let store: Store

	init(diagnosiskeyRetrieval: DiagnosisKeysRetrieval, client: Client, store: Store) {
		self.diagnosiskeyRetrieval = diagnosiskeyRetrieval
		self.client = client
		self.store = store
	}

	func hasRegistrationToken() -> Bool {
		guard let token = store.registrationToken, !token.isEmpty else {
			return false
		}
		return true
	}

	func deleteTest() {
		store.registrationToken = nil
	}

	/// This method gets the test result based on the registrationToken that was previously
	/// received, either from the TAN or QR Code flow. After successful completion,
	/// the timestamp of the last received test is updated.
	func getTestResult(_ completeWith: @escaping TestResultHandler) {
		guard let registrationToken = store.registrationToken else {
			completeWith(.failure(.noRegistrationToken))
			return
		}

		client.getTestResult(forDevice: registrationToken) { result in
			switch result {
			case let .failure(error):
				completeWith(.failure(self.parseError(error)))
			case let .success(testResult):
				guard let testResult = TestResult(rawValue: testResult) else {
					completeWith(.failure(.other("Failed to parse TestResult")))
					return
				}

				completeWith(.success(testResult))
				self.store.testResultReceivedTimeStamp = Int64(Date().timeIntervalSince1970)
			}
		}
	}

	/// Stores the provided key, retrieves the registration token and deletes the key.
	func getRegistrationToken(
		forKey deviceRegistrationKey: DeviceRegistrationKey,
		completion completeWith: @escaping RegistrationHandler
	) {
		store(key: deviceRegistrationKey)
		let (key, type) = getKeyAndType(for: deviceRegistrationKey)
		client.getRegistrationToken(forKey: key, withType: type) { result in
			switch result {
			case let .failure(error):
				completeWith(.failure(self.parseError(error)))
			case let .success(registrationToken):
				self.store.registrationToken = registrationToken
				self.delete(key: deviceRegistrationKey)
				completeWith(.success(registrationToken))
			}
		}
	}

	func getTANForExposureSubmit(
		hasConsent: Bool,
		completion completeWith: @escaping TANHandler
	) {
		// alert+ store consent+ clientrequest
		store.devicePairingConsentAccept = hasConsent

		if !store.devicePairingConsentAccept {
			completeWith(.failure(.noConsent))
			return
		}

		guard let token = store.registrationToken else {
			completeWith(.failure(.noRegistrationToken))
			return
		}

		client.getTANForExposureSubmit(forDevice: token) { result in
			switch result {
			case let .failure(error):
				completeWith(.failure(self.parseError(error)))
			case let .success(tan):
				self.store.tan = tan
				completeWith(.success(tan))
			}
		}
	}

	private func getKeyAndType(for key: DeviceRegistrationKey) -> (String, String) {
		switch key {
		case let .guid(guid):
			return (Hasher.sha256(guid), "GUID")
		case let .teleTan(teleTan):
			// teleTAN should NOT be hashed, is for short time
			// usage only.
			return (teleTan, "TELETAN")
		}
	}

	private func store(key: DeviceRegistrationKey) {
		switch key {
		case let .guid(testGUID):
			store.testGUID = testGUID
		case let .teleTan(teleTan):
			store.teleTan = teleTan
		}
	}

	private func delete(key: DeviceRegistrationKey) {
		switch key {
		case .guid:
			store.testGUID = nil
		case .teleTan:
			store.teleTan = nil
		}
	}

	/// This method submits the exposure keys. Additionally, after successful completion,
	/// the timestamp of the key submission is updated.
	func submitExposure(with tan: String, completionHandler: @escaping ExposureSubmissionHandler) {
		log(message: "Started exposure submission...")

		diagnosiskeyRetrieval.accessDiagnosisKeys { keys, error in
			if let error = error {
				logError(message: "Error while retrieving diagnosis keys: \(error.localizedDescription)")
				completionHandler(self.parseError(error))
				return
			}

			guard let keys = keys, !keys.isEmpty else {
				completionHandler(.noKeys)
				return
			}

			self.client.submit(keys: keys, tan: tan) { error in
				if let error = error {
					logError(message: "Error while submiting diagnosis keys: \(error.localizedDescription)")
					completionHandler(self.parseError(error))
					return
				}
				log(message: "Successfully completed exposure sumbission.")
				self.submitExposureCleanup()
				completionHandler(nil)
			}
		}
	}

	// This method removes all left over persisted objects part of the
	// `submitExposure` flow. Removes the guid, registrationToken,
	// and isAllowedToSubmitDiagnosisKeys.
	private func submitExposureCleanup() {
		// View comment in `delete(key: DeviceRegistrationKey)`
		// why this method is needed explicitly like this.
		delete(key: .guid(""))
		store.registrationToken = nil
		store.isAllowedToSubmitDiagnosisKeys = false
		store.lastSuccessfulSubmitDiagnosisKeyTimestamp = Int64(Date().timeIntervalSince1970)
	}

	/// This method attempts to parse all different types of incoming errors, regardless
	/// whether internal or external, and transform them to an `ExposureSubmissionError`
	/// used for interpretation in the frontend.
	// swiftlint:disable:next cyclomatic_complexity
	private func parseError(_ error: Error) -> ExposureSubmissionError {
		if let enError = error as? ENError {
			switch enError.code {
			default:
				return .enNotEnabled
			}
		}

		if let exposureNotificationError = error as? ExposureNotificationError {
			switch exposureNotificationError {
			case .exposureNotificationRequired, .exposureNotificationAuthorization, .exposureNotificationUnavailable:
				return .enNotEnabled
			case .apiMisuse:
				return .other("ENErrorCodeAPIMisuse")
			}
		}

		if let submissionError = error as? SubmissionError {
			switch submissionError {
			case .invalidTan:
				return .invalidTan
			case let .serverError(code):
				return .serverError(code)
			default:
				return .other(submissionError.localizedDescription)
			}
		}

		if let urlFailure = error as? URLSession.Response.Failure {
			switch urlFailure {
			case let .httpError(wrapped):
				return .httpError(wrapped.localizedDescription)
			case .invalidResponse:
				return .invalidResponse
			case .qRTeleTanAlreadyUsed:
				return .qRTeleTanAlreadyUsed
			case .regTokenNotExist:
				return .regTokenNotExist
			case .noResponse:
				return .noResponse
			case let .serverError(code):
				return .serverError(code)
			}
		}

		return .unknown
	}
}

enum ExposureSubmissionError: Error, Equatable {
	case other(String)
	case noRegistrationToken
	case enNotEnabled
	case noKeys
	case noConsent
	case invalidTan
	case invalidResponse
	case noResponse
	case qRTeleTanAlreadyUsed
	case regTokenNotExist
	case serverError(Int)
	case unknown
	case httpError(String)
}

extension ExposureSubmissionError: LocalizedError {
	var errorDescription: String? {
		switch self {
		case let .serverError(code):
			return "Error \(code): \(HTTPURLResponse.localizedString(forStatusCode: code))"
		case let .httpError(desc):
			return desc
		case .invalidTan:
			return "Invalid Tan"
		case .enNotEnabled:
			return "Exposure Notification disabled"
		case .noRegistrationToken:
			return "No registration token"
		case .invalidResponse:
			return "Invalid response"
		case .noResponse:
			return "No response was received"
		case .qRTeleTanAlreadyUsed:
			return "QR Code or TeleTAN already used."
		case .regTokenNotExist:
			return "Reg Token does not exist."
		case .noKeys:
			return "No diagnoses keys available. Please try tomorrow again."
		case let .other(desc):
			return "Other Error: \(desc)"
		case .unknown:
			return "An unknown error occured"
		default:
			logError(message: "\(self)")
			return "Default Exposure Submission Error"
		}
	}
}
