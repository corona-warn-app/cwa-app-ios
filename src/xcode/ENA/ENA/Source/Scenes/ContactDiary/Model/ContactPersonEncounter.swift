////
// 🦠 Corona-Warn-App
//

import Foundation

struct ContactPersonEncounter: Equatable {

	// MARK: - Types

	enum Duration: Int {
		case none
		case lessThan15Minutes
		case moreThan15Minutes

		var description: String {
			switch self {
			case .none:
				return ""
			case .lessThan15Minutes:
				return AppStrings.ContactDiary.PersonEncounter.durationLessThan15Minutes
			case .moreThan15Minutes:
				return AppStrings.ContactDiary.PersonEncounter.durationMoreThan15Minutes
			}
		}

		var germanDescription: String {
			switch self {
			case .none:
				return ""
			case .lessThan15Minutes:
				return "< 15 Minuten"
			case .moreThan15Minutes:
				return "> 15 Minuten"
			}
		}
	}

	enum MaskSituation: Int {
		case none
		case withMask
		case withoutMask

		var description: String {
			switch self {
			case .none:
				return ""
			case .withMask:
				return AppStrings.ContactDiary.PersonEncounter.maskSituationWithMask
			case .withoutMask:
				return AppStrings.ContactDiary.PersonEncounter.maskSituationWithoutMask
			}
		}

		var germanDescription: String {
			switch self {
			case .none:
				return ""
			case .withMask:
				return "mit Maske"
			case .withoutMask:
				return "ohne Maske"
			}
		}
	}

	enum Setting: Int {
		case none
		case outside
		case inside

		var description: String {
			switch self {
			case .none:
				return ""
			case .outside:
				return AppStrings.ContactDiary.PersonEncounter.settingOutside
			case .inside:
				return AppStrings.ContactDiary.PersonEncounter.settingInside
			}
		}

		var germanDescription: String {
			switch self {
			case .none:
				return ""
			case .outside:
				return "im Freien"
			case .inside:
				return "im Gebäude"
			}
		}
	}

	// MARK: - Init

	init(
		id: Int,
		date: String,
		contactPersonId: Int,
		duration: Duration = .none,
		maskSituation: MaskSituation = .none,
		setting: Setting = .none,
		circumstances: String = ""
	) {
		self.id = id
		self.date = date
		self.contactPersonId = contactPersonId
		self.duration = duration
		self.maskSituation = maskSituation
		self.setting = setting
		self.circumstances = circumstances
	}

	// MARK: - Internal

	let id: Int
	let date: String
	let contactPersonId: Int

	let duration: Duration
	let maskSituation: MaskSituation
	let setting: Setting

	let circumstances: String
}
