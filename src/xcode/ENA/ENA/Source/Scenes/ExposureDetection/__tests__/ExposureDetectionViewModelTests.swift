//
// 🦠 Corona-Warn-App
//

import Foundation
import XCTest
@testable import ENA
import OpenCombine

// swiftlint:disable file_length
// swiftlint:disable:next type_body_length
class ExposureDetectionViewModelTests: XCTestCase {

	private var otpService: OTPServiceProviding!
	private var ppacToken: PPACToken!
	private var store: MockTestStore!
	private var client: Client!
	private var riskExpectation: XCTestExpectation?
	
	override func setUp() {
		super.setUp()
		
		self.store = MockTestStore()
		self.client = ClientMock()
		self.otpService = OTPService(store: store, client: client)
		self.ppacToken = PPACToken(apiToken: "apiTokenFake", deviceToken: "deviceTokenFake")
	}
	
	override func tearDown() {
		otpService = nil
		ppacToken = nil
		client = nil
		store = nil
		
		super.tearDown()
	}
	
	func testInitialLowRiskStateWithoutEncounters() {

		let homeState = HomeState(
			store: store,
			riskProvider: MockRiskProvider(),
			exposureManagerState: ExposureManagerState(authorized: true, enabled: true, status: .active),
			enState: .enabled,
			exposureSubmissionService: MockExposureSubmissionService(),
			statisticsProvider: StatisticsProvider(
				client: CachingHTTPClientMock(store: store),
				store: store
			)
		)
		homeState.updateDetectionMode(.automatic)

		let viewModel = ExposureDetectionViewModel(
			homeState: homeState,
			appConfigurationProvider: CachedAppConfigurationMock(),
			otpService: otpService,
			onSurveyTap: { _ in },
			onInactiveButtonTap: { _ in }
		)

		// Needed to check the isHidden state of sections
		let viewController = ExposureDetectionViewController(viewModel: viewModel, store: store)

		checkLowRiskConfiguration(
			of: viewModel.dynamicTableViewModel,
			viewController: viewController,
			hasAtLeastOneDayWithLowRiskLevel: false,
			isLoading: false
		)

		XCTAssertEqual(viewModel.titleText, AppStrings.ExposureDetection.low)
		XCTAssertEqual(viewModel.riskBackgroundColor, .enaColor(for: .riskLow))
		XCTAssertEqual(viewModel.titleTextColor, .enaColor(for: .textContrast))
		XCTAssertEqual(viewModel.closeButtonStyle, .contrast)

		XCTAssertEqual(viewModel.isButtonHidden, true)

		XCTAssertEqual(viewModel.riskTintColor, .enaColor(for: .riskLow))
		XCTAssertEqual(viewModel.riskContrastTintColor, .enaColor(for: .textContrast))
		XCTAssertEqual(viewModel.riskSeparatorColor, .enaColor(for: .hairlineContrast))

		XCTAssertEqual(
			viewModel.riskDetails,
			Risk.Details(
				mostRecentDateWithRiskLevel: nil,
				numberOfDaysWithRiskLevel: 0,
				activeTracing: store.tracingStatusHistory.activeTracing(),
				exposureDetectionDate: nil
			)
		)
	}

	func testLowRiskStateWithEncounters() {

		let mostRecentDateWithLowRisk = Date()
		let calculationDate = Date()
		store.riskCalculationResult = RiskCalculationResult(
			riskLevel: .low,
			minimumDistinctEncountersWithLowRisk: 2,
			minimumDistinctEncountersWithHighRisk: 0,
			mostRecentDateWithLowRisk: mostRecentDateWithLowRisk,
			mostRecentDateWithHighRisk: nil,
			numberOfDaysWithLowRisk: 2,
			numberOfDaysWithHighRisk: 0,
			calculationDate: calculationDate,
			riskLevelPerDate: [mostRecentDateWithLowRisk: .low]
		)

		let homeState = HomeState(
			store: store,
			riskProvider: MockRiskProvider(),
			exposureManagerState: ExposureManagerState(authorized: true, enabled: true, status: .active),
			enState: .enabled,
			exposureSubmissionService: MockExposureSubmissionService(),
			statisticsProvider: StatisticsProvider(
				client: CachingHTTPClientMock(store: store),
				store: store
			)
		)
		homeState.updateDetectionMode(.automatic)

		let viewModel = ExposureDetectionViewModel(
			homeState: homeState,
			appConfigurationProvider: CachedAppConfigurationMock(),
			otpService: otpService,
			onSurveyTap: { _ in },
			onInactiveButtonTap: { _ in }
		)

		// Needed to check the isHidden state of sections
		let viewController = ExposureDetectionViewController(viewModel: viewModel, store: store)

		checkLowRiskConfiguration(
			of: viewModel.dynamicTableViewModel,
			viewController: viewController,
			hasAtLeastOneDayWithLowRiskLevel: true,
			isLoading: false
		)

		XCTAssertEqual(viewModel.titleText, AppStrings.ExposureDetection.low)
		XCTAssertEqual(viewModel.riskBackgroundColor, .enaColor(for: .riskLow))
		XCTAssertEqual(viewModel.titleTextColor, .enaColor(for: .textContrast))
		XCTAssertEqual(viewModel.closeButtonStyle, .contrast)

		XCTAssertTrue(viewModel.isButtonHidden)

		XCTAssertEqual(viewModel.riskTintColor, .enaColor(for: .riskLow))
		XCTAssertEqual(viewModel.riskContrastTintColor, .enaColor(for: .textContrast))
		XCTAssertEqual(viewModel.riskSeparatorColor, .enaColor(for: .hairlineContrast))

		XCTAssertEqual(
			viewModel.riskDetails,
			Risk.Details(
				mostRecentDateWithRiskLevel: mostRecentDateWithLowRisk,
				numberOfDaysWithRiskLevel: 2,
				activeTracing: store.tracingStatusHistory.activeTracing(),
				exposureDetectionDate: calculationDate
			)
		)

		// Check downloading state

		homeState.riskProviderActivityState = .downloading

		checkLowRiskConfiguration(
			of: viewModel.dynamicTableViewModel,
			viewController: viewController,
			hasAtLeastOneDayWithLowRiskLevel: true,
			isLoading: true
		)

		// Check detecting state

		homeState.riskProviderActivityState = .detecting

		checkLowRiskConfiguration(
			of: viewModel.dynamicTableViewModel,
			viewController: viewController,
			hasAtLeastOneDayWithLowRiskLevel: true,
			isLoading: true
		)

		// Check idle state

		homeState.riskProviderActivityState = .idle

		checkLowRiskConfiguration(
			of: viewModel.dynamicTableViewModel,
			viewController: viewController,
			hasAtLeastOneDayWithLowRiskLevel: true,
			isLoading: false
		)

		// Check that button is shown in manual mode

		homeState.updateDetectionMode(.manual)

		XCTAssertFalse(viewModel.isButtonHidden)

		// Check that button is hidden again in automatic mode

		homeState.updateDetectionMode(.automatic)

		XCTAssertTrue(viewModel.isButtonHidden)
	}

