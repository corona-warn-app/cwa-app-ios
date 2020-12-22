////
// 🦠 Corona-Warn-App
//

import UIKit
import OpenCombine

class HomeTableViewModel {

	// MARK: - Init

	init(
		state: HomeState
	) {
		self.state = state
	}

	// MARK: - Internal

	enum Section: Int, CaseIterable {
		case exposureDetection
		case riskAndTest
		case diary
		case infos
		case settings
	}

	var state: HomeState

	var numberOfSections: Int {
		Section.allCases.count
	}

	func numberOfRows(in section: Int) -> Int {
		switch Section(rawValue: section) {
		case .exposureDetection:
			return 1
		case .riskAndTest:
			return 0
		case .diary:
			return 1
		case .infos:
			return 2
		case .settings:
			return 2
		case .none:
			fatalError("Invalid section")
		}
	}

	// MARK: - Private

}
