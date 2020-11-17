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

}
