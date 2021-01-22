////
// 🦠 Corona-Warn-App
//

import Foundation

struct DiaryDay: Equatable {

	// MARK: - Init

	init(
		dateString: String,
		entries: [DiaryEntry]
	) {
		self.dateString = dateString
		self.entries = entries
	}

	// MARK: - Internal

	let dateString: String
	let entries: [DiaryEntry]

	var selectedEntries: [DiaryEntry] {
		entries.filter { $0.isSelected }
	}

	var formattedDate: String {
		let dateFormatter = DateFormatter()
		dateFormatter.setLocalizedDateFormatFromTemplate("EEEEddMMyy")

		return dateFormatter.string(from: localMidnightDate)
	}

	var utcMidnightDate: Date {
		let dateFormatter = ISO8601DateFormatter.contactDiaryUTCFormatter

		guard let date = dateFormatter.date(from: dateString) else {
			Log.error("Could not get date from date string", log: .contactdiary)
			return Date()
		}

		return date
	}

	// MARK: - Private

	private var localMidnightDate: Date {
		let dateFormatter = ISO8601DateFormatter.contactDiaryFormatter

		guard let date = dateFormatter.date(from: dateString) else {
			Log.error("Could not get date from date string", log: .contactdiary)
			return Date()
		}

		return date
	}

}