	func testHighRiskStateWithDisabledSurvey() {
		highRiskTesting(surveyEnabled: false)
		highRiskHomeStatesTesting(surveyEnabled: false)

	}
	
	func testHighRiskStateWithEnabledSurvey() {
		highRiskTesting(surveyEnabled: true)
		highRiskHomeStatesTesting(surveyEnabled: true)
	}

	func testEventSurveyDisabled_cellShouldBeHidden() {
		var subscriptions = Set<AnyCancellable>()
				
		let mostRecentDateWithHighRisk = Date()
		let calculationDate = Date()
		store.riskCalculationResult = RiskCalculationResult(
			riskLevel: .high,
			minimumDistinctEncountersWithLowRisk: 0,
			minimumDistinctEncountersWithHighRisk: 1,
			mostRecentDateWithLowRisk: nil,
			mostRecentDateWithHighRisk: mostRecentDateWithHighRisk,
			numberOfDaysWithLowRisk: 0,
			numberOfDaysWithHighRisk: 1,
			calculationDate: calculationDate,
			riskLevelPerDate: [mostRecentDateWithHighRisk: .high]
		)
		
		let homeState = HomeState(
			store: store,
			riskProvider: MockRiskProvider(),
			exposureManagerState: ExposureManagerState(authorized: true, enabled: true, status: .active),
			enState: .enabled,
			exposureSubmissionService: MockExposureSubmissionService(),
			statisticsProvider: StatisticsProvider(
				client: CachingHTTPClientMock(store: store),
				store: store
			)
		)
		homeState.updateDetectionMode(.automatic)
		
		let configuration = CachedAppConfigurationMock(isEventSurveyEnabled: false, isEventSurveyUrlAvailable: false)
		
		let viewModel = ExposureDetectionViewModel(
			homeState: homeState,
			appConfigurationProvider: configuration,
			otpService: otpService,
			onSurveyTap: { _ in },
			onInactiveButtonTap: { _ in }
		)
		
		// Needed to check the isHidden state of sections
		let viewController = ExposureDetectionViewController(viewModel: viewModel, store: store)
		
		let appConfigurationExpectation = expectation(description: "appConfigurationIsSet")
		viewModel.appConfigurationProvider.appConfiguration()
			.sink { _ in
				appConfigurationExpectation.fulfill()
			}
			.store(in: &subscriptions)
		
		waitForExpectations(timeout: 5, handler: { [weak self] _ in
			self?.checkHighRiskConfiguration(
				of: viewModel.dynamicTableViewModel,
				viewController: viewController,
				isLoading: false
			)
		})
	}

