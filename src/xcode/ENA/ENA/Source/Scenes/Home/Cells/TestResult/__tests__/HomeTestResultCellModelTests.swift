////
// 🦠 Corona-Warn-App
//

import XCTest
import OpenCombine
import HealthCertificateToolkit
@testable import ENA

class HomeTestResultCellModelTests: CWATestCase {
	
	// expected values arrays have to test the default flow values plus explicitly test setting the testResult into [.pending, .negative, .invalid, .positive, .expired]
	// so the total test cases are [.pending, .negative, .invalid, .positive, .expired, (Loading)]
	
	private var subscriptions = [AnyCancellable]()

	let subtitleArray = [
		AppStrings.Home.TestResult.Pending.title,
		nil,
		AppStrings.Home.TestResult.Invalid.title,
		AppStrings.Home.TestResult.Available.title,
		AppStrings.Home.TestResult.Expired.title,
		AppStrings.Home.TestResult.Loading.title
	]
	let descriptionsArray = [
		AppStrings.Home.TestResult.Pending.pcrDescription,
		AppStrings.Home.TestResult.Negative.description,
		AppStrings.Home.TestResult.Invalid.description,
		AppStrings.Home.TestResult.Available.description,
		AppStrings.Home.TestResult.Expired.description,
		AppStrings.Home.TestResult.Loading.description
	]
	let buttonTitlesArray = [
		AppStrings.Home.TestResult.Button.showResult,
		AppStrings.Home.TestResult.Button.showResult,
		AppStrings.Home.TestResult.Button.showResult,
		AppStrings.Home.TestResult.Button.retrieveResult,
		AppStrings.Home.TestResult.Button.deleteTest,
		AppStrings.Home.TestResult.Button.showResult
	]
	let imagesArray = [
		UIImage(named: "Illu_Hand_with_phone-pending"),
		UIImage(named: "Illu_Home_NegativesTestErgebnis"),
		UIImage(named: "Illu_Hand_with_phone-error"),
		UIImage(named: "Illu_Hand_with_phone-error"),
		UIImage(named: "Illu_Hand_with_phone-pending"),
		UIImage(named: "Illu_Hand_with_phone-initial")
	]
	let isNegativeDiagnosisHiddenArray = [true, false, true, true, true, true]
	let indicatorVisibilityArray = [true, true, true, true, true, false]
	let userInteractionArray = [true, true, true, true, true, false]
	let accessibilityIdentifiersArray = [
		AccessibilityIdentifiers.Home.TestResultCell.pendingPCRButton,
		AccessibilityIdentifiers.Home.TestResultCell.negativePCRButton,
		AccessibilityIdentifiers.Home.TestResultCell.invalidPCRButton,
		AccessibilityIdentifiers.Home.TestResultCell.availablePCRButton,
		AccessibilityIdentifiers.Home.TestResultCell.expiredPCRButton,
		AccessibilityIdentifiers.Home.TestResultCell.loadingPCRButton
	]

