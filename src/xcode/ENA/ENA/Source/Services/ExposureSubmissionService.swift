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

	func submitExposure(completionHandler: @escaping ExposureSubmissionHandler)
	func getRegistrationToken(
		forKey deviceRegistrationKey: DeviceRegistrationKey,
		completion completeWith: @escaping RegistrationHandler
	)
	func getTestResult(_ completeWith: @escaping TestResultHandler)
	func hasRegistrationToken() -> Bool
	func deleteTest()
	var devicePairingConsentAcceptTimestamp: Int64? { get }
	var devicePairingSuccessfulTimestamp: Int64? { get }
	func preconditions() -> ExposureManagerState
	func acceptPairing()
}

class ENAExposureSubmissionService: ExposureSubmissionService {

	let diagnosiskeyRetrieval: DiagnosisKeysRetrieval
	let client: Client
	let store: Store
	
	private var devicePairingConsentAccept: Bool {
		get { self.store.devicePairingConsentAccept }
		set { self.store.devicePairingConsentAccept = newValue }
	}

	private(set) var devicePairingConsentAcceptTimestamp: Int64? {
		get { self.store.devicePairingConsentAcceptTimestamp }
		set { self.store.devicePairingConsentAcceptTimestamp = newValue }
	}
	private(set) var devicePairingSuccessfulTimestamp: Int64? {
		get { self.store.devicePairingSuccessfulTimestamp }
		set { self.store.devicePairingSuccessfulTimestamp = newValue }
	}

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
		store.testResultReceivedTimeStamp = nil
		store.devicePairingConsentAccept = false
		store.devicePairingSuccessfulTimestamp = nil
		store.devicePairingConsentAcceptTimestamp = nil
		store.isAllowedToSubmitDiagnosisKeys = false
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
				if testResult != .pending {
					self.store.testResultReceivedTimeStamp = Int64(Date().timeIntervalSince1970)
				}
			}
		}
	}

	/// Stores the provided key, retrieves the registration token and deletes the key.
	func getRegistrationToken(
		forKey deviceRegistrationKey: DeviceRegistrationKey,
		completion completeWith: @escaping RegistrationHandler
	) {
		let (key, type) = getKeyAndType(for: deviceRegistrationKey)
		client.getRegistrationToken(forKey: key, withType: type) { result in
			switch result {
			case let .failure(error):
				completeWith(.failure(self.parseError(error)))
			case let .success(registrationToken):
				self.store.registrationToken = registrationToken
				self.store.testResultReceivedTimeStamp = nil
				self.store.devicePairingSuccessfulTimestamp = Int64(Date().timeIntervalSince1970)
				self.store.devicePairingConsentAccept = true
				completeWith(.success(registrationToken))
			}
		}
	}

	private func getTANForExposureSubmit(
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

	/// This method submits the exposure keys. Additionally, after successful completion,
	/// the timestamp of the key submission is updated.
	func submitExposure(completionHandler: @escaping ExposureSubmissionHandler) {
		log(message: "Started exposure submission...")

		diagnosiskeyRetrieval.accessDiagnosisKeys { keys, error in
			if let error = error {
				logError(message: "Error while retrieving diagnosis keys: \(error.localizedDescription)")
				completionHandler(self.parseError(error))
				return
			}

			guard var keys = keys, !keys.isEmpty else {
				completionHandler(.noKeys)
				// We perform a cleanup in order to set the correct
				// timestamps, despite not having communicated with the backend,
				// in order to show the correct screens.
				self.submitExposureCleanup()
				return
			}

			var transmissionRiskDefaultVector: [Int] {
				[5, 6, 8, 8, 8, 5, 3, 1, 1, 1, 1, 1, 1, 1, 1]
			}

			keys.sort {
				$0.rollingStartNumber > $1.rollingStartNumber
			}
			
			if keys.count > 14 {
				keys = Array(keys[0 ..< 14])
			}
			
			let startIndex = 0
			for i in startIndex...keys.count - 1 {
				if i + 1 <= transmissionRiskDefaultVector.count - 1 {
					keys[i].transmissionRiskLevel = UInt8(transmissionRiskDefaultVector[i + 1])
				} else {
					keys[i].transmissionRiskLevel = UInt8(1)
				}
			}

			self.getTANForExposureSubmit(hasConsent: true, completion: { result in
				switch result {
				case let .failure(error):
					completionHandler(error)
				case let .success(tan):
					self.submit(keys, with: tan, completion: completionHandler)
				}
			})
		}
	}

	/// Helper method that is used to submit keys after a TAN was retrieved.
	private func submit(_ keys: [ENTemporaryExposureKey], with tan: String, completion: @escaping ExposureSubmissionHandler) {
		self.client.submit(keys: keys, tan: tan) { error in
			if let error = error {
				logError(message: "Error while submiting diagnosis keys: \(error.localizedDescription)")
				completion(self.parseError(error))
				return
			}

			self.submitExposureCleanup()
			log(message: "Successfully completed exposure sumbission.")
			completion(nil)
		}
	}

	// This method removes all left over persisted objects part of the
	// `submitExposure` flow. Removes the registrationToken,
	// and isAllowedToSubmitDiagnosisKeys.
	private func submitExposureCleanup() {
		store.registrationToken = nil
		store.isAllowedToSubmitDiagnosisKeys = false
		store.lastSuccessfulSubmitDiagnosisKeyTimestamp = Int64(Date().timeIntervalSince1970)
		log(message: "Exposure submission cleanup.")
	}

	/// This method attempts to parse all different types of incoming errors, regardless
	/// whether internal or external, and transform them to an `ExposureSubmissionError`
	/// used for interpretation in the frontend.
	/// If the error cannot be parsed to the expected error/failure types `ENError`, `ExposureNotificationError`,
	/// `ExposureNotificationError`, `SubmissionError`, or `URLSession.Response.Failure`,
	/// an unknown error is returned. Therefore, if this method returns `.unknown`,
	/// examine the incoming `Error` closely.
	private func parseError(_ error: Error) -> ExposureSubmissionError {

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

	func preconditions() -> ExposureManagerState {
		diagnosiskeyRetrieval.preconditions()
	}

	func acceptPairing() {
		devicePairingConsentAccept = true
		devicePairingConsentAcceptTimestamp = Int64(Date().timeIntervalSince1970)
	}
}

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
			return AppStrings.ExposureSubmissionError.internal
		case .unsupported:
			return AppStrings.ExposureSubmissionError.unsupported
		case .rateLimited:
			return AppStrings.ExposureSubmissionError.rateLimited
		case let .other(desc):
			return  "\(AppStrings.ExposureSubmissionError.other)\(desc)\(AppStrings.ExposureSubmissionError.otherend)"
		case .unknown:
			return AppStrings.ExposureSubmissionError.unknown
		default:
			logError(message: "\(self)")
			return AppStrings.ExposureSubmissionError.defaultError
		}
	}
}
