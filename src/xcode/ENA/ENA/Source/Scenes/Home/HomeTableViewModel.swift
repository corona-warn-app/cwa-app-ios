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
		onTestResultCellTap: @escaping (CoronaTestType?) -> Void,
		badgeWrapper: HomeBadgeWrapper
	) {
		self.state = state
		self.store = store
		self.coronaTestService = coronaTestService
		self.onTestResultCellTap = onTestResultCellTap
		self.badgeWrapper = badgeWrapper

		coronaTestService.$pcrTest
			.sink { [weak self] _ in
				self?.update()
			}
			.store(in: &subscriptions)

		coronaTestService.$antigenTest
			.sink { [weak self] _ in
				self?.update()
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
		case moreInfo
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
		case .moreInfo:
			return 1
		case .none:
			fatalError("Invalid section")
		}
	}

	func heightForRow(at indexPath: IndexPath) -> CGFloat {
		let isStatisticsCell = HomeTableViewModel.Section(rawValue: indexPath.section) == .statistics
		let isGlobalStatisticsNotLoaded = state.statistics.supportedCardIDSequence.isEmpty
		let isLocalStatisticsNotCached = state.store.selectedLocalStatisticsRegions.isEmpty
		
		if isStatisticsCell && isGlobalStatisticsNotLoaded && isLocalStatisticsNotCached {
			Log.debug("[Autolayout] Layout issues due to preloading of statistics cell! ", log: .ui)
			// if this causes (further?) crashes we have to refactor the preloading of the statistics cell
			return 0
		}

		return UITableView.automaticDimension
	}

	func didTapTestResultCell(coronaTestType: CoronaTestType) {
		if coronaTestType == .antigen && coronaTestService.antigenTestIsOutdated {
			return
		}

		onTestResultCellTap(coronaTestType)
	}

	func didTapTestResultButton(coronaTestType: CoronaTestType) {
		if coronaTestType == .antigen && coronaTestService.antigenTestIsOutdated {
			coronaTestService.removeTest(coronaTestType)
		} else {
			onTestResultCellTap(coronaTestType)
		}
	}

	func shouldShowDeletionConfirmationAlert(for coronaTestType: CoronaTestType) -> Bool {
		coronaTestService.coronaTest(ofType: coronaTestType)?.testResult == .expired
	}

	func moveTestToBin(type coronaTestType: CoronaTestType) {
		coronaTestService.moveTestToBin(coronaTestType)
	}

	func updateTestResult() {
		// According to the tech spec, test results should always be updated in the foreground, even if the final test result was received. Therefore: force = true
		CoronaTestType.allCases.forEach { coronaTestType in
			Log.info("Updating result for test of type: \(coronaTestType)")
			coronaTestService.updateTestResult(for: coronaTestType, force: true) { [weak self] result in
				guard let self = self else {
					Log.error("Could not create strong self")
					return
				}

				if case .failure(let error) = result {
					switch error {
					case .noCoronaTestOfRequestedType, .noRegistrationToken, .testExpired:
						// Errors because of no registered corona tests or expired tests are ignored
						break
					case .responseFailure(let responseFailure):
						switch responseFailure {
						case .fakeResponse:
							Log.info("Fake response - skip it as it's not an error")
						case .noResponse:
							Log.info("Tried to get test result but no response was received")
						default:
							self.showErrorIfNeeded(testType: coronaTestType, error)
						}
					case .teleTanError, .registrationTokenError, .unknownTestResult, .malformedDateOfBirthKey, .testResultError:
						self.showErrorIfNeeded(testType: coronaTestType, error)
					}
				}
			}
		}
	}

	func resetBadgeCount() {
		badgeWrapper.resetAll()
	}

	// MARK: - Private

	private let onTestResultCellTap: (CoronaTestType?) -> Void
	private let badgeWrapper: HomeBadgeWrapper

	private var subscriptions = Set<AnyCancellable>()

	private func showErrorIfNeeded(testType: CoronaTestType, _ error: CoronaTestServiceError) {
		switch testType {
			// Only show errors for corona tests that are still expecting their final test result
		case .pcr:
			if self.coronaTestService.pcrTest != nil && self.coronaTestService.pcrTest?.finalTestResultReceivedDate == nil {
				self.testResultLoadingError = error
			}
		case .antigen:
			if self.coronaTestService.antigenTest != nil && self.coronaTestService.antigenTest?.finalTestResultReceivedDate == nil {
				self.testResultLoadingError = error
			}
		}
	}

	private var computedRiskAndTestResultsRows: [RiskAndTestResultsRow] {
		var riskAndTestResultsRows = [RiskAndTestResultsRow]()

		if !coronaTestService.hasAtLeastOneShownPositiveOrSubmittedTest {
			riskAndTestResultsRows.append(.risk)
		}

		if let pcrTest = coronaTestService.pcrTest {
			let testResultState: TestResultState
			if pcrTest.testResult == .positive && pcrTest.positiveTestResultWasShown {
				testResultState = .positiveResultWasShown
			} else {
				testResultState = .default
			}
			riskAndTestResultsRows.append(.pcrTestResult(testResultState))
		}

		if let antigenTest = coronaTestService.antigenTest {
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

	private func update() {
		let updatedRiskAndTestResultsRows = self.computedRiskAndTestResultsRows

		if updatedRiskAndTestResultsRows.contains(.risk) && !self.riskAndTestResultsRows.contains(.risk) {
			self.state.requestRisk(userInitiated: true)
		}

		if updatedRiskAndTestResultsRows != self.riskAndTestResultsRows {
			isUpdating = true
			self.riskAndTestResultsRows = updatedRiskAndTestResultsRows
		}
	}

}
