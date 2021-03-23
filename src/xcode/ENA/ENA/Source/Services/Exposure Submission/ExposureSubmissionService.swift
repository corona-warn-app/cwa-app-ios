//
// 🦠 Corona-Warn-App
//

import ExposureNotification
import Foundation
import OpenCombine

/// The `ENASubmissionSubmission Service` provides functions and attributes to access relevant information
/// around the exposure submission process.
/// Especially, when it comes to the `submissionConsent`, then only this service should be used to modify (change) the value of the current
/// state. It wraps around the `SecureStore` binding.
/// The consent value is published using the `isSubmissionConsentGivenPublisher` and the rest of the application can simply subscribe to
/// it to stay in sync.

class ENAExposureSubmissionService: ExposureSubmissionService {

	// MARK: - Init

	init(
		diagnosisKeysRetrieval: DiagnosisKeysRetrieval,
		appConfigurationProvider: AppConfigurationProviding,
		client: Client,
		store: Store,
		warnOthersReminder: WarnOthersRemindable,
		deadmanNotificationManager: DeadmanNotificationManageable? = nil
	) {
		self.diagnosisKeysRetrieval = diagnosisKeysRetrieval
		self.appConfigurationProvider = appConfigurationProvider
		self.client = client
		self.store = store
		self.warnOthersReminder = warnOthersReminder
		self.deadmanNotificationManager = deadmanNotificationManager ?? DeadmanNotificationManager(store: store)
		self._isSubmissionConsentGiven = store.isSubmissionConsentGiven

		self.isSubmissionConsentGivenPublisher.sink { isSubmissionConsentGiven in
			self.store.isSubmissionConsentGiven = isSubmissionConsentGiven
		}.store(in: &subscriptions)
	}

	convenience init(dependencies: ExposureSubmissionServiceDependencies) {
		self.init(
			diagnosisKeysRetrieval: dependencies.exposureManager,
			appConfigurationProvider: dependencies.appConfigurationProvider,
			client: dependencies.client,
			store: dependencies.store,
			warnOthersReminder: dependencies.warnOthersReminder
		)
	}

	// MARK: - Protocol ExposureSubmissionService

	private(set) var devicePairingConsentAcceptTimestamp: Int64? {
		get { store.devicePairingConsentAcceptTimestamp }
		set { store.devicePairingConsentAcceptTimestamp = newValue }
	}

	private(set) var devicePairingSuccessfulTimestamp: Int64? {
		get { store.devicePairingSuccessfulTimestamp }
		set { store.devicePairingSuccessfulTimestamp = newValue }
	}

	var symptomsOnset: SymptomsOnset {
		get { store.submissionSymptomsOnset }
		set { store.submissionSymptomsOnset = newValue }
	}

	var hasRegistrationToken: Bool {
		guard let token = store.registrationToken, !token.isEmpty else {
			return false
		}
		return true
	}

	var isSubmissionConsentGivenPublisher: OpenCombine.Published<Bool>.Publisher { $_isSubmissionConsentGiven }

	var isSubmissionConsentGiven: Bool {
		get {
			return _isSubmissionConsentGiven
		}
		set {
			_isSubmissionConsentGiven = newValue
		}
	}

	func loadSupportedCountries(
		isLoading: @escaping (Bool) -> Void,
		onSuccess: @escaping ([Country]) -> Void
	) {
		isLoading(true)

		appConfigurationProvider.appConfiguration().sink { [weak self] config in
			guard let self = self else { return }

			isLoading(false)

			let countries = config.supportedCountries.compactMap({ Country(countryCode: $0) })
			if countries.isEmpty {
				Log.debug("App config provided empty country list. Falling back to default country", log: .appConfig)
				self.supportedCountries = [.defaultCountry()]
			} else {
				self.supportedCountries = countries
			}

			onSuccess(self.supportedCountries)
		}.store(in: &subscriptions)
	}

	
	// [KGA]
	// checkins aus Store holen, dann mappen auf Protobuff Struktur
	func getTemporaryExposureKeys(completion: @escaping ExposureSubmissionHandler) {
		Log.info("Getting temporary exposure keys...", log: .api)

		diagnosisKeysRetrieval.accessDiagnosisKeys { [weak self] keys, error in
			if let error = error {
				Log.error("Error while retrieving temporary exposure keys: \(error.localizedDescription)", log: .api)
				completion(self?.parseError(error))

				return
			}

			// Empty array means successful key retrieval without keys
			self?.temporaryExposureKeys = keys?.map { $0.sapKey } ?? []
			completion(nil)
		}
	}