	// swiftlint:disable:next function_body_length
	func test_whenTestResultChanges_then_changesAreReflectedInTheSubscription() {
		let expectationSubtitles = expectation(description: "expectationSubtitles")
		let expectationDescription = expectation(description: "expectationDescription")
		let expectationButtonTitle = expectation(description: "expectationButtonTitle")
		let expectationButtonImage = expectation(description: "expectationButtonImage")
		let expectationIndicatorVisibility = expectation(description: "expectationIndicatorVisibility")
		let expectationUserInteraction = expectation(description: "expectationUserInteraction")
		let expectationAccessibilityIdentifiers = expectation(description: "expectationAccessibilityIdentifiers")
		let expectationOnUpdate = expectation(description: "expectationOnUpdate")

		var receivedSubtitles = [String?]()
		var receivedDescription = [String?]()
		var receivedButtonTitle = [String?]()
		var receivedImages = [UIImage?]()
		var receivedActivityIndicatorsVisibility = [Bool]()
		var receivedUserInteractivity = [Bool]()
		var receivedAccessibilityIdentifiers = [String?]()
		
		expectationSubtitles.expectedFulfillmentCount = subtitleArray.count
		expectationDescription.expectedFulfillmentCount = descriptionsArray.count
		expectationButtonTitle.expectedFulfillmentCount = buttonTitlesArray.count
		expectationButtonImage.expectedFulfillmentCount = imagesArray.count
		expectationIndicatorVisibility.expectedFulfillmentCount = indicatorVisibilityArray.count
		expectationUserInteraction.expectedFulfillmentCount = userInteractionArray.count
		expectationAccessibilityIdentifiers.expectedFulfillmentCount = accessibilityIdentifiersArray.count
		expectationOnUpdate.expectedFulfillmentCount = 7

		let client = ClientMock()
		let store = MockTestStore()
		let appConfiguration = CachedAppConfigurationMock()
		
		let coronaTestService = CoronaTestService(
			client: client,
			store: store,
			eventStore: MockEventStore(),
			diaryStore: MockDiaryStore(),
			appConfiguration: appConfiguration,
			healthCertificateService: HealthCertificateService(
				store: store,
				dccSignatureVerifier: DCCSignatureVerifyingStub(),
				dscListProvider: MockDSCListProvider(),
				client: client,
				appConfiguration: appConfiguration,
				boosterNotificationsService: BoosterNotificationsService(
					rulesDownloadService: FakeRulesDownloadService()
				),
				recycleBin: .fake()
			),
			recycleBin: .fake(),
			badgeWrapper: .fake()
		)
		coronaTestService.pcrTest = PCRTest.mock()

		let cellModel = HomeTestResultCellModel(
			coronaTestType: .pcr,
			coronaTestService: coronaTestService,
			onUpdate: {
				expectationOnUpdate.fulfill()
			}
		)

		XCTAssertEqual(cellModel.title, AppStrings.Home.TestResult.pcrTitle)

		cellModel.$subtitle
			.dropFirst()
			.sink { receivedValue in
				receivedSubtitles.append(receivedValue)
				expectationSubtitles.fulfill()
			}
			.store(in: &subscriptions)

		cellModel.$description
			.dropFirst()
			.sink { receivedValue in
				receivedDescription.append(receivedValue)
				expectationDescription.fulfill()
			}
			.store(in: &subscriptions)

		cellModel.$buttonTitle
			.dropFirst()
			.sink { receivedValue in
				receivedButtonTitle.append(receivedValue)
				expectationButtonTitle.fulfill()
			}
			.store(in: &subscriptions)

		cellModel.$image
			.dropFirst()
			.sink { receivedValue in
				receivedImages.append(receivedValue)
				expectationButtonImage.fulfill()
			}
			.store(in: &subscriptions)

		cellModel.$isActivityIndicatorHidden
			.dropFirst()
			.sink { receivedValue in
				receivedActivityIndicatorsVisibility.append(receivedValue)
				expectationIndicatorVisibility.fulfill()
			}
			.store(in: &subscriptions)

		cellModel.$isUserInteractionEnabled
			.dropFirst()
			.sink { receivedValue in
				receivedUserInteractivity.append(receivedValue)
				expectationUserInteraction.fulfill()
			}
			.store(in: &subscriptions)
		
		cellModel.$accessibilityIdentifier
			.dropFirst()
			.sink { receivedValue in
				receivedAccessibilityIdentifiers.append(receivedValue)
				expectationAccessibilityIdentifiers.fulfill()
			}
			.store(in: &subscriptions)

		coronaTestService.pcrTest?.testResult = .negative
		coronaTestService.pcrTest?.testResult = .invalid
		coronaTestService.pcrTest?.testResult = .positive
		coronaTestService.pcrTest?.testResult = .expired
		coronaTestService.pcrTestResultIsLoading = true

		waitForExpectations(timeout: .short, handler: nil)

		subscriptions.forEach({ $0.cancel() })

		XCTAssertEqual(receivedSubtitles, subtitleArray)
		XCTAssertEqual(receivedDescription, descriptionsArray)
		XCTAssertEqual(receivedButtonTitle, buttonTitlesArray)
		XCTAssertEqual(receivedImages, imagesArray)
		XCTAssertEqual(receivedActivityIndicatorsVisibility, indicatorVisibilityArray)
		XCTAssertEqual(receivedUserInteractivity, userInteractionArray)
		XCTAssertEqual(receivedAccessibilityIdentifiers, accessibilityIdentifiersArray)
	}
}
