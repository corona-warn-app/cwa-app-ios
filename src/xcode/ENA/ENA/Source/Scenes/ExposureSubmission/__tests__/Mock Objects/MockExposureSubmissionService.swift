//
// 🦠 Corona-Warn-App
//

import Foundation

#if DEBUG
class MockExposureSubmissionService: ExposureSubmissionService {

	// MARK: - Mock callbacks.

	var submitExposureCallback: ((SymptomsOnset, [Country], @escaping ExposureSubmissionHandler) -> Void)?
	var getRegistrationTokenCallback: ((DeviceRegistrationKey, @escaping RegistrationHandler) -> Void)?
	var getTANForExposureSubmitCallback: ((Bool, @escaping TANHandler) -> Void)?
	var getTestResultCallback: ((@escaping TestResultHandler) -> Void)?
	var hasRegistrationTokenCallback: (() -> Bool)?
	var deleteTestCallback: (() -> Void)?
	var preconditionsCallback: (() -> ExposureManagerState)?
	var acceptPairingCallback: (() -> Void)?

	// MARK: - ExposureSubmissionService methods.
	
	func setSubmissionConsentGiven(consentGiven: Bool) {
		self.isSubmissionConsentGiven = consentGiven
	}

	func submitExposure(symptomsOnset: SymptomsOnset, visitedCountries: [Country], completionHandler: @escaping ExposureSubmissionHandler) {
		submitExposureCallback?(symptomsOnset, visitedCountries, completionHandler)
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

	func hasRegistrationToken() -> Bool {
		return hasRegistrationTokenCallback?() ?? false
	}

	func deleteTest() {
		deleteTestCallback?()
	}

	func fakeRequest(completionHandler: ExposureSubmissionHandler?) { }

	var devicePairingConsentAcceptTimestamp: Int64?

	var devicePairingSuccessfulTimestamp: Int64?
	
	// Needed to use a publisher in the protocal
	@Published var isSubmissionConsentGiven: Bool = false
	
	var isSubmissionConsentGivenPublisher: Published<Bool>.Publisher { $isSubmissionConsentGiven }

	func preconditions() -> ExposureManagerState {
		return preconditionsCallback?() ?? ExposureManagerState(authorized: false, enabled: false, status: .unknown)
	}

	func acceptPairing() {
		acceptPairingCallback?()
	}
}
#endif
