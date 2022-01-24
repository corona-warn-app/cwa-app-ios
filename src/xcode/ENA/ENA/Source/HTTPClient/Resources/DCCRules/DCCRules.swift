//
// 🦠 Corona-Warn-App
//

import Foundation

extension Locator {

	// send:	Empty
	// receive:	JSON Rule - attention special handling might be required here
	// type:	caching
	// comment:
	static func DCCRules(
		ruleType: HealthCertificateValidationRuleType,
		isFake: Bool
	) -> Locator {
		let fake = String(isFake ? 1 : 0)

		switch ruleType {
		case .acceptance, .invalidation:
			return Locator(
				endpoint: .distribution,
				paths: ["version", "v1", "ehn-dgc", ruleType.urlPath],
				method: .get,
				defaultHeaders: [
					"cwa-fake": fake,
					"cwa-header-padding": String.getRandomString(of: 14)
				]
			)
		case .boosterNotification:
			return Locator(
				endpoint: .distribution,
				paths: ["version", "v1", ruleType.urlPath],
				method: .get,
				defaultHeaders: [
					"cwa-fake": fake,
					"cwa-header-padding": String.getRandomString(of: 14)
				]
			)
		}
	}

}
