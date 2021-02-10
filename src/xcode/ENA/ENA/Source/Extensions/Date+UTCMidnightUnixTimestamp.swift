////
// 🦠 Corona-Warn-App
//

import Foundation

extension Date {

	var unixTimestamp: Int {
		return Int(self.timeIntervalSince1970)
	}
}
