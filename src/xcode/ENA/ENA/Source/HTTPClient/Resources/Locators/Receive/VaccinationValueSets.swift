//
// 🦠 Corona-Warn-App
//

import Foundation

extension Locator {

	static var vaccinationValueSets: Locator {
		Locator(
			endpoint: .distribution,
			paths: ["version", "v1", "ehn-dgc", Locale.current.languageCodeIfSupported ?? "en", "value-sets"],
			method: .get
		)
	}

}
