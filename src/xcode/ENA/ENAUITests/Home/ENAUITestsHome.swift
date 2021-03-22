//
// 🦠 Corona-Warn-App
//

import XCTest
import ExposureNotification

class ENAUITests_01_Home: XCTestCase {
	var app: XCUIApplication!

	override func setUpWithError() throws {
		continueAfterFailure = false
		app = XCUIApplication()
		setupSnapshot(app)
		app.setDefaults()
		app.launchArguments.append(contentsOf: ["-isOnboarded", "YES"])
		app.launchArguments.append(contentsOf: ["-setCurrentOnboardingVersion", "YES"])
		app.launchArguments.append(contentsOf: ["-userNeedsToBeInformedAboutHowRiskDetectionWorks", "NO"])
	}

	override func tearDownWithError() throws {
		// Put teardown code here. This method is called after the invocation of each test method in the class.
	}

	func test_0010_HomeFlow_medium() throws {
		app.setPreferredContentSizeCategory(accessibility: .normal, size: .M)
		app.launch()

		// only run if home screen is present
		XCTAssertTrue(app.buttons[AccessibilityIdentifiers.Home.rightBarButtonDescription].waitForExistence(timeout: .medium))

		app.swipeUp()
		// assert cells
		XCTAssertTrue(app.cells["AppStrings.Home.infoCardShareTitle"].waitForExistence(timeout: .medium))
		XCTAssertTrue(app.cells["AppStrings.Home.infoCardAboutTitle"].waitForExistence(timeout: .medium))
		XCTAssertTrue(app.cells["AppStrings.Home.appInformationCardTitle"].waitForExistence(timeout: .medium))
		XCTAssertTrue(app.cells["AppStrings.Home.settingsCardTitle"].waitForExistence(timeout: .medium))
		// snapshot("ScreenShot_\(#function)")
	}

	func test_0011_HomeFlow_extrasmall() throws {
		app.setPreferredContentSizeCategory(accessibility: .normal, size: .XS)
		app.launch()

		// only run if home screen is present
		XCTAssertTrue(app.buttons[AccessibilityIdentifiers.Home.rightBarButtonDescription].waitForExistence(timeout: .medium))

		app.swipeUp()
		// assert cells
		XCTAssertTrue(app.cells["AppStrings.Home.infoCardShareTitle"].waitForExistence(timeout: .medium))
		XCTAssertTrue(app.cells["AppStrings.Home.infoCardAboutTitle"].waitForExistence(timeout: .short))
		XCTAssertTrue(app.cells["AppStrings.Home.appInformationCardTitle"].waitForExistence(timeout: .short))
		XCTAssertTrue(app.cells["AppStrings.Home.settingsCardTitle"].waitForExistence(timeout: .short))
		// snapshot("ScreenShot_\(#function)")
	}

	func test_0013_HomeFlow_extralarge() throws {
		app.setPreferredContentSizeCategory(accessibility: .accessibility, size: .XL)
		app.launch()

		// only run if home screen is present
		XCTAssertTrue(app.buttons[AccessibilityIdentifiers.Home.rightBarButtonDescription].waitForExistence(timeout: .medium))

		app.swipeUp()
		app.swipeUp()
		// assert cells
		XCTAssertTrue(app.cells["AppStrings.Home.infoCardShareTitle"].waitForExistence(timeout: .medium))
		XCTAssertTrue(app.cells["AppStrings.Home.infoCardAboutTitle"].waitForExistence(timeout: .short))
		app.swipeUp()
		XCTAssertTrue(app.cells["AppStrings.Home.appInformationCardTitle"].waitForExistence(timeout: .medium))
		XCTAssertTrue(app.cells["AppStrings.Home.settingsCardTitle"].waitForExistence(timeout: .short))
		// snapshot("ScreenShot_\(#function)")
	}
	
