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
		self.startDate = checkIn.checkinStartDate
		self.endDate = checkIn.checkinEndDate

		self.checkInDescriptionCellModel = CheckInDescriptionCellModel(checkIn: checkIn)
		self.checkInStartCellModel = CheckInTimeModel(AppStrings.Checkins.Edit.checkedIn, date: checkIn.checkinStartDate)
		self.checkInEndCellModel = CheckInTimeModel(AppStrings.Checkins.Edit.checkedOut, date: checkIn.checkinEndDate)

		// update viewModel on change of cellModels
		checkInStartCellModel.$date
			.assign(to: \EditCheckinDetailViewModel.startDate, on: self)
			.store(in: &subscriptions)

		checkInEndCellModel.$date
			.assign(to: \EditCheckinDetailViewModel.endDate, on: self)
			.store(in: &subscriptions)
	}

	enum TableViewSections: Int, CaseIterable {
		case header
		case description
		case topCorner
		case checkInStart
		case startPicker
		case checkInEnd
		case endPicker
		case bottomCorner
		case notice
	}

	// MARK: - Internal

	let checkInDescriptionCellModel: CheckInDescriptionCellModel
	let checkInStartCellModel: CheckInTimeModel
	let checkInEndCellModel: CheckInTimeModel

	@OpenCombine.Published private(set) var isStartDatePickerVisible: Bool = false
	@OpenCombine.Published private(set) var isEndDatePickerVisible: Bool = false

	func numberOfRows(_ section: TableViewSections?) -> Int {
		guard let section = section else {
			Log.debug("unknown section -> better return 0 rows")
			return 0
		}
		switch section {
		case .startPicker:
			return isStartDatePickerVisible ? 1 : 0
		case .endPicker:
			return isEndDatePickerVisible ? 1 : 0
		default:
			return 1
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
	private var subscriptions = Set<AnyCancellable>()

	private (set) var startDate: Date
	private (set) var endDate: Date

}
