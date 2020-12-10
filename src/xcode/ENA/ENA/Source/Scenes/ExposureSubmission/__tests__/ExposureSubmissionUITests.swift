//
// 🦠 Corona-Warn-App
//

import XCTest
import ExposureNotification

// swiftlint:disable file_length
// swiftlint:disable:next type_body_length
class ENAUITests_04_ExposureSubmissionUITests: XCTestCase {

	// MARK: - Attributes.
	
	var app: XCUIApplication!

	// MARK: - Setup.

	override func setUpWithError() throws {
		continueAfterFailure = false
		app = XCUIApplication()
		setupSnapshot(app)
		app.setDefaults()
		app.launchArguments.append(contentsOf: ["-isOnboarded", "YES"])
		app.launchArguments.append(contentsOf: ["-setCurrentOnboardingVersion", "YES"])
	}

	// MARK: - Test cases.

	func test_NavigateToIntroVC() throws {
		launch()

		// Click submit card.
		XCTAssertTrue(app.collectionViews.buttons["AppStrings.Home.submitCardButton"].waitForExistence(timeout: .long))
		app.collectionViews.buttons["AppStrings.Home.submitCardButton"].tap()

		// Check whether we have entered the info screen.
		XCTAssertTrue(app.images["ExposureSubmissionIntroViewController.image"].waitForExistence(timeout: .medium))
	}

	func test_NavigateToHotlineVC() throws {
		launch()

		// Open Intro screen.
		XCTAssertTrue(app.collectionViews.buttons["AppStrings.Home.submitCardButton"].waitForExistence(timeout: .long))
		app.collectionViews.buttons["AppStrings.Home.submitCardButton"].tap()
		XCTAssertTrue(app.staticTexts["AppStrings.ExposureSubmissionDispatch.description"].waitForExistence(timeout: .medium))

		// Select hotline button.
		XCTAssertTrue(app
			.buttons["AppStrings.ExposureSubmissionDispatch.hotlineButtonDescription"]
			.waitForExistence(timeout: .medium)
		)
		app.buttons["AppStrings.ExposureSubmissionDispatch.hotlineButtonDescription"].tap()
		XCTAssertNotNil(app.navigationBars.firstMatch.title)
	}

	func test_QRCodeScanOpened() throws {
		launch()

		// -> Open Intro screen
		XCTAssertTrue(app.collectionViews.buttons["AppStrings.Home.submitCardButton"].waitForExistence(timeout: .long))
		app.collectionViews.buttons["AppStrings.Home.submitCardButton"].tap()
		XCTAssertTrue(app.navigationBars["ExposureSubmissionNavigationController"].waitForExistence(timeout: .medium))

		// Intro screen
		XCTAssertTrue(app.navigationBars["ENA.ExposureSubmissionIntroView"].waitForExistence(timeout: .medium))

		// -> Select QRCode screen.
		XCTAssertTrue(app.buttons["AppStrings.ExposureSubmissionDispatch.qrCodeButtonDescription"].waitForExistence(timeout: .medium))
		app.buttons["AppStrings.ExposureSubmissionDispatch.qrCodeButtonDescription"].tap()

		// QR Code Info Screen
		XCTAssertTrue(app.navigationBars["ENA.ExposureSubmissionQRInfoView"].waitForExistence(timeout: .medium))
		app.buttons["AppStrings.ExposureSubmission.primaryButton"].tap()

		// QR Code Scanner Screen
		XCTAssertTrue(app.navigationBars["ENA.ExposureSubmissionQRScannerView"].waitForExistence(timeout: .medium))
	}
	
	func test_Switch_consentSubmission() {
		app.launchArguments.append(contentsOf: ["-ENStatus", ENStatus.active.stringValue])
		app.launchArguments.append(contentsOf: ["-testResult", TestResult.pending.stringValue])
		launch()
		
		// Open pending test result screen.
		XCTAssertTrue(app.collectionViews.buttons["AppStrings.Home.submitCardButton"].waitForExistence(timeout: .long))
		app.collectionViews.buttons["AppStrings.Home.submitCardButton"].tap()
		XCTAssertTrue(app.staticTexts["AppStrings.ExposureSubmissionResult.procedure"].waitForExistence(timeout: .medium))
		
		// check the consent string is given or not based on the switch state.
		let consentNotGivenCell = app.tables.firstMatch.cells.staticTexts[app.localized("ExposureSubmissionResult_WarnOthersConsentNotGiven")]
		XCTAssertTrue(consentNotGivenCell.waitForExistence(timeout: .medium))
		consentNotGivenCell.tap()
		let consentSwitch = app.switches.firstMatch
		XCTAssertTrue(consentSwitch.waitForExistence(timeout: .medium))
		XCTAssertEqual(consentSwitch.value as? String, "0")
		consentSwitch.tap()
		XCTAssertEqual(consentSwitch.value as? String, "1")
		app.navigationBars["ExposureSubmissionNavigationController"].buttons.element(boundBy: 0).tap()
		
		let consentGivenCell = app.tables.firstMatch.cells.staticTexts[app.localized("ExposureSubmissionResult_WarnOthersConsentGiven")]
		XCTAssertTrue(consentGivenCell.waitForExistence(timeout: .long))
	}
	