	func test_screenshot_homescreen_riskCardHigh_riskOneDay() throws {
		var screenshotCounter = 0
		let riskLevel = "high"
		let numberOfDaysWithHighRisk = 1
		app.setPreferredContentSizeCategory(accessibility: .accessibility, size: .XS)
		app.launchArguments.append(contentsOf: ["-riskLevel", riskLevel])
		app.launchArguments.append(contentsOf: ["-ENStatus", ENStatus.active.stringValue])
		app.launch()
		
		XCTAssertTrue(app.buttons[AccessibilityIdentifiers.Home.RiskTableViewCell.topContainer].waitForExistence(timeout: .medium))
		XCTAssertTrue(app.buttons[AccessibilityIdentifiers.Home.submitCardButton].waitForExistence(timeout: .short))

		// Red risk card title "Erhöhtes Risiko" – the localized text is used as accessibility identifier
		// see HomeRiskLevelCellConfigurator.setupAccessibility()
		XCTAssertTrue(app.buttons[AccessibilityLabels.localized(AppStrings.Home.riskCardHighTitle)].waitForExistence(timeout: .short))
		
		// find an element with localized text "Begegnungen an 1 Tag mit erhöhtem Risiko"
		let highRiskTitle = String(format: AccessibilityLabels.localized(AppStrings.Home.riskCardHighNumberContactsItemTitle), numberOfDaysWithHighRisk)
		XCTAssertTrue(app.otherElements[highRiskTitle].waitForExistence(timeout: .short))
		
		XCTAssertTrue(app.buttons[AccessibilityIdentifiers.Home.rightBarButtonDescription].waitForExistence(timeout: .short))
		snapshot("homescreenrisk_level_\(riskLevel)_risk_one_day_\(String(format: "%04d", (screenshotCounter.inc() )))")
		app.swipeUp()
		snapshot("homescreenrisk_level_\(riskLevel)_risk_one_day_\(String(format: "%04d", (screenshotCounter.inc() )))")
	}

	func test_screenshot_homescreen_riskCardHigh_riskMultipleDays() throws {
		var screenshotCounter = 0
		let riskLevel = "high"
		let numberOfDaysWithHighRisk = "4"
		app.setPreferredContentSizeCategory(accessibility: .accessibility, size: .XS)
		app.launchArguments.append(contentsOf: ["-riskLevel", riskLevel])
		app.launchArguments.append(contentsOf: ["-numberOfDaysWithRiskLevel", numberOfDaysWithHighRisk])
		app.launchArguments.append(contentsOf: ["-ENStatus", ENStatus.active.stringValue])
		app.launch()
		
		XCTAssertTrue(app.buttons[AccessibilityIdentifiers.Home.RiskTableViewCell.topContainer].waitForExistence(timeout: .medium))
		XCTAssertTrue(app.buttons[AccessibilityIdentifiers.Home.submitCardButton].waitForExistence(timeout: .short))

		// Red risk card title "Erhöhtes Risiko" – the localized text is used as accessibility identifier
		// see HomeRiskLevelCellConfigurator.setupAccessibility()
		XCTAssertTrue(app.buttons[AccessibilityLabels.localized(AppStrings.Home.riskCardHighTitle)].waitForExistence(timeout: .short))
		
		// find an element with localized text "Begegnungen an 4 Tag mit erhöhtem Risiko"
		let highRiskTitle = String(format: AccessibilityLabels.localized(AppStrings.Home.riskCardHighNumberContactsItemTitle), 4)
		XCTAssertTrue(app.otherElements[highRiskTitle].waitForExistence(timeout: .medium))
		
		XCTAssertTrue(app.buttons[AccessibilityIdentifiers.Home.rightBarButtonDescription].waitForExistence(timeout: .short))
		snapshot("homescreenrisk_level_\(riskLevel)_risk_multiple_days_\(String(format: "%04d", (screenshotCounter.inc() )))")
		app.swipeUp()
		snapshot("homescreenrisk_level_\(riskLevel)_risk_multiple_days_\(String(format: "%04d", (screenshotCounter.inc() )))")
	}

