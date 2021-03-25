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
		case header
		case description
		case checkInStart
		case startPicker
		case checkInEnd
		case endPicker
		case notice
	}

	// MARK: - Internal

	var checkInDescriptionCellModel: CheckInDescriptionCellModel {
		return CheckInDescriptionCellModel(checkIn: checkIn)
	}

	var checkInStartCellModel: CheckInTimeModel {
		return CheckInTimeModel("Eingecheckt", date: checkIn.checkinStartDate)
	}

	func numberOfRows(_ section: TableViewSections?) ->  Int {
		guard let section = section else {
			Log.debug("unknown section -> better return 0 rows")
			return 0
		}
		switch section {
		case .header, .description, .checkInStart, .checkInEnd, .notice:
			return 1
		case .startPicker:
			return isStartDatePickerVisible ? 1 : 0
		case .endPicker:
			return isEndDatePickerVisible ? 1 : 0
		}
	}

	func toggleStartPicker() {
		isStartDatePickerVisible.toggle()
	}

	func toggleEndPicker() {
		isEndDatePickerVisible.toggle()
	}

	// MARK: - Private
	
	private let checkIn: Checkin

//	private var isStartDatePickerIsHidden: Bool = true

	@OpenCombine.Published private(set) var isStartDatePickerVisible: Bool = false
	@OpenCombine.Published private(set) var isEndDatePickerVisible: Bool = false

}
