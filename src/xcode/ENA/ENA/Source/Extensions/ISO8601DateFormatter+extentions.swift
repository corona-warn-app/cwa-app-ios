////
// 🦠 Corona-Warn-App
//

import Foundation

extension ISO8601DateFormatter {

	static let justDate: ISO8601DateFormatter = {
		let isoFormatter = ISO8601DateFormatter()
		isoFormatter.formatOptions = [.withFullDate]
		isoFormatter.timeZone = .utcTimeZone
		return isoFormatter
	}()
}
