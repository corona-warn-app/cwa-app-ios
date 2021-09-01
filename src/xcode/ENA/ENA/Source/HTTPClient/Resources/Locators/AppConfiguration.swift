//
// 🦠 Corona-Warn-App
//

import Foundation

extension Locator {

	static func appConfiguration() -> Locator {
		return Locator(
			endpoint: .distribution,
			paths: ["version", "v2", "app_config_ios"],
			method: .get,
			headers: [:]
		)
	}

}
