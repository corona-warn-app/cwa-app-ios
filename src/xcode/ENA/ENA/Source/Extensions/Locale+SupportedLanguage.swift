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
}