	func test_screenshot_homescreen_riskCardLow_riskNoDays() throws {
		var screenshotCounter = 0
		let riskLevel = "low"
		let numberOfDaysWithLowRisk = 0
		app.setPreferredContentSizeCategory(accessibility: .accessibility, size: .XS)
		app.launchArguments.append(contentsOf: ["-riskLevel", riskLevel])
		app.launch()
		
		XCTAssertTrue(app.buttons[AccessibilityIdentifiers.Home.RiskTableViewCell.topContainer].waitForExistence(timeout: .medium))
		XCTAssertTrue(app.buttons[AccessibilityIdentifiers.Home.submitCardButton].waitForExistence(timeout: .short))
		
		// Green risk card title "Niedriges Risiko" – the localized text is used as accessibility identifier
		// see HomeRiskLevelCellConfigurator.setupAccessibility()
		XCTAssertNotNil(app.buttons[AccessibilityLabels.localized(AppStrings.Home.riskCardLowTitle)].waitForExistence(timeout: .short))
		
		// find an element with localized text "Keine Risiko-Begegnungen"
		let lowRiskTitle = String(format: AccessibilityLabels.localized(AppStrings.Home.riskCardLowNumberContactsItemTitle), numberOfDaysWithLowRisk)
		XCTAssertTrue(app.otherElements[lowRiskTitle].waitForExistence(timeout: .long))
		
		XCTAssertTrue(app.buttons[AccessibilityIdentifiers.Home.rightBarButtonDescription].waitForExistence(timeout: .short))
		snapshot("homescreenrisk_level_\(riskLevel)_risk_no_days_\(String(format: "%04d", (screenshotCounter.inc() )))")
		app.swipeUp()
		snapshot("homescreenrisk_level_\(riskLevel)_risk_no_days_\(String(format: "%04d", (screenshotCounter.inc() )))")
	}

	func test_screenshot_homescreen_riskCardLow_riskOneDay() throws {
		var screenshotCounter = 0
		let riskLevel = "low"
		let numberOfDaysWithLowRisk = "1"
		app.setPreferredContentSizeCategory(accessibility: .accessibility, size: .XS)
		app.launchArguments.append(contentsOf: ["-riskLevel", riskLevel])
		app.launchArguments.append(contentsOf: ["-numberOfDaysWithRiskLevel", numberOfDaysWithLowRisk])
		app.launchArguments.append(contentsOf: ["-ENStatus", ENStatus.active.stringValue])
		app.launch()
		
		XCTAssertTrue(app.buttons[AccessibilityIdentifiers.Home.RiskTableViewCell.topContainer].waitForExistence(timeout: .medium))
		XCTAssertTrue(app.buttons[AccessibilityIdentifiers.Home.submitCardButton].waitForExistence(timeout: .short))
		
		// Green risk card title "Niedriges Risiko" – the localized text is used as accessibility identifier
		// see HomeRiskLevelCellConfigurator.setupAccessibility()
		XCTAssertNotNil(app.buttons[AccessibilityLabels.localized(AppStrings.Home.riskCardLowTitle)].waitForExistence(timeout: .short))
		
		// find an element with localized text "Keine Risiko-Begegnungen"
		let lowRiskTitle = String(format: AccessibilityLabels.localized(AppStrings.Home.riskCardLowNumberContactsItemTitle), 1)
		XCTAssertTrue(app.otherElements[lowRiskTitle].waitForExistence(timeout: .short))
		
		XCTAssertTrue(app.buttons[AccessibilityIdentifiers.Home.rightBarButtonDescription].waitForExistence(timeout: .short))
		snapshot("homescreenrisk_level_\(riskLevel)_risk_one_day_\(String(format: "%04d", (screenshotCounter.inc() )))")
		app.swipeUp()
		snapshot("homescreenrisk_level_\(riskLevel)_risk_one_day_\(String(format: "%04d", (screenshotCounter.inc() )))")
	}

