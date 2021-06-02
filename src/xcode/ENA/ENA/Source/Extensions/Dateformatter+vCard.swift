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
			return dateFormatter
		}

		static var revDate: DateFormatter {
			let dateFormatter = DateFormatter()
			dateFormatter.dateFormat = "yyyyMMdd'T'hhmmss'Z'"
			dateFormatter.timeZone = .utcTimeZone
			return dateFormatter
		}
	}

}
