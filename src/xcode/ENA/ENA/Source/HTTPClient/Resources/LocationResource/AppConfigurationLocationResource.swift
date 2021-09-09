//
// 🦠 Corona-Warn-App
//

import Foundation

struct AppConfigurationLocationResource: LocationResource {

	// MARK: - Init

	init() {
		self.locator = Locator.appConfiguration
		self.type = .caching
	}

	// MARK: - Overrides

	// MARK: - Protocol LocationResource

	var locator: Locator

	var type: ServiceType

	func urlRequest(environmentData: EnvironmentData, customHeader: [String : String]?) -> Result<URLRequest, ResourceError> {
		return .failure(.missingData)
	}

	// MARK: - Public

	// MARK: - Internal

	// MARK: - Private

}
