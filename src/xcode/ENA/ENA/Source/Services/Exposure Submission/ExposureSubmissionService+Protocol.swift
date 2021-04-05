//
// 🦠 Corona-Warn-App
//

import Foundation
import OpenCombine


protocol ExposureSubmissionService: class {

	typealias ExposureSubmissionHandler = (_ error: ExposureSubmissionError?) -> Void

	@available(*, deprecated)
	typealias RegistrationHandler = (Result<String, ExposureSubmissionError>) -> Void

	@available(*, deprecated)
	typealias TestResultHandler = (Result<TestResult, ExposureSubmissionError>) -> Void

	@available(*, deprecated)
	typealias TANHandler = (Result<String, ExposureSubmissionError>) -> Void

	var exposureManagerState: ExposureManagerState { get }

	@available(*, deprecated)
	var hasRegistrationToken: Bool { get }

	var supportedCountries: [Country] { get } // temporary!

	@available(*, deprecated)
	var devicePairingConsentAcceptTimestamp: Int64? { get }

	@available(*, deprecated)
	var devicePairingSuccessfulTimestamp: Int64? { get }

	var symptomsOnset: SymptomsOnset { get set }

	@available(*, deprecated)
	var isSubmissionConsentGiven: Bool { get set }
	@available(*, deprecated)
	var isSubmissionConsentGivenPublisher: OpenCombine.Published<Bool>.Publisher { get }

	func loadSupportedCountries(isLoading: @escaping (Bool) -> Void, onSuccess: @escaping ([Country]) -> Void)
	func getTemporaryExposureKeys(completion: @escaping ExposureSubmissionHandler)
	func submitExposure(completion: @escaping ExposureSubmissionHandler)

	@available(*, deprecated)
	func getRegistrationToken(
		forKey deviceRegistrationKey: DeviceRegistrationKey,
		completion completeWith: @escaping RegistrationHandler
	)

	@available(*, deprecated)
	func getTestResult(_ completeWith: @escaping TestResultHandler)

	/// Fetches test results for a given device key.
	///
	/// - Parameters:
	///   - deviceRegistrationKey: the device key to fetch the test results for
	///   - useStoredRegistration: flag to show if a separate registration is needed (`false`) or an existing registration token is used (`true`)
	///   - completion: a `TestResultHandler`
	@available(*, deprecated)
	func getTestResult(forKey deviceRegistrationKey: DeviceRegistrationKey, useStoredRegistration: Bool, completion: @escaping TestResultHandler)

	@available(*, deprecated)
	func deleteTest()

	@available(*, deprecated)
	func acceptPairing()

	@available(*, deprecated)
	func fakeRequest(completionHandler: ExposureSubmissionHandler?)

	@available(*, deprecated)
	func reset()

}

struct ExposureSubmissionServiceDependencies {
	let exposureManager: DiagnosisKeysRetrieval
	let appConfigurationProvider: AppConfigurationProviding
	let client: Client
	let store: Store
	let warnOthersReminder: WarnOthersRemindable
}
