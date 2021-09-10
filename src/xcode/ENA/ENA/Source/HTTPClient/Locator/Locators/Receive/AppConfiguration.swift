//
// 🦠 Corona-Warn-App
//

import Foundation

extension Locator {

	static var appConfiguration: Locator {
		Locator(
			endpoint: .distribution,
			paths: ["version", "v2", "app_config_ios"],
			method: .get
		)
	}

}