	func test_screenshot_homescreen_riskCardLow_riskMultipleDays() throws {
		var screenshotCounter = 0
		let riskLevel = "low"
		let numberOfDaysWithLowRisk = "4"
		app.setPreferredContentSizeCategory(accessibility: .accessibility, size: .XS)
		app.launchArguments.append(contentsOf: ["-riskLevel", riskLevel])
		app.launchArguments.append(contentsOf: ["-numberOfDaysWithRiskLevel", numberOfDaysWithLowRisk])
		app.launchArguments.append(contentsOf: ["-ENStatus", ENStatus.active.stringValue])
		app.launch()
		
		XCTAssertTrue(app.buttons[AccessibilityIdentifiers.Home.RiskTableViewCell.topContainer].waitForExistence(timeout: .medium))
		XCTAssertTrue(app.buttons[AccessibilityIdentifiers.Home.submitCardButton].waitForExistence(timeout: .short))
		
		// Green risk card title "Niedriges Risiko" – the localized text is used as accessibility identifier
		// see HomeRiskLevelCellConfigurator.setupAccessibility()
		XCTAssertNotNil(app.buttons[AccessibilityLabels.localized(AppStrings.Home.riskCardLowTitle)].waitForExistence(timeout: .short))
		
		// find an element with localized text "Keine Risiko-Begegnungen"
		let lowRiskTitle = String(format: AccessibilityLabels.localized(AppStrings.Home.riskCardLowNumberContactsItemTitle), 4)
		XCTAssertTrue(app.otherElements[lowRiskTitle].waitForExistence(timeout: .short))
		
		XCTAssertTrue(app.buttons[AccessibilityIdentifiers.Home.rightBarButtonDescription].waitForExistence(timeout: .short))
		snapshot("homescreenrisk_level_\(riskLevel)_risk_multiple_days_\(String(format: "%04d", (screenshotCounter.inc() )))")
		app.swipeUp()
		snapshot("homescreenrisk_level_\(riskLevel)_risk_multiple_days_\(String(format: "%04d", (screenshotCounter.inc() )))")
	}

	func test_screenshot_homescreen_riskCardLow_14days() throws {
		var screenshotCounter = 0
		let riskLevel = "low"
		let installationDays = "14"
		app.setPreferredContentSizeCategory(accessibility: .accessibility, size: .XS)
		app.launchArguments.append(contentsOf: ["-riskLevel", riskLevel])
		app.launchArguments.append(contentsOf: ["-appInstallationDays", installationDays])
		app.launchArguments.append(contentsOf: ["-ENStatus", ENStatus.active.stringValue])
		app.launch()
		
		snapshot("homescreenrisk_level_\(riskLevel)_installation_14days_\(String(format: "%04d", (screenshotCounter.inc() )))")
	}

	func test_screenshot_homescreen_riskCardLow_Ndays() throws {
		var screenshotCounter = 0
		let riskLevel = "low"
		// change the value based on N
		let installationDays = "12"
		app.setPreferredContentSizeCategory(accessibility: .accessibility, size: .XS)
		app.launchArguments.append(contentsOf: ["-riskLevel", riskLevel])
		app.launchArguments.append(contentsOf: ["-appInstallationDays", installationDays])
		app.launchArguments.append(contentsOf: ["-ENStatus", ENStatus.active.stringValue])
		app.launch()
		
		snapshot("homescreenrisk_level_\(riskLevel)_installation_\(installationDays)days_\(String(format: "%04d", (screenshotCounter.inc() )))")
	}