	private func highRiskTesting(surveyEnabled: Bool) {
		var subscriptions = Set<AnyCancellable>()
		
		let mostRecentDateWithHighRisk = Date()
		let calculationDate = Date()
		store.riskCalculationResult = RiskCalculationResult(
			riskLevel: .high,
			minimumDistinctEncountersWithLowRisk: 0,
			minimumDistinctEncountersWithHighRisk: 1,
			mostRecentDateWithLowRisk: nil,
			mostRecentDateWithHighRisk: mostRecentDateWithHighRisk,
			numberOfDaysWithLowRisk: 0,
			numberOfDaysWithHighRisk: 1,
			calculationDate: calculationDate,
			riskLevelPerDate: [mostRecentDateWithHighRisk: .high]
		)

		let homeState = HomeState(
			store: store,
			riskProvider: MockRiskProvider(),
			exposureManagerState: ExposureManagerState(authorized: true, enabled: true, status: .active),
			enState: .enabled,
			exposureSubmissionService: MockExposureSubmissionService(),
			statisticsProvider: StatisticsProvider(
				client: CachingHTTPClientMock(store: store),
				store: store
			)
		)
		homeState.updateDetectionMode(.automatic)
		
		let configuration: AppConfigurationProviding
		if surveyEnabled {
			configuration = CachedAppConfigurationMock(isEventSurveyEnabled: surveyEnabled, isEventSurveyUrlAvailable: true)
		} else {
			configuration = CachedAppConfigurationMock()
		}
		
		let viewModel = ExposureDetectionViewModel(
			homeState: homeState,
			appConfigurationProvider: configuration,
			otpService: otpService,
			onSurveyTap: { _ in },
			onInactiveButtonTap: { _ in }
		)
		
		// Needed to check the isHidden state of sections
		let viewController = ExposureDetectionViewController(viewModel: viewModel, store: store)
		
		let appConfigurationExpectation = expectation(description: "appConfigurationIsSet")
		viewModel.appConfigurationProvider.appConfiguration()
			.sink { _ in
				appConfigurationExpectation.fulfill()
			}
			.store(in: &subscriptions)

		waitForExpectations(timeout: 5, handler: { [weak self] _ in
			if surveyEnabled {
				self?.checkHighRiskConfigurationWithSurveyEnabled(
					of: viewModel.dynamicTableViewModel,
					viewController: viewController,
					isLoading: false
				)
			} else {
				self?.checkHighRiskConfiguration(
					of: viewModel.dynamicTableViewModel,
					viewController: viewController,
					isLoading: false
				)
			}
		})

		XCTAssertEqual(viewModel.titleText, AppStrings.ExposureDetection.high)
		XCTAssertEqual(viewModel.riskBackgroundColor, .enaColor(for: .riskHigh))
		XCTAssertEqual(viewModel.titleTextColor, .enaColor(for: .textContrast))
		XCTAssertEqual(viewModel.closeButtonStyle, .contrast)

		XCTAssertTrue(viewModel.isButtonHidden)

		XCTAssertEqual(viewModel.riskTintColor, .enaColor(for: .riskHigh))
		XCTAssertEqual(viewModel.riskContrastTintColor, .enaColor(for: .textContrast))
		XCTAssertEqual(viewModel.riskSeparatorColor, .enaColor(for: .hairlineContrast))

		XCTAssertEqual(
			viewModel.riskDetails,
			Risk.Details(
				mostRecentDateWithRiskLevel: mostRecentDateWithHighRisk,
				numberOfDaysWithRiskLevel: 1,
				activeTracing: store.tracingStatusHistory.activeTracing(),
				exposureDetectionDate: calculationDate
			)
		)

		// Check that button is shown in manual mode

		homeState.updateDetectionMode(.manual)

		XCTAssertFalse(viewModel.isButtonHidden)

		// Check that button is hidden again in automatic mode

		homeState.updateDetectionMode(.automatic)

		XCTAssertTrue(viewModel.isButtonHidden)
	}
	
	private func highRiskHomeStatesTesting(surveyEnabled: Bool) {
		var subscriptions = Set<AnyCancellable>()

		let mostRecentDateWithHighRisk = Date()
		let calculationDate = Date()
		store.riskCalculationResult = RiskCalculationResult(
			riskLevel: .high,
			minimumDistinctEncountersWithLowRisk: 0,
			minimumDistinctEncountersWithHighRisk: 1,
			mostRecentDateWithLowRisk: nil,
			mostRecentDateWithHighRisk: mostRecentDateWithHighRisk,
			numberOfDaysWithLowRisk: 0,
			numberOfDaysWithHighRisk: 1,
			calculationDate: calculationDate,
			riskLevelPerDate: [mostRecentDateWithHighRisk: .high]
		)

		let homeState = HomeState(
			store: store,
			riskProvider: MockRiskProvider(),
			exposureManagerState: ExposureManagerState(authorized: true, enabled: true, status: .active),
			enState: .enabled,
			exposureSubmissionService: MockExposureSubmissionService(),
			statisticsProvider: StatisticsProvider(
				client: CachingHTTPClientMock(store: store),
				store: store
			)
		)
		homeState.updateDetectionMode(.automatic)
		
		let configuration: AppConfigurationProviding
		if surveyEnabled {
			configuration = CachedAppConfigurationMock(isEventSurveyEnabled: surveyEnabled, isEventSurveyUrlAvailable: true)
		} else {
			configuration = CachedAppConfigurationMock()
		}
		
		let viewModel = ExposureDetectionViewModel(
			homeState: homeState,
			appConfigurationProvider: configuration,
			otpService: otpService,
			onSurveyTap: { _ in },
			onInactiveButtonTap: { _ in }
		)
		
		// Needed to check the isHidden state of sections
		let viewController = ExposureDetectionViewController(viewModel: viewModel, store: store)
		
		let appConfigurationExpectation = expectation(description: "appConfigurationIsSet")
		viewModel.appConfigurationProvider.appConfiguration()
			.sink { _ in
				appConfigurationExpectation.fulfill()
			}
			.store(in: &subscriptions)

		waitForExpectations(timeout: 5, handler: { [weak self] _ in
			if surveyEnabled {
				
				// Check downloading state
				
				homeState.riskProviderActivityState = .downloading
				
				self?.checkHighRiskConfigurationWithSurveyEnabled(
					of: viewModel.dynamicTableViewModel,
					viewController: viewController,
					isLoading: true
				)
				
				// Check detecting state
				
				homeState.riskProviderActivityState = .detecting
				
				self?.checkHighRiskConfigurationWithSurveyEnabled(
					of: viewModel.dynamicTableViewModel,
					viewController: viewController,
					isLoading: true
				)
				
				// Check idle state
				
				homeState.riskProviderActivityState = .idle
				
				self?.checkHighRiskConfigurationWithSurveyEnabled(
					of: viewModel.dynamicTableViewModel,
					viewController: viewController,
					isLoading: false
				)
			} else {
				
				// Check downloading state
				
				homeState.riskProviderActivityState = .downloading
				
				self?.checkHighRiskConfiguration(
					of: viewModel.dynamicTableViewModel,
					viewController: viewController,
					isLoading: true
				)
				
				// Check detecting state
				
				homeState.riskProviderActivityState = .detecting
				
				self?.checkHighRiskConfiguration(
					of: viewModel.dynamicTableViewModel,
					viewController: viewController,
					isLoading: true
				)
				
				// Check idle state
				
				homeState.riskProviderActivityState = .idle
				
				self?.checkHighRiskConfiguration(
					of: viewModel.dynamicTableViewModel,
					viewController: viewController,
					isLoading: false
				)
			}
		})
	}
	
