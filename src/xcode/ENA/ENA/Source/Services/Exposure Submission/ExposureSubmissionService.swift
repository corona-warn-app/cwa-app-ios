//
// 🦠 Corona-Warn-App
//

import ExposureNotification
import Foundation
import OpenCombine

enum ExposureSubmissionServicePreconditionError: LocalizedError, Equatable {
	case noCoronaTestOfGivenType
	case noCoronaTestTypeGiven
	case noSubmissionConsent
	case positiveTestResultNotShown
	case keysNotShared
	case noKeysCollected
	
	var errorDescription: String? {
		switch self {
		case .noKeysCollected:
			return AppStrings.ExposureSubmissionError.noKeysCollected
		default:
			Log.error("\(self)", log: .api)
			return AppStrings.ExposureSubmissionError.defaultError + "\n(\(String(describing: self)))"
		}
	}
}

enum ExposureSubmissionServiceError: LocalizedError, Equatable {
	case coronaTestServiceError(CoronaTestServiceError)
	case keySubmissionError(ServiceError<KeySubmissionResourceError>)
	case preconditionError(ExposureSubmissionServicePreconditionError)
	case srsError(SRSError)

	var errorDescription: String? {
		switch self {
		case .coronaTestServiceError(let error):
			return error.errorDescription
		case .keySubmissionError(let error):
			return error.errorDescription
		case .preconditionError(let error):
			return error.errorDescription
		case .srsError(let error):
			return error.description
		}
	}
}

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
		restServiceProvider: RestServiceProviding,
		store: Store,
		eventStore: EventStoringProviding,
		deadmanNotificationManager: DeadmanNotificationManageable? = nil,
		coronaTestService: CoronaTestServiceProviding
	) {
		
		#if DEBUG
		if isUITesting {
			self.diagnosisKeysRetrieval = diagnosisKeysRetrieval
			self.appConfigurationProvider = appConfigurationProvider
			self.restServiceProvider = .exposureSubmissionServiceProvider
			self.store = store
			self.eventStore = eventStore
			self.deadmanNotificationManager = deadmanNotificationManager ?? DeadmanNotificationManager()
			self.coronaTestService = coronaTestService
			
			fakeRequestService = FakeRequestService(restServiceProvider: restServiceProvider)
			return
		}
		#endif
		
		self.diagnosisKeysRetrieval = diagnosisKeysRetrieval
		self.appConfigurationProvider = appConfigurationProvider
		self.restServiceProvider = restServiceProvider
		self.store = store
		self.eventStore = eventStore
		self.deadmanNotificationManager = deadmanNotificationManager ?? DeadmanNotificationManager()
		self.coronaTestService = coronaTestService
		
		fakeRequestService = FakeRequestService(restServiceProvider: restServiceProvider)
	}

	convenience init(dependencies: ExposureSubmissionServiceDependencies) {
		self.init(
			diagnosisKeysRetrieval: dependencies.exposureManager,
			appConfigurationProvider: dependencies.appConfigurationProvider,
			restServiceProvider: dependencies.restServiceProvider,
			store: dependencies.store,
			eventStore: dependencies.eventStore,
			coronaTestService: dependencies.coronaTestService
		)
	}

	// MARK: - Protocol ExposureSubmissionService

	var symptomsOnset: SymptomsOnset {
		get { store.submissionSymptomsOnset }
		set { store.submissionSymptomsOnset = newValue }
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

	func getTemporaryExposureKeys(completion: @escaping ExposureSubmissionHandler) {
		Log.info("Getting temporary exposure keys...", log: .api)

		diagnosisKeysRetrieval.accessDiagnosisKeys { [weak self] keys, error in
			if let error = error {
				if let enError = error as? ENError {
					Log.error("Error while retrieving temporary exposure keys: \(error.localizedDescription)", log: .api)
					completion(enError.toExposureSubmissionError())
				} else {
					Log.error("Error while retrieving temporary exposure keys: unknown", log: .api)
					completion(.unknown)
				}

				return
			}

			// Empty array means successful key retrieval without keys
			self?.temporaryExposureKeys = keys?.map { $0.sapKey } ?? []
			completion(nil)
		}
	}

	/// This method submits the SRS exposure keys. Additionally, after successful completion,
	/// the timestamp of the key submission is updated.
	func submitSRSExposure(
		submissionType: SRSSubmissionType,
		srsOTP: String,
		completion: @escaping (_ error: ExposureSubmissionServiceError?) -> Void
	) {
		Log.info("Started SRS exposure submission...", log: .api)

		guard let keys = temporaryExposureKeys else {
			Log.info("Cancelled SRS exposure: No temporary exposure keys to submit.", log: .api)
			completion(.preconditionError(.keysNotShared))
			return
		}

		guard !keys.isEmpty || !checkins.isEmpty else {
			Log.info("Cancelled SRS exposure: No temporary exposure keys or checkins to submit.", log: .api)
			completion(.preconditionError(.noKeysCollected))

			// We perform a cleanup in order to set the correct
			// timestamps, despite not having communicated with the backend,
			// in order to show the correct screens.
			self.submitExposureCleanup(submissionTestType: .srs(submissionType))
			return
		}

		// we need the app configuration first…
		appConfigurationProvider
			.appConfiguration()
			.sink { [weak self] appConfig in
				guard let self = self else {
					Log.error("Failed to create strong self")
					return
				}
				// Fetch & process keys and checkins
				let processedKeys = keys.processedForSubmission(
					with: self.symptomsOnset
				)
				
				let unencryptedCheckinsEnabled = self.appConfigurationProvider.featureProvider.boolValue(for: .unencryptedCheckinsEnabled)
				
				var unencryptedCheckins = [SAP_Internal_Pt_CheckIn]()
				if unencryptedCheckinsEnabled {
					unencryptedCheckins = self.checkins.preparedForSubmission(
						appConfig: appConfig,
						transmissionRiskLevelSource: .symptomsOnset(self.symptomsOnset)
					)
				}
				
				let checkinProtectedReports = self.checkins.preparedProtectedReportsForSubmission(
					appConfig: appConfig,
					transmissionRiskLevelSource: .symptomsOnset(self.symptomsOnset)
				)
				
				// Request needs to be prepended by the fake request Playbook for srs.
				
				self._submitSRS(
					processedKeys,
					srsOtp: srsOTP,
					submissionType: submissionType,
					visitedCountries: self.supportedCountries,
					checkins: unencryptedCheckins,
					checkInProtectedReports: checkinProtectedReports,
					completion: { error in
						if let error = error {
							completion(.keySubmissionError(error))
						} else {
							completion(nil)
						}
					}
				)
			}
			.store(in: &subscriptions)
	}

	/// This method submits the exposure keys. Additionally, after successful completion,
	/// the timestamp of the key submission is updated.
	/// __Extension for plausible deniability__:
	/// We prepend a fake request in order to guarantee the V+V+S sequence. Please kindly check `getTestResult` for more information.
	func submitExposure(
		coronaTestType: CoronaTestType,
		completion: @escaping (_ error: ExposureSubmissionServiceError?) -> Void
	) {
		Log.info("Started exposure submission...", log: .api)

		guard let coronaTest = coronaTestService.coronaTest(ofType: coronaTestType) else {
			Log.info("Cancelled submission: No corona test of given type registered.", log: .api)
			completion(.preconditionError(.noCoronaTestOfGivenType))
			return
		}

		guard coronaTest.isSubmissionConsentGiven else {
			Log.info("Cancelled submission: Submission consent not given.", log: .api)
			completion(.preconditionError(.noSubmissionConsent))
			return
		}
		
		guard coronaTest.positiveTestResultWasShown else {
			Log.info("Cancelled submission: User has never seen their positive test result", log: .api)
			completion(.preconditionError(.positiveTestResultNotShown))
			return
		}

		guard let keys = temporaryExposureKeys else {
			Log.info("Cancelled submission: No temporary exposure keys to submit.", log: .api)
			completion(.preconditionError(.keysNotShared))
			return
		}

		guard !keys.isEmpty || !checkins.isEmpty else {
			Log.info("Cancelled submission: No temporary exposure keys or checkins to submit.", log: .api)
			completion(.preconditionError(.noKeysCollected))

			// We perform a cleanup in order to set the correct
			// timestamps, despite not having communicated with the backend,
			// in order to show the correct screens.
			submitExposureCleanup(submissionTestType: .registeredTest(coronaTest.type))
			return
		}

		// we need the app configuration first…
		appConfigurationProvider
			.appConfiguration()
			.sink { [weak self] appConfig in
				guard let self = self else {
					Log.error("Failed to create string self")
					return
				}
				// Fetch & process keys and checkins
				let processedKeys = keys.processedForSubmission(
					with: self.symptomsOnset
				)

				let unencryptedCheckinsEnabled = self.appConfigurationProvider.featureProvider.boolValue(for: .unencryptedCheckinsEnabled)

				var unencryptedCheckins = [SAP_Internal_Pt_CheckIn]()
				if unencryptedCheckinsEnabled {
					unencryptedCheckins = self.checkins.preparedForSubmission(
						appConfig: appConfig,
						transmissionRiskLevelSource: .symptomsOnset(self.symptomsOnset)
					)
				}

				let checkinProtectedReports = self.checkins.preparedProtectedReportsForSubmission(
					appConfig: appConfig,
					transmissionRiskLevelSource: .symptomsOnset(self.symptomsOnset)
				)

				// Request needs to be prepended by the fake request.
				self.fakeRequestService.fakeVerificationServerRequest {
					self._submitExposure(
						processedKeys,
						coronaTest: coronaTest,
						visitedCountries: self.supportedCountries,
						checkins: unencryptedCheckins,
						checkInProtectedReports: checkinProtectedReports,
						completion: { error in
							completion(error)
						}
					)
				}
			}
			.store(in: &subscriptions)
	}

	func loadSelfServiceParameters(
		isLoading: @escaping CompletionBool,
		onSuccess: @escaping (SAP_Internal_V2_PPDDSelfReportSubmissionParametersCommon) -> Void
	) {
		isLoading(true)

		appConfigurationProvider.appConfiguration().sink { config in
			isLoading(false)
			onSuccess(config.selfReportParameters.common)
		}.store(in: &subscriptions)
	}

	var exposureManagerState: ExposureManagerState {
		diagnosisKeysRetrieval.exposureManagerState
	}

	var checkins: [Checkin] {
		get { store.submissionCheckins }
		set { store.submissionCheckins = newValue }
	}

	// MARK: - Private

	private var subscriptions: Set<AnyCancellable> = []

	private let diagnosisKeysRetrieval: DiagnosisKeysRetrieval
	private let appConfigurationProvider: AppConfigurationProviding
	private let restServiceProvider: RestServiceProviding
	private let store: Store
	private let eventStore: EventStoringProviding
	private let deadmanNotificationManager: DeadmanNotificationManageable
	private let coronaTestService: CoronaTestServiceProviding

	private let fakeRequestService: FakeRequestService

	private var temporaryExposureKeys: [SAP_External_Exposurenotification_TemporaryExposureKey]? {
		get { store.submissionKeys }
		set { store.submissionKeys = newValue }
	}

	private(set) var supportedCountries: [Country] {
		get { store.submissionCountries }
		set { store.submissionCountries = newValue }
	}

	// MARK: methods for handling the API calls.

	/// This method does two API calls in one step - firstly, it gets the submission TAN, and then it submits the keys.
	/// For details, check the methods `_submit()` and `_getTANForExposureSubmit()` specifically.
	private func _submitExposure(
		_ keys: [SAP_External_Exposurenotification_TemporaryExposureKey],
		coronaTest: UserCoronaTest,
		visitedCountries: [Country],
		checkins: [SAP_Internal_Pt_CheckIn],
		checkInProtectedReports: [SAP_Internal_Pt_CheckInProtectedReport],
		completion: @escaping (_ error: ExposureSubmissionServiceError?) -> Void
	) {
		coronaTestService.getSubmissionTAN(for: coronaTest.type) { result in
			switch result {
			case let .failure(error):
				completion(.coronaTestServiceError(error))
			case let .success(tan):
				self._submitRegularSubmission(
					keys,
					coronaTest: coronaTest,
					with: tan,
					visitedCountries: visitedCountries,
					checkins: checkins,
					checkInProtectedReports: checkInProtectedReports
				) { error in
					if let error = error {
						completion(.keySubmissionError(error))
					} else {
						completion(nil)
					}
				}
			}
		}
	}

	/// Helper method that handles only the submission of the keys for SRS. Use this only if you really just want to do the
	/// part of the submission flow in which the keys are submitted.
	/// For more information, please check _submitExposure().
	private func _submitSRS(
		_ keys: [SAP_External_Exposurenotification_TemporaryExposureKey],
		srsOtp: String,
		submissionType: SRSSubmissionType,
		visitedCountries: [Country],
		checkins: [SAP_Internal_Pt_CheckIn],
		checkInProtectedReports: [SAP_Internal_Pt_CheckInProtectedReport],
		completion: @escaping (_ error: ServiceError<KeySubmissionResourceError>?) -> Void
	) {
		let payload = SubmissionPayload(
			exposureKeys: keys,
			visitedCountries: visitedCountries,
			checkins: checkins,
			checkinProtectedReports: checkInProtectedReports,
			tan: nil,
			submissionType: submissionType.protobufType
		)
				
		let resource = SRSKeySubmissionResource(payload: payload, srsOtp: srsOtp)
		restServiceProvider.load(resource) { result in
			
			switch result {
			case .success:
				self.submitExposureCleanup(submissionTestType: .srs(submissionType))

				Log.info("Successfully completed SRS exposure submission.", log: .api)
				completion(nil)
			case .failure(let error):
				Log.error("Error while submitting SRS diagnosis keys: \(error.localizedDescription)", log: .api)
				
				completion(error)
			}
		}
	}
	
	/// Helper method that handles only the submission of the keys. Use this only if you really just want to do the
	/// part of the submission flow in which the keys are submitted.
	/// For more information, please check _submitExposure().
	private func _submitRegularSubmission(
		_ keys: [SAP_External_Exposurenotification_TemporaryExposureKey],
		coronaTest: UserCoronaTest,
		with tan: String,
		visitedCountries: [Country],
		checkins: [SAP_Internal_Pt_CheckIn],
		checkInProtectedReports: [SAP_Internal_Pt_CheckInProtectedReport],
		completion: @escaping (_ error: ServiceError<KeySubmissionResourceError>?) -> Void
	) {
		let payload = SubmissionPayload(
			exposureKeys: keys,
			visitedCountries: visitedCountries,
			checkins: checkins,
			checkinProtectedReports: checkInProtectedReports,
			tan: tan,
			submissionType: coronaTest.protobufType
		)
				
		let resource = KeySubmissionResource(payload: payload)
		restServiceProvider.load(resource) { result in
			
			switch result {
			case .success:
				Analytics.collect(.keySubmissionMetadata(.submittedAfterRapidAntigenTest(coronaTest.type)))
				Analytics.collect(.keySubmissionMetadata(.setHoursSinceTestResult(coronaTest.type)))
				Analytics.collect(.keySubmissionMetadata(.setHoursSinceTestRegistration(coronaTest.type)))
				Analytics.collect(.keySubmissionMetadata(.submitted(true, coronaTest.type)))

				if !checkins.isEmpty {
					Analytics.collect(.keySubmissionMetadata(.submittedWithCheckins(true, coronaTest.type)))
				}

				self.submitExposureCleanup(submissionTestType: .registeredTest(coronaTest.type))

				Log.info("Successfully completed exposure submission.", log: .api)
				completion(nil)
			case .failure(let error):
				Log.error("Error while submitting diagnosis keys: \(error.localizedDescription)", log: .api)
				
				completion(error)
			}
		}
	}

	/// This method removes all left over persisted objects part of the `submitExposure` flow.
	private func submitExposureCleanup(submissionTestType: SubmissionTestType) {
		switch submissionTestType {
		case .registeredTest(let coronaTestType):
			guard let coronaTestType = coronaTestType else {
				Log.error("Corona test type is nil, case should not be possible")
				return
			}
			switch coronaTestType {
			case .pcr:
				coronaTestService.pcrTest.value?.keysSubmitted = true
				coronaTestService.pcrTest.value?.submissionTAN = nil
			case .antigen:
				coronaTestService.antigenTest.value?.keysSubmitted = true
				coronaTestService.antigenTest.value?.submissionTAN = nil
			}

			/// Deactivate deadman notification while submitted test is still present
			deadmanNotificationManager.resetDeadmanNotification()

		case .srs:
			// No cleanup needed as we don't store SRS
			break
		}

		temporaryExposureKeys = nil
		
		for checkin in checkins {
			let updatedCheckin = checkin.updatedCheckin(checkinSubmitted: true)
			self.eventStore.updateCheckin(updatedCheckin)
		}
		
		checkins = []
		supportedCountries = []
		symptomsOnset = .noInformation

		Log.info("Exposure submission cleanup.", log: .api)
	}

}
// swiftlint:enable type_body_length
