////
// 🦠 Corona-Warn-App
//

import XCTest
import OpenCombine
@testable import ENA

class HomeTestResultCellModelTests: XCTestCase {
	
	// expected values arrays have to test the default flow values plus explicitly test setting the testResult into [.none, .negative, .invalid, .pending, .positive, .expired]
	// so the total test cases are [.none(default), .none(explicit), .negative, .invalid, .pending, .positive, .expired, (Loading)]
	
	private var subscriptions = [AnyCancellable]()
	
	let titlesArray = [
		AppStrings.Home.submitCardTitle,
		AppStrings.Home.submitCardTitle,
		AppStrings.Home.resultCardResultAvailableTitle,
		AppStrings.Home.resultCardResultAvailableTitle,
		AppStrings.Home.resultCardResultUnvailableTitle,
		AppStrings.Home.resultCardResultAvailableTitle,
		AppStrings.Home.resultCardResultUnvailableTitle,
		AppStrings.Home.resultCardLoadingTitle
	]
	let subtitleArray = [
		nil,
		nil,
		AppStrings.Home.resultCardNegativeTitle,
		AppStrings.Home.resultCardInvalidTitle,
		nil,
		AppStrings.Home.resultCardAvailableSubtitle,
		nil,
		nil
	]
	let descriptionsArray = [
		AppStrings.Home.submitCardBody,
		AppStrings.Home.submitCardBody,
		AppStrings.Home.resultCardNegativeDesc,
		AppStrings.Home.resultCardInvalidDesc,
		AppStrings.Home.resultCardPendingDesc,
		AppStrings.Home.resultCardAvailableDesc,
		AppStrings.Home.resultCardPendingDesc,
		AppStrings.Home.resultCardLoadingBody
	]
	let buttonTitlesArray = [
		AppStrings.Home.submitCardButton,
		AppStrings.Home.submitCardButton,
		AppStrings.Home.resultCardShowResultButton,
		AppStrings.Home.resultCardShowResultButton,
		AppStrings.Home.resultCardShowResultButton,
		AppStrings.Home.resultCardRetrieveResultButton,
		AppStrings.Home.resultCardShowResultButton,
		AppStrings.Home.resultCardShowResultButton
	]
	let imagesArray = [
		UIImage(named: "Illu_Hand_with_phone-initial"),
		UIImage(named: "Illu_Hand_with_phone-initial"),
		UIImage(named: "Illu_Hand_with_phone-negativ"),
		UIImage(named: "Illu_Hand_with_phone-error"),
		UIImage(named: "Illu_Hand_with_phone-pending"),
		UIImage(named: "Illu_Hand_with_phone-error"),
		UIImage(named: "Illu_Hand_with_phone-pending"),
		UIImage(named: "Illu_Hand_with_phone-initial")
	]
	let colorsArray: [UIColor] = [
		.enaColor(for: .textPrimary1),
		.enaColor(for: .textPrimary1),
		.enaColor(for: .textSemanticGreen),
		.enaColor(for: .textSemanticGray),
		.enaColor(for: .textPrimary2),
		.enaColor(for: .textSemanticGray),
		.enaColor(for: .textPrimary2),
		.enaColor(for: .textPrimary1)
	]
	let indicatorVisibilityArray = [true, true, true, true, true, true, true, false]
	let userInteractionArray = [true, true, true, true, true, true, true, false]
	let accessabilityIdentifiersArray = [
		AccessibilityIdentifiers.Home.submitCardButton,
		AccessibilityIdentifiers.Home.submitCardButton,
		AccessibilityIdentifiers.Home.resultCardShowResultButton,
		AccessibilityIdentifiers.Home.resultCardShowResultButton,
		AccessibilityIdentifiers.Home.resultCardShowResultButton,
		AccessibilityIdentifiers.Home.resultCardShowResultButton,
		AccessibilityIdentifiers.Home.resultCardShowResultButton,
		AccessibilityIdentifiers.Home.submitCardButton
	]