	func test_SubmitTAN_SymptomsOptionNo() {
		app.launchArguments.append(contentsOf: ["-ENStatus", ENStatus.active.stringValue])
		app.launchArguments += [UITestingParameters.ExposureSubmission.useMock.rawValue]
		app.launchArguments += [UITestingParameters.ExposureSubmission.loadSupportedCountriesSuccess.rawValue]
		app.launchArguments += [UITestingParameters.ExposureSubmission.getTemporaryExposureKeysSuccess.rawValue]
		app.launchArguments += [UITestingParameters.ExposureSubmission.getRegistrationTokenSuccess.rawValue]
		app.launchArguments += [UITestingParameters.ExposureSubmission.submitExposureSuccess.rawValue]
		launch()
		navigateToSymptomsScreen()

		let optionYes = app.buttons["AppStrings.ExposureSubmissionSymptoms.answerOptionYes"]
		let optionNo = app.buttons["AppStrings.ExposureSubmissionSymptoms.answerOptionNo"]
		let optionPreferNotToSay = app.buttons["AppStrings.ExposureSubmissionSymptoms.answerOptionPreferNotToSay"]

		XCTAssertTrue(optionYes.waitForExistence(timeout: .medium))
		XCTAssertTrue(optionNo.exists)
		XCTAssertTrue(optionPreferNotToSay.exists)

		XCTAssertFalse(optionYes.isSelected)
		XCTAssertFalse(optionNo.isSelected)
		XCTAssertFalse(optionPreferNotToSay.isSelected)

		// continue is disabled?
		let btnContinue = app.buttons["AppStrings.ExposureSubmission.primaryButton"]
		XCTAssertTrue(btnContinue.exists)
		XCTAssertTrue(btnContinue.isHittable)
		XCTAssertFalse(btnContinue.isEnabled)

		// test radio buttons
		optionNo.tap()
		XCTAssertFalse(optionYes.isSelected)
		XCTAssertTrue(optionNo.isSelected)
		XCTAssertFalse(optionPreferNotToSay.isSelected)

		XCTAssertTrue(btnContinue.isEnabled)
		btnContinue.tap()
		
		waitForNonExistence(of: app.buttons["AppStrings.ExposureSubmission.primaryButton"], timeout: .long)
	}

	func test_SubmitTAN_SymptomsOptionPreferNotToSay() {
		app.launchArguments.append(contentsOf: ["-ENStatus", ENStatus.active.stringValue])
		app.launchArguments += [UITestingParameters.ExposureSubmission.useMock.rawValue]
		app.launchArguments += [UITestingParameters.ExposureSubmission.loadSupportedCountriesSuccess.rawValue]
		app.launchArguments += [UITestingParameters.ExposureSubmission.getTemporaryExposureKeysSuccess.rawValue]
		app.launchArguments += [UITestingParameters.ExposureSubmission.getRegistrationTokenSuccess.rawValue]
		app.launchArguments += [UITestingParameters.ExposureSubmission.submitExposureSuccess.rawValue]
		launch()
		navigateToSymptomsScreen()

		let optionYes = app.buttons["AppStrings.ExposureSubmissionSymptoms.answerOptionYes"]
		let optionNo = app.buttons["AppStrings.ExposureSubmissionSymptoms.answerOptionNo"]
		let optionPreferNotToSay = app.buttons["AppStrings.ExposureSubmissionSymptoms.answerOptionPreferNotToSay"]

		XCTAssertTrue(optionYes.waitForExistence(timeout: .medium))
		XCTAssertTrue(optionNo.exists)
		XCTAssertTrue(optionPreferNotToSay.exists)

		XCTAssertFalse(optionYes.isSelected)
		XCTAssertFalse(optionNo.isSelected)
		XCTAssertFalse(optionPreferNotToSay.isSelected)

		// continue is disabled?
		let btnContinue = app.buttons["AppStrings.ExposureSubmission.primaryButton"]
		XCTAssertTrue(btnContinue.exists)
		XCTAssertTrue(btnContinue.isHittable)
		XCTAssertFalse(btnContinue.isEnabled)

		// test radio buttons
		optionPreferNotToSay.tap()
		XCTAssertFalse(optionYes.isSelected)
		XCTAssertFalse(optionNo.isSelected)
		XCTAssertTrue(optionPreferNotToSay.isSelected)

		XCTAssertTrue(btnContinue.isEnabled)
		btnContinue.tap()
		waitForNonExistence(of: app.buttons["AppStrings.ExposureSubmission.primaryButton"], timeout: .long)
	}

