////
// 🦠 Corona-Warn-App
//

import XCTest
import OpenCombine
import HealthCertificateToolkit
@testable import ENA

// swiftlint:disable type_body_length
class HomeTestResultCellModelTests: CWATestCase {

	// swiftlint:disable function_body_length
	func test_PCR_whenTestResultChanges_then_changesAreReflectedInTheSubscription() {
		// expected values arrays have to test the default flow values plus explicitly test setting the testResult into [.pending, .negative, .invalid, .positive, .expired]
		// so the total test cases are [.pending, .negative, .invalid, .positive, .expired, (Loading)]

		var subscriptions = [AnyCancellable]()

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
		let footnotesArray = [
			nil,
			"Test registriert am 01.01.70",
			nil,
			nil,
			nil,
			nil
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
		let isDisclosureIndicatorHiddenArray = [false, false, false, false, true, false]
		let isNegativeDiagnosisHiddenArray = [true, false, true, true, true, true]
		let indicatorVisibilityArray = [true, true, true, true, true, false]
		let userInteractionArray = [true, true, true, true, true, false]
		let cellTappableArray = [true, true, true, true, false, true]
		let accessibilityIdentifiersArray = [
			AccessibilityIdentifiers.Home.TestResultCell.pendingPCRButton,
			AccessibilityIdentifiers.Home.TestResultCell.negativePCRButton,
			AccessibilityIdentifiers.Home.TestResultCell.invalidPCRButton,
			AccessibilityIdentifiers.Home.TestResultCell.availablePCRButton,
			AccessibilityIdentifiers.Home.TestResultCell.expiredPCRButton,
			AccessibilityIdentifiers.Home.TestResultCell.loadingPCRButton
		]

		let expectationSubtitles = expectation(description: "expectationSubtitles")
		let expectationDescription = expectation(description: "expectationDescription")
		let expectationFootnote = expectation(description: "expectationFootnote")
		let expectationButtonTitle = expectation(description: "expectationButtonTitle")
		let expectationButtonImage = expectation(description: "expectationButtonImage")
		let expectationDisclosureIndicatorVisibility = expectation(description: "expectationDisclosureIndicatorVisibility")
		let expectationNegativeDiagnosisVisibility = expectation(description: "expectationNegativeDiagnosisVisibility")
		let expectationIndicatorVisibility = expectation(description: "expectationIndicatorVisibility")
		let expectationUserInteraction = expectation(description: "expectationUserInteraction")
		let expectationCellTappability = expectation(description: "expectationCellTappability")
		let expectationAccessibilityIdentifiers = expectation(description: "expectationAccessibilityIdentifiers")
		let expectationOnUpdate = expectation(description: "expectationOnUpdate")

		var receivedSubtitles = [String?]()
		var receivedDescription = [String?]()
		var receivedFootnote = [String?]()
		var receivedButtonTitle = [String?]()
		var receivedImages = [UIImage?]()
		var receivedDisclosureIndicatorVisibility = [Bool]()
		var receivedNegativeDiagnosisVisibility = [Bool]()
		var receivedActivityIndicatorsVisibility = [Bool]()
		var receivedUserInteractivity = [Bool]()
		var receivedCellTappability = [Bool]()
		var receivedAccessibilityIdentifiers = [String?]()
		
		expectationSubtitles.expectedFulfillmentCount = subtitleArray.count
		expectationDescription.expectedFulfillmentCount = descriptionsArray.count
		expectationFootnote.expectedFulfillmentCount = footnotesArray.count
		expectationButtonTitle.expectedFulfillmentCount = buttonTitlesArray.count
		expectationButtonImage.expectedFulfillmentCount = imagesArray.count
		expectationDisclosureIndicatorVisibility.expectedFulfillmentCount = isDisclosureIndicatorHiddenArray.count
		expectationNegativeDiagnosisVisibility.expectedFulfillmentCount = isNegativeDiagnosisHiddenArray.count
		expectationIndicatorVisibility.expectedFulfillmentCount = indicatorVisibilityArray.count
		expectationUserInteraction.expectedFulfillmentCount = userInteractionArray.count
		expectationCellTappability.expectedFulfillmentCount = cellTappableArray.count
		expectationAccessibilityIdentifiers.expectedFulfillmentCount = accessibilityIdentifiersArray.count
		expectationOnUpdate.expectedFulfillmentCount = 8

		let coronaTestService = MockCoronaTestService()
		coronaTestService.pcrTest.value = .mock(registrationDate: Date(timeIntervalSince1970: 0))

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

		cellModel.$footnote
			.dropFirst()
			.sink { receivedValue in
				receivedFootnote.append(receivedValue)
				expectationFootnote.fulfill()
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

		cellModel.$isDisclosureIndicatorHidden
			.dropFirst()
			.sink { receivedValue in
				receivedDisclosureIndicatorVisibility.append(receivedValue)
				expectationDisclosureIndicatorVisibility.fulfill()
			}
			.store(in: &subscriptions)

		cellModel.$isNegativeDiagnosisHidden
			.dropFirst()
			.sink { receivedValue in
				receivedNegativeDiagnosisVisibility.append(receivedValue)
				expectationNegativeDiagnosisVisibility.fulfill()
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

		cellModel.$isCellTappable
			.dropFirst()
			.sink { receivedValue in
				receivedCellTappability.append(receivedValue)
				expectationCellTappability.fulfill()
			}
			.store(in: &subscriptions)
		
		cellModel.$accessibilityIdentifier
			.dropFirst()
			.sink { receivedValue in
				receivedAccessibilityIdentifiers.append(receivedValue)
				expectationAccessibilityIdentifiers.fulfill()
			}
			.store(in: &subscriptions)

		coronaTestService.pcrTest.value?.testResult = .pending
		coronaTestService.pcrTest.value?.testResult = .negative
		coronaTestService.pcrTest.value?.testResult = .invalid
		coronaTestService.pcrTest.value?.testResult = .positive
		coronaTestService.pcrTest.value?.testResult = .expired
		coronaTestService.pcrTestResultIsLoading.value = true

		waitForExpectations(timeout: .short, handler: nil)

		subscriptions.forEach({ $0.cancel() })

		XCTAssertEqual(receivedSubtitles, subtitleArray)
		XCTAssertEqual(receivedDescription, descriptionsArray)
		XCTAssertEqual(receivedFootnote, footnotesArray)
		XCTAssertEqual(receivedButtonTitle, buttonTitlesArray)
		XCTAssertEqual(receivedImages, imagesArray)
		XCTAssertEqual(receivedActivityIndicatorsVisibility, indicatorVisibilityArray)
		XCTAssertEqual(receivedDisclosureIndicatorVisibility, isDisclosureIndicatorHiddenArray)
		XCTAssertEqual(receivedNegativeDiagnosisVisibility, isNegativeDiagnosisHiddenArray)
		XCTAssertEqual(receivedUserInteractivity, userInteractionArray)
		XCTAssertEqual(receivedCellTappability, cellTappableArray)
		XCTAssertEqual(receivedAccessibilityIdentifiers, accessibilityIdentifiersArray)
	}

	func test_Antigen_whenTestResultChanges_then_changesAreReflectedInTheSubscription() {
		// expected values arrays have to test the default flow values plus explicitly test setting the testResult into [.pending, .negative, .invalid, .positive, .expired]
		// so the total test cases are [.pending, .negative, .invalid, .positive, .expired, (Outdated), (Loading)]

		var subscriptions = [AnyCancellable]()

		let subtitleArray = [
			AppStrings.Home.TestResult.Pending.title,
			nil,
			AppStrings.Home.TestResult.Invalid.title,
			AppStrings.Home.TestResult.Available.title,
			AppStrings.Home.TestResult.Expired.title,
			AppStrings.Home.TestResult.Outdated.title,
			AppStrings.Home.TestResult.Loading.title
		]
		let descriptionsArray = [
			AppStrings.Home.TestResult.Pending.antigenDescription,
			AppStrings.Home.TestResult.Negative.description,
			AppStrings.Home.TestResult.Invalid.description,
			AppStrings.Home.TestResult.Available.description,
			AppStrings.Home.TestResult.Expired.description,
			AppStrings.Home.TestResult.Outdated.description,
			AppStrings.Home.TestResult.Loading.description
		]
		let footnotesArray = [
			nil,
			"Durchgeführt am 01.01.70",
			nil,
			nil,
			nil,
			nil,
			nil
		]
		let buttonTitlesArray = [
			AppStrings.Home.TestResult.Button.showResult,
			AppStrings.Home.TestResult.Button.showResult,
			AppStrings.Home.TestResult.Button.showResult,
			AppStrings.Home.TestResult.Button.retrieveResult,
			AppStrings.Home.TestResult.Button.deleteTest,
			AppStrings.Home.TestResult.Button.hideTest,
			AppStrings.Home.TestResult.Button.showResult
		]
		let imagesArray = [
			UIImage(named: "Illu_Hand_with_phone-pending"),
			UIImage(named: "Illu_Home_NegativesTestErgebnis"),
			UIImage(named: "Illu_Hand_with_phone-error"),
			UIImage(named: "Illu_Hand_with_phone-error"),
			UIImage(named: "Illu_Hand_with_phone-pending"),
			UIImage(named: "Illu_Home_OutdatedTestErgebnis"),
			UIImage(named: "Illu_Hand_with_phone-initial")
		]
		let isDisclosureIndicatorHiddenArray = [false, false, false, false, true, true, false]
		let isNegativeDiagnosisHiddenArray = [true, false, true, true, true, true, true]
		let indicatorVisibilityArray = [true, true, true, true, true, true, false]
		let userInteractionArray = [true, true, true, true, true, true, false]
		let cellTappableArray = [true, true, true, true, false, false, true]
		let accessibilityIdentifiersArray = [
			AccessibilityIdentifiers.Home.TestResultCell.pendingAntigenButton,
			AccessibilityIdentifiers.Home.TestResultCell.negativeAntigenButton,
			AccessibilityIdentifiers.Home.TestResultCell.invalidAntigenButton,
			AccessibilityIdentifiers.Home.TestResultCell.availableAntigenButton,
			AccessibilityIdentifiers.Home.TestResultCell.expiredAntigenButton,
			AccessibilityIdentifiers.Home.TestResultCell.outdatedAntigenButton,
			AccessibilityIdentifiers.Home.TestResultCell.loadingAntigenButton
		]

		let expectationSubtitles = expectation(description: "expectationSubtitles")
		let expectationDescription = expectation(description: "expectationDescription")
		let expectationFootnote = expectation(description: "expectationFootnote")
		let expectationButtonTitle = expectation(description: "expectationButtonTitle")
		let expectationButtonImage = expectation(description: "expectationButtonImage")
		let expectationDisclosureIndicatorVisibility = expectation(description: "expectationDisclosureIndicatorVisibility")
		let expectationNegativeDiagnosisVisibility = expectation(description: "expectationNegativeDiagnosisVisibility")
		let expectationIndicatorVisibility = expectation(description: "expectationIndicatorVisibility")
		let expectationUserInteraction = expectation(description: "expectationUserInteraction")
		let expectationCellTappability = expectation(description: "expectationCellTappability")
		let expectationAccessibilityIdentifiers = expectation(description: "expectationAccessibilityIdentifiers")
		let expectationOnUpdate = expectation(description: "expectationOnUpdate")

		var receivedSubtitles = [String?]()
		var receivedDescription = [String?]()
		var receivedFootnote = [String?]()
		var receivedButtonTitle = [String?]()
		var receivedImages = [UIImage?]()
		var receivedDisclosureIndicatorVisibility = [Bool]()
		var receivedNegativeDiagnosisVisibility = [Bool]()
		var receivedActivityIndicatorsVisibility = [Bool]()
		var receivedUserInteractivity = [Bool]()
		var receivedCellTappability = [Bool]()
		var receivedAccessibilityIdentifiers = [String?]()

		expectationSubtitles.expectedFulfillmentCount = subtitleArray.count
		expectationDescription.expectedFulfillmentCount = descriptionsArray.count
		expectationFootnote.expectedFulfillmentCount = footnotesArray.count
		expectationButtonTitle.expectedFulfillmentCount = buttonTitlesArray.count
		expectationButtonImage.expectedFulfillmentCount = imagesArray.count
		expectationDisclosureIndicatorVisibility.expectedFulfillmentCount = isDisclosureIndicatorHiddenArray.count
		expectationNegativeDiagnosisVisibility.expectedFulfillmentCount = isNegativeDiagnosisHiddenArray.count
		expectationIndicatorVisibility.expectedFulfillmentCount = indicatorVisibilityArray.count
		expectationUserInteraction.expectedFulfillmentCount = userInteractionArray.count
		expectationCellTappability.expectedFulfillmentCount = cellTappableArray.count
		expectationAccessibilityIdentifiers.expectedFulfillmentCount = accessibilityIdentifiersArray.count
		expectationOnUpdate.expectedFulfillmentCount = 9

		let coronaTestService = MockCoronaTestService()
		coronaTestService.antigenTest.value = .mock(sampleCollectionDate: Date(timeIntervalSince1970: 0))

		let cellModel = HomeTestResultCellModel(
			coronaTestType: .antigen,
			coronaTestService: coronaTestService,
			onUpdate: {
				expectationOnUpdate.fulfill()
			}
		)

		XCTAssertEqual(cellModel.title, AppStrings.Home.TestResult.antigenTitle)

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

		cellModel.$footnote
			.dropFirst()
			.sink { receivedValue in
				receivedFootnote.append(receivedValue)
				expectationFootnote.fulfill()
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

		cellModel.$isDisclosureIndicatorHidden
			.dropFirst()
			.sink { receivedValue in
				receivedDisclosureIndicatorVisibility.append(receivedValue)
				expectationDisclosureIndicatorVisibility.fulfill()
			}
			.store(in: &subscriptions)

		cellModel.$isNegativeDiagnosisHidden
			.dropFirst()
			.sink { receivedValue in
				receivedNegativeDiagnosisVisibility.append(receivedValue)
				expectationNegativeDiagnosisVisibility.fulfill()
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

		cellModel.$isCellTappable
			.dropFirst()
			.sink { receivedValue in
				receivedCellTappability.append(receivedValue)
				expectationCellTappability.fulfill()
			}
			.store(in: &subscriptions)

		cellModel.$accessibilityIdentifier
			.dropFirst()
			.sink { receivedValue in
				receivedAccessibilityIdentifiers.append(receivedValue)
				expectationAccessibilityIdentifiers.fulfill()
			}
			.store(in: &subscriptions)

		coronaTestService.antigenTest.value?.testResult = .pending
		coronaTestService.antigenTest.value?.testResult = .negative
		coronaTestService.antigenTest.value?.testResult = .invalid
		coronaTestService.antigenTest.value?.testResult = .positive
		coronaTestService.antigenTest.value?.testResult = .expired
		coronaTestService.antigenTestIsOutdated.value = true
		coronaTestService.antigenTestResultIsLoading.value = true

		waitForExpectations(timeout: .short, handler: nil)

		subscriptions.forEach({ $0.cancel() })

		XCTAssertEqual(receivedSubtitles, subtitleArray)
		XCTAssertEqual(receivedDescription, descriptionsArray)
		XCTAssertEqual(receivedFootnote, footnotesArray)
		XCTAssertEqual(receivedButtonTitle, buttonTitlesArray)
		XCTAssertEqual(receivedImages, imagesArray)
		XCTAssertEqual(receivedActivityIndicatorsVisibility, indicatorVisibilityArray)
		XCTAssertEqual(receivedDisclosureIndicatorVisibility, isDisclosureIndicatorHiddenArray)
		XCTAssertEqual(receivedNegativeDiagnosisVisibility, isNegativeDiagnosisHiddenArray)
		XCTAssertEqual(receivedUserInteractivity, userInteractionArray)
		XCTAssertEqual(receivedCellTappability, cellTappableArray)
		XCTAssertEqual(receivedAccessibilityIdentifiers, accessibilityIdentifiersArray)
	}

}
