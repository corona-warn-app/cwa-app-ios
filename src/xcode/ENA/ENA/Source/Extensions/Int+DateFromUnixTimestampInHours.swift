////
// 🦠 Corona-Warn-App
//

import Foundation

extension Int {
		
	// Only for testing purposes.
	var dateFromUnixTimestampInHours: Date? {
		let interval = Double(self) * 3600.0
		return Date(timeIntervalSince1970: interval)
	}
}
