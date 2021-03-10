//
// 🦠 Corona-Warn-App
//

import Foundation

extension Date {

	var todaysMinutes: Int {
		let hour = Calendar.current.component(.hour, from: self)
		let minutes = Calendar.current.component(.minute, from: self)
		return hour * 60 + minutes
	}

	static func dateWithMinutes(_ minutes: Int) -> Date? {
		let calendar = Calendar.current
		let components = DateComponents(minute: minutes)
		let date = calendar.date(from: components)
		return date
	}

	var ageInDays: Int? {
		return Calendar.current.dateComponents([.day], from: self, to: Date()).day
	}

	// simple compare with another date
	func isEqual(to date: Date, toGranularity component: Calendar.Component) -> Bool {
		Calendar.current.isDate(self, equalTo: date, toGranularity: component)
	}

}
