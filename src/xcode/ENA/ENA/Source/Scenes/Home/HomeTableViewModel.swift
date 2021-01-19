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
		case exposureLogging
		case riskAndTest
		case statistics
		case diary
		case infos
		case settings
	}

	enum RiskAndTestRow {
		case risk
		case testResult
		case shownPositiveTestResult
		case thankYou
	}

	var state: HomeState

	var numberOfSections: Int {
		Section.allCases.count
	}

	var riskAndTestRows: [RiskAndTestRow] {
		if state.keysWereSubmitted {
			// This is shown when we submitted keys! (Positive test result + actually decided to submit keys.)
			// Once this state is reached, it cannot be left anymore.

			Log.info("Reached end of life state.", log: .localData)
			return [.thankYou]
		} else if state.positiveTestResultWasShown {
			// This is shown when a positive test result was already shown to the user. The risk cell will not be shown in that case.

			return [.shownPositiveTestResult]
		} else {
			return [.risk, .testResult]
		}
	}

	func numberOfRows(in section: Int) -> Int {
		switch Section(rawValue: section) {
		case .exposureLogging:
			return 1
		case .riskAndTest:
			return riskAndTestRows.count
		case .statistics:
			return 1
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

	func heightForRow(at indexPath: IndexPath) -> CGFloat {
		if state.statistics.supportedCardIDSequence.isEmpty && HomeTableViewModel.Section(rawValue: indexPath.section) == .statistics {
			return 0
		}

		return UITableView.automaticDimension
	}

	func heightForHeader(in section: Int) -> CGFloat {
		switch Section(rawValue: section) {
		case .exposureLogging, .riskAndTest, .diary, .statistics:
			return 0
		case .infos, .settings:
			return 16
		case .none:
			fatalError("Invalid section")
		}
	}

	func heightForFooter(in section: Int) -> CGFloat {
		switch Section(rawValue: section) {
		case .exposureLogging, .riskAndTest, .diary, .statistics:
			return 0
		case .infos:
			return 16
		case .settings:
			return 32
		case .none:
			fatalError("Invalid section")
		}
	}

}
