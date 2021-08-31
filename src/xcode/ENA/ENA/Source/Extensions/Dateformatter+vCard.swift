////
// 🦠 Corona-Warn-App
//

import Foundation

extension DateFormatter {

	enum VCard {

		static var justDate: DateFormatter {
			let dateFormatter = DateFormatter()
			dateFormatter.dateFormat = "yyyyMMdd"
			dateFormatter.timeZone = .utcTimeZone
			dateFormatter.locale = Locale(identifier: "en_US_POSIX")
			return dateFormatter
		}

		static var revDate: DateFormatter {
			let dateFormatter = DateFormatter()
			dateFormatter.dateFormat = "yyyyMMdd'T'HHmmss'Z'"
			dateFormatter.timeZone = .utcTimeZone
			dateFormatter.locale = Locale(identifier: "en_US_POSIX")
			return dateFormatter
		}
	}

}
