////
// 🦠 Corona-Warn-App
//

import Foundation
import OpenCombine

final class CheckInTimeModel {

	// MARK: - Init

	init(_ type: String, date: Date) {
		self.type = type
		self.date = date
	}

	// MARK: - Public

	// MARK: - Internal

	let type: String

	@OpenCombine.Published var date: Date

	var dateString: String {
		DateFormatter.localizedString(from: date, dateStyle: .short, timeStyle: .short)
	}

	// MARK: - Private

}
