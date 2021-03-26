////
// 🦠 Corona-Warn-App
//

import Foundation

final class CheckInTimeModel {

	// MARK: - Init

	init(_ type: String, date: Date) {
		self.type = type
		self.dateString = DateFormatter.localizedString(from: date, dateStyle: .short, timeStyle: .short)
	}

	// MARK: - Overrides

	// MARK: - Protocol <#Name#>

	// MARK: - Public

	// MARK: - Internal

	let type: String
	let dateString: String

	// MARK: - Private

}
