//
// 🦠 Corona-Warn-App
//

import Foundation

extension String {
	static func formattedToday() -> String {
		DateFormatter.packagesDateFormatter.string(from: Date())
	}
}

extension DateFormatter {
	static var packagesDateFormatter: DateFormatter = {
		let formatter = DateFormatter()
		formatter.dateFormat = "yyyy-MM-dd"
		formatter.timeZone = TimeZone(abbreviation: "UTC")
		formatter.locale = Locale(identifier: "en_US_POSIX")
		formatter.calendar = Calendar(identifier: .gregorian)

		return formatter
	}()
}
