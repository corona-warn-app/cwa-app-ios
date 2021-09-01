//
// 🦠 Corona-Warn-App
//

import Foundation

extension ResourceLocator {

	static func appConfiguration() -> ResourceLocator {
		return ResourceLocator(
			endpoint: .distribution,
			paths: ["version", "v2", "app_config_ios"],
			method: .get,
			headers: [:]
		)
	}

}