	func test_SubmitTAN_SymptomsOnsetDateOption() {
		app.launchArguments.append(contentsOf: ["-ENStatus", ENStatus.active.stringValue])
		app.launchArguments += [UITestingParameters.ExposureSubmission.useMock.rawValue]
		app.launchArguments += [UITestingParameters.ExposureSubmission.loadSupportedCountriesSuccess.rawValue]
		app.launchArguments += [UITestingParameters.ExposureSubmission.getTemporaryExposureKeysSuccess.rawValue]
		app.launchArguments += [UITestingParameters.ExposureSubmission.getRegistrationTokenSuccess.rawValue]
		app.launchArguments += [UITestingParameters.ExposureSubmission.submitExposureSuccess.rawValue]
		launch()
		navigateToSymptomsScreen()

		let optionExactDate = app.buttons["AppStrings.DatePickerOption.day"].firstMatch
		let optionLastSevenDays = app.buttons["AppStrings.ExposureSubmissionSymptomsOnset.answerOptionLastSevenDays"]
		let optionOneToTwoWeeksAgo = app.buttons["AppStrings.ExposureSubmissionSymptomsOnset.answerOptionOneToTwoWeeksAgo"]
		let optionMoreThanTwoWeeksAgo = app.buttons["AppStrings.ExposureSubmissionSymptomsOnset.answerOptionMoreThanTwoWeeksAgo"]
		let optionPreferNotToSay = app.buttons["AppStrings.ExposureSubmissionSymptomsOnset.answerOptionPreferNotToSay"]

		XCTAssertTrue(optionExactDate.waitForExistence(timeout: .medium))
		XCTAssertTrue(optionLastSevenDays.exists)
		XCTAssertTrue(optionOneToTwoWeeksAgo.exists)
		XCTAssertTrue(optionMoreThanTwoWeeksAgo.exists)
		XCTAssertTrue(optionPreferNotToSay.exists)

		XCTAssertFalse(optionExactDate.isSelected)
		XCTAssertFalse(optionLastSevenDays.isSelected)
		XCTAssertFalse(optionOneToTwoWeeksAgo.isSelected)
		XCTAssertFalse(optionMoreThanTwoWeeksAgo.isSelected)
		XCTAssertFalse(optionPreferNotToSay.isSelected)

		// continue is disabled?
		let btnContinue = app.buttons["AppStrings.ExposureSubmission.primaryButton"]
		XCTAssertTrue(btnContinue.exists)
		XCTAssertTrue(btnContinue.isHittable)
		XCTAssertFalse(btnContinue.isEnabled)

		// test radio buttons
		optionExactDate.tap()
		XCTAssertTrue(optionExactDate.isSelected)
		XCTAssertFalse(optionLastSevenDays.isSelected)
		XCTAssertFalse(optionOneToTwoWeeksAgo.isSelected)
		XCTAssertFalse(optionMoreThanTwoWeeksAgo.isSelected)
		XCTAssertFalse(optionPreferNotToSay.isSelected)

		XCTAssertTrue(btnContinue.isEnabled)

		optionLastSevenDays.tap()
		XCTAssertFalse(optionExactDate.isSelected)
		XCTAssertTrue(optionLastSevenDays.isSelected)
		XCTAssertFalse(optionOneToTwoWeeksAgo.isSelected)
		XCTAssertFalse(optionMoreThanTwoWeeksAgo.isSelected)
		XCTAssertFalse(optionPreferNotToSay.isSelected)

		XCTAssertTrue(btnContinue.isEnabled)

		app.swipeUp()

		optionOneToTwoWeeksAgo.tap()
		XCTAssertFalse(optionExactDate.isSelected)
		XCTAssertFalse(optionLastSevenDays.isSelected)
		XCTAssertTrue(optionOneToTwoWeeksAgo.isSelected)
		XCTAssertFalse(optionMoreThanTwoWeeksAgo.isSelected)
		XCTAssertFalse(optionPreferNotToSay.isSelected)

		XCTAssertTrue(btnContinue.isEnabled)

		optionMoreThanTwoWeeksAgo.tap()
		XCTAssertFalse(optionExactDate.isSelected)
		XCTAssertFalse(optionLastSevenDays.isSelected)
		XCTAssertFalse(optionOneToTwoWeeksAgo.isSelected)
		XCTAssertTrue(optionMoreThanTwoWeeksAgo.isSelected)
		XCTAssertFalse(optionPreferNotToSay.isSelected)

		XCTAssertTrue(btnContinue.isEnabled)

		optionPreferNotToSay.tap()
		XCTAssertFalse(optionExactDate.isSelected)
		XCTAssertFalse(optionLastSevenDays.isSelected)
		XCTAssertFalse(optionOneToTwoWeeksAgo.isSelected)
		XCTAssertFalse(optionMoreThanTwoWeeksAgo.isSelected)
		XCTAssertTrue(optionPreferNotToSay.isSelected)

		XCTAssertTrue(btnContinue.isEnabled)
		btnContinue.tap()
		waitForNonExistence(of: app.buttons["AppStrings.ExposureSubmission.primaryButton"], timeout: .long)
	}