	func test_screenshot_homescreen_riskCardInactive() throws {
		try XCTSkipIf(Locale.current.identifier == "bg_BG") // temporary hack!
		var screenshotCounter = 0
		let riskLevel = "inactive"
		app.setPreferredContentSizeCategory(accessibility: .accessibility, size: .XS)
		app.launchArguments.append(contentsOf: ["-riskLevel", riskLevel])
		app.launchArguments.append(contentsOf: ["-ENStatus", ENStatus.active.stringValue])
		app.launch()

		XCTAssertTrue(app.buttons[AccessibilityIdentifiers.Home.submitCardButton].waitForExistence(timeout: .short))

		// Inactive risk card title "Risiko-Ermittlung gestoppt"
		XCTAssertTrue(app.buttons[AccessibilityIdentifiers.Home.RiskTableViewCell.topContainer].waitForExistence(timeout: .short))
		
		XCTAssertTrue(app.buttons[AccessibilityIdentifiers.Home.rightBarButtonDescription].waitForExistence(timeout: .short))
		snapshot("homescreenrisk_level_\(riskLevel)_\(String(format: "%04d", (screenshotCounter.inc() )))")
		app.swipeUp()
		snapshot("homescreenrisk_level_\(riskLevel)_\(String(format: "%04d", (screenshotCounter.inc() )))")
		
	}

	// MARK: - Risk states with active Exposure Logging

	func test_screenshot_homescreen_riskCardHigh_disabledExposureLogging() throws {
		var screenshotCounter = 0
		let riskLevel = "high"
		app.setPreferredContentSizeCategory(accessibility: .accessibility, size: .XS)
		app.launchArguments.append(contentsOf: ["-riskLevel", riskLevel])
		app.launchArguments.append(contentsOf: ["-isOnboarded", "YES"])
		app.launchArguments.append(contentsOf: ["-ENStatus", ENStatus.disabled.stringValue])
		app.launch()

		XCTAssertTrue(app.buttons[AccessibilityIdentifiers.Home.RiskTableViewCell.topContainer].waitForExistence(timeout: .medium))
		XCTAssertTrue(app.buttons[AccessibilityIdentifiers.Home.submitCardButton].waitForExistence(timeout: .short))

		snapshot("homescreenrisk_level_\(riskLevel)_noExposureLogging_\(String(format: "%04d", (screenshotCounter.inc() )))")
		app.swipeUp()
		snapshot("homescreenrisk_level_\(riskLevel)_noExposureLogging_\(String(format: "%04d", (screenshotCounter.inc() )))")
	}

	func test_riskCardHigh_details_faqLink() throws {
		app.launchArguments.append(contentsOf: ["-riskLevel", "high"])
		app.launchArguments.append(contentsOf: ["-isOnboarded", "YES"])
		app.launchArguments.append(contentsOf: ["-ENStatus", ENStatus.active.stringValue])
		app.launch()

		let riskCell = app.cells.element(boundBy: 1)
		XCTAssertTrue(riskCell.waitForExistence(timeout: .medium))
		riskCell.tap()

		let faqCell = app.cells[AccessibilityIdentifiers.ExposureDetection.guideFAQ]
		XCTAssertTrue(faqCell.waitForExistence(timeout: .medium))
		faqCell.tap()

		XCTAssertTrue(app.webViews.firstMatch.waitForExistence(timeout: .long))
	}
	
	func test_screenshot_details_riskCardHigh_riskOneDay_tracingNdays() throws {
		var screenshotCounter = 0
		let riskLevel = "high"
		// change the value based on N
		let activeTracingDays = "5"
		app.setPreferredContentSizeCategory(accessibility: .accessibility, size: .XS)
		app.launchArguments.append(contentsOf: ["-riskLevel", riskLevel])
		app.launchArguments.append(contentsOf: ["-activeTracingDays", activeTracingDays])
		app.launchArguments.append(contentsOf: ["-ENStatus", ENStatus.active.stringValue])
		app.launch()

		let riskCell = app.cells.element(boundBy: 1)
		XCTAssertTrue(riskCell.waitForExistence(timeout: .medium))
		riskCell.tap()

		snapshot("details_screen_risk_level_\(riskLevel)_risk_one_day_active_tracing_\(activeTracingDays)days_\(String(format: "%04d", (screenshotCounter.inc() )))")
    }

