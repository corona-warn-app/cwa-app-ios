//
// 🦠 Corona-Warn-App
//

import XCTest
import ExposureNotification

// swiftlint:disable file_length
// swiftlint:disable:next type_body_length
class ENAUITests_04a_ExposureSubmission: XCTestCase {

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

		// Check that no unconfigured test result cells exist
		XCTAssertFalse(app.cells.buttons[AccessibilityIdentifiers.Home.TestResultCell.unconfiguredButton].exists)

		// Click submit card.
		app.cells.buttons[AccessibilityIdentifiers.Home.submitCardButton].waitAndTap()

		// Check whether we have entered the info screen.
		XCTAssertTrue(app.images["ExposureSubmissionIntroViewController.image"].waitForExistence(timeout: .medium))
	}

	func test_QRCodeScanOpened() throws {
		launch()

		// -> Open Intro screen
		app.cells.buttons[AccessibilityIdentifiers.Home.submitCardButton].waitAndTap()
		XCTAssertTrue(app.navigationBars["ExposureSubmissionNavigationController"].waitForExistence(timeout: .medium))

		// Intro screen
		XCTAssertTrue(app.navigationBars["ENA.ExposureSubmissionIntroView"].waitForExistence(timeout: .medium))

		// -> Select QRCode screen.
		app.buttons["AppStrings.ExposureSubmissionDispatch.qrCodeButtonDescription"].waitAndTap()

		// QR Code Info Screen
		XCTAssertTrue(app.navigationBars["ExposureSubmissionNavigationController"].waitForExistence(timeout: .medium))
		app.buttons["AppStrings.ExposureSubmission.primaryButton"].waitAndTap()

		// QR Code Scanner Screen
		XCTAssertTrue(app.navigationBars["ExposureSubmissionNavigationController"].waitForExistence(timeout: .medium))
	}
	
	func test_Switch_consentSubmission() {
		app.launchArguments.append(contentsOf: ["-ENStatus", ENStatus.active.stringValue])
		app.launchArguments.append(contentsOf: ["-pcrTestResult", TestResult.pending.stringValue])
		launch()
		
		// Open pending test result screen.
		app.cells.buttons[AccessibilityIdentifiers.Home.TestResultCell.pendingPCRButton].waitAndTap()
		XCTAssertTrue(app.staticTexts["AppStrings.ExposureSubmissionResult.procedure"].waitForExistence(timeout: .medium))

		app.cells[AccessibilityIdentifiers.ExposureSubmissionResult.warnOthersConsentNotGivenCell].waitAndTap()
		
		let consentSwitch = app.switches.firstMatch
		XCTAssertTrue(consentSwitch.waitForExistence(timeout: .medium))
		XCTAssertEqual(consentSwitch.value as? String, "0")
		consentSwitch.waitAndTap()
		XCTAssertEqual(consentSwitch.value as? String, "1")
		app.navigationBars["ExposureSubmissionNavigationController"].buttons.element(boundBy: 0).waitAndTap()
		
		let consentGivenCell = app.cells[AccessibilityIdentifiers.ExposureSubmissionResult.warnOthersConsentGivenCell]
		XCTAssertTrue(consentGivenCell.waitForExistence(timeout: .long))
	}
	
	func test_SymptomsOptionNo() {
		launchAndNavigateToSymptomsScreen()

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
		optionNo.waitAndTap()
		XCTAssertFalse(optionYes.isSelected)
		XCTAssertTrue(optionNo.isSelected)
		XCTAssertFalse(optionPreferNotToSay.isSelected)

		XCTAssertTrue(btnContinue.isEnabled)
		btnContinue.waitAndTap()
		
		// We should see now the exposureSubmissionSuccessViewController
		XCTAssertTrue(app.images[AccessibilityIdentifiers.ExposureSubmissionSuccess.accImageDescription].waitForExistence(timeout: .short))
		app.buttons[AccessibilityIdentifiers.ExposureSubmissionSuccess.closeButton].waitAndTap()
		
		// Back to homescreen
		XCTAssertTrue(app.cells[AccessibilityIdentifiers.Home.activateCardOnTitle].waitForExistence(timeout: .long))
		XCTAssertTrue(app.cells[AccessibilityIdentifiers.Home.activateCardOnTitle].isHittable)
	}

	func test_SymptomsOptionPreferNotToSay() {
		launchAndNavigateToSymptomsScreen()

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
		optionPreferNotToSay.waitAndTap()
		XCTAssertFalse(optionYes.isSelected)
		XCTAssertFalse(optionNo.isSelected)
		XCTAssertTrue(optionPreferNotToSay.isSelected)

		XCTAssertTrue(btnContinue.isEnabled)
		btnContinue.waitAndTap()
		
		// We should see now the exposureSubmissionSuccessViewController
		XCTAssertTrue(app.images[AccessibilityIdentifiers.ExposureSubmissionSuccess.accImageDescription].waitForExistence(timeout: .short))
		app.buttons[AccessibilityIdentifiers.ExposureSubmissionSuccess.closeButton].waitAndTap()
		
		// Back to homescreen
		XCTAssertTrue(app.cells[AccessibilityIdentifiers.Home.activateCardOnTitle].waitForExistence(timeout: .long))
		XCTAssertTrue(app.cells[AccessibilityIdentifiers.Home.activateCardOnTitle].isHittable)
	}

	func test_SymptomsOnsetDateOption() {
		launchAndNavigateToSymptomsOnsetScreen()

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
		optionExactDate.waitAndTap()
		XCTAssertTrue(optionExactDate.isSelected)
		XCTAssertFalse(optionLastSevenDays.isSelected)
		XCTAssertFalse(optionOneToTwoWeeksAgo.isSelected)
		XCTAssertFalse(optionMoreThanTwoWeeksAgo.isSelected)
		XCTAssertFalse(optionPreferNotToSay.isSelected)
		
		XCTAssertTrue(btnContinue.isEnabled)

		optionLastSevenDays.waitAndTap()
		XCTAssertFalse(optionExactDate.isSelected)
		XCTAssertTrue(optionLastSevenDays.isSelected)
		XCTAssertFalse(optionOneToTwoWeeksAgo.isSelected)
		XCTAssertFalse(optionMoreThanTwoWeeksAgo.isSelected)
		XCTAssertFalse(optionPreferNotToSay.isSelected)

		XCTAssertTrue(btnContinue.isEnabled)

		app.swipeUp()

		optionOneToTwoWeeksAgo.waitAndTap()
		XCTAssertFalse(optionExactDate.isSelected)
		XCTAssertFalse(optionLastSevenDays.isSelected)
		XCTAssertTrue(optionOneToTwoWeeksAgo.isSelected)
		XCTAssertFalse(optionMoreThanTwoWeeksAgo.isSelected)
		XCTAssertFalse(optionPreferNotToSay.isSelected)

		XCTAssertTrue(btnContinue.isEnabled)

		optionMoreThanTwoWeeksAgo.waitAndTap()
		XCTAssertFalse(optionExactDate.isSelected)
		XCTAssertFalse(optionLastSevenDays.isSelected)
		XCTAssertFalse(optionOneToTwoWeeksAgo.isSelected)
		XCTAssertTrue(optionMoreThanTwoWeeksAgo.isSelected)
		XCTAssertFalse(optionPreferNotToSay.isSelected)

		XCTAssertTrue(btnContinue.isEnabled)

		optionPreferNotToSay.waitAndTap()
		XCTAssertFalse(optionExactDate.isSelected)
		XCTAssertFalse(optionLastSevenDays.isSelected)
		XCTAssertFalse(optionOneToTwoWeeksAgo.isSelected)
		XCTAssertFalse(optionMoreThanTwoWeeksAgo.isSelected)
		XCTAssertTrue(optionPreferNotToSay.isSelected)

		XCTAssertTrue(btnContinue.isEnabled)
		btnContinue.waitAndTap()
		
		// We should see now the exposureSubmissionSuccessViewController
		XCTAssertTrue(app.images[AccessibilityIdentifiers.ExposureSubmissionSuccess.accImageDescription].waitForExistence(timeout: .short))
		app.buttons[AccessibilityIdentifiers.ExposureSubmissionSuccess.closeButton].waitAndTap()
		
		// Back to homescreen
		XCTAssertTrue(app.cells[AccessibilityIdentifiers.Home.activateCardOnTitle].waitForExistence(timeout: .long))
		XCTAssertTrue(app.cells[AccessibilityIdentifiers.Home.activateCardOnTitle].isHittable)

	}

	func test_SubmitTAN_CancelOnTestResultScreen() {
		app.launchArguments.append(contentsOf: ["-ENStatus", ENStatus.active.stringValue])
		launch()

		// monitor system dialogues and use default handler to simply dismiss any alert – we don't care for the result
		// see https://developer.apple.com/videos/play/wwdc2020/10220/
		addUIInterruptionMonitor(withDescription: "System Dialog") { _ -> Bool in
			return false
		}

		// Start Submission Flow
		app.cells.buttons[AccessibilityIdentifiers.Home.submitCardButton].waitAndTap()

		// Overview Screen: click TAN button.
		app.buttons["AppStrings.ExposureSubmissionDispatch.tanButtonDescription"].waitAndTap()

		let continueButton = app.buttons[AccessibilityIdentifiers.ExposureSubmission.primaryButton]
		XCTAssertTrue(continueButton.waitForExistence(timeout: .medium))
		XCTAssertFalse(continueButton.isEnabled)

		// Fill in dummy TAN.
		type(app, text: "qwdzxcsrhe")

		// Click continue button.
		XCTAssertTrue(continueButton.isEnabled)
		continueButton.waitAndTap()

		// TAN tests are ALWAYS positive!
		
		app.buttons[AccessibilityIdentifiers.ExposureSubmissionTestResultAvailable.primaryButton].waitAndTap()

		// Click secondary button to skip symptoms screens and immediately go to warn others screen.
		app.buttons["AppStrings.ExposureSubmission.secondaryButton"].waitAndTap()

		// don't warn
		app.alerts.firstMatch.buttons[AccessibilityIdentifiers.General.defaultButton].waitAndTap()

		// Back to homescreen
		XCTAssertTrue(app.cells[AccessibilityIdentifiers.Home.activateCardOnTitle].waitForExistence(timeout: .long))
		XCTAssertTrue(app.cells[AccessibilityIdentifiers.Home.activateCardOnTitle].isHittable)
	}
	
	func test_SubmitTAN_SecondaryFlowWithoutSymptomsScreens() {
		app.launchArguments.append(contentsOf: ["-ENStatus", ENStatus.active.stringValue])
		launch()

		// monitor system dialogues and use default handler to simply dismiss any alert – we don't care for the result
		// see https://developer.apple.com/videos/play/wwdc2020/10220/
		addUIInterruptionMonitor(withDescription: "System Dialog") { _ -> Bool in
			return false
		}
		
		// Start Submission Flow
		app.cells.buttons[AccessibilityIdentifiers.Home.submitCardButton].waitAndTap(.long)

		// Overview Screen: click TAN button.

		app.buttons[AccessibilityIdentifiers.ExposureSubmissionDispatch.tanButtonDescription].waitAndTap()
		
		let continueButton = app.buttons[AccessibilityIdentifiers.ExposureSubmission.primaryButton]
		XCTAssertTrue(continueButton.waitForExistence(timeout: .medium))
		XCTAssertFalse(continueButton.isEnabled)

		// Fill in dummy TAN.
		type(app, text: "qwdzxcsrhe")

		// Click continue button.

		XCTAssertTrue(continueButton.isEnabled)
		app.buttons[AccessibilityIdentifiers.ExposureSubmission.primaryButton].waitAndTap()
		
		// TAN tests are ALWAYS positive!

		app.buttons[AccessibilityIdentifiers.ExposureSubmissionTestResultAvailable.primaryButton].waitAndTap()
		
		// Click secondary button to skip symptoms screens and immediately go to warn others screen.

		app.buttons[AccessibilityIdentifiers.ExposureSubmission.secondaryButton].waitAndTap()
		
		app.buttons[AccessibilityIdentifiers.ExposureSubmission.primaryButton].waitAndTap()
		
		XCTAssertTrue(app.navigationBars[AccessibilityIdentifiers.General.exposureSubmissionNavigationControllerTitle].waitForExistence(timeout: .medium))
		app.buttons[AccessibilityIdentifiers.ExposureSubmission.primaryButton].waitAndTap()

		XCTAssertTrue(app.navigationBars[AccessibilityIdentifiers.General.exposureSubmissionNavigationControllerTitle].waitForExistence(timeout: .medium))
		app.buttons[AccessibilityIdentifiers.ExposureSubmission.primaryButton].waitAndTap()
	}
	
	// Navigate to the Thank You screen after getting the positive test result.
	func test_ThankYouScreen_withWarnOthers() {
		app.launchArguments.append(contentsOf: ["-ENStatus", ENStatus.active.stringValue])
		app.launchArguments.append(contentsOf: ["-pcrTestResult", TestResult.positive.stringValue])
		app.launchArguments.append(contentsOf: ["-pcrPositiveTestResultWasShown", "YES"])
		launch()
		
		// Open Intro screen.
		app.cells[AccessibilityIdentifiers.Home.ShownPositiveTestResultCell.pcrCell].waitAndTap(.long)
		
		// Open Warn Others screen.
		XCTAssertTrue(app.navigationBars["ExposureSubmissionNavigationController"].waitForExistence(timeout: .medium))
		app.buttons["AppStrings.ExposureSubmission.primaryButton"].waitAndTap()

		// Open Thank You screen.
		XCTAssertTrue(app.navigationBars["ExposureSubmissionNavigationController"].waitForExistence(timeout: .medium))
		app.buttons["AppStrings.ExposureSubmission.primaryButton"].waitAndTap()
		app.navigationBars["ExposureSubmissionNavigationController"].buttons.element(boundBy: 0).waitAndTap()
		app.buttons["AppStrings.ExposureSubmission.secondaryButton"].waitAndTap()
		// quick hack - can't easily use `addUIInterruptionMonitor` in this test
		app.alerts.firstMatch.buttons.element(boundBy: 1).waitAndTap() // no
		app.buttons["AppStrings.ExposureSubmission.secondaryButton"].waitAndTap()
		// quick hack - can't easily use `addUIInterruptionMonitor` in this test
		app.alerts.firstMatch.buttons.firstMatch.waitAndTap() // yes
		
		// Back to homescreen
		XCTAssertTrue(app.cells[AccessibilityIdentifiers.Home.ShownPositiveTestResultCell.submittedPCRCell].waitForExistence(timeout: .long))
		XCTAssertTrue(app.cells[AccessibilityIdentifiers.Home.ShownPositiveTestResultCell.submittedPCRCell].isHittable)
	}

	// Navigate to the Thank You screen with alert on Test Result Screen.
	func test_ThankYouScreen_WarnOthersFromAlert() {
		app.launchArguments.append(contentsOf: ["-ENStatus", ENStatus.active.stringValue])
		app.launchArguments.append(contentsOf: ["-pcrTestResult", TestResult.positive.stringValue])
		launch()
		
		// Open Intro screen.
		app.cells.buttons[AccessibilityIdentifiers.Home.TestResultCell.availablePCRButton].waitAndTap()

		XCTAssertTrue(app.navigationBars["ExposureSubmissionNavigationController"].waitForExistence(timeout: .medium))
		app.buttons["General.primaryFooterButton"].waitAndTap()
		
		// Open Test Result screen.
		XCTAssertTrue(app.navigationBars["ExposureSubmissionNavigationController"].waitForExistence(timeout: .medium))
		app.buttons["AppStrings.ExposureSubmission.secondaryButton"].waitAndTap()

		// quick hack - can't easily use `addUIInterruptionMonitor` in this test
		app.alerts.firstMatch.buttons.element(boundBy: 1).waitAndTap() // don't warn

		// Back to homescreen
		app.cells[AccessibilityIdentifiers.Home.ShownPositiveTestResultCell.pcrCell].waitAndTap()

		XCTAssertTrue(app.navigationBars["ExposureSubmissionNavigationController"].waitForExistence(timeout: .medium))
		app.buttons["AppStrings.ExposureSubmission.primaryButton"].waitAndTap()

		XCTAssertTrue(app.navigationBars["ExposureSubmissionNavigationController"].waitForExistence(timeout: .medium))
		app.buttons["AppStrings.ExposureSubmission.secondaryButton"].waitAndTap()

		// quick hack - can't easily use `addUIInterruptionMonitor` in this test
		app.alerts.firstMatch.buttons.element(boundBy: 1).waitAndTap() // warn
		app.buttons["AppStrings.ExposureSubmission.primaryButton"].waitAndTap()
		
		app.navigationBars["ExposureSubmissionNavigationController"].buttons.element(boundBy: 0).waitAndTap()
		
		app.buttons["AppStrings.ExposureSubmission.secondaryButton"].waitAndTap()

		// quick hack - can't easily use `addUIInterruptionMonitor` in this test
		app.alerts.firstMatch.buttons.element(boundBy: 1).waitAndTap() // no
		app.buttons["AppStrings.ExposureSubmission.secondaryButton"].waitAndTap()

		// quick hack - can't easily use `addUIInterruptionMonitor` in this test
		app.alerts.firstMatch.buttons.firstMatch.waitAndTap() // yes

		// Back to homescreen
		XCTAssertTrue(app.cells[AccessibilityIdentifiers.Home.activateCardOnTitle].waitForExistence(timeout: .long))
		XCTAssertTrue(app.cells[AccessibilityIdentifiers.Home.activateCardOnTitle].isHittable)
	}
	
	// MARK: - Screenshots

	func test_screenshot_SymptomsOptionYes() {
		var screenshotCounter = 0

		launchAndNavigateToSymptomsScreen()
		
		// capturing and selecting Yes button
		let optionYes = app.buttons["AppStrings.ExposureSubmissionSymptoms.answerOptionYes"]
		optionYes.waitAndTap()

		// take snapshot of the selection
		snapshot("tan_submissionflow_symptoms_selection\(String(format: "%04d", (screenshotCounter.inc() )))")
	}

	func test_screenshot_SubmitTAN() {
		var screenshotCounter = 0

		app.launchArguments.append(contentsOf: ["-ENStatus", ENStatus.active.stringValue])
		launch()

		// monitor system dialogues and use default handler to simply dismiss any alert – we don't care for the result
		addUIInterruptionMonitor(withDescription: "System Dialog") { _ -> Bool in
			return false
		}

		snapshot("tan_submissionflow_\(String(format: "%04d", (screenshotCounter.inc())))")
		
		// Open Intro screen.
		app.cells.buttons[AccessibilityIdentifiers.Home.submitCardButton].waitAndTap()
		snapshot("tan_submissionflow_tan_\(String(format: "%04d", (screenshotCounter.inc())))")
				
		// Overview Screen: click TAN button.
		app.buttons["AppStrings.ExposureSubmissionDispatch.tanButtonDescription"].waitAndTap()
		snapshot("tan_submissionflow_tan_\(String(format: "%04d", (screenshotCounter.inc())))")
		
		// Fill in dummy TAN.
		let continueButton = app.buttons["AppStrings.ExposureSubmission.primaryButton"]
		XCTAssertTrue(continueButton.waitForExistence(timeout: .medium))
		XCTAssertFalse(continueButton.isEnabled)
		
		type(app, text: "qwdzxcsrhe")
		snapshot("tan_submissionflow_tan_\(String(format: "%04d", (screenshotCounter.inc())))")
		
		// Click continue button.
		XCTAssertTrue(continueButton.isEnabled)
		app.buttons["AppStrings.ExposureSubmission.primaryButton"].waitAndTap()
		
		// TAN tests are ALWAYS positive!
		
		app.buttons[AccessibilityIdentifiers.ExposureSubmissionTestResultAvailable.primaryButton].waitAndTap()
		snapshot("tan_submissionflow_tan_\(String(format: "%04d", (screenshotCounter.inc())))")
		
		// Click secondary button to skip symptoms screens and immediately go to warn others screen.
		app.buttons["AppStrings.ExposureSubmission.secondaryButton"].waitAndTap()
		snapshot("tan_submissionflow_tan_\(String(format: "%04d", (screenshotCounter.inc())))")

		app.buttons["AppStrings.ExposureSubmission.primaryButton"].waitAndTap()
		
		XCTAssertTrue(app.navigationBars["ExposureSubmissionNavigationController"].waitForExistence(timeout: .medium))
		app.buttons["AppStrings.ExposureSubmission.primaryButton"].waitAndTap()
		snapshot("tan_submissionflow_tan_\(String(format: "%04d", (screenshotCounter.inc())))")
		
		XCTAssertTrue(app.navigationBars["ExposureSubmissionNavigationController"].waitForExistence(timeout: .medium))
		
		app.buttons["AppStrings.ExposureSubmission.primaryButton"].waitAndTap()
	}

	func test_screenshot_SubmitQR() {
		var screenshotCounter = 0

		app.launchArguments.append(contentsOf: ["-ENStatus", ENStatus.active.stringValue])

		if #available(iOS 13.4, *) {
			app.resetAuthorizationStatus(for: .camera)
		}
		launch()

		// monitor system dialogues and use default handler to simply dismiss any alert
		// see https://developer.apple.com/videos/play/wwdc2020/10220/
		addUIInterruptionMonitor(withDescription: "System Dialog") { _ -> Bool in
			return false
		}

		snapshot("tan_submissionflow_\(String(format: "%04d", (screenshotCounter.inc() )))")

		/// Home Screen
		
		app.cells.buttons[AccessibilityIdentifiers.Home.submitCardButton].waitAndTap()
		snapshot("tan_submissionflow_qr_\(String(format: "%04d", (screenshotCounter.inc() )))")

		/// Register your test screen
		
		let scanQRCodeButton = app.buttons[AccessibilityIdentifiers.ExposureSubmissionDispatch.qrCodeButtonDescription]
		scanQRCodeButton.waitAndTap()
		
		/// Your consent screen
		
		XCTAssertTrue(app.images[AccessibilityIdentifiers.ExposureSubmissionWarnOthers.accImageDescription].waitForExistence(timeout: .short))
		snapshot("tan_submissionflow_qr_\(String(format: "%04d", (screenshotCounter.inc() )))")
		let continueButton = app.buttons[AccessibilityIdentifiers.ExposureSubmission.primaryButton]
		continueButton.waitAndTap()

		/// Camera mode
		
		// fake tap to trigger interruption handler in case of privacy alerts

		let flashButton = app.buttons[AccessibilityIdentifiers.ExposureSubmissionQRScanner.flash]
		if flashButton.waitForExistence(timeout: .short) {
			flashButton.waitAndTap()
		}
		snapshot("tan_submissionflow_qr_\(String(format: "%04d", (screenshotCounter.inc() )))")
	}

	func test_screenshot_SubmissionNotPossible() throws {
		try XCTSkipIf(Locale.current.identifier == "bg_BG") // temporary hack!
		var screenshotCounter = 0

		app.launchArguments.append(contentsOf: ["-ENStatus", ENStatus.disabled.stringValue])
		launch()
		snapshot("tan_submissionflow_\(String(format: "%04d", (screenshotCounter.inc() )))")

		// Open Intro screen.
		app.cells.buttons[AccessibilityIdentifiers.Home.submitCardButton].waitAndTap()

		// Overview Screen: click TAN button.
		app.buttons["AppStrings.ExposureSubmissionDispatch.tanButtonDescription"].waitAndTap()

		let continueButton = app.buttons["AppStrings.ExposureSubmission.primaryButton"]
		XCTAssertTrue(continueButton.waitForExistence(timeout: .medium))
		XCTAssertFalse(continueButton.isEnabled)

		// Fill in dummy TAN.
		type(app, text: "qwdzxcsrhe")

		// Click continue button.
		XCTAssertTrue(continueButton.isEnabled)
		app.buttons["AppStrings.ExposureSubmission.primaryButton"].waitAndTap()

		// TAN tests are ALWAYS positive!
		
		app.buttons[AccessibilityIdentifiers.ExposureSubmissionTestResultAvailable.primaryButton].waitAndTap()

		// Click secondary button to skip symptoms screens and immediately go to warn others screen.
		app.buttons["AppStrings.ExposureSubmission.secondaryButton"].waitAndTap()

		// expect an error dialogue due to disabled exposure notification
		XCTAssertTrue(app.alerts.firstMatch.waitForExistence(timeout: .short))

		snapshot("error_submissionflow_\(String(format: "%04d", (screenshotCounter.inc() )))")
	}
	
	func test_screenshot_test_result_available() {
		app.launchArguments.append(contentsOf: ["-ENStatus", ENStatus.active.stringValue])
		app.launchArguments.append(contentsOf: ["-pcrTestResult", TestResult.positive.stringValue])
		launch()

		// Open test result available screen.
		
		app.cells.buttons[AccessibilityIdentifiers.Home.TestResultCell.availablePCRButton].waitAndTap()
		XCTAssertTrue(app.navigationBars["ExposureSubmissionNavigationController"].waitForExistence(timeout: .long))

		snapshot("submissionflow_screenshot_test_result_available")
	}

	func test_screenshot_test_result_pending() {
		app.launchArguments.append(contentsOf: ["-ENStatus", ENStatus.active.stringValue])
		app.launchArguments.append(contentsOf: ["-pcrTestResult", TestResult.pending.stringValue])
		launch()

		// Open test result screen.
		app.cells.buttons[AccessibilityIdentifiers.Home.TestResultCell.pendingPCRButton].waitAndTap()
		XCTAssertTrue(app.staticTexts["AppStrings.ExposureSubmissionResult.procedure"].waitForExistence(timeout: .medium))

		snapshot("submissionflow_screenshot_test_result_pending")
	}

	func test_screenshot_test_result_negative() {
		app.launchArguments.append(contentsOf: ["-ENStatus", ENStatus.active.stringValue])
		app.launchArguments.append(contentsOf: ["-pcrTestResult", TestResult.negative.stringValue])
		launch()

		// Open test result screen.
		app.cells.buttons[AccessibilityIdentifiers.Home.TestResultCell.negativePCRButton].waitAndTap()
		XCTAssertTrue(app.staticTexts["AppStrings.ExposureSubmissionResult.procedure"].waitForExistence(timeout: .medium))

		snapshot("submissionflow_screenshot_test_result_negative")
	}

	func test_screenshot_test_result_positive() {
		app.launchArguments.append(contentsOf: ["-ENStatus", ENStatus.active.stringValue])
		app.launchArguments.append(contentsOf: ["-isPCRSubmissionConsentGiven", "YES"])
		app.launchArguments.append(contentsOf: ["-pcrPositiveTestResultWasShown", "NO"])
		app.launchArguments.append(contentsOf: ["-pcrTestResult", TestResult.positive.stringValue])
		launch()

		// Open test result screen.

		app.cells.buttons[AccessibilityIdentifiers.Home.TestResultCell.availablePCRButton].waitAndTap()

		app.buttons[AccessibilityIdentifiers.General.primaryFooterButton].waitAndTap(.long)
		
		XCTAssertTrue(app.buttons["AppStrings.ExposureSubmission.primaryButton"].waitForExistence(timeout: .long))
		
		snapshot("submissionflow_screenshot_test_result_positive_constent_given")
	}

	func test_screenshot_symptoms_onset_date_option() {
		launchAndNavigateToSymptomsOnsetScreen()

		// select date
		let optionExactDate = app.buttons["AppStrings.DatePickerOption.day"].firstMatch
		optionExactDate.waitAndTap()

		snapshot("submissionflow_screenshot_symptoms_onset_date_option")
	}

	func test_screenshot_exposureSubmissionSuccess_screen() {
		launchAndNavigateToSymptomsScreen()

		// Symptoms Screen: Select no symptoms option
		let optionNo = app.buttons["AppStrings.ExposureSubmissionSymptoms.answerOptionNo"]
		XCTAssertTrue(optionNo.waitForExistence(timeout: .medium))
		optionNo.waitAndTap()

		let btnContinue = app.buttons["AppStrings.ExposureSubmission.primaryButton"]
		XCTAssertTrue(btnContinue.isEnabled)
		btnContinue.waitAndTap()

		// We should see now the exposureSubmissionSuccessViewController
		XCTAssertTrue(app.images[AccessibilityIdentifiers.ExposureSubmissionSuccess.accImageDescription].waitForExistence(timeout: .short))
		
		// the old thank you screen == exposureSubmissionSuccessViewController
		snapshot("submissionflow_screenshot_thank_you_screen")
		
		app.buttons[AccessibilityIdentifiers.ExposureSubmissionSuccess.closeButton].waitAndTap()

		// Back to homescreen
		XCTAssertTrue(app.cells[AccessibilityIdentifiers.Home.activateCardOnTitle].waitForExistence(timeout: .long))
		XCTAssertTrue(app.cells[AccessibilityIdentifiers.Home.activateCardOnTitle].isHittable)
	}
}

