////
// 🦠 Corona-Warn-App
//

import Foundation
import OpenCombine

final class CheckInTimeModel {

	// MARK: - Init

	init(_ type: String, date: Date, hasTopSeparator: Bool) {
		self.type = type
		self.date = date
		self.hasTopSeparator = hasTopSeparator
	}

	// MARK: - Internal

	let type: String
	let hasTopSeparator: Bool

	@OpenCombine.Published var date: Date

	var dateString: String {
		DateFormatter.localizedString(from: date, dateStyle: .short, timeStyle: .short)
	}

}
