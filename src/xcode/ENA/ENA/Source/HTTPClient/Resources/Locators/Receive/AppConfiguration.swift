//
// 🦠 Corona-Warn-App
//

import Foundation

extension Locator {

	// send:	Empty
	// receive:	Protobuf SAP_Internal_V2_ApplicationConfigurationIOS
	// type:	caching
	// comment:
	static var appConfiguration: Locator {
		Locator(
			endpoint: .distribution,
			paths: ["version", "v2", "app_config_ios"],
			method: .get
		)
	}

}
