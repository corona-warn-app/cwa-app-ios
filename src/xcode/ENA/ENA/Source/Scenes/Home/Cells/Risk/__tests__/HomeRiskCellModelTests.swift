//
// 🦠 Corona-Warn-App
//

import Foundation
import XCTest
@testable import ENA
import OpenCombine

// swiftlint:disable file_length
// swiftlint:disable:next type_body_length
class HomeRiskCellModelTests: XCTestCase {

	func testLowRiskState() {
		let store = MockTestStore()

		let riskCalculationResult = RiskCalculationResult(
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

		store.riskCalculationResult = riskCalculationResult

		let homeState = HomeState(
			store: store,
			riskProvider: MockRiskProvider(),
			exposureManagerState: ExposureManagerState(authorized: true, enabled: true, status: .active),
			enState: .enabled,
			exposureSubmissionService: MockExposureSubmissionService()
		)
		homeState.detectionMode = .automatic

		let viewModel = HomeRiskCellModel(
			homeState: homeState,
			onInactiveButtonTap: { },
			onUpdate: { }
		)

		XCTAssertEqual(viewModel.title, AppStrings.Home.riskCardLowTitle)
		XCTAssertEqual(viewModel.titleColor, .enaColor(for: .textContrast))
		XCTAssertEqual(viewModel.chevronStyle, .circled)

		XCTAssertTrue(viewModel.isBodyHidden)

		XCTAssertEqual(viewModel.backgroundColor, .enaColor(for: .riskLow))
		XCTAssertEqual(viewModel.separatorColor, .enaColor(for: .hairlineContrast))

		XCTAssertTrue(viewModel.isButtonHidden)

		XCTAssertEqual(viewModel.itemViewModels.count, 3)

		// Check downloading state

		homeState.riskProviderActivityState = .downloading

		XCTAssertEqual(viewModel.title, AppStrings.Home.riskCardStatusDownloadingTitle)
		XCTAssertEqual(viewModel.titleColor, .enaColor(for: .textContrast))
		XCTAssertEqual(viewModel.chevronStyle, .circled)

		XCTAssertTrue(viewModel.isBodyHidden)

		XCTAssertEqual(viewModel.backgroundColor, .enaColor(for: .riskLow))
		XCTAssertEqual(viewModel.separatorColor, .enaColor(for: .hairlineContrast))

		XCTAssertTrue(viewModel.isButtonHidden)

		XCTAssertEqual(viewModel.itemViewModels.count, 1)

		// Check detecting state

		homeState.riskProviderActivityState = .detecting

		XCTAssertEqual(viewModel.title, AppStrings.Home.riskCardStatusDetectingTitle)
		XCTAssertEqual(viewModel.titleColor, .enaColor(for: .textContrast))
		XCTAssertEqual(viewModel.chevronStyle, .circled)

		XCTAssertTrue(viewModel.isBodyHidden)

		XCTAssertEqual(viewModel.backgroundColor, .enaColor(for: .riskLow))
		XCTAssertEqual(viewModel.separatorColor, .enaColor(for: .hairlineContrast))

		XCTAssertTrue(viewModel.isButtonHidden)

		XCTAssertEqual(viewModel.itemViewModels.count, 1)

		// Check idle state

		homeState.riskProviderActivityState = .idle
		homeState.riskState = .risk(
			Risk(
				activeTracing: .init(interval: 0),
				riskCalculationResult: riskCalculationResult
			)
		)

		XCTAssertEqual(viewModel.title, AppStrings.Home.riskCardLowTitle)
		XCTAssertEqual(viewModel.titleColor, .enaColor(for: .textContrast))
		XCTAssertEqual(viewModel.chevronStyle, .circled)

		XCTAssertTrue(viewModel.isBodyHidden)

		XCTAssertEqual(viewModel.backgroundColor, .enaColor(for: .riskLow))
		XCTAssertEqual(viewModel.separatorColor, .enaColor(for: .hairlineContrast))

		XCTAssertTrue(viewModel.isButtonHidden)
		XCTAssertTrue(viewModel.isButtonInverted)

		XCTAssertEqual(viewModel.itemViewModels.count, 3)

		// Check that button is shown in manual mode

		homeState.detectionMode = .manual

		XCTAssertFalse(viewModel.isButtonHidden)

		// Check that button is hidden again in automatic mode

		homeState.detectionMode = .automatic

		XCTAssertTrue(viewModel.isButtonHidden)
	}

	func testHighRiskState() {
		let store = MockTestStore()

		let riskCalculationResult = RiskCalculationResult(
			riskLevel: .high,
			minimumDistinctEncountersWithLowRisk: 0,
			minimumDistinctEncountersWithHighRisk: 1,
			mostRecentDateWithLowRisk: nil,
			mostRecentDateWithHighRisk: Date(),
			numberOfDaysWithLowRisk: 0,
			numberOfDaysWithHighRisk: 1,
			calculationDate: Date(),
			riskLevelPerDate: [Date(): .high]
		)

		store.riskCalculationResult = riskCalculationResult

		let homeState = HomeState(
			store: store,
			riskProvider: MockRiskProvider(),
			exposureManagerState: ExposureManagerState(authorized: true, enabled: true, status: .active),
			enState: .enabled,
			exposureSubmissionService: MockExposureSubmissionService()
		)
		homeState.detectionMode = .automatic

		let viewModel = HomeRiskCellModel(
			homeState: homeState,
			onInactiveButtonTap: { },
			onUpdate: { }
		)

		XCTAssertEqual(viewModel.title, AppStrings.Home.riskCardHighTitle)
		XCTAssertEqual(viewModel.titleColor, .enaColor(for: .textContrast))
		XCTAssertEqual(viewModel.chevronStyle, .circled)

		XCTAssertTrue(viewModel.isBodyHidden)

		XCTAssertEqual(viewModel.backgroundColor, .enaColor(for: .riskHigh))
		XCTAssertEqual(viewModel.separatorColor, .enaColor(for: .hairlineContrast))

		XCTAssertTrue(viewModel.isButtonHidden)

		XCTAssertEqual(viewModel.itemViewModels.count, 3)

		// Check downloading state

		homeState.riskProviderActivityState = .downloading

		XCTAssertEqual(viewModel.title, AppStrings.Home.riskCardStatusDownloadingTitle)
		XCTAssertEqual(viewModel.titleColor, .enaColor(for: .textContrast))
		XCTAssertEqual(viewModel.chevronStyle, .circled)

		XCTAssertTrue(viewModel.isBodyHidden)

		XCTAssertEqual(viewModel.backgroundColor, .enaColor(for: .riskHigh))
		XCTAssertEqual(viewModel.separatorColor, .enaColor(for: .hairlineContrast))

		XCTAssertTrue(viewModel.isButtonHidden)
		XCTAssertTrue(viewModel.isButtonInverted)

		XCTAssertEqual(viewModel.itemViewModels.count, 1)

		// Check detecting state

		homeState.riskProviderActivityState = .detecting

		XCTAssertEqual(viewModel.title, AppStrings.Home.riskCardStatusDetectingTitle)
		XCTAssertEqual(viewModel.titleColor, .enaColor(for: .textContrast))
		XCTAssertEqual(viewModel.chevronStyle, .circled)

		XCTAssertTrue(viewModel.isBodyHidden)

		XCTAssertEqual(viewModel.backgroundColor, .enaColor(for: .riskHigh))
		XCTAssertEqual(viewModel.separatorColor, .enaColor(for: .hairlineContrast))

		XCTAssertTrue(viewModel.isButtonHidden)

		XCTAssertEqual(viewModel.itemViewModels.count, 1)

		// Check idle state

		homeState.riskProviderActivityState = .idle
		homeState.riskState = .risk(
			Risk(
				activeTracing: .init(interval: 0),
				riskCalculationResult: riskCalculationResult
			)
		)

		XCTAssertEqual(viewModel.title, AppStrings.Home.riskCardHighTitle)
		XCTAssertEqual(viewModel.titleColor, .enaColor(for: .textContrast))
		XCTAssertEqual(viewModel.chevronStyle, .circled)

		XCTAssertTrue(viewModel.isBodyHidden)

		XCTAssertEqual(viewModel.backgroundColor, .enaColor(for: .riskHigh))
		XCTAssertEqual(viewModel.separatorColor, .enaColor(for: .hairlineContrast))

		XCTAssertTrue(viewModel.isButtonHidden)

		XCTAssertEqual(viewModel.itemViewModels.count, 3)

		// Check that button is shown in manual mode

		homeState.detectionMode = .manual

		XCTAssertFalse(viewModel.isButtonHidden)

		// Check that button is hidden again in automatic mode

		homeState.detectionMode = .automatic

		XCTAssertTrue(viewModel.isButtonHidden)
	}

	func testInactiveState() {
		let store = MockTestStore()

		let homeState = HomeState(
			store: store,
			riskProvider: MockRiskProvider(),
			exposureManagerState: ExposureManagerState(authorized: true, enabled: true, status: .active),
			enState: .enabled,
			exposureSubmissionService: MockExposureSubmissionService()
		)
		homeState.detectionMode = .automatic
		homeState.riskState = .inactive

		let viewModel = HomeRiskCellModel(
			homeState: homeState,
			onInactiveButtonTap: { },
			onUpdate: { }
		)

		XCTAssertEqual(viewModel.title, AppStrings.Home.riskCardInactiveNoCalculationPossibleTitle)
		XCTAssertEqual(viewModel.titleColor, .enaColor(for: .textPrimary1))
		XCTAssertEqual(viewModel.chevronStyle, .plain)

		XCTAssertEqual(viewModel.body, AppStrings.Home.riskCardInactiveNoCalculationPossibleBody)
		XCTAssertEqual(viewModel.bodyColor, .enaColor(for: .textPrimary1))
		XCTAssertFalse(viewModel.isBodyHidden)

		XCTAssertEqual(viewModel.backgroundColor, .enaColor(for: .background))
		XCTAssertEqual(viewModel.separatorColor, .enaColor(for: .hairline))

		XCTAssertEqual(viewModel.buttonTitle, AppStrings.Home.riskCardInactiveNoCalculationPossibleButton)
		XCTAssertFalse(viewModel.isButtonInverted)
		XCTAssertFalse(viewModel.isButtonHidden)
		XCTAssertTrue(viewModel.isButtonEnabled)

		XCTAssertEqual(viewModel.itemViewModels.count, 2)

		// Check downloading state

		homeState.riskProviderActivityState = .downloading

		XCTAssertEqual(viewModel.title, AppStrings.Home.riskCardStatusDownloadingTitle)
		XCTAssertEqual(viewModel.titleColor, .enaColor(for: .textPrimary1))
		XCTAssertEqual(viewModel.chevronStyle, .plain)

		XCTAssertTrue(viewModel.isBodyHidden)

		XCTAssertEqual(viewModel.backgroundColor, .enaColor(for: .background))
		XCTAssertEqual(viewModel.separatorColor, .enaColor(for: .hairline))

		XCTAssertTrue(viewModel.isButtonHidden)

		XCTAssertEqual(viewModel.itemViewModels.count, 1)

		// Check detecting state

		homeState.riskProviderActivityState = .detecting

		XCTAssertEqual(viewModel.title, AppStrings.Home.riskCardStatusDetectingTitle)
		XCTAssertEqual(viewModel.titleColor, .enaColor(for: .textPrimary1))
		XCTAssertEqual(viewModel.chevronStyle, .plain)

		XCTAssertTrue(viewModel.isBodyHidden)

		XCTAssertEqual(viewModel.backgroundColor, .enaColor(for: .background))
		XCTAssertEqual(viewModel.separatorColor, .enaColor(for: .hairline))

		XCTAssertTrue(viewModel.isButtonHidden)

		XCTAssertEqual(viewModel.itemViewModels.count, 1)

		// Check idle state

		homeState.riskProviderActivityState = .idle
		homeState.riskState = .inactive

		XCTAssertEqual(viewModel.title, AppStrings.Home.riskCardInactiveNoCalculationPossibleTitle)
		XCTAssertEqual(viewModel.titleColor, .enaColor(for: .textPrimary1))
		XCTAssertEqual(viewModel.chevronStyle, .plain)

		XCTAssertEqual(viewModel.body, AppStrings.Home.riskCardInactiveNoCalculationPossibleBody)
		XCTAssertEqual(viewModel.bodyColor, .enaColor(for: .textPrimary1))
		XCTAssertFalse(viewModel.isBodyHidden)

		XCTAssertEqual(viewModel.backgroundColor, .enaColor(for: .background))
		XCTAssertEqual(viewModel.separatorColor, .enaColor(for: .hairline))

		XCTAssertEqual(viewModel.buttonTitle, AppStrings.Home.riskCardInactiveNoCalculationPossibleButton)
		XCTAssertFalse(viewModel.isButtonInverted)
		XCTAssertFalse(viewModel.isButtonHidden)
		XCTAssertTrue(viewModel.isButtonEnabled)

		XCTAssertEqual(viewModel.itemViewModels.count, 2)

		// Check that button is shown in manual mode

		homeState.detectionMode = .manual

		XCTAssertFalse(viewModel.isButtonHidden)

		// Check that button is shown in automatic mode

		homeState.detectionMode = .automatic

		XCTAssertFalse(viewModel.isButtonHidden)
	}

	func testFailedState() {
		let store = MockTestStore()

		let homeState = HomeState(
			store: store,
			riskProvider: MockRiskProvider(),
			exposureManagerState: ExposureManagerState(authorized: true, enabled: true, status: .active),
			enState: .enabled,
			exposureSubmissionService: MockExposureSubmissionService()
		)
		homeState.detectionMode = .automatic
		homeState.riskState = .detectionFailed

		let viewModel = HomeRiskCellModel(
			homeState: homeState,
			onInactiveButtonTap: { },
			onUpdate: { }
		)

		XCTAssertEqual(viewModel.title, AppStrings.Home.riskCardFailedCalculationTitle)
		XCTAssertEqual(viewModel.titleColor, .enaColor(for: .textPrimary1))
		XCTAssertEqual(viewModel.chevronStyle, .plain)

		XCTAssertEqual(viewModel.body, AppStrings.Home.riskCardFailedCalculationBody)
		XCTAssertEqual(viewModel.bodyColor, .enaColor(for: .textPrimary1))
		XCTAssertFalse(viewModel.isBodyHidden)

		XCTAssertEqual(viewModel.backgroundColor, .enaColor(for: .background))
		XCTAssertEqual(viewModel.separatorColor, .enaColor(for: .hairline))

		XCTAssertEqual(viewModel.buttonTitle, AppStrings.Home.riskCardFailedCalculationRestartButtonTitle)
		XCTAssertFalse(viewModel.isButtonInverted)
		XCTAssertFalse(viewModel.isButtonHidden)
		XCTAssertTrue(viewModel.isButtonEnabled)

		XCTAssertEqual(viewModel.itemViewModels.count, 2)

		// Check downloading state

		homeState.riskProviderActivityState = .downloading

		XCTAssertEqual(viewModel.title, AppStrings.Home.riskCardStatusDownloadingTitle)
		XCTAssertEqual(viewModel.titleColor, .enaColor(for: .textPrimary1))
		XCTAssertEqual(viewModel.chevronStyle, .plain)

		XCTAssertTrue(viewModel.isBodyHidden)

		XCTAssertEqual(viewModel.backgroundColor, .enaColor(for: .background))
		XCTAssertEqual(viewModel.separatorColor, .enaColor(for: .hairline))

		XCTAssertTrue(viewModel.isButtonHidden)

		XCTAssertEqual(viewModel.itemViewModels.count, 1)

		// Check detecting state

		homeState.riskProviderActivityState = .detecting

		XCTAssertEqual(viewModel.title, AppStrings.Home.riskCardStatusDetectingTitle)
		XCTAssertEqual(viewModel.titleColor, .enaColor(for: .textPrimary1))
		XCTAssertEqual(viewModel.chevronStyle, .plain)

		XCTAssertTrue(viewModel.isBodyHidden)

		XCTAssertEqual(viewModel.backgroundColor, .enaColor(for: .background))
		XCTAssertEqual(viewModel.separatorColor, .enaColor(for: .hairline))

		XCTAssertTrue(viewModel.isButtonHidden)

		XCTAssertEqual(viewModel.itemViewModels.count, 1)

		// Check idle state

		homeState.riskProviderActivityState = .idle
		homeState.riskState = .detectionFailed

		XCTAssertEqual(viewModel.title, AppStrings.Home.riskCardFailedCalculationTitle)
		XCTAssertEqual(viewModel.titleColor, .enaColor(for: .textPrimary1))
		XCTAssertEqual(viewModel.chevronStyle, .plain)

		XCTAssertEqual(viewModel.body, AppStrings.Home.riskCardFailedCalculationBody)
		XCTAssertEqual(viewModel.bodyColor, .enaColor(for: .textPrimary1))
		XCTAssertFalse(viewModel.isBodyHidden)

		XCTAssertEqual(viewModel.backgroundColor, .enaColor(for: .background))
		XCTAssertEqual(viewModel.separatorColor, .enaColor(for: .hairline))

		XCTAssertEqual(viewModel.buttonTitle, AppStrings.Home.riskCardFailedCalculationRestartButtonTitle)
		XCTAssertFalse(viewModel.isButtonInverted)
		XCTAssertFalse(viewModel.isButtonHidden)
		XCTAssertTrue(viewModel.isButtonEnabled)

		XCTAssertEqual(viewModel.itemViewModels.count, 2)

		// Check that button is shown in manual mode

		homeState.detectionMode = .manual

		XCTAssertFalse(viewModel.isButtonHidden)

		// Check that button is shown in automatic mode

		homeState.detectionMode = .automatic

		XCTAssertFalse(viewModel.isButtonHidden)
	}

	func testOnButtonTapInLowRiskStateAndManualMode() {
		let store = MockTestStore()
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
			exposureSubmissionService: MockExposureSubmissionService()
		)
		homeState.detectionMode = .manual

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

		let viewModel = HomeRiskCellModel(
			homeState: homeState,
			onInactiveButtonTap: { onInactiveButtonTapExpectation.fulfill() },
			onUpdate: { }
		)

		viewModel.onButtonTap()

		waitForExpectations(timeout: .medium)

		XCTAssertEqual(receivedActivityStates, expectedActivityStates)
	}

