//
// 🦠 Corona-Warn-App
//

import Foundation

enum ExposureSubmissionServiceFactory {

	/// Will return a mock service in UI tests if and only if the .useMock parameter is passed to the application.
	/// If the parameter is _not_ provided, the factory will instantiate a regular ENAExposureSubmissionService.
	static func create(
		diagnosisKeysRetrieval: DiagnosisKeysRetrieval,
		appConfigurationProvider: AppConfigurationProviding,
		client: Client,
		store: Store
	) -> ExposureSubmissionService {
		#if DEBUG
		if isUITesting {
			guard isEnabled(.useMock) else {
				return ENAExposureSubmissionService(
					diagnosisKeysRetrieval: diagnosisKeysRetrieval,
					appConfigurationProvider: appConfigurationProvider,
					client: client,
					store: store,
					warnOthersReminder: WarnOthersReminder(store: store)
				)
			}

			let service = MockExposureSubmissionService()

			if isEnabled(.getRegistrationTokenSuccess) {
				service.getRegistrationTokenCallback = { _, completeWith in
					DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
						completeWith(.success("dummyRegToken"))
					}
				}
			}

			if isEnabled(.loadSupportedCountriesSuccess) {
				service.loadSupportedCountriesCallback = { isLoading, onSuccess in
					isLoading(true)
					DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
						isLoading(false)
						onSuccess([.defaultCountry()])
					}
				}
			}

			if isEnabled(.getTemporaryExposureKeysSuccess) {
				service.getTemporaryExposureKeysCallback = { completeWith in
					DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
						completeWith(nil)
					}
				}
			}

			if isEnabled(.submitExposureSuccess) {
				service.submitExposureCallback = { completeWith in
					DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
						completeWith(nil)
					}
				}
			}

			return service
		}
		#endif

		let service = ENAExposureSubmissionService(
			diagnosisKeysRetrieval: diagnosisKeysRetrieval,
			appConfigurationProvider: appConfigurationProvider,
			client: client,
			store: store,
			warnOthersReminder: WarnOthersReminder(store: store)
		)

		return service
	}

	private static func isEnabled(_ parameter: UITestingParameters.ExposureSubmission) -> Bool {
		return ProcessInfo.processInfo.arguments.contains(parameter.rawValue)
	}

}
