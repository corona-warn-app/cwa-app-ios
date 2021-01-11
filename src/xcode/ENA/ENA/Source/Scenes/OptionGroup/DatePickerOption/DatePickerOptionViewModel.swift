//
// 🦠 Corona-Warn-App
//

import UIKit
import OpenCombine

struct DatePickerOptionViewModel {

	// MARK: - Init

	init(
		today: Date,
		calendar: Calendar = .gregorian()
	) {
		self.today = today
		self.calendar = calendar
	}

	// MARK: - Internal

	var subtitle: String {
		let dateIntervalFormatter = DateIntervalFormatter()
		dateIntervalFormatter.dateTemplate = "MMMMyyyy"

		guard let firstDayOfDatePicker = firstDayOfDatePicker else {
			return ""
		}

		return dateIntervalFormatter.string(from: firstDayOfDatePicker, to: today)
	}

	var datePickerDays: [DatePickerDay] {
		guard let firstDayOfDatePicker = firstDayOfDatePicker else {
				return []
		}

		var datePickerDays = [DatePickerDay]()
		for index in 0..<28 {
			guard let date = calendar.date(byAdding: .day, value: index, to: firstDayOfDatePicker),
				  let daysFromToday = calendar.dateComponents([.day], from: calendar.startOfDay(for: today), to: calendar.startOfDay(for: date)).day else {
				return []
			}

			var datePickerDay: DatePickerDay

			if calendar.isDate(date, inSameDayAs: today) {
				datePickerDay = .today(date)
			} else if date > today {
				datePickerDay = .future(date)
			} else if daysFromToday >= -21 {
				datePickerDay = .upTo21DaysAgo(date)
			} else {
				datePickerDay = .moreThan21DaysAgo(date)
			}

			datePickerDays.append(datePickerDay)
		}

		return datePickerDays
	}

	var weekdays: [String] {
		let dateFormatter = DateFormatter()
		dateFormatter.dateFormat = "EEEEE"

		return datesThisWeek.map { dateFormatter.string(from: $0) }
	}

	var weekdayTextColors: [UIColor] {
		datesThisWeek.map { calendar.isDate($0, inSameDayAs: today) ? .enaColor(for: .tint) : .enaColor(for: .textPrimary2) }
	}

	// MARK: - Private

	private let today: Date
	private let calendar: Calendar

	private var firstDayOfThisWeek: Date? {
		return calendar.date(from: calendar.dateComponents([.weekOfYear, .yearForWeekOfYear], from: today))
	}

	private var firstDayOfDatePicker: Date? {
		guard let firstDayOfThisWeek = firstDayOfThisWeek else { return nil }

		return calendar.date(byAdding: .day, value: -21, to: firstDayOfThisWeek)
	}

	private var datesThisWeek: [Date] {
		guard let firstDayOfThisWeek = firstDayOfThisWeek else { return [] }

		var datesThisWeek = [Date]()
		for index in 0..<7 {
			guard let date = calendar.date(byAdding: .day, value: index, to: firstDayOfThisWeek) else { return [] }

			datesThisWeek.append(date)
		}

		return datesThisWeek
	}

}