	func test_SubmitTAN_CancelOnTestResultScreen() {
		app.launchArguments.append(contentsOf: ["-ENStatus", ENStatus.active.stringValue])
		app.launchArguments += [UITestingParameters.ExposureSubmission.useMock.rawValue]
		app.launchArguments += [UITestingParameters.ExposureSubmission.loadSupportedCountriesSuccess.rawValue]
		app.launchArguments += [UITestingParameters.ExposureSubmission.getTemporaryExposureKeysSuccess.rawValue]
		app.launchArguments += [UITestingParameters.ExposureSubmission.getRegistrationTokenSuccess.rawValue]
		app.launchArguments += [UITestingParameters.ExposureSubmission.submitExposureSuccess.rawValue]
		launch()

		// Start Submission Flow
		XCTAssertTrue(app.collectionViews.buttons["AppStrings.Home.submitCardButton"].waitForExistence(timeout: .long))
		app.collectionViews.buttons["AppStrings.Home.submitCardButton"].tap()

		// Overview Screen: click TAN button.
		XCTAssertTrue(app
			.buttons["AppStrings.ExposureSubmissionDispatch.tanButtonDescription"]
			.waitForExistence(timeout: .medium)
		)
		app.buttons["AppStrings.ExposureSubmissionDispatch.tanButtonDescription"].tap()

		// Fill in dummy TAN.
		XCTAssertTrue(app.buttons["AppStrings.ExposureSubmission.primaryButton"].waitForExistence(timeout: .medium))
		type(app, text: "qwdzxcsrhe")

		// Click continue button.
		XCTAssertTrue(app.buttons["AppStrings.ExposureSubmission.primaryButton"].isEnabled)
		app.buttons["AppStrings.ExposureSubmission.primaryButton"].tap()

		// TAN tests are ALWAYS positive!

		// Click secondary button to skip symptoms screens and immediately go to warn others screen.
		XCTAssertTrue(app.buttons["AppStrings.ExposureSubmission.secondaryButton"].waitForExistence(timeout: .medium))
		app.buttons["AppStrings.ExposureSubmission.secondaryButton"].tap()

		app.alerts["Sie wollen keine Warnung verschicken?"].buttons["Nicht warnen"].tap()
		
		waitForNonExistence(of: app.buttons["AppStrings.ExposureSubmission.primaryButton"], timeout: .long)
		
	}
	