// MARK: - Helpers.

extension ENAUITests_04a_ExposureSubmission {

	private func type(_ app: XCUIApplication, text: String) {
		text.forEach {
			app.keyboards.keys[String($0)].waitAndTap()
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
			Bundle(for: ENAUITests_04a_ExposureSubmission.self)
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

	func launchAndNavigateToSymptomsScreen() {
		app.launchArguments.append(contentsOf: ["-ENStatus", ENStatus.active.stringValue])
		app.launchArguments.append(contentsOf: ["-pcrTestResult", TestResult.positive.stringValue])
		app.launchArguments.append(contentsOf: ["-pcrPositiveTestResultWasShown", "YES"])
		launch()

		app.cells[AccessibilityIdentifiers.Home.ShownPositiveTestResultCell.pcrCell].waitAndTap()

		// Test Result screen.
		XCTAssertTrue(app.navigationBars["ExposureSubmissionNavigationController"].waitForExistence(timeout: .medium))
		app.buttons["AppStrings.ExposureSubmission.primaryButton"].waitAndTap()

		// Thank You screen.
		XCTAssertTrue(app.navigationBars["ExposureSubmissionNavigationController"].waitForExistence(timeout: .medium))
		app.buttons["AppStrings.ExposureSubmission.primaryButton"].waitAndTap()
	}

	func launchAndNavigateToSymptomsOnsetScreen() {
		launchAndNavigateToSymptomsScreen()

		let optionYes = app.buttons["AppStrings.ExposureSubmissionSymptoms.answerOptionYes"]

		optionYes.waitAndTap()

		app.buttons["AppStrings.ExposureSubmission.primaryButton"].waitAndTap()
	}

}
