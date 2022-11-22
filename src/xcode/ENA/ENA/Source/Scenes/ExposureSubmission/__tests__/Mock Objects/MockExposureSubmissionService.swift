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
	var submitExposureCallback: ((@escaping (ExposureSubmissionServiceError?) -> Void) -> Void)?

	// MARK: - ExposureSubmissionService properties.

	var supportedCountries: [Country] = []
	
	var checkins: [Checkin] = []

	var exposureManagerState: ExposureManagerState = ExposureManagerState(authorized: false, enabled: false, status: .unknown)

	var symptomsOnset: SymptomsOnset = .noInformation

	// MARK: - ExposureSubmissionService methods.

	func loadSupportedCountries(isLoading: @escaping (Bool) -> Void, onSuccess: @escaping ([Country]) -> Void) {
		loadSupportedCountriesCallback?(isLoading, onSuccess)
	}

	func getTemporaryExposureKeys(completion: @escaping ExposureSubmissionHandler) {
		getTemporaryExposureKeysCallback?(completion)
	}

	func submitExposure(coronaTestType: CoronaTestType, completion: @escaping (ExposureSubmissionServiceError?) -> Void) {
		submitExposureCallback?(completion)
	}
	func submitSRSExposure(submissionType: SRSSubmissionType, srsOTP: String, completion: @escaping (ExposureSubmissionServiceError?) -> Void) {
		submitExposureCallback?(completion)
	}

}
#endif