	func test_SubmitTAN_SecondaryFlowWithoutSymptomsScreens() {
		app.launchArguments.append(contentsOf: ["-ENStatus", ENStatus.active.stringValue])
		app.launchArguments += [UITestingParameters.ExposureSubmission.useMock.rawValue]
		app.launchArguments += [UITestingParameters.ExposureSubmission.loadSupportedCountriesSuccess.rawValue]
		app.launchArguments += [UITestingParameters.ExposureSubmission.getTemporaryExposureKeysSuccess.rawValue]
		app.launchArguments += [UITestingParameters.ExposureSubmission.getRegistrationTokenSuccess.rawValue]
		app.launchArguments += [UITestingParameters.ExposureSubmission.submitExposureSuccess.rawValue]
		launch()
		
		// Start Submission Flow
		XCTAssertTrue(app.collectionViews.buttons["AppStrings.Home.submitCardButton"].waitForExistence(timeout: .long))
		app.collectionViews.buttons["AppStrings.Home.submitCardButton"].tap()

		// Overview Screen: click TAN button.
		XCTAssertTrue(app
			.buttons["AppStrings.ExposureSubmissionDispatch.tanButtonDescription"]
			.waitForExistence(timeout: .medium)
		)
		app.buttons["AppStrings.ExposureSubmissionDispatch.tanButtonDescription"].tap()

		// Fill in dummy TAN.
		XCTAssertTrue(app.buttons["AppStrings.ExposureSubmission.primaryButton"].waitForExistence(timeout: .medium))
		type(app, text: "qwdzxcsrhe")

		// Click continue button.
		XCTAssertTrue(app.buttons["AppStrings.ExposureSubmission.primaryButton"].isEnabled)
		app.buttons["AppStrings.ExposureSubmission.primaryButton"].tap()

		// TAN tests are ALWAYS positive!

		// Click secondary button to skip symptoms screens and immediately go to warn others screen.
		XCTAssertTrue(app.buttons["AppStrings.ExposureSubmission.secondaryButton"].waitForExistence(timeout: .medium))
		app.buttons["AppStrings.ExposureSubmission.secondaryButton"].tap()

		app.alerts["Sie wollen keine Warnung verschicken?"].buttons["Warnen"].tap()
		app.buttons["AppStrings.ExposureSubmission.primaryButton"].tap()
		
		XCTAssertTrue(app.navigationBars["ENA.ExposureSubmissionWarnOthersView"].waitForExistence(timeout: .medium))
		app.buttons["AppStrings.ExposureSubmission.primaryButton"].tap()

		XCTAssertTrue(app.navigationBars["ENA.ExposureSubmissionThankYouView"].waitForExistence(timeout: .medium))
		app.buttons["AppStrings.ExposureSubmission.primaryButton"].tap()
	}
	
	func test_screenshot_SubmitTAN() {
		var screenshotCounter = 0

		app.launchArguments.append(contentsOf: ["-ENStatus", ENStatus.active.stringValue])
		app.launchArguments += [UITestingParameters.ExposureSubmission.useMock.rawValue]
		app.launchArguments += [UITestingParameters.ExposureSubmission.getRegistrationTokenSuccess.rawValue]
		app.launchArguments += [UITestingParameters.ExposureSubmission.loadSupportedCountriesSuccess.rawValue]
		app.launchArguments += [UITestingParameters.ExposureSubmission.getTemporaryExposureKeysSuccess.rawValue]
		app.launchArguments += [UITestingParameters.ExposureSubmission.submitExposureSuccess.rawValue]
		launch()
		snapshot("tan_submissionflow_\(String(format: "%04d", (screenshotCounter.inc() )))")
		
		// Open Intro screen.
		XCTAssertTrue(app.collectionViews.buttons["AppStrings.Home.submitCardButton"].waitForExistence(timeout: .long))
		app.collectionViews.buttons["AppStrings.Home.submitCardButton"].tap()
		snapshot("tan_submissionflow_\(String(format: "%04d", (screenshotCounter.inc() )))")
				
		// Overview Screen: click TAN button.
		XCTAssertTrue(app
						.buttons["AppStrings.ExposureSubmissionDispatch.tanButtonDescription"]
						.waitForExistence(timeout: .medium)
		)
		app.buttons["AppStrings.ExposureSubmissionDispatch.tanButtonDescription"].tap()
		snapshot("tan_submissionflow_\(String(format: "%04d", (screenshotCounter.inc() )))")
		
		// Fill in dummy TAN.
		XCTAssertTrue(app.buttons["AppStrings.ExposureSubmission.primaryButton"].waitForExistence(timeout: .medium))
		type(app, text: "qwdzxcsrhe")
		snapshot("tan_submissionflow_\(String(format: "%04d", (screenshotCounter.inc() )))")
		
		// Click continue button.
		XCTAssertTrue(app.buttons["AppStrings.ExposureSubmission.primaryButton"].isEnabled)
		app.buttons["AppStrings.ExposureSubmission.primaryButton"].tap()
		
		// TAN tests are ALWAYS positive!
		
		// Click secondary button to skip symptoms screens and immediately go to warn others screen.
		XCTAssertTrue(app.buttons["AppStrings.ExposureSubmission.secondaryButton"].waitForExistence(timeout: .medium))
		app.buttons["AppStrings.ExposureSubmission.secondaryButton"].tap()
		snapshot("tan_submissionflow_\(String(format: "%04d", (screenshotCounter.inc() )))")
		
		app.alerts["Sie wollen keine Warnung verschicken?"].buttons["Warnen"].tap()
		app.buttons["AppStrings.ExposureSubmission.primaryButton"].tap()
		
		XCTAssertTrue(app.navigationBars["ENA.ExposureSubmissionWarnOthersView"].waitForExistence(timeout: .medium))
		app.buttons["AppStrings.ExposureSubmission.primaryButton"].tap()
		snapshot("tan_submissionflow_\(String(format: "%04d", (screenshotCounter.inc() )))")
		
		XCTAssertTrue(app.navigationBars["ENA.ExposureSubmissionThankYouView"].waitForExistence(timeout: .medium))
		
		app.buttons["AppStrings.ExposureSubmission.primaryButton"].tap()
	}

