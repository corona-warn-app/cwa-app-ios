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
		appConfiguration: AppConfigurationProviding,
		coronaTestService: CoronaTestServiceProviding,
		familyMemberCoronaTestService: FamilyMemberCoronaTestServiceProviding,
		cclService: CCLServable,
		onTestResultCellTap: @escaping (CoronaTestType?) -> Void,
		badgeWrapper: HomeBadgeWrapper
	) {
		self.state = state
		self.store = store
		self.appConfiguration = appConfiguration
		self.coronaTestService = coronaTestService
		self.familyMemberCoronaTestService = familyMemberCoronaTestService
		self.cclService = cclService
		self.onTestResultCellTap = onTestResultCellTap
		self.badgeWrapper = badgeWrapper

		coronaTestService.pcrTest
			.dropFirst()
			.sink { [weak self] _ in
				self?.update()
				self?.scheduleUpdateTimer()
			}
			.store(in: &subscriptions)

		coronaTestService.antigenTest
			.dropFirst()
			.sink { [weak self] _ in
				self?.update()
				self?.scheduleUpdateTimer()
			}
			.store(in: &subscriptions)

		familyMemberCoronaTestService.coronaTests
			.dropFirst()
			.sink { [weak self] _ in
				self?.update()
				self?.scheduleUpdateTimer()
			}
			.store(in: &subscriptions)

		state.$riskState
			.dropFirst()
			.sink { [weak self] _ in
				self?.update()
			}
			.store(in: &subscriptions)

		update()
		scheduleUpdateTimer()
	}

	// MARK: - Internal

	enum Section: Int, CaseIterable {
		case appClosureNotice
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
		case familyTestResults
	}

	enum TestResultState: Equatable {
		case `default`
		case positiveResultWasShown
	}

	let state: HomeState
	let store: Store
	let coronaTestService: CoronaTestServiceProviding
	let familyMemberCoronaTestService: FamilyMemberCoronaTestServiceProviding
	let cclService: CCLServable
	var isUpdating: Bool = false
	var shouldShowAppClosureNotice: Bool = false

	@OpenCombine.Published var testResultLoadingError: Error?
	@OpenCombine.Published var riskAndTestResultsRows: [RiskAndTestResultsRow] = []

	var riskStatusLoweredAlertShouldBeSuppressed: Bool {
		shouldHideRiskCard
	}

	var numberOfSections: Int {
		Section.allCases.count
	}
	
	var statusTabNotice: StatusTabNotice? {
		let result = self.cclService.statusTabNotice()
		
		switch result {
		case .success(let statusTabNotice):
			return statusTabNotice
		case .failure:
			return nil
		}
	}
	
	func numberOfRows(in section: Int) -> Int {
		switch Section(rawValue: section) {
		case .appClosureNotice:
			#if DEBUG
			if isUITesting, LaunchArguments.appClosureNotice.showAppClosureNoticeTile.boolValue {
				return 1
			}
			#endif
			return shouldShowAppClosureNotice ? 1 : 0
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
		let isGlobalStatisticsNotLoaded = state.statistics.supportedStatisticsCardIDSequence.isEmpty
		let isLocalStatisticsNotCached = state.store.selectedLocalStatisticsRegions.isEmpty
		
		if isStatisticsCell && isGlobalStatisticsNotLoaded && isLocalStatisticsNotCached {
			Log.debug("[Autolayout] Layout issues due to preloading of statistics cell! ", log: .ui)
			// if this causes (further?) crashes we have to refactor the preloading of the statistics cell
			return 0
		}

		return UITableView.automaticDimension
	}

	func didTapTestResultCell(coronaTestType: CoronaTestType) {
		if coronaTestType == .antigen && coronaTestService.antigenTestIsOutdated.value || coronaTestService.coronaTest(ofType: coronaTestType)?.testResult == .expired {
			return
		}

		onTestResultCellTap(coronaTestType)
	}

	func didTapTestResultButton(coronaTestType: CoronaTestType) {
		if coronaTestType == .antigen && coronaTestService.antigenTestIsOutdated.value {
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
					case .teleTanError, .registrationTokenError, .malformedDateOfBirthKey, .testResultError:
						self.showErrorIfNeeded(testType: coronaTestType, error)
					}
				}
			}
		}

		familyMemberCoronaTestService.updateTestResults(
			presentNotification: false
		) { _ in
			// Errors are only handled on the family member tests screen.
		}
	}

	func resetBadgeCount() {
		badgeWrapper.resetAll()
	}

	// MARK: - Private

	private let appConfiguration: AppConfigurationProviding
	private let onTestResultCellTap: (CoronaTestType?) -> Void
	private let badgeWrapper: HomeBadgeWrapper

	private var subscriptions = Set<AnyCancellable>()
	private var updateTimer: Timer?

	private var computedRiskAndTestResultsRows: [RiskAndTestResultsRow] {
		var riskAndTestResultsRows = [RiskAndTestResultsRow]()

		if !shouldHideRiskCard {
			riskAndTestResultsRows.append(.risk)
		}

		if let pcrTest = coronaTestService.pcrTest.value {
			let testResultState: TestResultState
			if pcrTest.testResult == .positive && pcrTest.positiveTestResultWasShown {
				testResultState = .positiveResultWasShown
			} else {
				testResultState = .default
			}
			riskAndTestResultsRows.append(.pcrTestResult(testResultState))
		}

		if let antigenTest = coronaTestService.antigenTest.value {
			let testResultState: TestResultState
			if antigenTest.testResult == .positive && antigenTest.positiveTestResultWasShown {
				testResultState = .positiveResultWasShown
			} else {
				testResultState = .default
			}
			riskAndTestResultsRows.append(.antigenTestResult(testResultState))
		}

		if !familyMemberCoronaTestService.coronaTests.value.isEmpty {
			riskAndTestResultsRows.append(.familyTestResults)
		}

		return riskAndTestResultsRows
	}

	private var shouldHideRiskCard: Bool {
		guard state.risk?.level != .high else {
			return false
		}

		let pcrTestShouldHideRiskCard = pcrRiskCardRevealDate.map { $0 > Date() } ?? false
		let antigenTestShouldHideRiskCard = antigenRiskCardRevealDate.map { $0 > Date() } ?? false

		return pcrTestShouldHideRiskCard || antigenTestShouldHideRiskCard
	}

	private var pcrRiskCardRevealDate: Date? {
		guard let pcrTest = coronaTestService.pcrTest.value, pcrTest.testResult == .positive, pcrTest.positiveTestResultWasShown else {
			return nil
		}

		let hoursSinceTestRegistrationToShowRiskCard = appConfiguration.currentAppConfig.value
			.coronaTestParameters.coronaPcrtestParameters.hoursSinceTestRegistrationToShowRiskCard

		return pcrTest.registrationDate
			.addingTimeInterval(3600 * Double(hoursSinceTestRegistrationToShowRiskCard))
	}

	private var antigenRiskCardRevealDate: Date? {
		guard let antigenTest = coronaTestService.antigenTest.value, antigenTest.testResult == .positive, antigenTest.positiveTestResultWasShown else {
			return nil
		}

		let hoursSinceSampleCollectionToShowRiskCard = appConfiguration.currentAppConfig.value
			.coronaTestParameters.coronaRapidAntigenTestParameters.hoursSinceSampleCollectionToShowRiskCard

		return antigenTest.testDate
			.addingTimeInterval(3600 * Double(hoursSinceSampleCollectionToShowRiskCard))
	}

	private var nextRevealDate: Date? {
		[pcrRiskCardRevealDate, antigenRiskCardRevealDate]
			.compactMap { $0 }
			.min()
	}

	private func showErrorIfNeeded(testType: CoronaTestType, _ error: CoronaTestServiceError) {
		switch testType {
		// Only show errors for corona tests that are still expecting their final test result
		case .pcr:
			if self.coronaTestService.pcrTest.value != nil && self.coronaTestService.pcrTest.value?.finalTestResultReceivedDate == nil {
				self.testResultLoadingError = error
			}
		case .antigen:
			if self.coronaTestService.antigenTest.value != nil && self.coronaTestService.antigenTest.value?.finalTestResultReceivedDate == nil {
				self.testResultLoadingError = error
			}
		}
	}

	@objc
	private func scheduleUpdateTimer() {
		updateTimer?.invalidate()

		NotificationCenter.default.removeObserver(self, name: UIApplication.didEnterBackgroundNotification, object: nil)
		NotificationCenter.default.removeObserver(self, name: UIApplication.didBecomeActiveNotification, object: nil)

		guard let nextRevealDate = nextRevealDate else {
			return
		}

		// Schedule new timer.
		NotificationCenter.default.addObserver(self, selector: #selector(invalidateTimer), name: UIApplication.didEnterBackgroundNotification, object: nil)
		NotificationCenter.default.addObserver(self, selector: #selector(scheduleUpdateTimer), name: UIApplication.didBecomeActiveNotification, object: nil)

		updateTimer = Timer(fireAt: nextRevealDate, interval: 0, target: self, selector: #selector(update), userInfo: nil, repeats: false)

		guard let updateTimer = updateTimer else { return }
		RunLoop.main.add(updateTimer, forMode: .common)
	}

	@objc
	private func invalidateTimer() {
		updateTimer?.invalidate()
	}

	@objc
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
