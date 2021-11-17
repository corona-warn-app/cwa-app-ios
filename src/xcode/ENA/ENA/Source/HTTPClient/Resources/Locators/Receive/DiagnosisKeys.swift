//
// 🦠 Corona-Warn-App
//

import Foundation

extension Locator {

	// send:	Empty
	// receive:	PackageDownloadResponse
	// type:	retrying
	// comment: we need to look how we will handle PackageDownloadResponse
	static func diagnosisKeys(
		day: String,
		country: String
	) -> Locator {
		Locator(
			endpoint: .distribution,
			paths: ["version", "v1", "diagnosis-keys", "country", country, "date", day],
			method: .get
		)
	}

}
