////
// 🦠 Corona-Warn-App
//

import Foundation
import Combine

class DiaryDay: Equatable {

	// MARK: - Init

	init(
		dateString: String,
		entries: [DiaryEntry]
	) {
		self.dateString = dateString
		self.entries = entries
	}

	// MARK: - Protocol Equatable

	static func == (lhs: DiaryDay, rhs: DiaryDay) -> Bool {
		return lhs.dateString == rhs.dateString && lhs.entries == rhs.entries
	}

	// MARK: - Internal

	let dateString: String

	@Published private(set) var entries: [DiaryEntry]

	var selectedEntries: [DiaryEntry] {
		entries.filter {
			switch $0 {
			case .location(let location):
				return location.isSelected
			case .contactPerson(let contactPerson):
				return contactPerson.isSelected
			}
		}
	}

	var date: Date {
		let dateFormatter = ISO8601DateFormatter()
		dateFormatter.formatOptions = [.withFullDate]

		guard let date = dateFormatter.date(from: dateString) else {
			Log.error("Could not get date from date string", log: .contactdiary)
			return Date()
		}

		return date
	}

	var formattedDate: String {
		let dateFormatter = DateFormatter()
		dateFormatter.setLocalizedDateFormatFromTemplate("EEEEddMMyy")

		return dateFormatter.string(from: date)
	}

}
