//
// 🦠 Corona-Warn-App
//

import Foundation

extension Locator {

	// send:	Empty
	// receive:	SAPDownloadedPackage
	// type:	caching
	// comment: we need to look how we will handle PackageDownloadResponse
	//			original eTag gets stored inside the secure store but not the last know model
	//			this might have some problems. Better replace it with caching
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
