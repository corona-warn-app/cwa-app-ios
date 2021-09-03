//
// 🦠 Corona-Warn-App
//

import Foundation

extension Locator {

	static func traceWarningPackageDiscovery(
		unencrypted: Bool,
		country: String
	) -> Locator {
		let fake = String(isFake ? 1 : 0)
		let apiVersion = unencrypted ? "v1" : "v2"
		return Locator(
			endpoint: .distribution,
			paths: ["version", apiVersion, "twp", "country", country, "hour"],
			method: .get,
			type: .default
		)
	}

}
