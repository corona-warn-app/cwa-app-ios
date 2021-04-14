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
			.receive(on: DispatchQueue.main.ocombine)
			.sink { [weak self] in
				self?.updateWith(pcrTest: $0)
			}
			.store(in: &subscriptions)

		coronaTestService.$antigenTest
			.receive(on: DispatchQueue.main.ocombine)
			.sink { [weak self] in
				self?.updateWith(antigenTest: $0)
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
		case keysSubmitted
	}

	let state: HomeState
	let store: Store
	let coronaTestService: CoronaTestService

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
			return 16
		case .settings:
			return 32
		case .none:
			fatalError("Invalid section")
		}
	}

	func didTapTestResultCell(coronaTestType: CoronaTestType) {
		if coronaTestService.coronaTest(ofType: coronaTestType)?.testResult == .expired {
			coronaTestService.removeTest(coronaTestType)
		} else {
			onTestResultCellTap(coronaTestType)
		}
	}

	func updateTestResult() {
		coronaTestService.updateTestResult(for: .pcr) { [weak self] result in
			if case .failure(let error) = result {
				self?.testResultLoadingError = error
			}
		}
	}

	// MARK: - Private

	private let onTestResultCellTap: (CoronaTestType?) -> Void
	private var subscriptions = Set<AnyCancellable>()

	private func updateWith(pcrTest: PCRTest? = nil, antigenTest: AntigenTest? = nil) {
		let updatedRiskAndTestResultsRows = self.computedRiskAndTestResultsRows(pcrTest: pcrTest, antigenTest: antigenTest)

		if updatedRiskAndTestResultsRows != self.riskAndTestResultsRows {
			self.riskAndTestResultsRows = updatedRiskAndTestResultsRows
		}

		if updatedRiskAndTestResultsRows.contains(.risk) && !self.riskAndTestResultsRows.contains(.risk) {
			self.state.requestRisk(userInitiated: true)
		}
	}

	private func computedRiskAndTestResultsRows(pcrTest: PCRTest? = nil, antigenTest: AntigenTest? = nil) -> [RiskAndTestResultsRow] {
		var riskAndTestResultsRows = [RiskAndTestResultsRow]()
		if !coronaTestService.hasAtLeastOneShownPositiveOrSubmittedTest {
			riskAndTestResultsRows.append(.risk)
		}

		if let pcrTest = pcrTest ?? coronaTestService.pcrTest {
			let testResultState: TestResultState
			if pcrTest.keysSubmitted {
				testResultState = .keysSubmitted
			} else if pcrTest.testResult == .positive && pcrTest.positiveTestResultWasShown {
				testResultState = .positiveResultWasShown
			} else {
				testResultState = .default
			}
			riskAndTestResultsRows.append(.pcrTestResult(testResultState))
		}

		if let antigenTest = antigenTest ?? coronaTestService.antigenTest {
			let testResultState: TestResultState
			if antigenTest.keysSubmitted {
				testResultState = .keysSubmitted
			} else if antigenTest.testResult == .positive && antigenTest.positiveTestResultWasShown {
				testResultState = .positiveResultWasShown
			} else {
				testResultState = .default
			}
			riskAndTestResultsRows.append(.antigenTestResult(testResultState))
		}

		return riskAndTestResultsRows
	}

}