	func test_screenshot_details_riskCardLow_riskOneDay_tracingNdays() throws {
		var screenshotCounter = 0
		let riskLevel = "low"
		// change the value based on N
		let activeTracingDays = "5"
		app.setPreferredContentSizeCategory(accessibility: .accessibility, size: .XS)
		app.launchArguments.append(contentsOf: ["-riskLevel", riskLevel])
		app.launchArguments.append(contentsOf: ["-activeTracingDays", activeTracingDays])
		app.launchArguments.append(contentsOf: ["-numberOfDaysWithRiskLevel", "1"])
		app.launchArguments.append(contentsOf: ["-ENStatus", ENStatus.active.stringValue])
		app.launch()
		
		let riskCell = app.cells.element(boundBy: 1)
		XCTAssertTrue(riskCell.waitForExistence(timeout: .medium))
		riskCell.tap()
		
		snapshot("details_screen_risk_level_\(riskLevel)_risk_one_day_active_tracing_\(activeTracingDays)days_\(String(format: "%04d", (screenshotCounter.inc() )))")
	}
	
	
	func test_screenshot_details_riskCardLow_riskOneDay_Ndays() throws {
		var screenshotCounter = 0
		let riskLevel = "low"
		let installationDays = "12"
		// change the value based on N
		app.setPreferredContentSizeCategory(accessibility: .accessibility, size: .XS)
		app.launchArguments.append(contentsOf: ["-riskLevel", riskLevel])
		app.launchArguments.append(contentsOf: ["-appInstallationDays", installationDays])
		app.launchArguments.append(contentsOf: ["-ENStatus", ENStatus.active.stringValue])
		app.launch()
		
		let riskCell = app.cells.element(boundBy: 1)
		XCTAssertTrue(riskCell.waitForExistence(timeout: .medium))
		riskCell.tap()
		
		snapshot("details_screen_risk_level_\(riskLevel)_risk_one_day_installation_\(installationDays)days_\(String(format: "%04d", (screenshotCounter.inc() )))")
	}
	
	func test_screenshot_homescreen_thankyou_screen() throws {
		var screenshotCounter = 0
		app.setPreferredContentSizeCategory(accessibility: .accessibility, size: .XS)
		app.launchArguments.append(contentsOf: ["-showThankYouScreen", "YES"])
		app.launch()

		snapshot("homescreenrisk_show_thankyou_screen_\(String(format: "%04d", (screenshotCounter.inc() )))")
		app.swipeUp(velocity: .slow)
		snapshot("homescreenrisk_show_thankyou_screen_\(String(format: "%04d", (screenshotCounter.inc() )))")
		app.swipeUp(velocity: .slow)
		snapshot("homescreenrisk_show_thankyou_screen_\(String(format: "%04d", (screenshotCounter.inc() )))")
    }
	
	func test_screenshot_homescreen_invalid_test_result() throws {
		var screenshotCounter = 0
		let riskLevel = "low"
		let numberOfDaysWithLowRisk = "1"
		app.setPreferredContentSizeCategory(accessibility: .accessibility, size: .XS)
		app.launchArguments.append(contentsOf: ["-riskLevel", riskLevel])
		app.launchArguments.append(contentsOf: ["-numberOfDaysWithRiskLevel", numberOfDaysWithLowRisk])
		app.launchArguments.append(contentsOf: ["-showTestResultScreen", "YES"])
		app.launchArguments.append(contentsOf: ["-showInvalidTestResult", "YES"])
		app.launchArguments.append(contentsOf: ["-ENStatus", ENStatus.active.stringValue])
		app.launch()

		snapshot("homescreenrisk_show_invalid_test_result_\(String(format: "%04d", (screenshotCounter.inc() )))")
		app.swipeUp(velocity: .slow)
		snapshot("homescreenrisk_show_invalid_test_result_\(String(format: "%04d", (screenshotCounter.inc() )))")
	}
	