	func testOnButtonTapInHighRiskStateAndManualMode() {
		let store = MockTestStore()
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
			exposureSubmissionService: MockExposureSubmissionService()
		)
		homeState.detectionMode = .manual

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

		let viewModel = HomeRiskCellModel(
			homeState: homeState,
			onInactiveButtonTap: { onInactiveButtonTapExpectation.fulfill() },
			onUpdate: { }
		)

		viewModel.onButtonTap()

		waitForExpectations(timeout: .medium)

		XCTAssertEqual(receivedActivityStates, expectedActivityStates)
	}

	func testOnButtonTapInInactiveState() {
		let store = MockTestStore()

		let homeState = HomeState(
			store: store,
			riskProvider: MockRiskProvider(),
			exposureManagerState: ExposureManagerState(authorized: true, enabled: true, status: .active),
			enState: .enabled,
			exposureSubmissionService: MockExposureSubmissionService()
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

		let viewModel = HomeRiskCellModel(
			homeState: homeState,
			onInactiveButtonTap: { onInactiveButtonTapExpectation.fulfill() },
			onUpdate: { }
		)

		viewModel.onButtonTap()

		waitForExpectations(timeout: .medium)

		XCTAssertEqual(receivedActivityStates, expectedActivityStates)
	}

	func testOnButtonTapInFailedState() {
		let homeState = HomeState(
			store: MockTestStore(),
			riskProvider: MockRiskProvider(),
			exposureManagerState: ExposureManagerState(authorized: true, enabled: true, status: .active),
			enState: .enabled,
			exposureSubmissionService: MockExposureSubmissionService()
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

		let viewModel = HomeRiskCellModel(
			homeState: homeState,
			onInactiveButtonTap: { onInactiveButtonTapExpectation.fulfill() },
			onUpdate: { }
		)

		viewModel.onButtonTap()

		waitForExpectations(timeout: .medium)

		XCTAssertEqual(receivedActivityStates, expectedActivityStates)
	}

	func testOnUpdateIsCalledForRiskState() {
		let store = MockTestStore()

		let homeState = HomeState(
			store: store,
			riskProvider: MockRiskProvider(),
			exposureManagerState: ExposureManagerState(authorized: true, enabled: true, status: .active),
			enState: .enabled,
			exposureSubmissionService: MockExposureSubmissionService()
		)

		let onUpdateExpectation = expectation(description: "onUpdate is called")
		// Called 3 times at initialization + 1 time for update
		onUpdateExpectation.expectedFulfillmentCount = 4

		let viewModel = HomeRiskCellModel(
			homeState: homeState,
			onInactiveButtonTap: { },
			onUpdate: { onUpdateExpectation.fulfill() }
		)

		homeState.riskState = .inactive

		waitForExpectations(timeout: .medium)

		// Using viewModel to silence warning "Initialization of immutable value was never used"
		viewModel.chevronStyle = .plain
	}

	func testOnUpdateIsCalledForRiskProviderActivityState() {
		let store = MockTestStore()

		let homeState = HomeState(
			store: store,
			riskProvider: MockRiskProvider(),
			exposureManagerState: ExposureManagerState(authorized: true, enabled: true, status: .active),
			enState: .enabled,
			exposureSubmissionService: MockExposureSubmissionService()
		)

		let onUpdateExpectation = expectation(description: "onUpdate is called")
		// Called 3 times at initialization + 1 time for update
		onUpdateExpectation.expectedFulfillmentCount = 4

		let viewModel = HomeRiskCellModel(
			homeState: homeState,
			onInactiveButtonTap: { },
			onUpdate: { onUpdateExpectation.fulfill() }
		)

		homeState.riskProviderActivityState = .downloading

		waitForExpectations(timeout: .medium)

		// Using viewModel to silence warning "Initialization of immutable value was never used"
		viewModel.chevronStyle = .plain
	}

	func testOnUpdateIsCalledForDetectionMode() {
		let store = MockTestStore()

		let homeState = HomeState(
			store: store,
			riskProvider: MockRiskProvider(),
			exposureManagerState: ExposureManagerState(authorized: true, enabled: true, status: .active),
			enState: .enabled,
			exposureSubmissionService: MockExposureSubmissionService()
		)

		let onUpdateExpectation = expectation(description: "onUpdate is called")
		// Called 3 times at initialization + 1 time for update
		onUpdateExpectation.expectedFulfillmentCount = 4

		let viewModel = HomeRiskCellModel(
			homeState: homeState,
			onInactiveButtonTap: { },
			onUpdate: { onUpdateExpectation.fulfill() }
		)

		homeState.detectionMode = .manual

		waitForExpectations(timeout: .medium)

		// Using viewModel to silence warning "Initialization of immutable value was never used"
		viewModel.chevronStyle = .plain
	}

}
