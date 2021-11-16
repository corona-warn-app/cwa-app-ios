//
// 🦠 Corona-Warn-App
//

import Foundation

extension Locator {

	// send:	Empty
	// receive:	SAPDownloadedPackage
	// type:	default - eTag got read but was never stored inside a cache
	// comment: we need to look how we will handle PackageDownloadResponse
	static func traceWarningPackageDiscovery(
		unencrypted: Bool,
		country: String,
		isFake: Bool
	) -> Locator {
		let fake = String(isFake ? 1 : 0)
		let apiVersion = unencrypted ? "v1" : "v2"
		return Locator(
			endpoint: .distribution,
			paths: ["version", apiVersion, "twp", "country", country, "hour"],
			method: .get,
			defaultHeaders: [
				"cwa-fake": fake
			]
		)
	}

}
