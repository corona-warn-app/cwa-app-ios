//
// 🦠 Corona-Warn-App
//

import Foundation

extension Date {

	var hoursSinceNow: Double {
		self.timeIntervalSinceNow / 60 / 60
	}
}
