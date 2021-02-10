////
// 🦠 Corona-Warn-App
//

import Foundation

extension Date {

	var unixTimestamp: Int64 {
		return Int64(self.timeIntervalSince1970)
	}
}
