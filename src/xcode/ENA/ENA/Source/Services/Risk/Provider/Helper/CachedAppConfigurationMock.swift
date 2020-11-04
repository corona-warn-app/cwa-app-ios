import Foundation

#if DEBUG
final class CachedAppConfigurationMock: AppConfigurationProviding {

	// MARK: - Init

	init(appConfigurationResult: Result<SAP_Internal_ApplicationConfiguration, Error> = .success(SAP_Internal_ApplicationConfiguration())) {
		self.appConfigurationResult = appConfigurationResult
	}

	// MARK: - Protocol AppConfigurationProviding

	func appConfiguration(forceFetch: Bool = false, completion: @escaping Completion) {
		DispatchQueue.main.async {
			completion(self.appConfigurationResult)
		}
	}

	func appConfiguration(completion: @escaping Completion) {
		self.appConfiguration(forceFetch: false, completion: completion)
	}

	// MARK: - Private

	private var appConfigurationResult: Result<SAP_Internal_ApplicationConfiguration, Error>

}
#endif
