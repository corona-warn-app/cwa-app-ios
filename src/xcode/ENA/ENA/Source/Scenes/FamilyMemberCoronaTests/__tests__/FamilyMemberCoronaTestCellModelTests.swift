////
// 🦠 Corona-Warn-App
//

import XCTest
import OpenCombine
import HealthCertificateToolkit
@testable import ENA

// swiftlint:disable type_body_length
class FamilyMemberCoronaTestCellModelTests: CWATestCase {

	// swiftlint:disable function_body_length
	func test_PCR_whenTestResultChanges_then_changesAreReflectedInTheSubscription() {
		// test cases are [.pending, .negative, .invalid, .positive, .expired]
		var subscriptions = [AnyCancellable]()

		let topDiagnosesArray = [
			AppStrings.FamilyMemberCoronaTest.pendingDiagnosis,
			AppStrings.FamilyMemberCoronaTest.negativeTopDiagnosis,
			AppStrings.FamilyMemberCoronaTest.invalidDiagnosis,
			AppStrings.FamilyMemberCoronaTest.positiveTopDiagnosis,
			AppStrings.FamilyMemberCoronaTest.expiredDiagnosis
		]
		let bottomDiagnosesArray = [
			nil,
			AppStrings.FamilyMemberCoronaTest.negativeBottomDiagnosis,
			nil,
			AppStrings.FamilyMemberCoronaTest.positiveBottomDiagnosis,
			nil
		]
		let bottomDiagnosisColorsArray: [UIColor?] = [
			nil,
			.enaColor(for: .riskLow),
			nil,
			.enaColor(for: .riskHigh),
			nil
		]
		let descriptionsArray = [
			AppStrings.FamilyMemberCoronaTest.pendingPCRDescription,
			nil,
			AppStrings.FamilyMemberCoronaTest.invalidDescription,
			nil,
			AppStrings.FamilyMemberCoronaTest.expiredDescription
		]
		let footnotesArray = [
			"Test hinzugefügt am 01.01.70",
			"Test hinzugefügt am 01.01.70",
			nil,
			"Test hinzugefügt am 01.01.70",
			nil
		]
		let buttonTitlesArray = [
			nil,
			nil,
			nil,
			nil,
			AppStrings.FamilyMemberCoronaTest.expiredButtonTitle
		]
		let imagesArray = [
			UIImage(named: "FamilyMember_CoronaTest_pending"),
			UIImage(named: "FamilyMember_CoronaTest_negative"),
			UIImage(named: "FamilyMember_CoronaTest_invalid_expired"),
			UIImage(named: "FamilyMember_CoronaTest_positive"),
			UIImage(named: "FamilyMember_CoronaTest_invalid_expired")
		]
		let isUnseenNewsIndicatorHiddenArray = [false, true, false, true, true]
		let isDisclosureIndicatorHiddenArray = [false, false, false, false, true]
		let userInteractionArray = [true, true, true, true, true]
		let cellTappableArray = [true, true, true, true, false]
		let accessibilityIdentifiersArray = [
			AccessibilityIdentifiers.FamilyMemberCoronaTestCell.pendingPCR,
			AccessibilityIdentifiers.FamilyMemberCoronaTestCell.negativePCR,
			AccessibilityIdentifiers.FamilyMemberCoronaTestCell.invalidPCR,
			AccessibilityIdentifiers.FamilyMemberCoronaTestCell.positivePCR,
			AccessibilityIdentifiers.FamilyMemberCoronaTestCell.expiredPCR
		]

		let expectationTopDiagnoses = expectation(description: "expectationTopDiagnoses")
		let expectationBottomDiagnoses = expectation(description: "expectationBottomDiagnoses")
		let expectationBottomDiagnosisColors = expectation(description: "expectationBottomDiagnosisColors")
		let expectationDescription = expectation(description: "expectationDescription")
		let expectationFootnote = expectation(description: "expectationFootnote")
		let expectationButtonTitle = expectation(description: "expectationButtonTitle")
		let expectationButtonImage = expectation(description: "expectationButtonImage")
		let expectationDisclosureIndicatorVisibility = expectation(description: "expectationDisclosureIndicatorVisibility")
		let expectationUnseenNewsIndicatorVisibility = expectation(description: "expectationUnseenNewsIndicatorVisibility")
		let expectationUserInteraction = expectation(description: "expectationUserInteraction")
		let expectationCellTappability = expectation(description: "expectationCellTappability")
		let expectationAccessibilityIdentifiers = expectation(description: "expectationAccessibilityIdentifiers")
		let expectationOnUpdate = expectation(description: "expectationOnUpdate")

		var receivedTopDiagnoses = [String?]()
		var receivedBottomDiagnoses = [String?]()
		var receivedBottomDiagnosisColors = [UIColor?]()
		var receivedDescription = [String?]()
		var receivedFootnote = [String?]()
		var receivedButtonTitle = [String?]()
		var receivedImages = [UIImage?]()
		var receivedDisclosureIndicatorVisibility = [Bool]()
		var receivedUnseenNewsIndicatorVisibility = [Bool]()
		var receivedUserInteractivity = [Bool]()
		var receivedCellTappability = [Bool]()
		var receivedAccessibilityIdentifiers = [String?]()
		
		expectationTopDiagnoses.expectedFulfillmentCount = topDiagnosesArray.count
		expectationBottomDiagnoses.expectedFulfillmentCount = bottomDiagnosesArray.count
		expectationBottomDiagnosisColors.expectedFulfillmentCount = bottomDiagnosisColorsArray.count
		expectationDescription.expectedFulfillmentCount = descriptionsArray.count
		expectationFootnote.expectedFulfillmentCount = footnotesArray.count
		expectationButtonTitle.expectedFulfillmentCount = buttonTitlesArray.count
		expectationButtonImage.expectedFulfillmentCount = imagesArray.count
		expectationDisclosureIndicatorVisibility.expectedFulfillmentCount = isDisclosureIndicatorHiddenArray.count
		expectationUnseenNewsIndicatorVisibility.expectedFulfillmentCount = isUnseenNewsIndicatorHiddenArray.count
		expectationUserInteraction.expectedFulfillmentCount = userInteractionArray.count
		expectationCellTappability.expectedFulfillmentCount = cellTappableArray.count
		expectationAccessibilityIdentifiers.expectedFulfillmentCount = accessibilityIdentifiersArray.count
		expectationOnUpdate.expectedFulfillmentCount = 6

		let coronaTest: FamilyMemberCoronaTest = .pcr(.mock(displayName: "pcrDisplayName", registrationDate: Date(timeIntervalSince1970: 0)))

		let familyMemberCoronaTestService = MockFamilyMemberCoronaTestService()
		familyMemberCoronaTestService.coronaTests.value = [coronaTest]

		let cellModel = FamilyMemberCoronaTestCellModel(
			coronaTest: coronaTest,
			familyMemberCoronaTestService: familyMemberCoronaTestService,
			appConfigurationProvider: CachedAppConfigurationMock(),
			onUpdate: {
				expectationOnUpdate.fulfill()
			}
		)

		XCTAssertEqual(cellModel.name, "pcrDisplayName")
		XCTAssertEqual(cellModel.caption, AppStrings.FamilyMemberCoronaTest.pcrCaption)

		cellModel.$topDiagnosis
			.dropFirst()
			.sink { receivedValue in
				receivedTopDiagnoses.append(receivedValue)
				expectationTopDiagnoses.fulfill()
			}
			.store(in: &subscriptions)

		cellModel.$bottomDiagnosis
			.dropFirst()
			.sink { receivedValue in
				receivedBottomDiagnoses.append(receivedValue)
				expectationBottomDiagnoses.fulfill()
			}
			.store(in: &subscriptions)

		cellModel.$bottomDiagnosisColor
			.dropFirst()
			.sink { receivedValue in
				receivedBottomDiagnosisColors.append(receivedValue)
				expectationBottomDiagnosisColors.fulfill()
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

		cellModel.$isUnseenNewsIndicatorHidden
			.dropFirst()
			.sink { receivedValue in
				receivedUnseenNewsIndicatorVisibility.append(receivedValue)
				expectationUnseenNewsIndicatorVisibility.fulfill()
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

		familyMemberCoronaTestService.coronaTests.value = [.pcr(.mock(displayName: "pcrDisplayName", registrationDate: Date(timeIntervalSince1970: 0), isNew: true, testResult: .pending))]
		familyMemberCoronaTestService.coronaTests.value = [.pcr(.mock(displayName: "pcrDisplayName", registrationDate: Date(timeIntervalSince1970: 0), testResult: .negative))]
		familyMemberCoronaTestService.coronaTests.value = [.pcr(.mock(displayName: "pcrDisplayName", registrationDate: Date(timeIntervalSince1970: 0), isNew: true, testResult: .invalid, finalTestResultReceivedDate: Date(), testResultWasShown: false))]
		familyMemberCoronaTestService.coronaTests.value = [.pcr(.mock(displayName: "pcrDisplayName", registrationDate: Date(timeIntervalSince1970: 0), testResult: .positive, finalTestResultReceivedDate: Date(), testResultWasShown: true))]
		familyMemberCoronaTestService.coronaTests.value = [.pcr(.mock(displayName: "pcrDisplayName", registrationDate: Date(timeIntervalSince1970: 0), testResult: .expired))]

		waitForExpectations(timeout: .short, handler: nil)

		subscriptions.forEach({ $0.cancel() })

		XCTAssertEqual(receivedTopDiagnoses, topDiagnosesArray)
		XCTAssertEqual(receivedBottomDiagnoses, bottomDiagnosesArray)
		XCTAssertEqual(receivedBottomDiagnosisColors.map { $0?.cgColor }, bottomDiagnosisColorsArray.map { $0?.cgColor })
		XCTAssertEqual(receivedDescription, descriptionsArray)
		XCTAssertEqual(receivedFootnote, footnotesArray)
		XCTAssertEqual(receivedButtonTitle, buttonTitlesArray)
		XCTAssertEqual(receivedImages, imagesArray)
		XCTAssertEqual(receivedDisclosureIndicatorVisibility, isDisclosureIndicatorHiddenArray)
		XCTAssertEqual(receivedUnseenNewsIndicatorVisibility, isUnseenNewsIndicatorHiddenArray)
		XCTAssertEqual(receivedUserInteractivity, userInteractionArray)
		XCTAssertEqual(receivedCellTappability, cellTappableArray)
		XCTAssertEqual(receivedAccessibilityIdentifiers, accessibilityIdentifiersArray)
	}

	// swiftlint:disable function_body_length
	func test_antigen_whenTestResultChanges_then_changesAreReflectedInTheSubscription() {
		// test cases are [.pending, .negative, .invalid, .positive, .expired, (Outdated)]
		var subscriptions = [AnyCancellable]()

		let topDiagnosesArray = [
			AppStrings.FamilyMemberCoronaTest.pendingDiagnosis,
			AppStrings.FamilyMemberCoronaTest.negativeTopDiagnosis,
			AppStrings.FamilyMemberCoronaTest.invalidDiagnosis,
			AppStrings.FamilyMemberCoronaTest.positiveTopDiagnosis,
			AppStrings.FamilyMemberCoronaTest.expiredDiagnosis,
			AppStrings.FamilyMemberCoronaTest.outdatedDiagnosis
		]
		let bottomDiagnosesArray = [
			nil,
			AppStrings.FamilyMemberCoronaTest.negativeBottomDiagnosis,
			nil,
			AppStrings.FamilyMemberCoronaTest.positiveBottomDiagnosis,
			nil,
			nil
		]
		let bottomDiagnosisColorsArray: [UIColor?] = [
			nil,
			.enaColor(for: .riskLow),
			nil,
			.enaColor(for: .riskHigh),
			nil,
			nil
		]
		let descriptionsArray = [
			AppStrings.FamilyMemberCoronaTest.pendingAntigenDescription,
			nil,
			AppStrings.FamilyMemberCoronaTest.invalidDescription,
			nil,
			AppStrings.FamilyMemberCoronaTest.expiredDescription,
			"Der Schnelltest ist älter als 37 Stunden und wird hier nicht mehr angezeigt."
		]
		let footnotesArray = [
			"Durchgeführt am 01.01.70",
			"Durchgeführt am 01.01.70",
			nil,
			"Durchgeführt am 01.01.70",
			nil,
			nil
		]
		let buttonTitlesArray = [
			nil,
			nil,
			nil,
			nil,
			AppStrings.FamilyMemberCoronaTest.expiredButtonTitle,
			AppStrings.FamilyMemberCoronaTest.outdatedButtonTitle
		]
		let imagesArray = [
			UIImage(named: "FamilyMember_CoronaTest_pending"),
			UIImage(named: "FamilyMember_CoronaTest_negative"),
			UIImage(named: "FamilyMember_CoronaTest_invalid_expired"),
			UIImage(named: "FamilyMember_CoronaTest_positive"),
			UIImage(named: "FamilyMember_CoronaTest_invalid_expired"),
			UIImage(named: "FamilyMember_CoronaTest_outdated")
		]
		let isUnseenNewsIndicatorHiddenArray = [false, true, false, true, true, true]
		let isDisclosureIndicatorHiddenArray = [false, false, false, false, true, true]
		let userInteractionArray = [true, true, true, true, true, true]
		let cellTappableArray = [true, true, true, true, false, false]
		let accessibilityIdentifiersArray = [
			AccessibilityIdentifiers.FamilyMemberCoronaTestCell.pendingAntigen,
			AccessibilityIdentifiers.FamilyMemberCoronaTestCell.negativeAntigen,
			AccessibilityIdentifiers.FamilyMemberCoronaTestCell.invalidAntigen,
			AccessibilityIdentifiers.FamilyMemberCoronaTestCell.positiveAntigen,
			AccessibilityIdentifiers.FamilyMemberCoronaTestCell.expiredAntigen,
			AccessibilityIdentifiers.FamilyMemberCoronaTestCell.outdatedAntigen
		]

		let expectationTopDiagnoses = expectation(description: "expectationTopDiagnoses")
		let expectationBottomDiagnoses = expectation(description: "expectationBottomDiagnoses")
		let expectationBottomDiagnosisColors = expectation(description: "expectationBottomDiagnosisColors")
		let expectationDescription = expectation(description: "expectationDescription")
		let expectationFootnote = expectation(description: "expectationFootnote")
		let expectationButtonTitle = expectation(description: "expectationButtonTitle")
		let expectationButtonImage = expectation(description: "expectationButtonImage")
		let expectationDisclosureIndicatorVisibility = expectation(description: "expectationDisclosureIndicatorVisibility")
		let expectationUnseenNewsIndicatorVisibility = expectation(description: "expectationUnseenNewsIndicatorVisibility")
		let expectationUserInteraction = expectation(description: "expectationUserInteraction")
		let expectationCellTappability = expectation(description: "expectationCellTappability")
		let expectationAccessibilityIdentifiers = expectation(description: "expectationAccessibilityIdentifiers")
		let expectationOnUpdate = expectation(description: "expectationOnUpdate")

		var receivedTopDiagnoses = [String?]()
		var receivedBottomDiagnoses = [String?]()
		var receivedBottomDiagnosisColors = [UIColor?]()
		var receivedDescription = [String?]()
		var receivedFootnote = [String?]()
		var receivedButtonTitle = [String?]()
		var receivedImages = [UIImage?]()
		var receivedDisclosureIndicatorVisibility = [Bool]()
		var receivedUnseenNewsIndicatorVisibility = [Bool]()
		var receivedUserInteractivity = [Bool]()
		var receivedCellTappability = [Bool]()
		var receivedAccessibilityIdentifiers = [String?]()

		expectationTopDiagnoses.expectedFulfillmentCount = topDiagnosesArray.count
		expectationBottomDiagnoses.expectedFulfillmentCount = bottomDiagnosesArray.count
		expectationBottomDiagnosisColors.expectedFulfillmentCount = bottomDiagnosisColorsArray.count
		expectationDescription.expectedFulfillmentCount = descriptionsArray.count
		expectationFootnote.expectedFulfillmentCount = footnotesArray.count
		expectationButtonTitle.expectedFulfillmentCount = buttonTitlesArray.count
		expectationButtonImage.expectedFulfillmentCount = imagesArray.count
		expectationDisclosureIndicatorVisibility.expectedFulfillmentCount = isDisclosureIndicatorHiddenArray.count
		expectationUnseenNewsIndicatorVisibility.expectedFulfillmentCount = isUnseenNewsIndicatorHiddenArray.count
		expectationUserInteraction.expectedFulfillmentCount = userInteractionArray.count
		expectationCellTappability.expectedFulfillmentCount = cellTappableArray.count
		expectationAccessibilityIdentifiers.expectedFulfillmentCount = accessibilityIdentifiersArray.count
		expectationOnUpdate.expectedFulfillmentCount = 7

		let coronaTest: FamilyMemberCoronaTest = .antigen(.mock(displayName: "antigenDisplayName", sampleCollectionDate: Date(timeIntervalSince1970: 0)))

		let familyMemberCoronaTestService = MockFamilyMemberCoronaTestService()
		familyMemberCoronaTestService.coronaTests.value = [coronaTest]

		var defaultAppConfig = CachedAppConfigurationMock.defaultAppConfiguration
		defaultAppConfig.coronaTestParameters.coronaRapidAntigenTestParameters.hoursToDeemTestOutdated = 37
		let appConfiguration = CachedAppConfigurationMock(with: defaultAppConfig)

		let cellModel = FamilyMemberCoronaTestCellModel(
			coronaTest: coronaTest,
			familyMemberCoronaTestService: familyMemberCoronaTestService,
			appConfigurationProvider: appConfiguration,
			onUpdate: {
				expectationOnUpdate.fulfill()
			}
		)

		XCTAssertEqual(cellModel.name, "antigenDisplayName")
		XCTAssertEqual(cellModel.caption, AppStrings.FamilyMemberCoronaTest.antigenCaption)

		cellModel.$topDiagnosis
			.dropFirst()
			.sink { receivedValue in
				receivedTopDiagnoses.append(receivedValue)
				expectationTopDiagnoses.fulfill()
			}
			.store(in: &subscriptions)

		cellModel.$bottomDiagnosis
			.dropFirst()
			.sink { receivedValue in
				receivedBottomDiagnoses.append(receivedValue)
				expectationBottomDiagnoses.fulfill()
			}
			.store(in: &subscriptions)

		cellModel.$bottomDiagnosisColor
			.dropFirst()
			.sink { receivedValue in
				receivedBottomDiagnosisColors.append(receivedValue)
				expectationBottomDiagnosisColors.fulfill()
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

		cellModel.$isUnseenNewsIndicatorHidden
			.dropFirst()
			.sink { receivedValue in
				receivedUnseenNewsIndicatorVisibility.append(receivedValue)
				expectationUnseenNewsIndicatorVisibility.fulfill()
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

		familyMemberCoronaTestService.coronaTests.value = [.antigen(.mock(displayName: "antigenDisplayName", sampleCollectionDate: Date(timeIntervalSince1970: 0), isNew: true, testResult: .pending))]
		familyMemberCoronaTestService.coronaTests.value = [.antigen(.mock(displayName: "antigenDisplayName", sampleCollectionDate: Date(timeIntervalSince1970: 0), testResult: .negative))]
		familyMemberCoronaTestService.coronaTests.value = [.antigen(.mock(displayName: "antigenDisplayName", sampleCollectionDate: Date(timeIntervalSince1970: 0), isNew: true, testResult: .invalid, finalTestResultReceivedDate: Date(), testResultWasShown: false))]
		familyMemberCoronaTestService.coronaTests.value = [.antigen(.mock(displayName: "antigenDisplayName", sampleCollectionDate: Date(timeIntervalSince1970: 0), testResult: .positive, finalTestResultReceivedDate: Date(), testResultWasShown: true))]
		familyMemberCoronaTestService.coronaTests.value = [.antigen(.mock(displayName: "antigenDisplayName", sampleCollectionDate: Date(timeIntervalSince1970: 0), testResult: .expired))]
		familyMemberCoronaTestService.coronaTests.value = [.antigen(.mock(displayName: "antigenDisplayName", sampleCollectionDate: Date(timeIntervalSince1970: 0), testResult: .negative, isOutdated: true))]

		waitForExpectations(timeout: .short, handler: nil)

		subscriptions.forEach({ $0.cancel() })

		XCTAssertEqual(receivedTopDiagnoses, topDiagnosesArray)
		XCTAssertEqual(receivedBottomDiagnoses, bottomDiagnosesArray)
		XCTAssertEqual(receivedBottomDiagnosisColors.map { $0?.cgColor }, bottomDiagnosisColorsArray.map { $0?.cgColor })
		XCTAssertEqual(receivedDescription, descriptionsArray)
		XCTAssertEqual(receivedFootnote, footnotesArray)
		XCTAssertEqual(receivedButtonTitle, buttonTitlesArray)
		XCTAssertEqual(receivedImages, imagesArray)
		XCTAssertEqual(receivedDisclosureIndicatorVisibility, isDisclosureIndicatorHiddenArray)
		XCTAssertEqual(receivedUnseenNewsIndicatorVisibility, isUnseenNewsIndicatorHiddenArray)
		XCTAssertEqual(receivedUserInteractivity, userInteractionArray)
		XCTAssertEqual(receivedCellTappability, cellTappableArray)
		XCTAssertEqual(receivedAccessibilityIdentifiers, accessibilityIdentifiersArray)
	}

}
