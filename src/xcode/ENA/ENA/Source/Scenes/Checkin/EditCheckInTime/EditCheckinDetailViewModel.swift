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
//		case checkInStart
//		case startPicker
//		case checkInEnd
//		case endPicker

		var numberOfRows: Int {
			switch self {
			case .description:
				return 1
			}
		}
	}

	// MARK: - Internal

	var checkInDescriptionCellModel: CheckInDescriptionCellModel {
		return CheckInDescriptionCellModel(checkIn: checkIn)
	}

	// MARK: - Private
	
	private let checkIn: Checkin

}
