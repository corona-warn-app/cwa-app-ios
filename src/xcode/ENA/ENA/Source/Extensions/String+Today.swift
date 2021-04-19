//
// 🦠 Corona-Warn-App
//

import Foundation

extension String {
	static func formattedToday() -> String {
		DateFormatter.packagesDayDateFormatter.string(from: Date())
	}
}

extension DateFormatter {
	static var packagesDayDateFormatter: DateFormatter = {
		let formatter = DateFormatter()
		formatter.dateFormat = "yyyy-MM-dd"
		formatter.timeZone = TimeZone(abbreviation: "UTC")
		formatter.locale = Locale(identifier: "en_US_POSIX")
		formatter.calendar = Calendar(identifier: .gregorian)

		return formatter
	}()

	static var packagesHourDateFormatter: DateFormatter = {
		let formatter = DateFormatter()
		formatter.dateFormat = "H"
		formatter.timeZone = TimeZone(abbreviation: "UTC")
		formatter.locale = Locale(identifier: "en_US_POSIX")
		formatter.calendar = Calendar(identifier: .gregorian)

		return formatter
	}()
}

extension TimeZone {
	static var utcTimeZone: TimeZone = {
		guard let utcTimeZone = TimeZone(abbreviation: "UTC") else {
			fatalError("Could not create UTC TimeZone.")
		}
		return utcTimeZone
	}()
}

extension Calendar {
	static var utcCalendar: Calendar = {
		var utcCalendar = Calendar(identifier: .gregorian)
		utcCalendar.timeZone = TimeZone.utcTimeZone
		return utcCalendar
	}()
}
