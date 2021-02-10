////
// 🦠 Corona-Warn-App
//

import Foundation

extension Date {

	var utcMidnightUnixTimestamp: Int64? {
		let utcDataFormatter = ISO8601DateFormatter()
		utcDataFormatter.formatOptions = [.withFullDate]

		guard let utcDate = utcDataFormatter.date(from: utcDataFormatter.string(from: self)) else {
			return nil
		}
		return Int64(utcDate.timeIntervalSince1970)
	}
}
