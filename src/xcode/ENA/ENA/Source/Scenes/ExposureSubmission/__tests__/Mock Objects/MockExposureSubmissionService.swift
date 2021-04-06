//
// 🦠 Corona-Warn-App
//

import Foundation
import OpenCombine

#if DEBUG
class MockExposureSubmissionService: ExposureSubmissionService {

	// MARK: - Mock callbacks.

	var loadSupportedCountriesCallback: (((@escaping (Bool) -> Void), (@escaping ([Country]) -> Void)) -> Void)?
	var getTemporaryExposureKeysCallback: ((@escaping ExposureSubmissionHandler) -> Void)?
	var submitExposureCallback: ((@escaping ExposureSubmissionHandler) -> Void)?

	@available(*, deprecated)
	var getRegistrationTokenCallback: ((DeviceRegistrationKey, @escaping RegistrationHandler) -> Void)?
	@available(*, deprecated)
	var getTANForExposureSubmitCallback: ((Bool, @escaping TANHandler) -> Void)?
	@available(*, deprecated)
	var getTestResultCallback: ((@escaping TestResultHandler) -> Void)?
	@available(*, deprecated)
	var deleteTestCallback: (() -> Void)?
	@available(*, deprecated)
	var acceptPairingCallback: (() -> Void)?

	// MARK: - ExposureSubmissionService properties.

	var supportedCountries: [Country] = []

	var exposureManagerState: ExposureManagerState = ExposureManagerState(authorized: false, enabled: false, status: .unknown)

	@available(*, deprecated)
	var hasRegistrationToken: Bool = false

	@available(*, deprecated)
	var devicePairingConsentAcceptTimestamp: Int64?
	@available(*, deprecated)
	var devicePairingSuccessfulTimestamp: Int64?

	var symptomsOnset: SymptomsOnset = .noInformation

	// Needed to use a publisher in the protocol
	@available(*, deprecated)
	@OpenCombine.Published var isSubmissionConsentGiven: Bool = false
	@available(*, deprecated)
	var isSubmissionConsentGivenPublisher: OpenCombine.Published<Bool>.Publisher { $isSubmissionConsentGiven }

	// MARK: - ExposureSubmissionService methods.

	@available(*, deprecated)
	func setSubmissionConsentGiven(consentGiven: Bool) {
		self.isSubmissionConsentGiven = consentGiven
	}

	func loadSupportedCountries(isLoading: @escaping (Bool) -> Void, onSuccess: @escaping ([Country]) -> Void) {
		loadSupportedCountriesCallback?(isLoading, onSuccess)
	}

	func getTemporaryExposureKeys(completion: @escaping ExposureSubmissionHandler) {
		getTemporaryExposureKeysCallback?(completion)
	}

	func submitExposure(completion: @escaping ExposureSubmissionHandler) {
		submitExposureCallback?(completion)
	}

	@available(*, deprecated)
	func getRegistrationToken(forKey deviceRegistrationKey: DeviceRegistrationKey, completion completeWith: @escaping RegistrationHandler) {
		getRegistrationTokenCallback?(deviceRegistrationKey, completeWith)
	}

	@available(*, deprecated)
	func getTANForExposureSubmit(hasConsent: Bool, completion completeWith: @escaping TANHandler) {
		getTANForExposureSubmitCallback?(hasConsent, completeWith)
	}

	@available(*, deprecated)
	func getTestResult(_ completeWith: @escaping TestResultHandler) {
		getTestResultCallback?(completeWith)
	}

	@available(*, deprecated)
	func getTestResult(forKey deviceRegistrationKey: DeviceRegistrationKey, useStoredRegistration: Bool, completion: @escaping TestResultHandler) {
		getTestResultCallback?(completion)
	}

	@available(*, deprecated)
	func deleteTest() {
		deleteTestCallback?()
	}

	@available(*, deprecated)
	func fakeRequest(completionHandler: ExposureSubmissionHandler?) { }

	@available(*, deprecated)
	func acceptPairing() {
		acceptPairingCallback?()
	}

	@available(*, deprecated)
	func reset() {
		isSubmissionConsentGiven = false
	}

}
#endif
