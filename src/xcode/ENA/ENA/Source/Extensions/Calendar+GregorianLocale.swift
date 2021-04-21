//
// 🦠 Corona-Warn-App
//

import Foundation

extension Calendar {

	static func gregorian(with locale: Locale = .current) -> Calendar {
		var calendar = Calendar(identifier: .gregorian)
		calendar.locale = locale

		return calendar
	}

	static func utc() -> Calendar {
		var calendar = Calendar(identifier: .gregorian)
		guard let timezone = TimeZone(abbreviation: "UTC") else {
			fatalError("Could not create UTC timezone.")
		}
		calendar.timeZone = timezone
		return calendar
	}
}
