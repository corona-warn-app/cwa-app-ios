////
// 🦠 Corona-Warn-App
//

import UIKit
import OpenCombine

final class EditCheckinDetailViewModel {

	// MARK: - Init
	
	init(
		_ checkIn: Checkin
	) {
		self.checkIn = checkIn
	}

	enum TableViewSections: Int, CaseIterable {
		case description
		case checkInStart
//		case startPicker
//		case checkInEnd
//		case endPicker

		var sectionTitle: String? {
			switch self {
			case .description:
				return AppStrings.Checkins.Edit.sectionHeaderTitle
			default:
				return nil
			}
		}
	}

	// MARK: - Internal

	var updateTableViewSection: (IndexSet) -> Void = { _ in }

	var checkInDescriptionCellModel: CheckInDescriptionCellModel {
		return CheckInDescriptionCellModel(checkIn: checkIn)
	}

	var checkInStartCellModel: CheckInTimeWithPickerModel {
		return CheckInTimeWithPickerModel("Eingecheckt", date: checkIn.checkinStartDate)
	}

	func numberOfRows(_ section: TableViewSections?) ->  Int {
		guard let section = section else {
			Log.debug("unknown section -> better return 0 rows")
			return 0
		}
		switch section {
		case .description, .checkInStart:
			return 1
		}
	}

	// MARK: - Private
	
	private let checkIn: Checkin
	private var isStartDatePickerIsHidden: Bool = true

}
