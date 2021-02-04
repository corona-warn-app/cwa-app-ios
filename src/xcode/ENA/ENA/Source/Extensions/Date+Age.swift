//
// 🦠 Corona-Warn-App
//

import Foundation

extension Date {

	var ageInDays: Int? {
		return Calendar.current.dateComponents([.day], from: self, to: Date()).day
	}

	// simple compare with another date
	func isEqual(to date: Date, toGranularity component: Calendar.Component) -> Bool {
		Calendar.current.isDate(self, equalTo: date, toGranularity: component)
	}

}
