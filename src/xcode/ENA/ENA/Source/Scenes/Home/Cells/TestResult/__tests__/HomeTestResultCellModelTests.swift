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

	let subtitleArray = [
		nil,
		AppStrings.Home.TestResult.Invalid.title,
		AppStrings.Home.TestResult.Pending.title,
		AppStrings.Home.TestResult.Available.title,
		AppStrings.Home.TestResult.Expired.title,
		AppStrings.Home.TestResult.Loading.title
	]
	let descriptionsArray = [
		AppStrings.Home.TestResult.Negative.description,
		AppStrings.Home.TestResult.Invalid.description,
		AppStrings.Home.TestResult.Pending.pcrDescription,
		AppStrings.Home.TestResult.Available.description,
		AppStrings.Home.TestResult.Expired.description,
		AppStrings.Home.TestResult.Loading.description
	]
	let buttonTitlesArray = [
		AppStrings.Home.TestResult.Button.showResult,
		AppStrings.Home.TestResult.Button.showResult,
		AppStrings.Home.TestResult.Button.showResult,
		AppStrings.Home.TestResult.Button.showResult,
		AppStrings.Home.TestResult.Button.deleteTest,
		AppStrings.Home.TestResult.Button.showResult
	]
	let imagesArray = [
		UIImage(named: "Illu_Home_NegativesTestErgebnis"),
		UIImage(named: "Illu_Hand_with_phone-error"),
		UIImage(named: "Illu_Hand_with_phone-pending"),
		UIImage(named: "Illu_Hand_with_phone-error"),
		UIImage(named: "Illu_Hand_with_phone-pending"),
		UIImage(named: "Illu_Hand_with_phone-initial")
	]
	let isNegativeDiagnosisHiddenArray = [false, true, true, true, true, true]
	let indicatorVisibilityArray = [true, true, true, true, true, false]
	let userInteractionArray = [true, true, true, true, true, false]
	let accessabilityIdentifiersArray = [
		AccessibilityIdentifiers.Home.submitCardButton,
		AccessibilityIdentifiers.Home.submitCardButton,
		AccessibilityIdentifiers.Home.submitCardButton,
		AccessibilityIdentifiers.Home.submitCardButton,
		AccessibilityIdentifiers.Home.submitCardButton,
		AccessibilityIdentifiers.Home.submitCardButton
	]

	func test_whenHomeENStateChanges_then_changesAreReflectedInTheSubscription() {
		let expectationTitles = expectation(description: "expectationTitles")
		let expectationSubtitles = expectation(description: "expectationSubtitles")
		let expectationDescription = expectation(description: "expectationDescription")
		let expectationButtonTitle = expectation(description: "expectationButtonTitle")
		let expectationButtonImage = expectation(description: "expectationButtonImage")
		let expectationIndicatorVisibility = expectation(description: "expectationIndicatorVisibility")
		let expectationUserInteraction = expectation(description: "expectationUserInteraction")
		let expectationAccessabilityIdentifiers = expectation(description: "expectationAccessabilityIdentifiers")
		let expectationOnUpdate = expectation(description: "expectationOnUpdate")

		var recievedTitles = [String?]()
		var recievedSubtitles = [String?]()
		var recievedDescription = [String?]()
		var recievedButtonTitle = [String?]()
		var recievedImages = [UIImage?]()
		var recievedActivityIndicatorsVisibility = [Bool]()
		var recievedUserInteractivity = [Bool]()
		var recievedAccessibilityIdentifiers = [String?]()
		
		expectationSubtitles.expectedFulfillmentCount = subtitleArray.count
		expectationDescription.expectedFulfillmentCount = descriptionsArray.count
		expectationButtonTitle.expectedFulfillmentCount = buttonTitlesArray.count
		expectationButtonImage.expectedFulfillmentCount = imagesArray.count
		expectationIndicatorVisibility.expectedFulfillmentCount = indicatorVisibilityArray.count
		expectationUserInteraction.expectedFulfillmentCount = userInteractionArray.count
		expectationAccessabilityIdentifiers.expectedFulfillmentCount = accessabilityIdentifiersArray.count
		expectationOnUpdate.expectedFulfillmentCount = accessabilityIdentifiersArray.count
		
		let coronaTestService = CoronaTestService(
			client: ClientMock(),
			store: MockTestStore(),
			appConfiguration: CachedAppConfigurationMock()
		)
		coronaTestService.pcrTest = PCRTest.mock()

		let sut = HomeTestResultCellModel(
			coronaTestType: .pcr,
			coronaTestService: coronaTestService,
			onUpdate: {
				expectationOnUpdate.fulfill()
			}
		)
		
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

		coronaTestService.pcrTest?.testResult = .negative
		coronaTestService.pcrTest?.testResult = .invalid
		coronaTestService.pcrTest?.testResult = .pending
		coronaTestService.pcrTest?.testResult = .positive
		coronaTestService.pcrTest?.testResult = .expired
		coronaTestService.pcrTestResultIsLoading = true
				
		waitForExpectations(timeout: .short, handler: nil)
		
		subscriptions.forEach({ $0.cancel() })

		XCTAssertEqual(recievedSubtitles, subtitleArray)
		XCTAssertEqual(recievedDescription, descriptionsArray)
		XCTAssertEqual(recievedButtonTitle, buttonTitlesArray)
		XCTAssertEqual(recievedImages, imagesArray)
		XCTAssertEqual(recievedActivityIndicatorsVisibility, indicatorVisibilityArray)
		XCTAssertEqual(recievedUserInteractivity, userInteractionArray)
		XCTAssertEqual(recievedAccessibilityIdentifiers, accessabilityIdentifiersArray)
	}
}
