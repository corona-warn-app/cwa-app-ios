////
// 🦠 Corona-Warn-App
//

import Foundation

extension ISO8601DateFormatter {

	static var justLocalDateFormatter: ISO8601DateFormatter {
		let dateFormatter = ISO8601DateFormatter()
		dateFormatter.formatOptions = [.withFullDate]
		dateFormatter.timeZone = TimeZone.autoupdatingCurrent

		return dateFormatter
	}

	static var justUTCDateFormatter: ISO8601DateFormatter {
		let dateFormatter = ISO8601DateFormatter()
		dateFormatter.formatOptions = [.withFullDate]

		return dateFormatter
	}

}
