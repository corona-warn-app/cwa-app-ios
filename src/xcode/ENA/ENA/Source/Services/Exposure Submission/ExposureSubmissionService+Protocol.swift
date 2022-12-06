//
// 🦠 Corona-Warn-App
//

import Foundation
import OpenCombine


protocol ExposureSubmissionService: AnyObject {

	typealias ExposureSubmissionHandler = (_ error: ExposureSubmissionError?) -> Void

	var exposureManagerState: ExposureManagerState { get }

	var supportedCountries: [Country] { get } // temporary!
	
	var checkins: [Checkin] { get set }

	var symptomsOnset: SymptomsOnset { get set }

	func loadSupportedCountries(isLoading: @escaping (Bool) -> Void, onSuccess: @escaping ([Country]) -> Void)
	func loadSelfServiceParameters(isLoading: @escaping CompletionBool, onSuccess: @escaping (SAP_Internal_V2_PPDDSelfReportSubmissionParametersCommon) -> Void)
	func getTemporaryExposureKeys(completion: @escaping ExposureSubmissionHandler)
	func submitExposure(coronaTestType: CoronaTestType, completion: @escaping (_ error: ExposureSubmissionServiceError?) -> Void)
	func submitSRSExposure(
		submissionType: SRSSubmissionType,
		srsOTP: String,
		completion: @escaping (Result<Int?, ExposureSubmissionServiceError>) -> Void
	)
}

struct ExposureSubmissionServiceDependencies {
	let exposureManager: DiagnosisKeysRetrieval
	let appConfigurationProvider: AppConfigurationProviding
	let restServiceProvider: RestServiceProviding
	let store: Store
	let eventStore: EventStoringProviding
	let coronaTestService: CoronaTestServiceProviding
	let ppacService: PrivacyPreservingAccessControl
}
