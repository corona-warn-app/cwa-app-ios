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

	// MARK: - Static properties.

	static let fakeRegistrationToken = "63b4d3ff-e0de-4bd4-90c1-17c2bb683a2f"
	static var fakeSubmissionTan: String { return UUID().uuidString }

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

	// MARK: - Private methods for handling the API calls.

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

	/// Helper method that handles only gets the submission tan. Use this only if you really just want to do the
	/// part of the submission flow in which the tan is gotten for the submission
	/// For more information, please check _submitExposure().
	private func _getTANForExposureSubmit(
		hasConsent: Bool,
		completion completeWith: @escaping TANHandler
	) {
		// alert+ store consent+ clientrequest
		store.devicePairingConsentAccept = hasConsent

		// It might happen that the _getTANForExposureSubmit() returns successfully, but the _submit() method returns an error.
		// In this case, if we retry _submitExposure() we will have the issue that we will again ask for the one-time TAN
		// with _getTANForExposureSubmit() and thus get an error. In order to circumvent this, if _getTANForExposureSubmit()
		// succeeds it will write into the store. Therefore, we break out of this method if this was already set.
		if store.tan != nil {
			// swiftlint:disable force_unwrapping
			completeWith(.success(store.tan!))
			return
		}

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
				self.store.isAllowedToPerformBackgroundFakeRequests = true
				completeWith(.success(tan))
			}
		}
	}

	/// This method does two API calls in one step - firstly, it gets the submission TAN, and then it submits the keys.
	/// For details, check the methods `_submit()` and `_getTANForExposureSubmit()` specifically.
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

	/// Helper method that handles only the submission of the keys. Use this only if you really just want to do the
	/// part of the submission flow in which the keys are submitted.
	/// For more information, please check _submitExposure().
	private func _submit(
		_ keys: [ENTemporaryExposureKey],
		with tan: String,
		completion: @escaping ExposureSubmissionHandler
	) {
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

	// MARK: - Public API for accessing the service methods needed for Exposure Submission.

	/// This method gets the test result based on the registrationToken that was previously
	/// received, either from the TAN or QR Code flow. After successful completion,
	/// the timestamp of the last received test is updated.
	/// __Extension for plausible deniability__:
	/// We append two fake requests to this request in order to fulfill the V+V+S sequence. (This means, we
	/// always send three requests, regardless which API call we do. The first two have to go to the verification server,
	/// and the last one goes to the submission server.)
	func getTestResult(_ completeWith: @escaping TestResultHandler) {
		guard let registrationToken = store.registrationToken else {
			completeWith(.failure(.noRegistrationToken))
			return
		}

		_getTestResult(registrationToken) { result in
			completeWith(result)

			// Fake requests.
			self._fakeVerificationAndSubmissionServerRequest()
		}
	}

	/// Stores the provided key, retrieves the registration token and deletes the key.
	/// __Extension for plausible deniability__:
	/// We append two fake requests to this request in order to fulfill the V+V+S sequence. Please kindly check `getTestResult` for more information.
	func getRegistrationToken(
		forKey deviceRegistrationKey: DeviceRegistrationKey,
		completion completeWith: @escaping RegistrationHandler
	) {
		let (key, type) = getKeyAndType(for: deviceRegistrationKey)

		_getRegistrationToken(key, type) { result in
			completeWith(result)

			// Fake requests.
			self._fakeVerificationAndSubmissionServerRequest()
		}
	}

	/// This method submits the exposure keys. Additionally, after successful completion,
	/// the timestamp of the key submission is updated.
	/// __Extension for plausible deniability__:
	/// We prepend a fake request in order to guarantee the V+V+S sequence. Please kindly check `getTestResult` for more information.
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
			self._fakeVerificationServerRequest(completion: { _ in
				self._submitExposure(keys, completionHandler: completionHandler)
			})
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
		if isFake { return ENAExposureSubmissionService.fakeRegistrationToken }
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
		store.tan = nil
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

// MARK: - Fake requests.

extension ENAExposureSubmissionService {

	/// This method represents a dummy method that is sent to the verification server.
	private func _fakeVerificationServerRequest(completion completeWith: @escaping TANHandler) {
		client.getTANForExposureSubmit(forDevice: ENAExposureSubmissionService.fakeRegistrationToken, isFake: true) { _ in
			completeWith(.failure(.fakeResponse))
		}
	}

	/// This method represents a dummy method that is sent to the submission server.
	private func _fakeSubmissionServerRequest(completion: @escaping ExposureSubmissionHandler) {
		self.client.submit(keys: [], tan: ENAExposureSubmissionService.fakeSubmissionTan, isFake: true) { _ in
			completion(.fakeResponse)
		}
	}

	/// This method is convenience for sending a V + S request pattern.
	private func _fakeVerificationAndSubmissionServerRequest(completionHandler: ExposureSubmissionHandler? = nil) {
		self._fakeVerificationServerRequest { _ in
			self._fakeSubmissionServerRequest { _ in
				completionHandler?(.fakeResponse)
			}
		}
	}

	/// This method is called randomly sometimes in the foreground and from the background.
	/// It represents the full-fledged dummy request needed to realize plausible deniability.
	/// Nothing called in this method is considered a "real" request.
	func fakeRequest(completionHandler: ExposureSubmissionHandler? = nil) {
		_fakeVerificationServerRequest { _ in
			self._fakeVerificationServerRequest(completion: { _ in
				self._fakeSubmissionServerRequest(completion: { _ in
					completionHandler?(.fakeResponse)
				})
			})
		}
	}
}
