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
		XCTAssertTrue(app.cells.buttons[AccessibilityIdentifiers.Home.submitCardButton].waitForExistence(timeout: .long))
		app.cells.buttons[AccessibilityIdentifiers.Home.submitCardButton].tap()

		// Check whether we have entered the info screen.
		XCTAssertTrue(app.images["ExposureSubmissionIntroViewController.image"].waitForExistence(timeout: .medium))
	}

	func test_NavigateToHotlineVC() throws {
		launch()

		// Open Intro screen.
		XCTAssertTrue(app.cells.buttons[AccessibilityIdentifiers.Home.submitCardButton].waitForExistence(timeout: .long))
		app.cells.buttons[AccessibilityIdentifiers.Home.submitCardButton].tap()
		XCTAssertTrue(app.staticTexts["AppStrings.ExposureSubmissionDispatch.description"].waitForExistence(timeout: .medium))

		// Select hotline button.
		XCTAssertTrue(app
			.buttons["AppStrings.ExposureSubmissionDispatch.hotlineButtonDescription"]
			.waitForExistence(timeout: .medium)
		)
		app.buttons["AppStrings.ExposureSubmissionDispatch.hotlineButtonDescription"].tap()
		XCTAssertNotNil(app.navigationBars.firstMatch.title)

		XCTAssertTrue(app.buttons["AppStrings.ExposureSubmissionHotline.callButtonTitle"].waitForExistence(timeout: 2.0))
		XCTAssertTrue(app.buttons["AppStrings.ExposureSubmissionHotline.tanInputButtonTitle"].waitForExistence(timeout: 2.0))
	}

	func test_QRCodeScanOpened() throws {
		launch()

		// -> Open Intro screen
		XCTAssertTrue(app.cells.buttons[AccessibilityIdentifiers.Home.submitCardButton].waitForExistence(timeout: .long))
		app.cells.buttons[AccessibilityIdentifiers.Home.submitCardButton].tap()
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
		XCTAssertTrue(app.cells.buttons[AccessibilityIdentifiers.Home.submitCardButton].waitForExistence(timeout: .long))
		app.cells.buttons[AccessibilityIdentifiers.Home.submitCardButton].tap()
		XCTAssertTrue(app.staticTexts["AppStrings.ExposureSubmissionResult.procedure"].waitForExistence(timeout: .medium))

		let consentNotGivenCell = app.cells[AccessibilityIdentifiers.ExposureSubmissionResult.warnOthersConsentNotGivenCell]
		XCTAssertTrue(consentNotGivenCell.waitForExistence(timeout: .medium))
		
		consentNotGivenCell.tap()
		let consentSwitch = app.switches.firstMatch
		XCTAssertTrue(consentSwitch.waitForExistence(timeout: .medium))
		XCTAssertEqual(consentSwitch.value as? String, "0")
		consentSwitch.tap()
		XCTAssertEqual(consentSwitch.value as? String, "1")
		app.navigationBars["ExposureSubmissionNavigationController"].buttons.element(boundBy: 0).tap()
		
		let consentGivenCell = app.cells[AccessibilityIdentifiers.ExposureSubmissionResult.warnOthersConsentGivenCell]
		XCTAssertTrue(consentGivenCell.waitForExistence(timeout: .long))
	}
	
	func test_SubmitTAN_Screenshot_SymptomsOptionYes() {
		var screenshotCounter = 0
		
		// setting up launch arguments
		app.launchArguments.append(contentsOf: ["-ENStatus", ENStatus.active.stringValue])
		app.launchArguments += [UITestingParameters.ExposureSubmission.useMock.rawValue]
		app.launchArguments += [UITestingParameters.ExposureSubmission.loadSupportedCountriesSuccess.rawValue]
		app.launchArguments += [UITestingParameters.ExposureSubmission.getTemporaryExposureKeysSuccess.rawValue]
		app.launchArguments += [UITestingParameters.ExposureSubmission.getRegistrationTokenSuccess.rawValue]
		app.launchArguments += [UITestingParameters.ExposureSubmission.submitExposureSuccess.rawValue]
		
		// launch and nagivate to the desired screen
		launch()
		navigateToSymptomsScreen()
		
		// capturing and selecting Yes button
		let optionYes = app.buttons["AppStrings.ExposureSubmissionSymptoms.answerOptionYes"]
		optionYes.tap()

		// take snapshot of the selection
		snapshot("tan_submissionflow_symptoms_selection\(String(format: "%04d", (screenshotCounter.inc() )))")
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
		
		// This may fail in future because of the Thank You card. So, just check the home screen
		XCTAssertTrue(app.cells.buttons[AccessibilityIdentifiers.Home.submitCardButton].waitForExistence(timeout: .long))

		// Back to homescreen
		XCTAssertTrue(app.cells.buttons[AccessibilityIdentifiers.Home.submitCardButton].waitForExistence(timeout: .long))
		XCTAssertTrue(app.cells.buttons[AccessibilityIdentifiers.Home.submitCardButton].isHittable)
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
		
		// This button ID might fail in future versions because of the to be added 'Thank You' card.
		// Currently UI tests CURRENTLY don't reflect the correct UI state after this test.
		// 'Thank You' should be visible and is expected in non-ui tests!
		let thankYouCardID = AccessibilityIdentifiers.Home.submitCardButton
		XCTAssertTrue(app.cells.buttons[thankYouCardID].waitForExistence(timeout: .long))
		XCTAssertTrue(app.cells.buttons[thankYouCardID].isHittable)
	}

	func test_SubmitTAN_SymptomsOnsetDateOption() {
		app.launchArguments.append(contentsOf: ["-ENStatus", ENStatus.active.stringValue])
		app.launchArguments += [UITestingParameters.ExposureSubmission.useMock.rawValue]
		app.launchArguments += [UITestingParameters.ExposureSubmission.loadSupportedCountriesSuccess.rawValue]
		app.launchArguments += [UITestingParameters.ExposureSubmission.getTemporaryExposureKeysSuccess.rawValue]
		app.launchArguments += [UITestingParameters.ExposureSubmission.getRegistrationTokenSuccess.rawValue]
		app.launchArguments += [UITestingParameters.ExposureSubmission.submitExposureSuccess.rawValue]
		launch()
		navigateToSymptomsOnsetScreen()

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
		
		// This may fail in future because of the Thank You card. So, just check the home screen
		XCTAssertTrue(app.cells.buttons[AccessibilityIdentifiers.Home.submitCardButton].waitForExistence(timeout: .long))
		XCTAssertTrue(app.cells.buttons[AccessibilityIdentifiers.Home.submitCardButton].isHittable)
	}

	func test_SubmitTAN_CancelOnTestResultScreen() {
		app.launchArguments.append(contentsOf: ["-ENStatus", ENStatus.active.stringValue])
		app.launchArguments += [UITestingParameters.ExposureSubmission.useMock.rawValue]
		app.launchArguments += [UITestingParameters.ExposureSubmission.loadSupportedCountriesSuccess.rawValue]
		app.launchArguments += [UITestingParameters.ExposureSubmission.getTemporaryExposureKeysSuccess.rawValue]
		app.launchArguments += [UITestingParameters.ExposureSubmission.getRegistrationTokenSuccess.rawValue]
		app.launchArguments += [UITestingParameters.ExposureSubmission.submitExposureSuccess.rawValue]
		launch()

		// monitor system dialogues and use default handler to simply dismiss any alert – we don't care for the result
		// see https://developer.apple.com/videos/play/wwdc2020/10220/
		addUIInterruptionMonitor(withDescription: "System Dialog") { _ -> Bool in
			return false
		}

		// Start Submission Flow
		XCTAssertTrue(app.cells.buttons[AccessibilityIdentifiers.Home.submitCardButton].waitForExistence(timeout: .long))
		app.cells.buttons[AccessibilityIdentifiers.Home.submitCardButton].tap()

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

		// don't warn
		app.alerts.firstMatch.buttons[AccessibilityIdentifiers.General.defaultButton].tap()

		// Back to homescreen
		XCTAssertTrue(app.cells.buttons[AccessibilityIdentifiers.Home.submitCardButton].waitForExistence(timeout: .long))
		XCTAssertTrue(app.cells.buttons[AccessibilityIdentifiers.Home.submitCardButton].isHittable)
	}
	
	func test_SubmitTAN_SecondaryFlowWithoutSymptomsScreens() {
		app.launchArguments.append(contentsOf: ["-ENStatus", ENStatus.active.stringValue])
		app.launchArguments += [UITestingParameters.ExposureSubmission.useMock.rawValue]
		app.launchArguments += [UITestingParameters.ExposureSubmission.loadSupportedCountriesSuccess.rawValue]
		app.launchArguments += [UITestingParameters.ExposureSubmission.getTemporaryExposureKeysSuccess.rawValue]
		app.launchArguments += [UITestingParameters.ExposureSubmission.getRegistrationTokenSuccess.rawValue]
		app.launchArguments += [UITestingParameters.ExposureSubmission.submitExposureSuccess.rawValue]
		launch()

		// monitor system dialogues and use default handler to simply dismiss any alert – we don't care for the result
		// see https://developer.apple.com/videos/play/wwdc2020/10220/
		addUIInterruptionMonitor(withDescription: "System Dialog") { _ -> Bool in
			return false
		}
		
		// Start Submission Flow
		XCTAssertTrue(app.cells.buttons[AccessibilityIdentifiers.Home.submitCardButton].waitForExistence(timeout: .long))
		app.cells.buttons[AccessibilityIdentifiers.Home.submitCardButton].tap()

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

		// monitor system dialogues and use default handler to simply dismiss any alert – we don't care for the result
		addUIInterruptionMonitor(withDescription: "System Dialog") { _ -> Bool in
			return false
		}

		snapshot("tan_submissionflow_\(String(format: "%04d", (screenshotCounter.inc() )))")
		
		// Open Intro screen.
		XCTAssertTrue(app.cells.buttons[AccessibilityIdentifiers.Home.submitCardButton].waitForExistence(timeout: .long))
		app.cells.buttons[AccessibilityIdentifiers.Home.submitCardButton].tap()
		snapshot("tan_submissionflow_tan_\(String(format: "%04d", (screenshotCounter.inc() )))")
				
		// Overview Screen: click TAN button.
		XCTAssertTrue(app
						.buttons["AppStrings.ExposureSubmissionDispatch.tanButtonDescription"]
						.waitForExistence(timeout: .medium)
		)
		app.buttons["AppStrings.ExposureSubmissionDispatch.tanButtonDescription"].tap()
		snapshot("tan_submissionflow_tan_\(String(format: "%04d", (screenshotCounter.inc() )))")
		
		// Fill in dummy TAN.
		XCTAssertTrue(app.buttons["AppStrings.ExposureSubmission.primaryButton"].waitForExistence(timeout: .medium))
		type(app, text: "qwdzxcsrhe")
		snapshot("tan_submissionflow_tan_\(String(format: "%04d", (screenshotCounter.inc() )))")
		
		// Click continue button.
		XCTAssertTrue(app.buttons["AppStrings.ExposureSubmission.primaryButton"].isEnabled)
		app.buttons["AppStrings.ExposureSubmission.primaryButton"].tap()
		
		// TAN tests are ALWAYS positive!
		
		// Click secondary button to skip symptoms screens and immediately go to warn others screen.
		XCTAssertTrue(app.buttons["AppStrings.ExposureSubmission.secondaryButton"].waitForExistence(timeout: .medium))
		app.buttons["AppStrings.ExposureSubmission.secondaryButton"].tap()
		snapshot("tan_submissionflow_tan_\(String(format: "%04d", (screenshotCounter.inc() )))")

		app.buttons["AppStrings.ExposureSubmission.primaryButton"].tap()
		
		XCTAssertTrue(app.navigationBars["ENA.ExposureSubmissionWarnOthersView"].waitForExistence(timeout: .medium))
		app.buttons["AppStrings.ExposureSubmission.primaryButton"].tap()
		snapshot("tan_submissionflow_tan_\(String(format: "%04d", (screenshotCounter.inc() )))")
		
		XCTAssertTrue(app.navigationBars["ENA.ExposureSubmissionThankYouView"].waitForExistence(timeout: .medium))
		
		app.buttons["AppStrings.ExposureSubmission.primaryButton"].tap()
	}

	func test_screenshot_SubmitQR() {
		var screenshotCounter = 0

		app.launchArguments.append(contentsOf: ["-ENStatus", ENStatus.active.stringValue])
		app.launchArguments += [UITestingParameters.ExposureSubmission.useMock.rawValue]
		app.launchArguments += [UITestingParameters.ExposureSubmission.getRegistrationTokenSuccess.rawValue]
		app.launchArguments += [UITestingParameters.ExposureSubmission.loadSupportedCountriesSuccess.rawValue]
		app.launchArguments += [UITestingParameters.ExposureSubmission.getTemporaryExposureKeysSuccess.rawValue]
		app.launchArguments += [UITestingParameters.ExposureSubmission.submitExposureSuccess.rawValue]

		if #available(iOS 13.4, *) {
			app.resetAuthorizationStatus(for: .camera)
		}
		launch()

		// monitor system dialogues and use default handler to simply dismiss any alert – we don't care for the result
		// see https://developer.apple.com/videos/play/wwdc2020/10220/
		addUIInterruptionMonitor(withDescription: "System Dialog") { _ -> Bool in
			return false
		}

		snapshot("tan_submissionflow_\(String(format: "%04d", (screenshotCounter.inc() )))")

		// Open Intro screen.
		XCTAssertTrue(app.cells.buttons[AccessibilityIdentifiers.Home.submitCardButton].waitForExistence(timeout: .long))
		app.cells.buttons[AccessibilityIdentifiers.Home.submitCardButton].tap()
		snapshot("tan_submissionflow_qr_\(String(format: "%04d", (screenshotCounter.inc() )))")

		// Overview Screen: click TAN button.
		XCTAssertTrue(app
			.buttons["AppStrings.ExposureSubmissionDispatch.qrCodeButtonDescription"]
			.waitForExistence(timeout: .medium)
		)
		app.buttons["AppStrings.ExposureSubmissionDispatch.qrCodeButtonDescription"].tap()

		// QR Info screen
		snapshot("tan_submissionflow_qr_\(String(format: "%04d", (screenshotCounter.inc() )))")
		// "Einverstanden"
		XCTAssertTrue(app.buttons["AppStrings.ExposureSubmission.primaryButton"].waitForExistence(timeout: .medium))
		app.buttons["AppStrings.ExposureSubmission.primaryButton"].tap()

		// QR view
		// fake tap to trigger interruption handler in case of privacy alerts
		let flashButton = app.buttons["AppStrings.ExposureSubmissionQRScanner.flash"]
		if flashButton.waitForExistence(timeout: .long) {
			flashButton.tap()
		}
		snapshot("tan_submissionflow_qr_\(String(format: "%04d", (screenshotCounter.inc() )))")
	}

	func test_screenshot_SubmissionNotPossible() throws {
		try XCTSkipIf(Locale.current.identifier == "bg_BG") // temporary hack!
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
		XCTAssertTrue(app.cells.buttons[AccessibilityIdentifiers.Home.submitCardButton].waitForExistence(timeout: .long))
		app.cells.buttons[AccessibilityIdentifiers.Home.submitCardButton].tap()

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
		XCTAssertTrue(app.cells.buttons[AccessibilityIdentifiers.Home.submitCardButton].waitForExistence(timeout: .long))
		app.cells.buttons[AccessibilityIdentifiers.Home.submitCardButton].tap()
		
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
		// quick hack - can't easily use `addUIInterruptionMonitor` in this test
		app.alerts.firstMatch.buttons.element(boundBy: 1).tap() // no
		app.buttons["AppStrings.ExposureSubmission.secondaryButton"].tap()
		// quick hack - can't easily use `addUIInterruptionMonitor` in this test
		app.alerts.firstMatch.buttons.firstMatch.tap() // no
		
		// Back to homescreen
		XCTAssertTrue(app.cells.buttons[AccessibilityIdentifiers.Home.submitCardButton].waitForExistence(timeout: .long))
		XCTAssertTrue(app.cells.buttons[AccessibilityIdentifiers.Home.submitCardButton].isHittable)
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
		XCTAssertTrue(app.cells.buttons[AccessibilityIdentifiers.Home.submitCardButton].waitForExistence(timeout: .long))
		app.cells.buttons[AccessibilityIdentifiers.Home.submitCardButton].tap()
		
		// Open Test Result screen.
		XCTAssertTrue(app.navigationBars["ENA.ExposureSubmissionTestResultView"].waitForExistence(timeout: .medium))
		app.buttons["AppStrings.ExposureSubmission.secondaryButton"].tap()

		// quick hack - can't easily use `addUIInterruptionMonitor` in this test
		app.alerts.firstMatch.buttons.element(boundBy: 1).tap() // don't warn

		// Back to homescreen
		XCTAssertTrue(app.cells.buttons[AccessibilityIdentifiers.Home.submitCardButton].waitForExistence(timeout: .long))

		app.cells.buttons[AccessibilityIdentifiers.Home.submitCardButton].tap()
		
		XCTAssertTrue(app.navigationBars["ENA.ExposureSubmissionTestResultView"].waitForExistence(timeout: .medium))
		app.buttons["AppStrings.ExposureSubmission.secondaryButton"].tap()
				
		// quick hack - can't easily use `addUIInterruptionMonitor` in this test
		app.alerts.firstMatch.buttons[AccessibilityIdentifiers.General.cancelButton].tap()
		app.buttons["AppStrings.ExposureSubmission.primaryButton"].tap()
		
		XCTAssertTrue(app.navigationBars["ENA.ExposureSubmissionWarnOthersView"].waitForExistence(timeout: .medium))
		app.buttons["AppStrings.ExposureSubmission.primaryButton"].tap()
		
		XCTAssertTrue(app.navigationBars["ENA.ExposureSubmissionThankYouView"].waitForExistence(timeout: .medium))
		app.buttons["AppStrings.ExposureSubmission.primaryButton"].tap()
		
		app.navigationBars["ExposureSubmissionNavigationController"].buttons.element(boundBy: 0).tap()
		
		app.buttons["AppStrings.ExposureSubmission.secondaryButton"].tap()

		// quick hack - can't easily use `addUIInterruptionMonitor` in this test
		app.alerts.firstMatch.buttons.element(boundBy: 1).tap() // no
		app.buttons["AppStrings.ExposureSubmission.secondaryButton"].tap()

		// quick hack - can't easily use `addUIInterruptionMonitor` in this test
		app.alerts.firstMatch.buttons.firstMatch.tap() // yes

		// Back to homescreen
		XCTAssertTrue(app.cells.buttons[AccessibilityIdentifiers.Home.submitCardButton].waitForExistence(timeout: .long))
		XCTAssertTrue(app.cells.buttons[AccessibilityIdentifiers.Home.submitCardButton].isHittable)
	}
	
	func test_screenshot_test_result_available() {
		app.launchArguments.append(contentsOf: ["-ENStatus", ENStatus.active.stringValue])
		app.launchArguments += [UITestingParameters.ExposureSubmission.useMock.rawValue]
		app.launchArguments += [UITestingParameters.ExposureSubmission.loadSupportedCountriesSuccess.rawValue]
		app.launchArguments += [UITestingParameters.ExposureSubmission.getTemporaryExposureKeysSuccess.rawValue]
		app.launchArguments += [UITestingParameters.ExposureSubmission.getRegistrationTokenSuccess.rawValue]
		app.launchArguments += [UITestingParameters.ExposureSubmission.submitExposureSuccess.rawValue]
		app.launchArguments.append(contentsOf: ["-testResult", TestResult.positive.stringValue])
		app.launchArguments.append(contentsOf: ["-showTestResultAvailableViewController", "YES"])
		launch()

		// Open test result available screen.
		XCTAssertTrue(app.cells.buttons[AccessibilityIdentifiers.Home.submitCardButton].waitForExistence(timeout: .long))
		app.cells.buttons[AccessibilityIdentifiers.Home.submitCardButton].tap()
		XCTAssertTrue(app.navigationBars["ENA.TestResultAvailableView"].waitForExistence(timeout: .long))

		snapshot("submissionflow_screenshot_test_result_available")
	}

	func test_screenshot_test_result_pending() {
		app.launchArguments.append(contentsOf: ["-ENStatus", ENStatus.active.stringValue])
		app.launchArguments.append(contentsOf: ["-testResult", TestResult.pending.stringValue])
		launch()

		// Open test result screen.
		XCTAssertTrue(app.cells.buttons[AccessibilityIdentifiers.Home.submitCardButton].waitForExistence(timeout: .long))
		app.cells.buttons[AccessibilityIdentifiers.Home.submitCardButton].tap()
		XCTAssertTrue(app.staticTexts["AppStrings.ExposureSubmissionResult.procedure"].waitForExistence(timeout: .medium))

		snapshot("submissionflow_screenshot_test_result_pending")
	}

	func test_screenshot_test_result_negative() {
		app.launchArguments.append(contentsOf: ["-ENStatus", ENStatus.active.stringValue])
		app.launchArguments.append(contentsOf: ["-testResult", TestResult.negative.stringValue])
		launch()

		// Open test result screen.
		XCTAssertTrue(app.cells.buttons[AccessibilityIdentifiers.Home.submitCardButton].waitForExistence(timeout: .long))
		app.cells.buttons[AccessibilityIdentifiers.Home.submitCardButton].tap()
		XCTAssertTrue(app.staticTexts["AppStrings.ExposureSubmissionResult.procedure"].waitForExistence(timeout: .medium))

		snapshot("submissionflow_screenshot_test_result_negative")
	}

	func test_screenshot_test_result_positive() {
		app.launchArguments.append(contentsOf: ["-ENStatus", ENStatus.active.stringValue])
		app.launchArguments.append(contentsOf: ["-isSubmissionConsentGiven", "YES"])
		app.launchArguments.append(contentsOf: ["-testResult", TestResult.positive.stringValue])
		launch()

		// Open test result screen.
		XCTAssertTrue(app.cells.buttons[AccessibilityIdentifiers.Home.submitCardButton].waitForExistence(timeout: .long))
		app.cells.buttons[AccessibilityIdentifiers.Home.submitCardButton].tap()
		XCTAssertTrue(app.navigationBars["ENA.ExposureSubmissionTestResultView"].waitForExistence(timeout: .medium))

		snapshot("submissionflow_screenshot_test_result_positive_constent_given")
	}

	func test_screenshot_symptoms_onset_date_option() {
		app.launchArguments.append(contentsOf: ["-ENStatus", ENStatus.active.stringValue])
		app.launchArguments += [UITestingParameters.ExposureSubmission.useMock.rawValue]
		app.launchArguments += [UITestingParameters.ExposureSubmission.loadSupportedCountriesSuccess.rawValue]
		app.launchArguments += [UITestingParameters.ExposureSubmission.getTemporaryExposureKeysSuccess.rawValue]
		app.launchArguments += [UITestingParameters.ExposureSubmission.getRegistrationTokenSuccess.rawValue]
		app.launchArguments += [UITestingParameters.ExposureSubmission.submitExposureSuccess.rawValue]
		launch()
		navigateToSymptomsOnsetScreen()

		// select date
		let optionExactDate = app.buttons["AppStrings.DatePickerOption.day"].firstMatch
		optionExactDate.tap()

		snapshot("submissionflow_screenshot_symptoms_onset_date_option")
	}

	func test_screenshot_thankyou_screen() {
		app.launchArguments.append(contentsOf: ["-ENStatus", ENStatus.active.stringValue])
		app.launchArguments += [UITestingParameters.ExposureSubmission.useMock.rawValue]
		app.launchArguments += [UITestingParameters.ExposureSubmission.loadSupportedCountriesSuccess.rawValue]
		app.launchArguments += [UITestingParameters.ExposureSubmission.getTemporaryExposureKeysSuccess.rawValue]
		app.launchArguments += [UITestingParameters.ExposureSubmission.getRegistrationTokenSuccess.rawValue]
		app.launchArguments += [UITestingParameters.ExposureSubmission.submitExposureSuccess.rawValue]
		app.launchArguments.append(contentsOf: ["-testResult", TestResult.positive.stringValue])
		launch()

		// Open Intro screen.
		XCTAssertTrue(app.cells.buttons[AccessibilityIdentifiers.Home.submitCardButton].waitForExistence(timeout: .long))
		app.cells.buttons[AccessibilityIdentifiers.Home.submitCardButton].tap()

		// Open Test Result screen.
		XCTAssertTrue(app.navigationBars["ENA.ExposureSubmissionTestResultView"].waitForExistence(timeout: .medium))
		app.buttons["AppStrings.ExposureSubmission.primaryButton"].tap()

		// Open Warn Others screen.
		XCTAssertTrue(app.navigationBars["ENA.ExposureSubmissionWarnOthersView"].waitForExistence(timeout: .medium))
		app.buttons["AppStrings.ExposureSubmission.primaryButton"].tap()

		// Open Thank You screen.
		XCTAssertTrue(app.navigationBars["ENA.ExposureSubmissionThankYouView"].waitForExistence(timeout: .medium))

		snapshot("submissionflow_screenshot_thank_you_screen")

		app.buttons["AppStrings.ExposureSubmission.secondaryButton"].tap()
		app.alerts.firstMatch.buttons.element(boundBy: 0).tap()

		// Back to homescreen
		XCTAssertTrue(app.cells.buttons[AccessibilityIdentifiers.Home.submitCardButton].waitForExistence(timeout: .long))
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
		XCTAssertTrue(app.buttons[AccessibilityIdentifiers.Home.rightBarButtonDescription].waitForExistence(timeout: .long))
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
		XCTAssertTrue(app.cells.buttons[AccessibilityIdentifiers.Home.submitCardButton].waitForExistence(timeout: .long))
		app.cells.buttons[AccessibilityIdentifiers.Home.submitCardButton].tap()

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