	func test_screenshot_SubmissionNotPossible() {
		var screenshotCounter = 0

		app.launchArguments.append(contentsOf: ["-ENStatus", ENStatus.disabled.stringValue])
		app.launchArguments += [UITestingParameters.ExposureSubmission.useMock.rawValue]
		app.launchArguments += [UITestingParameters.ExposureSubmission.getRegistrationTokenSuccess.rawValue]
		app.launchArguments += [UITestingParameters.ExposureSubmission.loadSupportedCountriesSuccess.rawValue]
		app.launchArguments += [UITestingParameters.ExposureSubmission.getTemporaryExposureKeysSuccess.rawValue]
		app.launchArguments += [UITestingParameters.ExposureSubmission.submitExposureSuccess.rawValue]
		launch()
		snapshot("tan_submissionflow_\(String(format: "%04d", (screenshotCounter.inc() )))")

		// Open Intro screen.
		XCTAssertTrue(app.collectionViews.buttons["AppStrings.Home.submitCardButton"].waitForExistence(timeout: .long))
		app.collectionViews.buttons["AppStrings.Home.submitCardButton"].tap()

		// Overview Screen: click TAN button.
		XCTAssertTrue(app
						.buttons["AppStrings.ExposureSubmissionDispatch.tanButtonDescription"]
						.waitForExistence(timeout: .medium)
		)
		app.buttons["AppStrings.ExposureSubmissionDispatch.tanButtonDescription"].tap()

		// Fill in dummy TAN.
		XCTAssertTrue(app.buttons["AppStrings.ExposureSubmission.primaryButton"].waitForExistence(timeout: .medium))
		type(app, text: "qwdzxcsrhe")

		// Click continue button.
		XCTAssertTrue(app.buttons["AppStrings.ExposureSubmission.primaryButton"].isEnabled)
		app.buttons["AppStrings.ExposureSubmission.primaryButton"].tap()

		// TAN tests are ALWAYS positive!

		// Click secondary button to skip symptoms screens and immediately go to warn others screen.
		XCTAssertTrue(app.buttons["AppStrings.ExposureSubmission.secondaryButton"].waitForExistence(timeout: .medium))
		app.buttons["AppStrings.ExposureSubmission.secondaryButton"].tap()

		// expect an error dialogue due to disabled exposure notification
		XCTAssertTrue(app.alerts.firstMatch.waitForExistence(timeout: .short))

		snapshot("error_submissionflow_\(String(format: "%04d", (screenshotCounter.inc() )))")
	}
	
