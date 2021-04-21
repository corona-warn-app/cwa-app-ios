////
// 🦠 Corona-Warn-App
//

import Foundation

extension ISO8601DateFormatter {

	// can get used to handle ISO8610 formatted date strings without time informations
	// aka "1981-11-01"
	
	static let justDate: ISO8601DateFormatter = {
		let isoFormatter = ISO8601DateFormatter()
		isoFormatter.formatOptions = [.withFullDate]
		isoFormatter.timeZone = .utcTimeZone
		return isoFormatter
	}()
}
