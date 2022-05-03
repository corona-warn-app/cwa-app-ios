//
// 🦠 Corona-Warn-App
//

import Foundation

extension Locator {

	// send:	Empty
	// receive:	PackageDownloadResponse
	// type:	retrying
	// comment:
	static func diagnosisKeysHour(
		day: String,
		country: String,
		hour: Int
	) -> Locator {
		Locator(
			endpoint: .distribution,
			paths: ["version", "v1", "diagnosis-keys", "country", country, "date", day, "hour", String(hour)],
			method: .get
		)
	}

}
