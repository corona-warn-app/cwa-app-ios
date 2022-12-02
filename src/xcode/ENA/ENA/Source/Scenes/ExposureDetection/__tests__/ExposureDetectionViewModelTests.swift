//
// 🦠 Corona-Warn-App
//

import Foundation
import XCTest
@testable import ENA
import OpenCombine

// swiftlint:disable file_length
// swiftlint:disable:next type_body_length
class ExposureDetectionViewModelTests: CWATestCase {

	private var otpService: OTPServiceProviding!
	private var ppacToken: PPACToken!
	private var store: MockTestStore!
	private var client: Client!

	override func setUp() {
		super.setUp()
		
		let deviceCheck = PPACDeviceCheckMock(true, deviceToken: "SomeToken")
		let ppacService = PPACService(store: store, deviceCheck: deviceCheck)
		
		self.store = MockTestStore()
		self.client = ClientMock()
		self.otpService = OTPService(store: store, client: client, restServiceProvider: RestServiceProviderStub(), riskProvider: MockRiskProvider(), ppacService: ppacService, appConfiguration: CachedAppConfigurationMock())
		self.ppacToken = PPACToken(apiToken: "apiTokenFake", deviceToken: "deviceTokenFake")
	}
	
	func testInitialLowRiskStateWithoutEncounters() {
		var subscriptions = Set<AnyCancellable>()

		let homeState = HomeState(
			store: store,
			riskProvider: MockRiskProvider(),
			exposureManagerState: ExposureManagerState(authorized: true, enabled: true, status: .active),
			enState: .enabled,
			statisticsProvider: StatisticsProvider(
				client: CachingHTTPClientMock(),
				store: store
			), localStatisticsProvider: LocalStatisticsProvider(
				client: CachingHTTPClientMock(),
				store: store
			)
		)
		homeState.updateDetectionMode(.automatic)

		let viewModel = ExposureDetectionViewModel(
			homeState: homeState,
			appConfigurationProvider: CachedAppConfigurationMock(),
			onSurveyTap: { },
			onInactiveButtonTap: { },
			onHygieneRulesInfoButtonTap: { },
			onRiskOfContagionInfoButtonTap: { }
		)

		// Needed to check the isHidden state of sections
		let viewController = ExposureDetectionViewController(viewModel: viewModel, store: store)

		let appConfigurationExpectation = expectation(description: "appConfigurationIsSet")
		viewModel.appConfigurationProvider.appConfiguration()
			.sink { _ in
				appConfigurationExpectation.fulfill()
			}
			.store(in: &subscriptions)

		waitForExpectations(timeout: .short)
		
		checkLowRiskConfiguration(
			of: viewModel.dynamicTableViewModel,
			viewController: viewController,
			hasAtLeastOneDayWithLowRiskLevel: false,
			isLoading: false
		)

		XCTAssertEqual(viewModel.titleText, AppStrings.ExposureDetection.low)
		XCTAssertEqual(viewModel.riskBackgroundColor.cgColor, UIColor.enaColor(for: .riskLow).cgColor)
		XCTAssertEqual(viewModel.titleTextColor.cgColor, UIColor.enaColor(for: .textContrast).cgColor)
		XCTAssertEqual(viewModel.closeButtonStyle, .contrast)

		XCTAssertTrue(viewModel.isButtonHidden)

		XCTAssertEqual(viewModel.riskTintColor.cgColor, UIColor.enaColor(for: .riskLow).cgColor)
		XCTAssertEqual(viewModel.riskContrastTintColor.cgColor, UIColor.enaColor(for: .textContrast).cgColor)
		XCTAssertEqual(viewModel.riskSeparatorColor.cgColor, UIColor.enaColor(for: .hairlineContrast).cgColor)

		XCTAssertEqual(
			viewModel.riskDetails,
			Risk.Details(
				mostRecentDateWithRiskLevel: nil,
				numberOfDaysWithRiskLevel: 0,
				calculationDate: nil
			)
		)
	}

