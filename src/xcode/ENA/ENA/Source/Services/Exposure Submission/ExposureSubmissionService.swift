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

class ENAExposureSubmissionService: ExposureSubmissionService {

	// MARK: - Properties.

	let diagnosiskeyRetrieval: DiagnosisKeysRetrieval
	let client: Client
	let store: Store

	// MARK: - Computed properties.

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

	// MARK: - Initializer.

	init(diagnosiskeyRetrieval: DiagnosisKeysRetrieval, client: Client, store: Store) {
		self.diagnosiskeyRetrieval = diagnosiskeyRetrieval
		self.client = client
		self.store = store
	}

	// MARK: - Convenience methods with support for fake requests, in order to support plausible deniability.

	private func _getTestResult(
		_ registrationToken: String,
		_ completeWith: @escaping ENAExposureSubmissionService.TestResultHandler
	) {
		client.getTestResult(forDevice: registrationToken, isFake: false) { result in

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

	private func _fakeGetTestResult(
		_ completeWith: @escaping ENAExposureSubmissionService.TestResultHandler
	) {
		// Fill out bogus data.
		client.getTestResult(forDevice: "", isFake: true) { _ in
			completeWith(.failure(.fakeResponse))
		}
	}

	private func _getTANForExposureSubmit(
		hasConsent: Bool,
		completion completeWith: @escaping TANHandler
	) {
		// alert+ store consent+ clientrequest
		store.devicePairingConsentAccept = hasConsent

		if !store.devicePairingConsentAccept {
			completeWith(.failure(.noConsent))
			return
		}

		guard let token = getToken(isFake: false) else {
			completeWith(.failure(.noRegistrationToken))
			return
		}

		client.getTANForExposureSubmit(forDevice: token, isFake: false) { result in
			switch result {
			case let .failure(error):
				completeWith(.failure(self.parseError(error)))
			case let .success(tan):
				self.store.tan = tan
				completeWith(.success(tan))
			}
		}
	}

	private func _fakeGetTANForExposureSubmit(completion completeWith: @escaping TANHandler) {
		// TODO: Fill out with bogus data.
		client.getTANForExposureSubmit(forDevice: "", isFake: true) { _ in
			completeWith(.failure(.fakeResponse))
		}
	}

	private func _submitExposure(
		_ keys: [ENTemporaryExposureKey],
		completionHandler: @escaping ExposureSubmissionHandler
	) {
		self._getTANForExposureSubmit(hasConsent: true, completion: { result in
			switch result {
			case let .failure(error):
				completionHandler(error)
			case let .success(tan):
				self._submit(keys, with: tan, completion: completionHandler)
			}
		})
	}

	private func _fakeSubmitExposure(
		completionHandler: ExposureSubmissionHandler? = nil
	) {
		self._fakeGetTANForExposureSubmit { _ in
			self._fakeSubmit { _ in
				completionHandler?(.fakeResponse)
			}
		}
	}

	/// Helper method that is used to submit keys after a TAN was retrieved.
	private func _submit(
		_ keys: [ENTemporaryExposureKey],
		with tan: String,
		completion: @escaping ExposureSubmissionHandler) {

		self.client.submit(keys: keys, tan: tan, isFake: false) { error in

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

	private func _fakeSubmit(completion: @escaping ExposureSubmissionHandler) {
		// TODO: Fill with bogus data
		self.client.submit(keys: [], tan: "", isFake: true) { _ in
			completion(.fakeResponse)
		}
	}

	private func _getRegistrationToken(
		_ key: String,
		_ type: String,
		_ completeWith: @escaping RegistrationHandler
	) {
		client.getRegistrationToken(forKey: key, withType: type, isFake: false) { result in
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

	private func _fakeGetRegistrationToken(_ completeWith: @escaping RegistrationHandler) {
		client.getRegistrationToken(forKey: "", withType: "", isFake: true) { _ in
			completeWith(.failure(.fakeResponse))
		}
	}

	// MARK: - Public API for accessing the service methods needed for Exposure Submission.

	/// This method gets the test result based on the registrationToken that was previously
	/// received, either from the TAN or QR Code flow. After successful completion,
	/// the timestamp of the last received test is updated.
	func getTestResult(_ completeWith: @escaping TestResultHandler) {
		guard let registrationToken = store.registrationToken else {
			completeWith(.failure(.noRegistrationToken))
			return
		}

		_getTestResult(registrationToken) { result in
			completeWith(result)

			// Fake requests.
			self._fakeSubmitExposure()
		}
	}

	/// Stores the provided key, retrieves the registration token and deletes the key.
	func getRegistrationToken(
		forKey deviceRegistrationKey: DeviceRegistrationKey,
		completion completeWith: @escaping RegistrationHandler
	) {
		let (key, type) = getKeyAndType(for: deviceRegistrationKey)

		_getRegistrationToken(key, type) { result in
			completeWith(result)

			// Fake requests.
			self._fakeSubmitExposure()
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
			keys.processedForSubmission()

			// Request needs to be prepended by the fake request.
			self._fakeGetRegistrationToken { _ in
				self._submitExposure(keys, completionHandler: completionHandler)
			}
		}
	}

	/// TODO: Refine comment.
	/// This method is called randomly sometimes in the foreground and from the background.
	func fakeRequest(completionHandler: ExposureSubmissionHandler? = nil) {
		_fakeGetRegistrationToken { _ in
			self._fakeSubmitExposure { _ in
				completionHandler?(.fakeResponse)
			}
		}
	}

	// MARK: - Helper methods.

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

	private func getToken(isFake: Bool) -> String? {
		// TODO: change bogus registration token.
		if isFake { return "aksdjfhalksjdfhlasdjkf" }
		guard let token = store.registrationToken else { return nil }
		return token
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

	// This method removes all left over persisted objects part of the
	// `submitExposure` flow. Removes the registrationToken,
	// and isAllowedToSubmitDiagnosisKeys.
	private func submitExposureCleanup() {
		store.registrationToken = nil
		store.isAllowedToSubmitDiagnosisKeys = false
		store.lastSuccessfulSubmitDiagnosisKeyTimestamp = Int64(Date().timeIntervalSince1970)
		log(message: "Exposure submission cleanup.")
	}

	func preconditions() -> ExposureManagerState {
		diagnosiskeyRetrieval.preconditions()
	}

	func acceptPairing() {
		devicePairingConsentAccept = true
		devicePairingConsentAcceptTimestamp = Int64(Date().timeIntervalSince1970)
	}
}
