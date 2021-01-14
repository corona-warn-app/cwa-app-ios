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

	enum HistoryExposure: Equatable {
		case encounter(RiskLevel)
		case none

		var imageName: String? {
			switch self {
			case let .encounter(risk):
				switch risk {
				case .low:
					return "Icons_Attention_low"
				case .high:
					return "Icons_Attention_high"
				}

			case .none:
				return nil
			}
		}
	}

	let dateString: String
	let entries: [DiaryEntry]
	let exposureEncounter: HistoryExposure = .encounter(.high)

	var selectedEntries: [DiaryEntry] {
		entries.filter { $0.isSelected }
	}

	var formattedDate: String {
		let dateFormatter = DateFormatter()
		dateFormatter.setLocalizedDateFormatFromTemplate("EEEEddMMyy")

		return dateFormatter.string(from: date)
	}

	// MARK: - Private

	private var date: Date {
		let dateFormatter = ISO8601DateFormatter.contactDiaryFormatter

		guard let date = dateFormatter.date(from: dateString) else {
			Log.error("Could not get date from date string", log: .contactdiary)
			return Date()
		}

		return date
	}

}
