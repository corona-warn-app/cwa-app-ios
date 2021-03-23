//
// 🦠 Corona-Warn-App
//

import Foundation

extension Date {

	var hoursSinceNow: Double {
		self.timeIntervalSinceNow / 60 / 60
	}

	static func - (lhs: Date, rhs: Date) -> TimeInterval {
		return lhs.timeIntervalSince1970 - rhs.timeIntervalSince1970
	}
}