	// [KGA] Hier könnte ich meine Werte einfügen. Keys sind instanzevariable. Aus store könnte ich mir hier die checkins holen, und auf protobuff mappen
	// Proc
	/// This method submits the exposure keys. Additionally, after successful completion,
	/// the timestamp of the key submission is updated.
	/// __Extension for plausible deniability__:
	/// We prepend a fake request in order to guarantee the V+V+S sequence. Please kindly check `getTestResult` for more information.
	func submitExposure(
		completion: @escaping ExposureSubmissionHandler
	) {
		Log.info("Started exposure submission...", log: .api)

		guard isSubmissionConsentGiven else {
			Log.info("Cancelled submission: Submission consent not given.", log: .api)
			completion(.noSubmissionConsent)
			return
		}

		guard let keys = temporaryExposureKeys else {
			Log.info("Cancelled submission: No temporary exposure keys to submit.", log: .api)
			completion(.keysNotShared)
			return
		}

		guard !keys.isEmpty else {
			Log.info("Cancelled submission: No temporary exposure keys to submit.", log: .api)
			completion(.noKeysCollected)

			// We perform a cleanup in order to set the correct
			// timestamps, despite not having communicated with the backend,
			// in order to show the correct screens.
			submitExposureCleanup()
			return
		}
		// [KGA] Hier Check-ins übernehmen und integrieren
		let processedKeys = keys.processedForSubmission(with: symptomsOnset)

		// Request needs to be prepended by the fake request.
		_fakeVerificationServerRequest(completion: { _ in
			self._submitExposure(processedKeys, visitedCountries: self.supportedCountries, completion: completion)
		})
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

	func getTestResult(forKey deviceRegistrationKey: DeviceRegistrationKey, useStoredRegistration: Bool = true, completion: @escaping TestResultHandler) {
		if useStoredRegistration {
			getTestResult(completion)
		} else {

			let (key, type) = getKeyAndType(for: deviceRegistrationKey)
			_getRegistrationToken(key, type) { result in
				switch result {
				case .failure(let error):
					completion(.failure(error))

					// Fake requests.
					self._fakeVerificationAndSubmissionServerRequest()
				case .success(let token):
					// because this block is only called in QR submission
					Analytics.collect(.testResultMetadata(.registerNewTestMetadata(Date(), token)))
					Analytics.collect(.keySubmissionMetadata(.submittedWithTeletan(false)))
					self.store.testRegistrationDate = Date()
					self._getTestResult(token) { testResult in
						completion(testResult)
					}

					// Fake request.
					self._fakeSubmissionServerRequest { _ in /* no op */ }
				}
			}
		}
	}

	func deleteTest() {
		store.registrationToken = nil
		store.testResultReceivedTimeStamp = nil
		store.devicePairingConsentAccept = false
		store.devicePairingSuccessfulTimestamp = nil
		store.devicePairingConsentAcceptTimestamp = nil
		isSubmissionConsentGiven = false
	}

	var exposureManagerState: ExposureManagerState {
		diagnosisKeysRetrieval.exposureManagerState
	}

	func acceptPairing() {
		devicePairingConsentAccept = true
		devicePairingConsentAcceptTimestamp = Int64(Date().timeIntervalSince1970)
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

	func reset() {
		Log.info("ExposureSubmissionServce: isConsentGiven value resetted to 'false'")
		isSubmissionConsentGiven = false
	}

	// MARK: - Internal

	static let fakeRegistrationToken = "63b4d3ff-e0de-4bd4-90c1-17c2bb683a2f"

	func updateStoreWithKeySubmissionMetadataDefaultValues() {
		let keySubmissionMetadata = KeySubmissionMetadata(
			submitted: false,
			submittedInBackground: false,
			submittedAfterCancel: false,
			submittedAfterSymptomFlow: false,
			lastSubmissionFlowScreen: .submissionFlowScreenUnknown,
			advancedConsentGiven: self.store.isSubmissionConsentGiven,
			hoursSinceTestResult: 0,
			hoursSinceTestRegistration: 0,
			daysSinceMostRecentDateAtRiskLevelAtTestRegistration: -1,
			hoursSinceHighRiskWarningAtTestRegistration: -1)
		Analytics.collect(.keySubmissionMetadata(.create(keySubmissionMetadata)))
	}


	// MARK: - Private

	private static var fakeSubmissionTan: String { return UUID().uuidString }

	private var subscriptions: Set<AnyCancellable> = []

	private let diagnosisKeysRetrieval: DiagnosisKeysRetrieval
	private let appConfigurationProvider: AppConfigurationProviding
	private let client: Client
	private let store: Store
	private let warnOthersReminder: WarnOthersRemindable
	private let deadmanNotificationManager: DeadmanNotificationManageable

	@OpenCombine.Published private var _isSubmissionConsentGiven: Bool

	private var devicePairingConsentAccept: Bool {
		get { store.devicePairingConsentAccept }
		set { store.devicePairingConsentAccept = newValue }
	}

	private var temporaryExposureKeys: [SAP_External_Exposurenotification_TemporaryExposureKey]? {
		get { store.submissionKeys }
		set { store.submissionKeys = newValue }
	}

	private(set) var supportedCountries: [Country] {
		get { store.submissionCountries }
		set { store.submissionCountries = newValue }
	}

	// MARK: methods for handling the API calls.

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
				Analytics.collect(.testResultMetadata(.updateTestResult(testResult, registrationToken)))
				switch testResult {
				case .positive, .negative, .invalid:
					self.store.testResultReceivedTimeStamp = Int64(Date().timeIntervalSince1970)
					Analytics.collect(.keySubmissionMetadata(.setHoursSinceHighRiskWarningAtTestRegistration))
					Analytics.collect(.keySubmissionMetadata(.setDaysSinceMostRecentDateAtRiskLevelAtTestRegistration))
					completeWith(.success(testResult))
				case .pending:
					completeWith(.success(testResult))
				case .expired:
					/// The .expired status is only known after the test has been registered on the server
					/// so we generate an error here, even if the server returned the http result 201
					completeWith(.failure(.qrExpired))
					self.store.registrationToken = nil
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
			completeWith(.failure(.noDevicePairingConsent))
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
		_ keys: [SAP_External_Exposurenotification_TemporaryExposureKey],
		visitedCountries: [Country],
		completion: @escaping ExposureSubmissionHandler
	) {
		_getTANForExposureSubmit(hasConsent: true, completion: { result in
			switch result {
			case let .failure(error):
				completion(error)
			case let .success(tan):
				self._submit(keys, with: tan, visitedCountries: visitedCountries, completion: completion)
			}
		})
	}

	/// Helper method that handles only the submission of the keys. Use this only if you really just want to do the
	/// part of the submission flow in which the keys are submitted.
	/// For more information, please check _submitExposure().
	private func _submit(
		_ keys: [SAP_External_Exposurenotification_TemporaryExposureKey],
		with tan: String,
		visitedCountries: [Country],
		completion: @escaping ExposureSubmissionHandler
	) {
		let payload = CountrySubmissionPayload(
			exposureKeys: keys,
			visitedCountries: visitedCountries,
			tan: tan
		)
		client.submit(payload: payload, isFake: false) { result in
			switch result {
			case .success:
				Analytics.collect(.keySubmissionMetadata(.advancedConsentGiven(self.store.isSubmissionConsentGiven)))
				Analytics.collect(.keySubmissionMetadata(.updateSubmittedWithTeletan))
				Analytics.collect(.keySubmissionMetadata(.setHoursSinceTestResult))
				Analytics.collect(.keySubmissionMetadata(.setHoursSinceTestRegistration))
				Analytics.collect(.keySubmissionMetadata(.submitted(true)))
				self.submitExposureCleanup()
				Log.info("Successfully completed exposure sumbission.", log: .api)
				completion(nil)
			case .failure(let error):
				Log.error("Error while submiting diagnosis keys: \(error.localizedDescription)", log: .api)
				completion(self.parseError(error))
			}
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
				self.store.testRegistrationDate = Date()
				self.store.testResultReceivedTimeStamp = nil
				self.store.devicePairingSuccessfulTimestamp = Int64(Date().timeIntervalSince1970)
				self.store.devicePairingConsentAccept = true
				completeWith(.success(registrationToken))
			}
		}
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

	/// This method removes all left over persisted objects part of the `submitExposure` flow.
	private func submitExposureCleanup() {
		/// Cancel warn others notifications and set positiveTestResultWasShown = false
		warnOthersReminder.reset()

		// This timestamp must be set before resetting the deadman notification
		store.lastSuccessfulSubmitDiagnosisKeyTimestamp = Int64(Date().timeIntervalSince1970)

		/// Deactivate deadman notification for end-of-life-state
		deadmanNotificationManager.resetDeadmanNotification()

		store.registrationToken = nil
		store.tan = nil

		isSubmissionConsentGiven = false
		temporaryExposureKeys = nil
		supportedCountries = []
		symptomsOnset = .noInformation


		Log.info("Exposure submission cleanup.", log: .api)
	}

	// MARK: Fake requests

	/// This method represents a dummy method that is sent to the verification server.
	private func _fakeVerificationServerRequest(completion completeWith: @escaping TANHandler) {
		client.getTANForExposureSubmit(forDevice: ENAExposureSubmissionService.fakeRegistrationToken, isFake: true) { _ in
			completeWith(.failure(.fakeResponse))
		}
	}

	/// This method represents a dummy method that is sent to the submission server.
	private func _fakeSubmissionServerRequest(completion: @escaping ExposureSubmissionHandler) {
		let payload = CountrySubmissionPayload(
			exposureKeys: [],
			visitedCountries: [],
			tan: ENAExposureSubmissionService.fakeSubmissionTan
		)

		client.submit(payload: payload, isFake: true) { _ in
			completion(.fakeResponse)
		}
	}

	/// This method is convenience for sending a V + S request pattern.
	private func _fakeVerificationAndSubmissionServerRequest(completionHandler: ExposureSubmissionHandler? = nil) {
		_fakeVerificationServerRequest { _ in
			self._fakeSubmissionServerRequest { _ in
				completionHandler?(.fakeResponse)
			}
		}
	}
}
