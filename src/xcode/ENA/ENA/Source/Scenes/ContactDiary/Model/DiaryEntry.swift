////
// 🦠 Corona-Warn-App
//

import Foundation

enum DiaryEntry: Equatable {

	enum New: Equatable {

		// MARK: - Internal

		case location(DiaryLocation.New)
		case contactPerson(DiaryContactPerson.New)

	}

	// MARK: - Internal

	case location(DiaryLocation)
	case contactPerson(DiaryContactPerson)

	var name: String {
		switch self {
		case .location(let location):
			return location.name
		case .contactPerson(let contactPerson):
			return contactPerson.name
		}
	}

	var isSelected: Bool {
		switch self {
		case .location(let location):
			return location.isSelected
		case .contactPerson(let contactPerson):
			return contactPerson.isSelected
		}
	}

	var type: DiaryEntryType {
		switch self {
		case .location:
			return .location
		case .contactPerson:
			return .contactPerson
		}
	}

}