	// swiftlint:disable:next function_body_length
	func test_whenHomeENStateChanges_then_changesAreReflectedInTheSubscription() {
		
		let expectationTitles = expectation(description: "expectationTitles")
		let expectationSubtitles = expectation(description: "expectationSubtitles")
		let expectationDescription = expectation(description: "expectationDescription")
		let expectationButtonTitle = expectation(description: "expectationButtonTitle")
		let expectationButtonImage = expectation(description: "expectationButtonImage")
		let expectationTintColor = expectation(description: "expectationTintColor")
		let expectationIndicatorVisibility = expectation(description: "expectationIndicatorVisibility")
		let expectationUserInteraction = expectation(description: "expectationUserInteraction")
		let expectationAccessabilityIdentifiers = expectation(description: "expectationAccessabilityIdentifiers")
		let expectationOnUpdate = expectation(description: "expectationOnUpdate")

		var recievedTitles = [String?]()
		var recievedSubtitles = [String?]()
		var recievedDescription = [String?]()
		var recievedButtonTitle = [String?]()
		var recievedImages = [UIImage?]()
		var recievedtintColors = [UIColor]()
		var recievedActivityIndicatorsVisibility = [Bool]()
		var recievedUserInteractivity = [Bool]()
		var recievedAccessibilityIdentifiers = [String?]()
		
		expectationTitles.expectedFulfillmentCount = titlesArray.count
		expectationSubtitles.expectedFulfillmentCount = subtitleArray.count
		expectationDescription.expectedFulfillmentCount = descriptionsArray.count
		expectationButtonTitle.expectedFulfillmentCount = buttonTitlesArray.count
		expectationButtonImage.expectedFulfillmentCount = imagesArray.count
		expectationTintColor.expectedFulfillmentCount = colorsArray.count
		expectationIndicatorVisibility.expectedFulfillmentCount = indicatorVisibilityArray.count
		expectationUserInteraction.expectedFulfillmentCount = userInteractionArray.count
		expectationAccessabilityIdentifiers.expectedFulfillmentCount = accessabilityIdentifiersArray.count
		expectationOnUpdate.expectedFulfillmentCount = accessabilityIdentifiersArray.count
		
		let state = makeHomeState()
		
		let sut = HomeTestResultCellModel(homeState: state) {
			expectationOnUpdate.fulfill()
		}
		
		sut.$title
			.dropFirst()
			.sink { recievedValue in
				recievedTitles.append(recievedValue)
				expectationTitles.fulfill()
			}
			.store(in: &subscriptions)
		
		sut.$subtitle
			.dropFirst()
			.sink { recievedValue in
				recievedSubtitles.append(recievedValue)
				expectationSubtitles.fulfill()
			}
			.store(in: &subscriptions)
		
		sut.$description
			.dropFirst()
			.sink { recievedValue in
				recievedDescription.append(recievedValue)
				expectationDescription.fulfill()
			}
			.store(in: &subscriptions)
		
		sut.$buttonTitle
			.dropFirst()
			.sink { recievedValue in
				recievedButtonTitle.append(recievedValue)
				expectationButtonTitle.fulfill()
			}
			.store(in: &subscriptions)
		
		sut.$image
			.dropFirst()
			.sink { recievedValue in
				recievedImages.append(recievedValue)
				expectationButtonImage.fulfill()
			}
			.store(in: &subscriptions)
		
		sut.$tintColor
			.dropFirst()
			.sink { recievedValue in
				recievedtintColors.append(recievedValue)
				expectationTintColor.fulfill()
			}
			.store(in: &subscriptions)
		
		sut.$isActivityIndicatorHidden
			.dropFirst()
			.sink { recievedValue in
				recievedActivityIndicatorsVisibility.append(recievedValue)
				expectationIndicatorVisibility.fulfill()
			}
			.store(in: &subscriptions)
		
		sut.$isUserInteractionEnabled
			.dropFirst()
			.sink { recievedValue in
				recievedUserInteractivity.append(recievedValue)
				expectationUserInteraction.fulfill()
			}
			.store(in: &subscriptions)
		
		sut.$accessibilityIdentifier
			.dropFirst()
			.sink { recievedValue in
				recievedAccessibilityIdentifiers.append(recievedValue)
				expectationAccessabilityIdentifiers.fulfill()
			}
			.store(in: &subscriptions)
		
		state.testResult = .none
		state.testResult = .negative
		state.testResult = .invalid
		state.testResult = .pending
		state.testResult = .positive
		state.testResult = .expired
		state.testResultIsLoading = true
				
		waitForExpectations(timeout: .short, handler: nil)
		
		subscriptions.forEach({ $0.cancel() })
		
		XCTAssertEqual(recievedTitles, titlesArray)
		XCTAssertEqual(recievedSubtitles, subtitleArray)
		XCTAssertEqual(recievedDescription, descriptionsArray)
		XCTAssertEqual(recievedButtonTitle, buttonTitlesArray)
		XCTAssertEqual(recievedImages, imagesArray)
		XCTAssertEqual(recievedtintColors, colorsArray)
		XCTAssertEqual(recievedActivityIndicatorsVisibility, indicatorVisibilityArray)
		XCTAssertEqual(recievedUserInteractivity, userInteractionArray)
		XCTAssertEqual(recievedAccessibilityIdentifiers, accessabilityIdentifiersArray)
	}
	
	private func makeHomeState() -> HomeState {
		let store = MockTestStore()

		return HomeState(
			store: store,
			riskProvider: MockRiskProvider(),
			exposureManagerState: .init(),
			enState: .enabled,
			exposureSubmissionService: MockExposureSubmissionService(),
			statisticsProvider: StatisticsProvider(
				client: CachingHTTPClientMock(store: store),
				store: store
			)
		)
	}
}
