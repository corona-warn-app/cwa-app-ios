////
// 🦠 Corona-Warn-App
//

import Foundation

extension Locale {

	var languageCodeIfSupported: String? {
		guard
			let languageCode = languageCode,
			Bundle.main.localizations.contains(languageCode)
		else {
			return nil
		}

		return languageCode
	}

	var languageCodeWithDefault: String {
		if let languageCode = languageCode,
		   Bundle.main.localizations.contains(languageCode) {
			return languageCode
		} else if Bundle.main.localizations.contains("en") {
			return "en"
		} else {
			return "de"
		}
	}
}
