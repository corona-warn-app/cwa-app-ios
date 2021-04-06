//
// 🦠 Corona-Warn-App
//

import Foundation
import OpenCombine


protocol ExposureSubmissionService: class {

	typealias ExposureSubmissionHandler = (_ error: ExposureSubmissionError?) -> Void

	var exposureManagerState: ExposureManagerState { get }

	var supportedCountries: [Country] { get } // temporary!

	var symptomsOnset: SymptomsOnset { get set }

	func loadSupportedCountries(isLoading: @escaping (Bool) -> Void, onSuccess: @escaping ([Country]) -> Void)
	func getTemporaryExposureKeys(completion: @escaping ExposureSubmissionHandler)
	func submitExposure(coronaTestType: CoronaTestType, completion: @escaping ExposureSubmissionHandler)

}

struct ExposureSubmissionServiceDependencies {
	let exposureManager: DiagnosisKeysRetrieval
	let appConfigurationProvider: AppConfigurationProviding
	let client: Client
	let store: Store
	let coronaTestService: CoronaTestService
}
