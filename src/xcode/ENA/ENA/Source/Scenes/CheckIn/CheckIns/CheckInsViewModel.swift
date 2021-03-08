////
// 🦠 Corona-Warn-App
//

import Foundation
import AVFoundation

final class CheckInsViewModel {

	// MARK: - Init

	convenience init() {
		self.init([])
	}

	init(
		_ checkIns: [String]
	) {
		self.checkIns = checkIns
	}

	// MARK: - Internal

	enum Sections: Int, CaseIterable {
		case state
		case checkIns
	}

	var numberOfSections: Int {
		Sections.allCases.count
	}

	func numberOfItem(in section: Int) -> Int {
		switch Sections(rawValue: section) {
		case .none:
			return 0
		case .some(let section):
			switch section {

			case .state:
				return 1
			case .checkIns:
				return checkIns.count
			}
		}
	}

	var statusCellViewModel: StatusCellViewModel {
		return StatusCellViewModel()
	}

	func checkInCellViewModel(index: Int) -> CheckInCellViewModel {
		CheckInCellViewModel()
	}


	// MARK: - Private

	private var checkIns: [String]

}
