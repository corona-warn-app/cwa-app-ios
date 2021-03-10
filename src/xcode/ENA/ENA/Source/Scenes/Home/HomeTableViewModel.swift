////
// 🦠 Corona-Warn-App
//

import UIKit
import OpenCombine

class HomeTableViewModel {

	// MARK: - Init

	init(
		state: HomeState,
		store: Store
	) {
		self.state = state
		self.store = store
	}

	// MARK: - Internal

	enum Section: Int, CaseIterable {
		case exposureLogging
		case riskAndTest
		case statistics
		case event
		case infos
		case settings
	}

	enum RiskAndTestRow {
		case risk
		case testResult
		case shownPositiveTestResult
		case thankYou
	}

	let state: HomeState
	let store: Store

	var numberOfSections: Int {
		Section.allCases.count
	}

	var riskAndTestRows: [RiskAndTestRow] {
		#if DEBUG
		if isUITesting {
			// adding this for launch argument to fake cards on home screen for testing
			if UserDefaults.standard.string(forKey: "showThankYouScreen") == "YES" {
				return [.thankYou]
			} else if UserDefaults.standard.string(forKey: "showTestResultScreen") == "YES" {
				return [.risk, .testResult]
			} else if UserDefaults.standard.string(forKey: "showPositiveTestResult") == "YES" {
				return [.shownPositiveTestResult]
			} else if state.positiveTestResultWasShown {
				return [.shownPositiveTestResult]
			} else {
				return [.risk, .testResult]
			}
		}
		#endif
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
		case .event:
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
		case .exposureLogging, .riskAndTest, .statistics, .event:
			return 0
		case .infos, .settings:
			return 16
		case .none:
			fatalError("Invalid section")
		}
	}

	func heightForFooter(in section: Int) -> CGFloat {
		switch Section(rawValue: section) {
		case .exposureLogging, .riskAndTest, .statistics, .event:
			return 0
		case .infos:
			return 16
		case .settings:
			return 32
		case .none:
			fatalError("Invalid section")
		}
	}

	func reenableRiskDetection() {
		store.positiveTestResultWasShown = false
		store.lastSuccessfulSubmitDiagnosisKeyTimestamp = nil
		store.testResultReceivedTimeStamp = nil

		state.testResult = nil
		state.requestRisk(userInitiated: true)
	}

}
