////
// 🦠 Corona-Warn-App
//

import UIKit
import OpenCombine

class HomeTableViewModel {

	// MARK: - Init

	init(
		state: HomeState,
		store: Store,
		coronaTestService: CoronaTestService,
		onTestResultCellTap: @escaping (CoronaTestType?) -> Void
	) {
		self.state = state
		self.store = store
		self.coronaTestService = coronaTestService
		self.onTestResultCellTap = onTestResultCellTap

		coronaTestService.$pcrTest
			.sink { [weak self] in
				self?.update(pcrTest: $0)
			}
			.store(in: &subscriptions)

		coronaTestService.$antigenTest
			.sink { [weak self] in
				self?.update(antigenTest: $0)
			}
			.store(in: &subscriptions)
	}

	// MARK: - Internal

	enum Section: Int, CaseIterable {
		case exposureLogging
		case riskAndTestResults
		case testRegistration
		case statistics
		case traceLocations
		case infos
		case settings
	}

	enum RiskAndTestResultsRow: Equatable {
		case risk
		case pcrTestResult(TestResultState)
		case antigenTestResult(TestResultState)
	}

	enum TestResultState: Equatable {
		case `default`
		case positiveResultWasShown
	}

	let state: HomeState
	let store: Store
	let coronaTestService: CoronaTestService
	var isUpdating: Bool = false

	@OpenCombine.Published var testResultLoadingError: Error?
	@OpenCombine.Published var riskAndTestResultsRows: [RiskAndTestResultsRow] = []

	var numberOfSections: Int {
		Section.allCases.count
	}

	func numberOfRows(in section: Int) -> Int {
		switch Section(rawValue: section) {
		case .exposureLogging:
			return 1
		case .riskAndTestResults:
			return riskAndTestResultsRows.count
		case .testRegistration:
			return 1
		case .statistics:
			return 1
		case .traceLocations:
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
		case .exposureLogging, .riskAndTestResults, .testRegistration, .statistics, .traceLocations:
			return 0
		case .infos, .settings:
			return 16
		case .none:
			fatalError("Invalid section")
		}
	}

	func heightForFooter(in section: Int) -> CGFloat {
		switch Section(rawValue: section) {
		case .exposureLogging, .riskAndTestResults, .testRegistration, .statistics, .traceLocations:
			return 0
		case .infos:
			return 12
		case .settings:
			return 24
		case .none:
			fatalError("Invalid section")
		}
	}

	func didTapTestResultCell(coronaTestType: CoronaTestType) {
		if coronaTestType == .antigen && coronaTestService.antigenTestIsOutdated {
			return
		}

		onTestResultCellTap(coronaTestType)
	}

	func didTapTestResultButton(coronaTestType: CoronaTestType) {
		if coronaTestService.coronaTest(ofType: coronaTestType)?.testResult == .expired ||
			(coronaTestType == .antigen && coronaTestService.antigenTestIsOutdated) {
			coronaTestService.removeTest(coronaTestType)
		} else {
			onTestResultCellTap(coronaTestType)
		}
	}

	func updateTestResult() {
		// According to the tech spec, test results should always be updated in the foreground, even if the final test result was received. Therefore: force = true
		coronaTestService.updateTestResults(force: true, presentNotification: false) { [weak self] result in
			guard let self = self else { return }

			if case .failure(let error) = result {
				switch error {
				case .noCoronaTestOfRequestedType, .noRegistrationToken, .testExpired:
					// Errors because of no registered corona tests or expired tests are ignored
					break
				case .responseFailure, .unknownTestResult:
					// Only show errors for corona tests that are still expecting their final test result
					if self.coronaTestService.pcrTest != nil && self.coronaTestService.pcrTest?.finalTestResultReceivedDate == nil ||
						self.coronaTestService.antigenTest != nil && self.coronaTestService.antigenTest?.finalTestResultReceivedDate == nil {
						self.testResultLoadingError = error
					}
				}
			}
		}
	}

	// MARK: - Private

	private let onTestResultCellTap: (CoronaTestType?) -> Void
	private var subscriptions = Set<AnyCancellable>()

	private func update(pcrTest: PCRTest? = nil, antigenTest: AntigenTest? = nil) {
		let updatedRiskAndTestResultsRows = self.computedRiskAndTestResultsRows(pcrTest: pcrTest, antigenTest: antigenTest)

		if updatedRiskAndTestResultsRows.contains(.risk) && !self.riskAndTestResultsRows.contains(.risk) {
			self.state.requestRisk(userInitiated: true)
		}

		if updatedRiskAndTestResultsRows != self.riskAndTestResultsRows {
			isUpdating = true
			self.riskAndTestResultsRows = updatedRiskAndTestResultsRows
		}
	}

	private func computedRiskAndTestResultsRows(pcrTest: PCRTest? = nil, antigenTest: AntigenTest? = nil) -> [RiskAndTestResultsRow] {
		var riskAndTestResultsRows = [RiskAndTestResultsRow]()
		if !coronaTestService.hasAtLeastOneShownPositiveOrSubmittedTest {
			riskAndTestResultsRows.append(.risk)
		}

		if let pcrTest = pcrTest ?? coronaTestService.pcrTest {
			let testResultState: TestResultState
			if pcrTest.testResult == .positive && pcrTest.positiveTestResultWasShown {
				testResultState = .positiveResultWasShown
			} else {
				testResultState = .default
			}
			riskAndTestResultsRows.append(.pcrTestResult(testResultState))
		}

		if let antigenTest = antigenTest ?? coronaTestService.antigenTest {
			let testResultState: TestResultState
			if antigenTest.testResult == .positive && antigenTest.positiveTestResultWasShown {
				testResultState = .positiveResultWasShown
			} else {
				testResultState = .default
			}
			riskAndTestResultsRows.append(.antigenTestResult(testResultState))
		}

		return riskAndTestResultsRows
	}

}
