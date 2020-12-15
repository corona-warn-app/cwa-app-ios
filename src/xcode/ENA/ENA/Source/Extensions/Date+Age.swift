//
// 🦠 Corona-Warn-App
//

import Foundation

extension Date {

	var ageInDays: Int? {
		return Calendar.current.dateComponents([.day], from: self, to: Date()).day
	}

}