	func testInactiveState() {
		let homeState = HomeState(
			store: store,
			riskProvider: MockRiskProvider(),
			exposureManagerState: ExposureManagerState(authorized: true, enabled: true, status: .active),
			enState: .enabled,
			exposureSubmissionService: MockExposureSubmissionService(),
			statisticsProvider: StatisticsProvider(
				client: CachingHTTPClientMock(store: store),
				store: store
			)
		)
		homeState.updateDetectionMode(.automatic)
		homeState.riskState = .inactive

		let viewModel = ExposureDetectionViewModel(
			homeState: homeState,
			appConfigurationProvider: CachedAppConfigurationMock(),
			otpService: otpService,
			onSurveyTap: { _ in },
			onInactiveButtonTap: { _ in }
		)

		// Needed to check the isHidden state of sections
		let viewController = ExposureDetectionViewController(viewModel: viewModel, store: store)

		checkInactiveOrFailedConfiguration(
			of: viewModel.dynamicTableViewModel,
			viewController: viewController,
			isLoading: false
		)

		XCTAssertEqual(viewModel.titleText, AppStrings.ExposureDetection.off)
		XCTAssertEqual(viewModel.riskBackgroundColor, .enaColor(for: .background))
		XCTAssertEqual(viewModel.titleTextColor, .enaColor(for: .textPrimary1))
		XCTAssertEqual(viewModel.closeButtonStyle, .normal)

		XCTAssertEqual(viewModel.buttonTitle, AppStrings.Home.riskCardInactiveNoCalculationPossibleButton)
		XCTAssertEqual(viewModel.isButtonEnabled, true)
		XCTAssertEqual(viewModel.isButtonHidden, false)

		XCTAssertEqual(viewModel.riskTintColor, .enaColor(for: .riskNeutral))
		XCTAssertEqual(viewModel.riskContrastTintColor, .enaColor(for: .riskNeutral))
		XCTAssertEqual(viewModel.riskSeparatorColor, .enaColor(for: .hairline))

		XCTAssertNil(viewModel.riskDetails)

		// Check downloading state

		homeState.riskProviderActivityState = .downloading

		checkInactiveOrFailedConfiguration(
			of: viewModel.dynamicTableViewModel,
			viewController: viewController,
			isLoading: true
		)

		// Check detecting state

		homeState.riskProviderActivityState = .detecting

		checkInactiveOrFailedConfiguration(
			of: viewModel.dynamicTableViewModel,
			viewController: viewController,
			isLoading: true
		)

		// Check idle state

		homeState.riskProviderActivityState = .idle

		checkInactiveOrFailedConfiguration(
			of: viewModel.dynamicTableViewModel,
			viewController: viewController,
			isLoading: false
		)
	}

	func testFailedState() {
		let homeState = HomeState(
			store: store,
			riskProvider: MockRiskProvider(),
			exposureManagerState: ExposureManagerState(authorized: true, enabled: true, status: .active),
			enState: .enabled,
			exposureSubmissionService: MockExposureSubmissionService(),
			statisticsProvider: StatisticsProvider(
				client: CachingHTTPClientMock(store: store),
				store: store
			)
		)
		homeState.updateDetectionMode(.automatic)
		homeState.riskState = .detectionFailed

		let viewModel = ExposureDetectionViewModel(
			homeState: homeState,
			appConfigurationProvider: CachedAppConfigurationMock(),
			otpService: otpService,
			onSurveyTap: { _ in },
			onInactiveButtonTap: { _ in }
		)

		// Needed to check the isHidden state of sections
		let viewController = ExposureDetectionViewController(viewModel: viewModel, store: store)

		checkInactiveOrFailedConfiguration(
			of: viewModel.dynamicTableViewModel,
			viewController: viewController,
			isLoading: false
		)

		XCTAssertEqual(viewModel.titleText, AppStrings.ExposureDetection.riskCardFailedCalculationTitle)
		XCTAssertEqual(viewModel.riskBackgroundColor, .enaColor(for: .background))
		XCTAssertEqual(viewModel.titleTextColor, .enaColor(for: .textPrimary1))
		XCTAssertEqual(viewModel.closeButtonStyle, .normal)

		XCTAssertEqual(viewModel.buttonTitle, AppStrings.Home.riskCardFailedCalculationRestartButtonTitle)
		XCTAssertEqual(viewModel.isButtonEnabled, true)
		XCTAssertEqual(viewModel.isButtonHidden, false)

		XCTAssertEqual(viewModel.riskTintColor, .enaColor(for: .riskNeutral))
		XCTAssertEqual(viewModel.riskContrastTintColor, .enaColor(for: .riskNeutral))
		XCTAssertEqual(viewModel.riskSeparatorColor, .enaColor(for: .hairline))

		XCTAssertNil(viewModel.riskDetails)

		// Check downloading state

		homeState.riskProviderActivityState = .downloading

		checkInactiveOrFailedConfiguration(
			of: viewModel.dynamicTableViewModel,
			viewController: viewController,
			isLoading: true
		)

		// Check detecting state

		homeState.riskProviderActivityState = .detecting

		checkInactiveOrFailedConfiguration(
			of: viewModel.dynamicTableViewModel,
			viewController: viewController,
			isLoading: true
		)

		// Check idle state

		homeState.riskProviderActivityState = .idle

		checkInactiveOrFailedConfiguration(
			of: viewModel.dynamicTableViewModel,
			viewController: viewController,
			isLoading: false
		)
	}
	
