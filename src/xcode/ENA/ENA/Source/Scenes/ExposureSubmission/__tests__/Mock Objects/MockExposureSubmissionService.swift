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
	var getRegistrationTokenCallback: ((DeviceRegistrationKey, @escaping RegistrationHandler) -> Void)?
	var getTANForExposureSubmitCallback: ((Bool, @escaping TANHandler) -> Void)?
	var getTestResultCallback: ((@escaping TestResultHandler) -> Void)?
	var deleteTestCallback: (() -> Void)?
	var acceptPairingCallback: (() -> Void)?

	// MARK: - ExposureSubmissionService properties.

	var supportedCountries: [Country] = []

	var exposureManagerState: ExposureManagerState = ExposureManagerState(authorized: false, enabled: false, status: .unknown)
	var hasRegistrationToken: Bool = false

	var devicePairingConsentAcceptTimestamp: Int64?
	var devicePairingSuccessfulTimestamp: Int64?

	var symptomsOnset: SymptomsOnset = .noInformation

	// Needed to use a publisher in the protocol
	@OpenCombine.Published var isSubmissionConsentGiven: Bool = false
	var isSubmissionConsentGivenPublisher: OpenCombine.Published<Bool>.Publisher { $isSubmissionConsentGiven }

	// MARK: - ExposureSubmissionService methods.
	
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

	func getRegistrationToken(forKey deviceRegistrationKey: DeviceRegistrationKey, completion completeWith: @escaping RegistrationHandler) {
		getRegistrationTokenCallback?(deviceRegistrationKey, completeWith)
	}

	func getTANForExposureSubmit(hasConsent: Bool, completion completeWith: @escaping TANHandler) {
		getTANForExposureSubmitCallback?(hasConsent, completeWith)
	}

	func getTestResult(_ completeWith: @escaping TestResultHandler) {
		getTestResultCallback?(completeWith)
	}

	func getTestResult(forKey deviceRegistrationKey: DeviceRegistrationKey, useStoredRegistration: Bool, completion: @escaping TestResultHandler) {
		getTestResultCallback?(completion)
	}

	func deleteTest() {
		deleteTestCallback?()
	}

	func fakeRequest(completionHandler: ExposureSubmissionHandler?) { }

	func acceptPairing() {
		acceptPairingCallback?()
	}
	
	func reset() {
		isSubmissionConsentGiven = false
	}

}
#endif
