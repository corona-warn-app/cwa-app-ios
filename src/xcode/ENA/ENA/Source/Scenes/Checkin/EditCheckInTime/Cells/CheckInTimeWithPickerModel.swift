////
// 🦠 Corona-Warn-App
//

import Foundation

final class CheckInTimeWithPickerModel {

	// MARK: - Init

	init(_ type: String, date: Date) {
		self.type = type
		self.currentDate = date
	}

	// MARK: - Overrides

	// MARK: - Protocol <#Name#>

	// MARK: - Public

	// MARK: - Internal
	let type: String

	var dateString: String {
		return DateFormatter.localizedString(from: currentDate, dateStyle: .short, timeStyle: .none)
	}

	var timeString: String {
		return DateFormatter.localizedString(from: currentDate, dateStyle: .none, timeStyle: .short)
	}

	// MARK: - Private

	private var currentDate: Date

}