	// Navigate to the Thank You screen after getting the positive test result.
	func test_ThankYouScreen_withWarnOthers() {
		app.launchArguments.append(contentsOf: ["-ENStatus", ENStatus.active.stringValue])
		app.launchArguments += [UITestingParameters.ExposureSubmission.useMock.rawValue]
		app.launchArguments += [UITestingParameters.ExposureSubmission.loadSupportedCountriesSuccess.rawValue]
		app.launchArguments += [UITestingParameters.ExposureSubmission.getTemporaryExposureKeysSuccess.rawValue]
		app.launchArguments += [UITestingParameters.ExposureSubmission.getRegistrationTokenSuccess.rawValue]
		app.launchArguments += [UITestingParameters.ExposureSubmission.submitExposureSuccess.rawValue]
		app.launchArguments.append(contentsOf: ["-testResult", TestResult.positive.stringValue])
		launch()
		
		// Open Intro screen.
		XCTAssertTrue(app.collectionViews.buttons["AppStrings.Home.submitCardButton"].waitForExistence(timeout: .long))
		app.collectionViews.buttons["AppStrings.Home.submitCardButton"].tap()
		
		// Open Test Result screen.
		XCTAssertTrue(app.navigationBars["ENA.ExposureSubmissionTestResultView"].waitForExistence(timeout: .medium))
		app.buttons["AppStrings.ExposureSubmission.primaryButton"].tap()
		
		// Open Warn Others screen.
		XCTAssertTrue(app.navigationBars["ENA.ExposureSubmissionWarnOthersView"].waitForExistence(timeout: .medium))
		app.buttons["AppStrings.ExposureSubmission.primaryButton"].tap()

		// Open Thank You screen.
		XCTAssertTrue(app.navigationBars["ENA.ExposureSubmissionThankYouView"].waitForExistence(timeout: .medium))
		app.buttons["AppStrings.ExposureSubmission.primaryButton"].tap()
		app.navigationBars["ExposureSubmissionNavigationController"].buttons.element(boundBy: 0).tap()
		app.buttons["AppStrings.ExposureSubmission.secondaryButton"].tap()
		app.alerts["Wollen Sie die Symptom-Erfassung abbrechen?"].buttons["Nein"].tap()
		app.buttons["AppStrings.ExposureSubmission.secondaryButton"].tap()
		app.alerts["Wollen Sie die Symptom-Erfassung abbrechen?"].buttons["Ja"].tap()
		
		waitForNonExistence(of: app.buttons["AppStrings.ExposureSubmission.primaryButton"], timeout: .long)
		
	}

	// Navigate to the Thank You screen with alert on Test Result Screen.
	func test_ThankYouScreen_WarnOthersFromAlert() {
		app.launchArguments.append(contentsOf: ["-ENStatus", ENStatus.active.stringValue])
		app.launchArguments += [UITestingParameters.ExposureSubmission.useMock.rawValue]
		app.launchArguments += [UITestingParameters.ExposureSubmission.loadSupportedCountriesSuccess.rawValue]
		app.launchArguments += [UITestingParameters.ExposureSubmission.getTemporaryExposureKeysSuccess.rawValue]
		app.launchArguments += [UITestingParameters.ExposureSubmission.getRegistrationTokenSuccess.rawValue]
		app.launchArguments += [UITestingParameters.ExposureSubmission.submitExposureSuccess.rawValue]
		app.launchArguments.append(contentsOf: ["-testResult", TestResult.positive.stringValue])
		launch()
		
		// Open Intro screen.
		XCTAssertTrue(app.collectionViews.buttons["AppStrings.Home.submitCardButton"].waitForExistence(timeout: .long))
		app.collectionViews.buttons["AppStrings.Home.submitCardButton"].tap()
		
		// Open Test Result screen.
		XCTAssertTrue(app.navigationBars["ENA.ExposureSubmissionTestResultView"].waitForExistence(timeout: .medium))
		app.buttons["AppStrings.ExposureSubmission.secondaryButton"].tap()
		
		app.alerts["Sie wollen keine Warnung verschicken?"].buttons["Nicht warnen"].tap()
		waitForNonExistence(of: app.buttons["AppStrings.ExposureSubmission.primaryButton"], timeout: .long)
		app.collectionViews.buttons["AppStrings.Home.submitCardButton"].tap()
		
		XCTAssertTrue(app.navigationBars["ENA.ExposureSubmissionTestResultView"].waitForExistence(timeout: .medium))
		app.buttons["AppStrings.ExposureSubmission.secondaryButton"].tap()
				
		app.alerts["Sie wollen keine Warnung verschicken?"].buttons["Warnen"].tap()
		app.buttons["AppStrings.ExposureSubmission.primaryButton"].tap()
		
		XCTAssertTrue(app.navigationBars["ENA.ExposureSubmissionWarnOthersView"].waitForExistence(timeout: .medium))
		app.buttons["AppStrings.ExposureSubmission.primaryButton"].tap()
		
		XCTAssertTrue(app.navigationBars["ENA.ExposureSubmissionThankYouView"].waitForExistence(timeout: .medium))
		app.buttons["AppStrings.ExposureSubmission.primaryButton"].tap()
		
		app.navigationBars["ExposureSubmissionNavigationController"].buttons.element(boundBy: 0).tap()
		
		app.buttons["AppStrings.ExposureSubmission.secondaryButton"].tap()
		
		app.alerts["Wollen Sie die Symptom-Erfassung abbrechen?"].buttons["Nein"].tap()
		app.buttons["AppStrings.ExposureSubmission.secondaryButton"].tap()
		
		app.alerts["Wollen Sie die Symptom-Erfassung abbrechen?"].buttons["Ja"].tap()
		
		waitForNonExistence(of: app.buttons["AppStrings.ExposureSubmission.primaryButton"], timeout: .long)
		
	}
}

