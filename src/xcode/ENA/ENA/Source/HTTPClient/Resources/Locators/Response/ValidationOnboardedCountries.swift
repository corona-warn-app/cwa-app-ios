//
// 🦠 Corona-Warn-App
//

import Foundation

extension Locator {

	static func validationOnboardedCountries(
		isFake: Bool
	) -> Locator {
		let fake = String(isFake ? 1 : 0)
		return Locator(
			endpoint: .distribution,
			paths: ["version", "v1", "ehn-dgc", "onboarded-countries"],
			method: .get,
			defaultHeaders: [fake: "cwa-fake", String.getRandomString(of: 14): "cwa-header-padding"]
		)
	}

}
