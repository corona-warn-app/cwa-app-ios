//
// 🦠 Corona-Warn-App
//

import Foundation

extension Locator {

	// send:	Empty
	// receive:	SAPDownloadedPackage
	// type:	caching
	// comment:
	static func validationOnboardedCountries(
		isFake: Bool
	) -> Locator {
		let fake = String(isFake ? 1 : 0)
		return Locator(
			endpoint: .distribution,
			paths: ["version", "v1", "ehn-dgc", "onboarded-countries"],
			method: .get,
			defaultHeaders: [
				"cwa-fake": fake,
				"cwa-header-padding": String.getRandomString(of: 14)
			]
		)
	}

}