// MARK: - Helpers.

extension ENAUITests_04_ExposureSubmissionUITests {

	private func type(_ app: XCUIApplication, text: String) {
		text.forEach {
			app.keyboards.keys[String($0)].tap()
		}
	}

	/// Launch and wait until the app is ready.
	private func launch() {
		app.launch()
		XCTAssertTrue(app.buttons["AppStrings.Home.rightBarButtonDescription"].waitForExistence(timeout: .long))
	}

	/// Use this method to grab localized strings correctly.
	private func localized(_ string: String) -> String {
		if let path =
			Bundle(for: ENAUITests_04_ExposureSubmissionUITests.self)
				.path(
					forResource: deviceLanguage,
					ofType: "lproj"
			),
			let bundle = Bundle(path: path) {
			return NSLocalizedString(
				string,
				bundle: bundle,
				comment: ""
			)
		}
		fatalError("Localization could not be loaded.")
	}

	func navigateToSymptomsScreen() {
		// Open Intro screen.
		XCTAssertTrue(app.collectionViews.buttons["AppStrings.Home.submitCardButton"].waitForExistence(timeout: .long))
		app.collectionViews.buttons["AppStrings.Home.submitCardButton"].tap()

		// Click TAN button.
		XCTAssertTrue(app
			.buttons["AppStrings.ExposureSubmissionDispatch.tanButtonDescription"]
			.waitForExistence(timeout: .medium)
		)
		app.buttons["AppStrings.ExposureSubmissionDispatch.tanButtonDescription"].tap()

		// Fill in dummy TAN.
		XCTAssertTrue(app.buttons["AppStrings.ExposureSubmission.primaryButton"].waitForExistence(timeout: .medium))
		type(app, text: "qwdzxcsrhe")

		// Click continue button.
		XCTAssertTrue(app.buttons["AppStrings.ExposureSubmission.primaryButton"].isEnabled)
		app.buttons["AppStrings.ExposureSubmission.primaryButton"].tap()
		// TAN tests are ALWAYS positive!

		// Click next.
		XCTAssertTrue(app.buttons["AppStrings.ExposureSubmission.primaryButton"].waitForExistence(timeout: .medium))
		app.buttons["AppStrings.ExposureSubmission.primaryButton"].tap()

		// Click next to warn others.
		XCTAssertTrue(app.buttons["AppStrings.ExposureSubmission.primaryButton"].waitForExistence(timeout: .medium))
		app.buttons["AppStrings.ExposureSubmission.primaryButton"].tap()
		
		// Click next to Symptoms Screen.
		XCTAssertTrue(app.buttons["AppStrings.ExposureSubmission.primaryButton"].waitForExistence(timeout: .medium))
		app.buttons["AppStrings.ExposureSubmission.primaryButton"].tap()
	}

	func navigateToSymptomsOnsetScreen() {
		app.launchArguments.append(contentsOf: ["-ENStatus", ENStatus.active.stringValue])
		navigateToSymptomsScreen()

		let optionYes = app.buttons["AppStrings.ExposureSubmissionSymptoms.answerOptionYes"]

		XCTAssertTrue(optionYes.waitForExistence(timeout: .medium))
		optionYes.tap()

		app.buttons["AppStrings.ExposureSubmission.primaryButton"].tap()
	}

}

extension XCTestCase {
	func waitForNonExistence(of element: XCUIElement, timeout: TimeInterval) {
		let doesNotExistPredicate = NSPredicate(format: "exists == FALSE")
		expectation(for: doesNotExistPredicate, evaluatedWith: element, handler: nil)
		waitForExpectations(timeout: timeout, handler: nil)
	}
}