	func testLowRiskStateWithEncounters() {
		var subscriptions = Set<AnyCancellable>()

		let mostRecentDateWithLowRisk = Calendar.utcCalendar.startOfDay(for: Date())

		let calculationDate = Date()
		store.enfRiskCalculationResult = ENFRiskCalculationResult(
			riskLevel: .low,
			minimumDistinctEncountersWithLowRisk: 1,
			minimumDistinctEncountersWithHighRisk: 0,
			mostRecentDateWithLowRisk: mostRecentDateWithLowRisk,
			mostRecentDateWithHighRisk: nil,
			numberOfDaysWithLowRisk: 1,
			numberOfDaysWithHighRisk: 0,
			calculationDate: calculationDate,
			riskLevelPerDate: [mostRecentDateWithLowRisk: .low],
			minimumDistinctEncountersWithHighRiskPerDate: [:]
		)

		store.checkinRiskCalculationResult = CheckinRiskCalculationResult(
			calculationDate: calculationDate,
			checkinIdsWithRiskPerDate: [:],
			riskLevelPerDate: [mostRecentDateWithLowRisk: .low]
		)

		let homeState = HomeState(
			store: store,
			riskProvider: MockRiskProvider(),
			exposureManagerState: ExposureManagerState(authorized: true, enabled: true, status: .active),
			enState: .enabled,
			statisticsProvider: StatisticsProvider(
				client: CachingHTTPClientMock(),
				store: store
			), localStatisticsProvider: LocalStatisticsProvider(
				client: CachingHTTPClientMock(),
				store: store
			)
		)
		homeState.updateDetectionMode(.automatic)

		let viewModel = ExposureDetectionViewModel(
			homeState: homeState,
			appConfigurationProvider: CachedAppConfigurationMock(),
			onSurveyTap: { },
			onInactiveButtonTap: { },
			onHygieneRulesInfoButtonTap: { },
			onRiskOfContagionInfoButtonTap: { }
		)

		// Needed to check the isHidden state of sections
		let viewController = ExposureDetectionViewController(viewModel: viewModel, store: store)

		let appConfigurationExpectation = expectation(description: "appConfigurationIsSet")
		viewModel.appConfigurationProvider.appConfiguration()
			.sink { _ in
				appConfigurationExpectation.fulfill()
			}
			.store(in: &subscriptions)

		waitForExpectations(timeout: .short)
		
		checkLowRiskConfiguration(
			of: viewModel.dynamicTableViewModel,
			viewController: viewController,
			hasAtLeastOneDayWithLowRiskLevel: true,
			isLoading: false
		)

		XCTAssertEqual(viewModel.titleText, AppStrings.ExposureDetection.low)
		XCTAssertEqual(viewModel.riskBackgroundColor.cgColor, UIColor.enaColor(for: .riskLow).cgColor)
		XCTAssertEqual(viewModel.titleTextColor.cgColor, UIColor.enaColor(for: .textContrast).cgColor)
		XCTAssertEqual(viewModel.closeButtonStyle, .contrast)

		XCTAssertTrue(viewModel.isButtonHidden)

		XCTAssertEqual(viewModel.riskTintColor.cgColor, UIColor.enaColor(for: .riskLow).cgColor)
		XCTAssertEqual(viewModel.riskContrastTintColor.cgColor, UIColor.enaColor(for: .textContrast).cgColor)
		XCTAssertEqual(viewModel.riskSeparatorColor.cgColor, UIColor.enaColor(for: .hairlineContrast).cgColor)

		XCTAssertEqual(
			viewModel.riskDetails,
			Risk.Details(
				mostRecentDateWithRiskLevel: mostRecentDateWithLowRisk,
				numberOfDaysWithRiskLevel: 1,
				calculationDate: calculationDate
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
		store.enfRiskCalculationResult = ENFRiskCalculationResult(
			riskLevel: .high,
			minimumDistinctEncountersWithLowRisk: 0,
			minimumDistinctEncountersWithHighRisk: 1,
			mostRecentDateWithLowRisk: nil,
			mostRecentDateWithHighRisk: mostRecentDateWithHighRisk,
			numberOfDaysWithLowRisk: 0,
			numberOfDaysWithHighRisk: 1,
			calculationDate: calculationDate,
			riskLevelPerDate: [mostRecentDateWithHighRisk: .high],
			minimumDistinctEncountersWithHighRiskPerDate: [Date(): 1]
		)

		store.checkinRiskCalculationResult = CheckinRiskCalculationResult(
			calculationDate: calculationDate,
			checkinIdsWithRiskPerDate: [:],
			riskLevelPerDate: [mostRecentDateWithHighRisk: .high]
		)
		
		let homeState = HomeState(
			store: store,
			riskProvider: MockRiskProvider(),
			exposureManagerState: ExposureManagerState(authorized: true, enabled: true, status: .active),
			enState: .enabled,
			statisticsProvider: StatisticsProvider(
				client: CachingHTTPClientMock(),
				store: store
			),
			localStatisticsProvider: LocalStatisticsProvider(
				client: CachingHTTPClientMock(),
				store: store
			)
		)
		homeState.updateDetectionMode(.automatic)
		
		let configuration = CachedAppConfigurationMock(isEventSurveyEnabled: false, isEventSurveyUrlAvailable: false)
		
		let viewModel = ExposureDetectionViewModel(
			homeState: homeState,
			appConfigurationProvider: configuration,
			onSurveyTap: { },
			onInactiveButtonTap: { },
			onHygieneRulesInfoButtonTap: { },
			onRiskOfContagionInfoButtonTap: { }
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
		store.enfRiskCalculationResult = ENFRiskCalculationResult(
			riskLevel: .high,
			minimumDistinctEncountersWithLowRisk: 0,
			minimumDistinctEncountersWithHighRisk: 1,
			mostRecentDateWithLowRisk: nil,
			mostRecentDateWithHighRisk: mostRecentDateWithHighRisk,
			numberOfDaysWithLowRisk: 0,
			numberOfDaysWithHighRisk: 1,
			calculationDate: calculationDate,
			riskLevelPerDate: [mostRecentDateWithHighRisk: .high],
			minimumDistinctEncountersWithHighRiskPerDate: [Date(): 1]
		)

		store.checkinRiskCalculationResult = CheckinRiskCalculationResult(
			calculationDate: calculationDate,
			checkinIdsWithRiskPerDate: [:],
			riskLevelPerDate: [mostRecentDateWithHighRisk: .high]
		)

		let homeState = HomeState(
			store: store,
			riskProvider: MockRiskProvider(),
			exposureManagerState: ExposureManagerState(authorized: true, enabled: true, status: .active),
			enState: .enabled,
			statisticsProvider: StatisticsProvider(
				client: CachingHTTPClientMock(),
				store: store
			),
			localStatisticsProvider: LocalStatisticsProvider(
				client: CachingHTTPClientMock(),
				store: store
			)
		)
		homeState.updateDetectionMode(.automatic)
		
		let configuration = CachedAppConfigurationMock(isEventSurveyEnabled: surveyEnabled, isEventSurveyUrlAvailable: surveyEnabled)
		
		let viewModel = ExposureDetectionViewModel(
			homeState: homeState,
			appConfigurationProvider: configuration,
			onSurveyTap: { },
			onInactiveButtonTap: { },
			onHygieneRulesInfoButtonTap: { },
			onRiskOfContagionInfoButtonTap: { }
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
		XCTAssertEqual(viewModel.riskBackgroundColor.cgColor, UIColor.enaColor(for: .riskHigh).cgColor)
		XCTAssertEqual(viewModel.titleTextColor.cgColor, UIColor.enaColor(for: .textContrast).cgColor)
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
				calculationDate: calculationDate
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
		store.enfRiskCalculationResult = ENFRiskCalculationResult(
			riskLevel: .high,
			minimumDistinctEncountersWithLowRisk: 0,
			minimumDistinctEncountersWithHighRisk: 1,
			mostRecentDateWithLowRisk: nil,
			mostRecentDateWithHighRisk: mostRecentDateWithHighRisk,
			numberOfDaysWithLowRisk: 0,
			numberOfDaysWithHighRisk: 1,
			calculationDate: calculationDate,
			riskLevelPerDate: [mostRecentDateWithHighRisk: .high],
			minimumDistinctEncountersWithHighRiskPerDate: [Date(): 1]
		)

		store.checkinRiskCalculationResult = CheckinRiskCalculationResult(
			calculationDate: calculationDate,
			checkinIdsWithRiskPerDate: [:],
			riskLevelPerDate: [mostRecentDateWithHighRisk: .high]
		)

		let homeState = HomeState(
			store: store,
			riskProvider: MockRiskProvider(),
			exposureManagerState: ExposureManagerState(authorized: true, enabled: true, status: .active),
			enState: .enabled,
			statisticsProvider: StatisticsProvider(
				client: CachingHTTPClientMock(),
				store: store
			),
			localStatisticsProvider: LocalStatisticsProvider(
				client: CachingHTTPClientMock(),
				store: store
			)
		)
		homeState.updateDetectionMode(.automatic)
		
		let configuration = CachedAppConfigurationMock(isEventSurveyEnabled: surveyEnabled, isEventSurveyUrlAvailable: surveyEnabled)
		
		let viewModel = ExposureDetectionViewModel(
			homeState: homeState,
			appConfigurationProvider: configuration,
			onSurveyTap: { },
			onInactiveButtonTap: { },
			onHygieneRulesInfoButtonTap: { },
			onRiskOfContagionInfoButtonTap: { }
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
			statisticsProvider: StatisticsProvider(
				client: CachingHTTPClientMock(),
				store: store
			),
			localStatisticsProvider: LocalStatisticsProvider(
				client: CachingHTTPClientMock(),
				store: store
			)
		)
		homeState.updateDetectionMode(.automatic)
		homeState.riskState = .inactive

		let viewModel = ExposureDetectionViewModel(
			homeState: homeState,
			appConfigurationProvider: CachedAppConfigurationMock(),
			onSurveyTap: { },
			onInactiveButtonTap: { },
			onHygieneRulesInfoButtonTap: { },
			onRiskOfContagionInfoButtonTap: { }
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
		XCTAssertTrue(viewModel.isButtonEnabled)
		XCTAssertFalse(viewModel.isButtonHidden)

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
			statisticsProvider: StatisticsProvider(
				client: CachingHTTPClientMock(),
				store: store
			),
			localStatisticsProvider: LocalStatisticsProvider(
				client: CachingHTTPClientMock(),
				store: store
			)
		)
		homeState.updateDetectionMode(.automatic)
		homeState.riskState = .detectionFailed

		let viewModel = ExposureDetectionViewModel(
			homeState: homeState,
			appConfigurationProvider: CachedAppConfigurationMock(),
			onSurveyTap: { },
			onInactiveButtonTap: { },
			onHygieneRulesInfoButtonTap: { },
			onRiskOfContagionInfoButtonTap: { }
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
		XCTAssertTrue(viewModel.isButtonEnabled)
		XCTAssertFalse(viewModel.isButtonHidden)

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
	
	func testOnButtonTapInLowRiskStateAndManualMode() {
		let date = Calendar.utcCalendar.startOfDay(for: Date())
		store.enfRiskCalculationResult = ENFRiskCalculationResult(
			riskLevel: .low,
			minimumDistinctEncountersWithLowRisk: 1,
			minimumDistinctEncountersWithHighRisk: 0,
			mostRecentDateWithLowRisk: Date(),
			mostRecentDateWithHighRisk: nil,
			numberOfDaysWithLowRisk: 1,
			numberOfDaysWithHighRisk: 0,
			calculationDate: date,
			riskLevelPerDate: [date: .low],
			minimumDistinctEncountersWithHighRiskPerDate: [:]
		)

		store.checkinRiskCalculationResult = CheckinRiskCalculationResult(
			calculationDate: date,
			checkinIdsWithRiskPerDate: [:],
			riskLevelPerDate: [date: .low]
		)

		let homeState = HomeState(
			store: store,
			riskProvider: MockRiskProvider(),
			exposureManagerState: ExposureManagerState(authorized: true, enabled: true, status: .active),
			enState: .enabled,
			statisticsProvider: StatisticsProvider(
				client: CachingHTTPClientMock(),
				store: store
			),
			localStatisticsProvider: LocalStatisticsProvider(
				client: CachingHTTPClientMock(),
				store: store
			)
		)
		homeState.updateDetectionMode(.manual)

		var subscriptions = Set<AnyCancellable>()

		let expectedActivityStates: [RiskProviderActivityState] = [.idle, .riskManuallyRequested, .downloading, .detecting, .idle]

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
			onSurveyTap: { },
			onInactiveButtonTap: { onInactiveButtonTapExpectation.fulfill() },
			onHygieneRulesInfoButtonTap: { },
			onRiskOfContagionInfoButtonTap: { }
		)

		viewModel.onButtonTap()

		waitForExpectations(timeout: .medium)

		XCTAssertEqual(receivedActivityStates, expectedActivityStates)
	}

	func testOnButtonTapInHighRiskStateAndManualMode() {
		let date = Calendar.utcCalendar.startOfDay(for: Date())

		store.enfRiskCalculationResult = ENFRiskCalculationResult(
			riskLevel: .high,
			minimumDistinctEncountersWithLowRisk: 0,
			minimumDistinctEncountersWithHighRisk: 1,
			mostRecentDateWithLowRisk: nil,
			mostRecentDateWithHighRisk: Date(),
			numberOfDaysWithLowRisk: 0,
			numberOfDaysWithHighRisk: 1,
			calculationDate: date,
			riskLevelPerDate: [date: .high],
			minimumDistinctEncountersWithHighRiskPerDate: [Date(): 1]
		)

		store.checkinRiskCalculationResult = CheckinRiskCalculationResult(
			calculationDate: date,
			checkinIdsWithRiskPerDate: [:],
			riskLevelPerDate: [date: .low]
		)

		let homeState = HomeState(
			store: store,
			riskProvider: MockRiskProvider(),
			exposureManagerState: ExposureManagerState(authorized: true, enabled: true, status: .active),
			enState: .enabled,
			statisticsProvider: StatisticsProvider(
				client: CachingHTTPClientMock(),
				store: store
			),
			localStatisticsProvider: LocalStatisticsProvider(
				client: CachingHTTPClientMock(),
				store: store
			)
		)
		homeState.updateDetectionMode(.manual)

		var subscriptions = Set<AnyCancellable>()

		let expectedActivityStates: [RiskProviderActivityState] = [.idle, .riskManuallyRequested, .downloading, .detecting, .idle]

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
			onSurveyTap: { },
			onInactiveButtonTap: { onInactiveButtonTapExpectation.fulfill() },
			onHygieneRulesInfoButtonTap: { },
			onRiskOfContagionInfoButtonTap: { }
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
			statisticsProvider: StatisticsProvider(
				client: CachingHTTPClientMock(),
				store: store
			),
			localStatisticsProvider: LocalStatisticsProvider(
				client: CachingHTTPClientMock(),
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
			onSurveyTap: { },
			onInactiveButtonTap: { onInactiveButtonTapExpectation.fulfill() },
			onHygieneRulesInfoButtonTap: { },
			onRiskOfContagionInfoButtonTap: { }
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
			statisticsProvider: StatisticsProvider(
				client: CachingHTTPClientMock(),
				store: store
			),
			localStatisticsProvider: LocalStatisticsProvider(
				client: CachingHTTPClientMock(),
				store: store
			)
		)
		homeState.riskState = .detectionFailed

		var subscriptions = Set<AnyCancellable>()

		let expectedActivityStates: [RiskProviderActivityState] = [.idle, .riskManuallyRequested, .downloading, .detecting, .idle]

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
			onSurveyTap: { },
			onInactiveButtonTap: { onInactiveButtonTapExpectation.fulfill() },
			onHygieneRulesInfoButtonTap: { },
			onRiskOfContagionInfoButtonTap: { }
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
			XCTAssertEqual(section.cells.count, 3)
			XCTAssertEqual(section.cells[0].cellReuseIdentifier.rawValue, "riskCell")
			XCTAssertEqual(section.cells[1].cellReuseIdentifier.rawValue, "riskCell")
			XCTAssertEqual(section.cells[2].cellReuseIdentifier.rawValue, "riskCell")
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
			XCTAssertEqual(section.cells.count, 3)
			XCTAssertEqual(section.cells[0].cellReuseIdentifier.rawValue, "labelCell")
			XCTAssertEqual(section.cells[1].cellReuseIdentifier.rawValue, "headerCell")
			XCTAssertEqual(section.cells[2].cellReuseIdentifier.rawValue, "labelCell")
		} else {
			XCTAssertEqual(section.cells.count, 0)
		}

		// Standard guide section
		section = dynamicTableViewModel.section(3)
		XCTAssertEqual(section.cells.count, 8)
		XCTAssertEqual(section.cells[0].cellReuseIdentifier.rawValue, "headerCell")
		XCTAssertEqual(section.cells[1].cellReuseIdentifier.rawValue, "guideCell")
		XCTAssertEqual(section.cells[2].cellReuseIdentifier.rawValue, "guideCell")
		XCTAssertEqual(section.cells[3].cellReuseIdentifier.rawValue, "guideCell")
		XCTAssertEqual(section.cells[4].cellReuseIdentifier.rawValue, "guideCell")
		XCTAssertEqual(section.cells[5].cellReuseIdentifier.rawValue, "guideCell")
		XCTAssertEqual(section.cells[6].cellReuseIdentifier.rawValue, "guideCell")
		XCTAssertEqual(section.cells[7].cellReuseIdentifier.rawValue, "guideCell")

		// Tracing section
		section = dynamicTableViewModel.section(4)
		XCTAssertEqual(section.cells.count, 2)
		XCTAssertEqual(section.cells[0].cellReuseIdentifier.rawValue, "headerCell")
		XCTAssertEqual(section.cells[1].cellReuseIdentifier.rawValue, "labelCell")

		// Explanation section
		section = dynamicTableViewModel.section(5)
		if hasAtLeastOneDayWithLowRiskLevel == true {
			XCTAssertEqual(section.cells.count, 3)
		} else {
			XCTAssertEqual(section.cells.count, 2)
		}
		XCTAssertEqual(section.cells[0].cellReuseIdentifier.rawValue, "headerCell")
		XCTAssertEqual(section.cells[1].cellReuseIdentifier.rawValue, "labelCell")

	}

	private func checkHighRiskConfiguration(
		of dynamicTableViewModel: DynamicTableViewModel,
		viewController: ExposureDetectionViewController,
		isLoading: Bool
	) {
		// Risk data section
		var section = dynamicTableViewModel.section(0)
		XCTAssertEqual(section.cells.count, 3)
		XCTAssertEqual(section.cells[0].cellReuseIdentifier.rawValue, "riskCell")
		XCTAssertEqual(section.cells[1].cellReuseIdentifier.rawValue, "riskCell")
		XCTAssertEqual(section.cells[2].cellReuseIdentifier.rawValue, "riskCell")
		XCTAssertEqual(section.isHidden(for: viewController), isLoading ? true : false)

		// Loading section
		section = dynamicTableViewModel.section(1)
		XCTAssertEqual(section.cells.count, 1)
		XCTAssertEqual(section.cells[0].cellReuseIdentifier.rawValue, "riskLoadingCell")
		XCTAssertEqual(section.isHidden(for: viewController), isLoading ? false : true)

		// Behaviour section
		section = dynamicTableViewModel.section(2)
		XCTAssertEqual(section.cells.count, 9)
		XCTAssertEqual(section.cells[0].cellReuseIdentifier.rawValue, "labelCell")
		XCTAssertEqual(section.cells[1].cellReuseIdentifier.rawValue, "labelCell")
		XCTAssertEqual(section.cells[2].cellReuseIdentifier.rawValue, "headerCell")
		XCTAssertEqual(section.cells[3].cellReuseIdentifier.rawValue, "guideCell")
		XCTAssertEqual(section.cells[4].cellReuseIdentifier.rawValue, "guideCell")
		XCTAssertEqual(section.cells[5].cellReuseIdentifier.rawValue, "guideCell")
		XCTAssertEqual(section.cells[6].cellReuseIdentifier.rawValue, "longGuideCell")
		XCTAssertEqual(section.cells[7].cellReuseIdentifier.rawValue, "iconWithLinkText")
		XCTAssertEqual(section.cells[8].cellReuseIdentifier.rawValue, "guideCell")

		// Tracing section
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
		XCTAssertEqual(section.cells.count, 3)
		XCTAssertEqual(section.cells[0].cellReuseIdentifier.rawValue, "riskCell")
		XCTAssertEqual(section.cells[1].cellReuseIdentifier.rawValue, "riskCell")
		XCTAssertEqual(section.cells[2].cellReuseIdentifier.rawValue, "riskCell")
		XCTAssertEqual(section.isHidden(for: viewController), isLoading ? true : false)

		// Loading section
		section = dynamicTableViewModel.section(1)
		XCTAssertEqual(section.cells.count, 1)
		XCTAssertEqual(section.cells[0].cellReuseIdentifier.rawValue, "riskLoadingCell")
		XCTAssertEqual(section.isHidden(for: viewController), isLoading ? false : true)

		// Behaviour section
		section = dynamicTableViewModel.section(2)
		XCTAssertEqual(section.cells.count, 9)
		XCTAssertEqual(section.cells[0].cellReuseIdentifier.rawValue, "labelCell")
		XCTAssertEqual(section.cells[1].cellReuseIdentifier.rawValue, "labelCell")
		XCTAssertEqual(section.cells[2].cellReuseIdentifier.rawValue, "headerCell")
		XCTAssertEqual(section.cells[3].cellReuseIdentifier.rawValue, "guideCell")
		XCTAssertEqual(section.cells[4].cellReuseIdentifier.rawValue, "guideCell")
		XCTAssertEqual(section.cells[5].cellReuseIdentifier.rawValue, "guideCell")
		XCTAssertEqual(section.cells[6].cellReuseIdentifier.rawValue, "longGuideCell")
		XCTAssertEqual(section.cells[7].cellReuseIdentifier.rawValue, "iconWithLinkText")
		XCTAssertEqual(section.cells[8].cellReuseIdentifier.rawValue, "guideCell")

		// Survey section
		section = dynamicTableViewModel.section(3)
		XCTAssertEqual(section.cells.count, 1)

		// Tracing section
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
		XCTAssertEqual(section.cells.count, 8)
		XCTAssertEqual(section.cells[0].cellReuseIdentifier.rawValue, "headerCell")
		XCTAssertEqual(section.cells[1].cellReuseIdentifier.rawValue, "guideCell")
		XCTAssertEqual(section.cells[2].cellReuseIdentifier.rawValue, "guideCell")
		XCTAssertEqual(section.cells[3].cellReuseIdentifier.rawValue, "guideCell")
		XCTAssertEqual(section.cells[4].cellReuseIdentifier.rawValue, "guideCell")
		XCTAssertEqual(section.cells[5].cellReuseIdentifier.rawValue, "guideCell")
		XCTAssertEqual(section.cells[6].cellReuseIdentifier.rawValue, "guideCell")
		XCTAssertEqual(section.cells[7].cellReuseIdentifier.rawValue, "guideCell")

		// Explanation section
		let numberOfExposures = viewController.viewModel.riskDetails?.numberOfDaysWithRiskLevel ?? -1
		section = dynamicTableViewModel.section(3)
		XCTAssertEqual(section.cells.count, numberOfExposures > 0 ? 3 : 2)
		XCTAssertEqual(section.cells[0].cellReuseIdentifier.rawValue, "headerCell")
		XCTAssertEqual(section.cells[1].cellReuseIdentifier.rawValue, "labelCell")
	}
}