	func test_screenshot_homescreen_loading_test_result() throws {
		var screenshotCounter = 0
		let riskLevel = "low"
		let numberOfDaysWithLowRisk = "1"
		app.setPreferredContentSizeCategory(accessibility: .accessibility, size: .XS)
		app.launchArguments.append(contentsOf: ["-riskLevel", riskLevel])
		app.launchArguments.append(contentsOf: ["-numberOfDaysWithRiskLevel", numberOfDaysWithLowRisk])
		app.launchArguments.append(contentsOf: ["-showTestResultScreen", "YES"])
		app.launchArguments.append(contentsOf: ["-showLoadingTestResult", "YES"])
		app.launchArguments.append(contentsOf: ["-ENStatus", ENStatus.active.stringValue])
		app.launch()

		snapshot("homescreenrisk_show_loading_test_result_\(String(format: "%04d", (screenshotCounter.inc() )))")
		app.swipeUp(velocity: .slow)
		snapshot("homescreenrisk_show_loading_test_result_\(String(format: "%04d", (screenshotCounter.inc() )))")
	}

	func test_screenshot_homescreen_pending_test_result() throws {
		var screenshotCounter = 0
		let riskLevel = "low"
		let numberOfDaysWithLowRisk = "1"
		app.setPreferredContentSizeCategory(accessibility: .accessibility, size: .XS)
		app.launchArguments.append(contentsOf: ["-riskLevel", riskLevel])
		app.launchArguments.append(contentsOf: ["-numberOfDaysWithRiskLevel", numberOfDaysWithLowRisk])
		app.launchArguments.append(contentsOf: ["-showTestResultScreen", "YES"])
		app.launchArguments.append(contentsOf: ["-showPendingTestResult", "YES"])
		app.launchArguments.append(contentsOf: ["-ENStatus", ENStatus.active.stringValue])
		app.launch()

		snapshot("homescreenrisk_show_pending_test_result_\(String(format: "%04d", (screenshotCounter.inc() )))")
		app.swipeUp(velocity: .slow)
		snapshot("homescreenrisk_show_pending_test_result_\(String(format: "%04d", (screenshotCounter.inc() )))")
	}
	
	func test_screenshot_homescreen_negative_test_result() throws {
		var screenshotCounter = 0
		let riskLevel = "low"
		let numberOfDaysWithLowRisk = "1"
		app.setPreferredContentSizeCategory(accessibility: .accessibility, size: .XS)
		app.launchArguments.append(contentsOf: ["-riskLevel", riskLevel])
		app.launchArguments.append(contentsOf: ["-numberOfDaysWithRiskLevel", numberOfDaysWithLowRisk])
		app.launchArguments.append(contentsOf: ["-showTestResultScreen", "YES"])
		app.launchArguments.append(contentsOf: ["-showNegativeTestResult", "YES"])
		app.launchArguments.append(contentsOf: ["-ENStatus", ENStatus.active.stringValue])
		app.launch()

		snapshot("homescreenrisk_show_negative_test_result_\(String(format: "%04d", (screenshotCounter.inc() )))")
		app.swipeUp(velocity: .slow)
		snapshot("homescreenrisk_show_negative_test_result_\(String(format: "%04d", (screenshotCounter.inc() )))")
	}
	
	func test_screenshot_homescreen_positive_test_result() throws {
		var screenshotCounter = 0
		app.setPreferredContentSizeCategory(accessibility: .accessibility, size: .XS)
		// we just need one launch argument because it is handled separately
		app.launchArguments.append(contentsOf: ["-showPositiveTestResult", "YES"])
		app.launchArguments.append(contentsOf: ["-ENStatus", ENStatus.active.stringValue])
		app.launch()

		snapshot("homescreenrisk_show_positive_test_result_\(String(format: "%04d", (screenshotCounter.inc() )))")
		app.swipeUp(velocity: .slow)
		snapshot("homescreenrisk_show_positive_test_result_\(String(format: "%04d", (screenshotCounter.inc() )))")
	}
}
