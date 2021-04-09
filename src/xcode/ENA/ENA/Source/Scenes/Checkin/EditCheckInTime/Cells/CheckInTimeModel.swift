////
// 🦠 Corona-Warn-App
//

import Foundation
import OpenCombine

final class CheckInTimeModel {

	// MARK: - Init

	init(
		_ type: String,
		minDate: Date,
		maxDate: Date,
		date: Date,
		hasTopSeparator: Bool,
		isPickerVisible: Bool
	) {
		self.type = type
		self.minDate = minDate
		self.maxDate = maxDate
		self.date = date
		self.hasTopSeparator = hasTopSeparator
		self.isPickerVisible = isPickerVisible
	}

	// MARK: - Internal

	let type: String
	let hasTopSeparator: Bool

	@OpenCombine.Published var minDate: Date
	@OpenCombine.Published var maxDate: Date
	@OpenCombine.Published var date: Date

	@OpenCombine.Published var isPickerVisible: Bool = false
	@OpenCombine.Published var isFirstResponder: Bool = false

	var dateString: String {
		DateFormatter.localizedString(from: date, dateStyle: .short, timeStyle: .short)
	}

}