	func testIfRishChangeFromHighToLow_thenOTPisReseted() throws {
		
		let homeState = HomeState(
			store: store,
			riskProvider: MockRiskProvider(),
			exposureManagerState: ExposureManagerState(authorized: true, enabled: true, status: .active),
			enState: .enabled,
			exposureSubmissionService: MockExposureSubmissionService(),
			statisticsProvider: StatisticsProvider(
				client: CachingHTTPClientMock(store: store),
				store: store
			)
		)
		homeState.updateDetectionMode(.automatic)
		homeState.riskState = .detectionFailed

		otpService.getOTP(ppacToken: PPACToken(apiToken: "test", deviceToken: "test")) { result in
			switch result {
			case .success:
				XCTAssert(true)
			case .failure(let error):
				XCTFail(error.localizedDescription)
			}
		}
		// we need the "let" or the viewModel instance will be deallocated when the expectations closure in line 701 returns
		let viewModel = ExposureDetectionViewModel(
			homeState: homeState,
			appConfigurationProvider: CachedAppConfigurationMock(),
			otpService: otpService,
			onSurveyTap: { _ in },
			onInactiveButtonTap: { _ in }
		)
		XCTAssertNotNil(viewModel, "View model should not be deallocated")
		
		store.shouldShowRiskStatusLoweredAlert = false
		let riskProvider = try riskProviderChangingRiskLevel(from: .high, to: .low, store: store)
		riskProvider.requestRisk(userInitiated: true)
		
		self.riskExpectation = expectation(description: "otp token reset expectation")
		NotificationCenter.default.addObserver(self, selector: #selector(didReciveNotificationForRiskLevelChange(_:)), name: .riskStatusLowerd, object: nil)
		waitForExpectations(timeout: 10) { [weak self] _ in
			guard let self = self else { return }
			XCTAssertNil(self.store.otpToken, "Token should be reseted after changing risk from high to low")
		}
	}
	
	func testOnButtonTapInLowRiskStateAndManualMode() {
		store.riskCalculationResult = RiskCalculationResult(
			riskLevel: .low,
			minimumDistinctEncountersWithLowRisk: 2,
			minimumDistinctEncountersWithHighRisk: 0,
			mostRecentDateWithLowRisk: Date(),
			mostRecentDateWithHighRisk: nil,
			numberOfDaysWithLowRisk: 2,
			numberOfDaysWithHighRisk: 0,
			calculationDate: Date(),
			riskLevelPerDate: [Date(): .low]
		)

		let homeState = HomeState(
			store: store,
			riskProvider: MockRiskProvider(),
			exposureManagerState: ExposureManagerState(authorized: true, enabled: true, status: .active),
			enState: .enabled,
			exposureSubmissionService: MockExposureSubmissionService(),
			statisticsProvider: StatisticsProvider(
				client: CachingHTTPClientMock(store: store),
				store: store
			)
		)
		homeState.updateDetectionMode(.manual)

		var subscriptions = Set<AnyCancellable>()

		let expectedActivityStates: [RiskProviderActivityState] = [.idle, .riskRequested, .downloading, .detecting, .idle]

		let activityStateExpectation = expectation(description: "riskProviderActivityState updated")
		activityStateExpectation.expectedFulfillmentCount = expectedActivityStates.count

		var receivedActivityStates = [RiskProviderActivityState]()
		homeState.$riskProviderActivityState
			.sink {
				receivedActivityStates.append($0)
				activityStateExpectation.fulfill()
			}
			.store(in: &subscriptions)


		let onInactiveButtonTapExpectation = expectation(description: "onInactiveButtonTap not called")
		onInactiveButtonTapExpectation.isInverted = true

		let viewModel = ExposureDetectionViewModel(
			homeState: homeState,
			appConfigurationProvider: CachedAppConfigurationMock(),
			otpService: otpService,
			onSurveyTap: { _ in },
			onInactiveButtonTap: { _ in onInactiveButtonTapExpectation.fulfill() }
		)

		viewModel.onButtonTap()

		waitForExpectations(timeout: .medium)

		XCTAssertEqual(receivedActivityStates, expectedActivityStates)
	}

	func testOnButtonTapInHighRiskStateAndManualMode() {
		store.riskCalculationResult = RiskCalculationResult(
			riskLevel: .high,
			minimumDistinctEncountersWithLowRisk: 0,
			minimumDistinctEncountersWithHighRisk: 2,
			mostRecentDateWithLowRisk: nil,
			mostRecentDateWithHighRisk: Date(),
			numberOfDaysWithLowRisk: 0,
			numberOfDaysWithHighRisk: 1,
			calculationDate: Date(),
			riskLevelPerDate: [Date(): .high]
		)

		let homeState = HomeState(
			store: store,
			riskProvider: MockRiskProvider(),
			exposureManagerState: ExposureManagerState(authorized: true, enabled: true, status: .active),
			enState: .enabled,
			exposureSubmissionService: MockExposureSubmissionService(),
			statisticsProvider: StatisticsProvider(
				client: CachingHTTPClientMock(store: store),
				store: store
			)
		)
		homeState.updateDetectionMode(.manual)

		var subscriptions = Set<AnyCancellable>()

		let expectedActivityStates: [RiskProviderActivityState] = [.idle, .riskRequested, .downloading, .detecting, .idle]

		let activityStateExpectation = expectation(description: "riskProviderActivityState updated")
		activityStateExpectation.expectedFulfillmentCount = expectedActivityStates.count

		var receivedActivityStates = [RiskProviderActivityState]()
		homeState.$riskProviderActivityState
			.sink {
				receivedActivityStates.append($0)
				activityStateExpectation.fulfill()
			}
			.store(in: &subscriptions)


		let onInactiveButtonTapExpectation = expectation(description: "onInactiveButtonTap not called")
		onInactiveButtonTapExpectation.isInverted = true

		let viewModel = ExposureDetectionViewModel(
			homeState: homeState,
			appConfigurationProvider: CachedAppConfigurationMock(),
			otpService: otpService,
			onSurveyTap: { _ in },
			onInactiveButtonTap: { _ in onInactiveButtonTapExpectation.fulfill() }
		)

		viewModel.onButtonTap()

		waitForExpectations(timeout: .medium)

		XCTAssertEqual(receivedActivityStates, expectedActivityStates)
	}

	func testOnButtonTapInInactiveState() {
		let homeState = HomeState(
			store: store,
			riskProvider: MockRiskProvider(),
			exposureManagerState: ExposureManagerState(authorized: true, enabled: true, status: .active),
			enState: .enabled,
			exposureSubmissionService: MockExposureSubmissionService(),
			statisticsProvider: StatisticsProvider(
				client: CachingHTTPClientMock(store: store),
				store: store
			)
		)
		homeState.riskState = .inactive

		var subscriptions = Set<AnyCancellable>()

		let expectedActivityStates: [RiskProviderActivityState] = [.idle]

		let activityStateExpectation = expectation(description: "riskProviderActivityState initialized but not updated")
		activityStateExpectation.expectedFulfillmentCount = expectedActivityStates.count

		var receivedActivityStates = [RiskProviderActivityState]()
		homeState.$riskProviderActivityState
			.sink {
				receivedActivityStates.append($0)
				activityStateExpectation.fulfill()
			}
			.store(in: &subscriptions)


		let onInactiveButtonTapExpectation = expectation(description: "onInactiveButtonTap called")

		let viewModel = ExposureDetectionViewModel(
			homeState: homeState,
			appConfigurationProvider: CachedAppConfigurationMock(),
			otpService: otpService,
			onSurveyTap: { _ in },
			onInactiveButtonTap: { _ in onInactiveButtonTapExpectation.fulfill() }
		)

		viewModel.onButtonTap()

		waitForExpectations(timeout: .medium)

		XCTAssertEqual(receivedActivityStates, expectedActivityStates)
	}

	func testOnButtonTapInFailedState() {
		let homeState = HomeState(
			store: store,
			riskProvider: MockRiskProvider(),
			exposureManagerState: ExposureManagerState(authorized: true, enabled: true, status: .active),
			enState: .enabled,
			exposureSubmissionService: MockExposureSubmissionService(),
			statisticsProvider: StatisticsProvider(
				client: CachingHTTPClientMock(store: store),
				store: store
			)
		)
		homeState.riskState = .detectionFailed

		var subscriptions = Set<AnyCancellable>()

		let expectedActivityStates: [RiskProviderActivityState] = [.idle, .riskRequested, .downloading, .detecting, .idle]

		let activityStateExpectation = expectation(description: "riskProviderActivityState updated")
		activityStateExpectation.expectedFulfillmentCount = expectedActivityStates.count

		var receivedActivityStates = [RiskProviderActivityState]()
		homeState.$riskProviderActivityState
			.sink {
				receivedActivityStates.append($0)
				activityStateExpectation.fulfill()
			}
			.store(in: &subscriptions)

		let onInactiveButtonTapExpectation = expectation(description: "onInactiveButtonTap not called")
		onInactiveButtonTapExpectation.isInverted = true


		let viewModel = ExposureDetectionViewModel(
			homeState: homeState,
			appConfigurationProvider: CachedAppConfigurationMock(),
			otpService: otpService,
			onSurveyTap: { _ in },
			onInactiveButtonTap: { _ in onInactiveButtonTapExpectation.fulfill() }
		)

		viewModel.onButtonTap()

		waitForExpectations(timeout: .medium)

		XCTAssertEqual(receivedActivityStates, expectedActivityStates)
	}

	// MARK: - Private

	private func checkLowRiskConfiguration(
		of dynamicTableViewModel: DynamicTableViewModel,
		viewController: ExposureDetectionViewController,
		hasAtLeastOneDayWithLowRiskLevel: Bool,
		isLoading: Bool
	) {
		// Risk data section
		var section = dynamicTableViewModel.section(0)
		if hasAtLeastOneDayWithLowRiskLevel {
			XCTAssertEqual(section.cells.count, 4)
			XCTAssertEqual(section.cells[0].cellReuseIdentifier.rawValue, "riskCell")
			XCTAssertEqual(section.cells[1].cellReuseIdentifier.rawValue, "riskCell")
			XCTAssertEqual(section.cells[2].cellReuseIdentifier.rawValue, "riskCell")
			XCTAssertEqual(section.cells[3].cellReuseIdentifier.rawValue, "riskCell")
		} else {
			XCTAssertEqual(section.cells.count, 3)
			XCTAssertEqual(section.cells[0].cellReuseIdentifier.rawValue, "riskCell")
			XCTAssertEqual(section.cells[1].cellReuseIdentifier.rawValue, "riskCell")
			XCTAssertEqual(section.cells[2].cellReuseIdentifier.rawValue, "riskCell")
		}
		XCTAssertEqual(section.isHidden(for: viewController), isLoading ? true : false)

		// Loading section
		section = dynamicTableViewModel.section(1)
		XCTAssertEqual(section.cells.count, 1)
		XCTAssertEqual(section.cells[0].cellReuseIdentifier.rawValue, "riskLoadingCell")
		XCTAssertEqual(section.isHidden(for: viewController), isLoading ? false : true)

		// Low risk exposure section
		section = dynamicTableViewModel.section(2)
		if hasAtLeastOneDayWithLowRiskLevel {
			XCTAssertEqual(section.cells.count, 2)
			XCTAssertEqual(section.cells[0].cellReuseIdentifier.rawValue, "headerCell")
			XCTAssertEqual(section.cells[1].cellReuseIdentifier.rawValue, "labelCell")
		} else {
			XCTAssertEqual(section.cells.count, 0)
		}

		// Standard guide section
		section = dynamicTableViewModel.section(3)
		XCTAssertEqual(section.cells.count, 5)
		XCTAssertEqual(section.cells[0].cellReuseIdentifier.rawValue, "headerCell")
		XCTAssertEqual(section.cells[1].cellReuseIdentifier.rawValue, "guideCell")
		XCTAssertEqual(section.cells[2].cellReuseIdentifier.rawValue, "guideCell")
		XCTAssertEqual(section.cells[3].cellReuseIdentifier.rawValue, "guideCell")
		XCTAssertEqual(section.cells[4].cellReuseIdentifier.rawValue, "guideCell")

		// Active tracing section
		section = dynamicTableViewModel.section(4)
		XCTAssertEqual(section.cells.count, 2)
		XCTAssertEqual(section.cells[0].cellReuseIdentifier.rawValue, "headerCell")
		XCTAssertEqual(section.cells[1].cellReuseIdentifier.rawValue, "labelCell")

		// Explanation section
		section = dynamicTableViewModel.section(5)
		XCTAssertEqual(section.cells.count, hasAtLeastOneDayWithLowRiskLevel ? 3 : 2)
		XCTAssertEqual(section.cells[0].cellReuseIdentifier.rawValue, "headerCell")
		XCTAssertEqual(section.cells[1].cellReuseIdentifier.rawValue, "labelCell")

		if hasAtLeastOneDayWithLowRiskLevel {
			XCTAssertEqual(section.cells[2].cellReuseIdentifier.rawValue, "linkCell")

			switch section.cells[2].action {
			case .open(url: let url):
				XCTAssertEqual(AppStrings.ExposureDetection.explanationFAQLink, url?.absoluteString)
			default:
				XCTFail("FAQ Link cell not found")
			}
		}
	}

	private func checkHighRiskConfiguration(
		of dynamicTableViewModel: DynamicTableViewModel,
		viewController: ExposureDetectionViewController,
		isLoading: Bool
	) {
		// Risk data section
		var section = dynamicTableViewModel.section(0)
		XCTAssertEqual(section.cells.count, 4)
		XCTAssertEqual(section.cells[0].cellReuseIdentifier.rawValue, "riskCell")
		XCTAssertEqual(section.cells[1].cellReuseIdentifier.rawValue, "riskCell")
		XCTAssertEqual(section.cells[2].cellReuseIdentifier.rawValue, "riskCell")
		XCTAssertEqual(section.cells[3].cellReuseIdentifier.rawValue, "riskCell")
		XCTAssertEqual(section.isHidden(for: viewController), isLoading ? true : false)

		// Loading section
		section = dynamicTableViewModel.section(1)
		XCTAssertEqual(section.cells.count, 1)
		XCTAssertEqual(section.cells[0].cellReuseIdentifier.rawValue, "riskLoadingCell")
		XCTAssertEqual(section.isHidden(for: viewController), isLoading ? false : true)

		// Behaviour section
		section = dynamicTableViewModel.section(2)
		XCTAssertEqual(section.cells.count, 4)
		XCTAssertEqual(section.cells[0].cellReuseIdentifier.rawValue, "headerCell")
		XCTAssertEqual(section.cells[1].cellReuseIdentifier.rawValue, "guideCell")
		XCTAssertEqual(section.cells[2].cellReuseIdentifier.rawValue, "guideCell")
		XCTAssertEqual(section.cells[3].cellReuseIdentifier.rawValue, "longGuideCell")

		// Active tracing section
		section = dynamicTableViewModel.section(3)
		XCTAssertEqual(section.cells.count, 2)
		XCTAssertEqual(section.cells[0].cellReuseIdentifier.rawValue, "headerCell")
		XCTAssertEqual(section.cells[1].cellReuseIdentifier.rawValue, "labelCell")

		// Explanation section
		section = dynamicTableViewModel.section(4)
		XCTAssertEqual(section.cells.count, 2)
		XCTAssertEqual(section.cells[0].cellReuseIdentifier.rawValue, "headerCell")
		XCTAssertEqual(section.cells[1].cellReuseIdentifier.rawValue, "labelCell")
	}

	private func checkHighRiskConfigurationWithSurveyEnabled(
		of dynamicTableViewModel: DynamicTableViewModel,
		viewController: ExposureDetectionViewController,
		isLoading: Bool
	) {
		// Risk data section
		var section = dynamicTableViewModel.section(0)
		XCTAssertEqual(section.cells.count, 4)
		XCTAssertEqual(section.cells[0].cellReuseIdentifier.rawValue, "riskCell")
		XCTAssertEqual(section.cells[1].cellReuseIdentifier.rawValue, "riskCell")
		XCTAssertEqual(section.cells[2].cellReuseIdentifier.rawValue, "riskCell")
		XCTAssertEqual(section.cells[3].cellReuseIdentifier.rawValue, "riskCell")
		XCTAssertEqual(section.isHidden(for: viewController), isLoading ? true : false)

		// Loading section
		section = dynamicTableViewModel.section(1)
		XCTAssertEqual(section.cells.count, 1)
		XCTAssertEqual(section.cells[0].cellReuseIdentifier.rawValue, "riskLoadingCell")
		XCTAssertEqual(section.isHidden(for: viewController), isLoading ? false : true)

		// Behaviour section
		section = dynamicTableViewModel.section(2)
		XCTAssertEqual(section.cells.count, 4)
		XCTAssertEqual(section.cells[0].cellReuseIdentifier.rawValue, "headerCell")
		XCTAssertEqual(section.cells[1].cellReuseIdentifier.rawValue, "guideCell")
		XCTAssertEqual(section.cells[2].cellReuseIdentifier.rawValue, "guideCell")
		XCTAssertEqual(section.cells[3].cellReuseIdentifier.rawValue, "longGuideCell")

		// Survey section
		section = dynamicTableViewModel.section(3)
		XCTAssertEqual(section.cells.count, 1)

		// Active tracing section
		section = dynamicTableViewModel.section(4)
		XCTAssertEqual(section.cells.count, 2)
		XCTAssertEqual(section.cells[0].cellReuseIdentifier.rawValue, "headerCell")
		XCTAssertEqual(section.cells[1].cellReuseIdentifier.rawValue, "labelCell")

		// Explanation section
		section = dynamicTableViewModel.section(5)
		XCTAssertEqual(section.cells.count, 2)
		XCTAssertEqual(section.cells[0].cellReuseIdentifier.rawValue, "headerCell")
		XCTAssertEqual(section.cells[1].cellReuseIdentifier.rawValue, "labelCell")
	}
	
	private func checkInactiveOrFailedConfiguration(
		of dynamicTableViewModel: DynamicTableViewModel,
		viewController: ExposureDetectionViewController,
		isLoading: Bool
	) {
		// Data section
		var section = dynamicTableViewModel.section(0)
		XCTAssertEqual(section.cells.count, 3)
		XCTAssertEqual(section.cells[0].cellReuseIdentifier.rawValue, "riskTextCell")
		XCTAssertEqual(section.cells[1].cellReuseIdentifier.rawValue, "riskCell")
		XCTAssertEqual(section.cells[2].cellReuseIdentifier.rawValue, "riskCell")

		// Loading section
		section = dynamicTableViewModel.section(1)
		XCTAssertEqual(section.cells.count, 1)
		XCTAssertEqual(section.cells[0].cellReuseIdentifier.rawValue, "riskLoadingCell")
		XCTAssertEqual(section.isHidden(for: viewController), isLoading ? false : true)

		// Standard guide section
		section = dynamicTableViewModel.section(2)
		XCTAssertEqual(section.cells.count, 5)
		XCTAssertEqual(section.cells[0].cellReuseIdentifier.rawValue, "headerCell")
		XCTAssertEqual(section.cells[1].cellReuseIdentifier.rawValue, "guideCell")
		XCTAssertEqual(section.cells[2].cellReuseIdentifier.rawValue, "guideCell")
		XCTAssertEqual(section.cells[3].cellReuseIdentifier.rawValue, "guideCell")
		XCTAssertEqual(section.cells[4].cellReuseIdentifier.rawValue, "guideCell")

		// Explanation section
		section = dynamicTableViewModel.section(3)
		XCTAssertEqual(section.cells.count, 2)
		XCTAssertEqual(section.cells[0].cellReuseIdentifier.rawValue, "headerCell")
		XCTAssertEqual(section.cells[1].cellReuseIdentifier.rawValue, "labelCell")
	}
	
	@objc private func didReciveNotificationForRiskLevelChange(_: NSNotification) {
		self.riskExpectation?.fulfill()
	}
	private func riskProviderChangingRiskLevel(from previousRiskLevel: RiskLevel, to newRiskLevel: RiskLevel, store: MockTestStore) throws -> RiskProvider {
		let duration = DateComponents(day: 2)

		let lastExposureDetectionDate = try XCTUnwrap(
			Calendar.current.date(byAdding: .day, value: -1, to: Date(), wrappingComponents: false)
		)

		store.riskCalculationResult = RiskCalculationResult(
			riskLevel: previousRiskLevel,
			minimumDistinctEncountersWithLowRisk: 0,
			minimumDistinctEncountersWithHighRisk: 0,
			mostRecentDateWithLowRisk: nil,
			mostRecentDateWithHighRisk: nil,
			numberOfDaysWithLowRisk: 0,
			numberOfDaysWithHighRisk: 0,
			calculationDate: lastExposureDetectionDate,
			riskLevelPerDate: [:]
		)

		let config = RiskProvidingConfiguration(
			exposureDetectionValidityDuration: duration,
			exposureDetectionInterval: duration,
			detectionMode: .automatic
		)

		let exposureDetectionDelegateStub = ExposureDetectionDelegateStub(result: .success([MutableENExposureWindow()]))

		let appConfigurationProvider = CachedAppConfigurationMock()

		let downloadedPackagesStore: DownloadedPackagesStore = DownloadedPackagesSQLLiteStore .inMemory()
		downloadedPackagesStore.open()
		let client = ClientMock()
		let keyPackageDownload = KeyPackageDownload(
			downloadedPackagesStore: downloadedPackagesStore,
			client: client,
			wifiClient: client,
			store: store
		)
		return RiskProvider(
			configuration: config,
			store: store,
			appConfigurationProvider: appConfigurationProvider,
			exposureManagerState: .init(authorized: true, enabled: true, status: .active),
			riskCalculation: RiskCalculationFake(riskLevel: newRiskLevel),
			keyPackageDownload: keyPackageDownload,
			exposureDetectionExecutor: exposureDetectionDelegateStub
		)
	}
	
	private struct RiskCalculationFake: RiskCalculationProtocol {

		init(riskLevel: RiskLevel = .low) {
			self.riskLevel = riskLevel
		}

		let riskLevel: RiskLevel

		func calculateRisk(
			exposureWindows: [ExposureWindow],
			configuration: RiskCalculationConfiguration
		) throws -> RiskCalculationResult {
			RiskCalculationResult(
				riskLevel: riskLevel,
				minimumDistinctEncountersWithLowRisk: 0,
				minimumDistinctEncountersWithHighRisk: 0,
				mostRecentDateWithLowRisk: nil,
				mostRecentDateWithHighRisk: nil,
				numberOfDaysWithLowRisk: 0,
				numberOfDaysWithHighRisk: 0,
				calculationDate: Date(),
				riskLevelPerDate: [:]
			)
		}

	}
}
