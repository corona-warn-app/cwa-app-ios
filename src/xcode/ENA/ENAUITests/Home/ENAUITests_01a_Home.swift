//
// 🦠 Corona-Warn-App
//

import XCTest
import ExposureNotification

class ENAUITests_01a_Home: CWATestCase {
	var app: XCUIApplication!

	override func setUpWithError() throws {
		try super.setUpWithError()
		continueAfterFailure = false
		app = XCUIApplication()
		setupSnapshot(app)
		app.setDefaults()
		app.setLaunchArgument(LaunchArguments.onboarding.isOnboarded, to: true)
		app.setLaunchArgument(LaunchArguments.onboarding.setCurrentOnboardingVersion, to: true)
		app.setLaunchArgument(LaunchArguments.infoScreen.userNeedsToBeInformedAboutHowRiskDetectionWorks, to: false)
	}

	func test_0010_HomeFlow_medium() throws {
		app.setPreferredContentSizeCategory(accessibility: .normal, size: .M)
		app.launch()

		// only run if home screen is present
		XCTAssertTrue(app.buttons[AccessibilityIdentifiers.Home.rightBarButtonDescription].waitForExistence(timeout: .medium))

		app.swipeUp()
		// assert cells
		let moreCell = app.cells[AccessibilityIdentifiers.Home.MoreInfoCell.moreCell]

		let shareLabel = moreCell.buttons[AccessibilityIdentifiers.Home.MoreInfoCell.shareLabel]
		XCTAssertTrue(shareLabel.waitForExistence(timeout: .medium))

		let faqLabel = moreCell.buttons[AccessibilityIdentifiers.Home.MoreInfoCell.faqLabel]
		XCTAssertTrue(faqLabel.waitForExistence(timeout: .medium))
		
		let socialMediaLabel = moreCell.buttons[AccessibilityIdentifiers.Home.MoreInfoCell.socialMediaLabel]
		XCTAssertTrue(socialMediaLabel.waitForExistence(timeout: .medium))
		
		let infoLabel = moreCell.buttons[AccessibilityIdentifiers.Home.MoreInfoCell.appInformationLabel]
		XCTAssertTrue(infoLabel.waitForExistence(timeout: .medium))
	
		let settingsLabel = moreCell.buttons[AccessibilityIdentifiers.Home.MoreInfoCell.settingsLabel]
		XCTAssertTrue(settingsLabel.waitForExistence(timeout: .medium))
	}

	func test_0011_HomeFlow_extrasmall() throws {
		app.setPreferredContentSizeCategory(accessibility: .normal, size: .XS)
		app.launch()

		// only run if home screen is present
		XCTAssertTrue(app.buttons[AccessibilityIdentifiers.Home.rightBarButtonDescription].waitForExistence(timeout: .medium))

		app.swipeUp()
		// assert cells
		let moreCell = app.cells[AccessibilityIdentifiers.Home.MoreInfoCell.moreCell]
		
		let shareLabel = moreCell.buttons[AccessibilityIdentifiers.Home.MoreInfoCell.shareLabel]
		XCTAssertTrue(shareLabel.waitForExistence(timeout: .medium))

		let faqLabel = moreCell.buttons[AccessibilityIdentifiers.Home.MoreInfoCell.faqLabel]
		XCTAssertTrue(faqLabel.waitForExistence(timeout: .medium))
		
		let socialMediaLabel = moreCell.buttons[AccessibilityIdentifiers.Home.MoreInfoCell.socialMediaLabel]
		XCTAssertTrue(socialMediaLabel.waitForExistence(timeout: .medium))

		let infoLabel = moreCell.buttons[AccessibilityIdentifiers.Home.MoreInfoCell.appInformationLabel]
		XCTAssertTrue(infoLabel.waitForExistence(timeout: .medium))
	
		let settingsLabel = moreCell.buttons[AccessibilityIdentifiers.Home.MoreInfoCell.settingsLabel]
		XCTAssertTrue(settingsLabel.waitForExistence(timeout: .medium))
	}

	func test_0013_HomeFlow_extralarge() throws {
		app.setPreferredContentSizeCategory(accessibility: .accessibility, size: .XL)
		app.launch()

		// only run if home screen is present
		XCTAssertTrue(app.buttons[AccessibilityIdentifiers.Home.rightBarButtonDescription].waitForExistence(timeout: .medium))

		app.swipeUp()
		app.swipeUp()
		// assert cells
		let moreCell = app.cells[AccessibilityIdentifiers.Home.MoreInfoCell.moreCell]

		let shareLabel = moreCell.buttons[AccessibilityIdentifiers.Home.MoreInfoCell.shareLabel]
		XCTAssertTrue(shareLabel.waitForExistence(timeout: .medium))

		let faqLabel = moreCell.buttons[AccessibilityIdentifiers.Home.MoreInfoCell.faqLabel]
		XCTAssertTrue(faqLabel.waitForExistence(timeout: .medium))
	
		let socialMediaLabel = moreCell.buttons[AccessibilityIdentifiers.Home.MoreInfoCell.socialMediaLabel]
		XCTAssertTrue(socialMediaLabel.waitForExistence(timeout: .medium))

		let infoLabel = moreCell.buttons[AccessibilityIdentifiers.Home.MoreInfoCell.appInformationLabel]
		XCTAssertTrue(infoLabel.waitForExistence(timeout: .medium))
	
		let settingsLabel = moreCell.buttons[AccessibilityIdentifiers.Home.MoreInfoCell.settingsLabel]
		XCTAssertTrue(settingsLabel.waitForExistence(timeout: .medium))
	}
	
	func test_homescreen_remove_positive_test_result() throws {
		app.setPreferredContentSizeCategory(accessibility: .accessibility, size: .XS)
		app.setLaunchArgument(LaunchArguments.test.pcr.testResult, to: TestResult.positive.stringValue)
		app.setLaunchArgument(LaunchArguments.test.pcr.positiveTestResultWasShown, to: true)
		app.setLaunchArgument(LaunchArguments.common.ENStatus, to: ENStatus.active.stringValue)
		app.launch()
		
		// only run if home screen is present
		XCTAssertTrue(app.buttons[AccessibilityIdentifiers.Home.ShownPositiveTestResultCell.removeTestButton].waitForExistence(timeout: .medium))

		// remove test
		app.buttons[AccessibilityIdentifiers.Home.ShownPositiveTestResultCell.removeTestButton].waitAndTap()
		
		// confirm deletion
		app.alerts.firstMatch.buttons.element(boundBy: 0).waitAndTap()
		
		// check if the pcr cell disappears
		XCTAssertFalse(app.cells[AccessibilityIdentifiers.Home.ShownPositiveTestResultCell.pcrCell].waitForExistence(timeout: .medium))
	}
	
	func test_homescreen_riskCardHigh_riskMultipleDays() throws {
		let riskLevel = "high"
		let numberOfDaysWithHighRisk = "4"
		app.setPreferredContentSizeCategory(accessibility: .accessibility, size: .XS)
		app.setLaunchArgument(LaunchArguments.risk.riskLevel, to: riskLevel)
		app.setLaunchArgument(LaunchArguments.risk.numberOfDaysWithRiskLevel, to: numberOfDaysWithHighRisk)
		app.setLaunchArgument(LaunchArguments.common.ENStatus, to: ENStatus.active.stringValue)
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
	}
	
	func test_homescreen_riskCardLow_riskMultipleDays() throws {
		let riskLevel = "low"
		let numberOfDaysWithLowRisk = "4"
		app.setPreferredContentSizeCategory(accessibility: .accessibility, size: .XS)
		app.setLaunchArgument(LaunchArguments.risk.riskLevel, to: riskLevel)
		app.setLaunchArgument(LaunchArguments.risk.numberOfDaysWithRiskLevel, to: numberOfDaysWithLowRisk)
		app.setLaunchArgument(LaunchArguments.common.ENStatus, to: ENStatus.active.stringValue)
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
	}
	
	func test_homescreen_riskCardLow_Ndays() throws {
		let riskLevel = "low"
		// change the value based on N
		let installationDays = "12"
		app.setPreferredContentSizeCategory(accessibility: .accessibility, size: .XS)
		app.setLaunchArgument(LaunchArguments.risk.riskLevel, to: riskLevel)
		app.setLaunchArgument(LaunchArguments.common.appInstallationDays, to: installationDays)
		app.setLaunchArgument(LaunchArguments.common.ENStatus, to: ENStatus.active.stringValue)
		app.launch()
	}
	
	func test_homescreen_riskCardLow_1day() throws {
		let riskLevel = "low"
		let installationDays = "1"
		app.setPreferredContentSizeCategory(accessibility: .accessibility, size: .XS)
		app.setLaunchArgument(LaunchArguments.risk.riskLevel, to: riskLevel)
		app.setLaunchArgument(LaunchArguments.common.appInstallationDays, to: installationDays)
		app.setLaunchArgument(LaunchArguments.common.ENStatus, to: ENStatus.active.stringValue)
		app.launch()
	}
	
	func test_homescreen_riskCardLow_0days() throws {
		let riskLevel = "low"
		let installationDays = "0"
		app.setPreferredContentSizeCategory(accessibility: .accessibility, size: .XS)
		app.setLaunchArgument(LaunchArguments.risk.riskLevel, to: riskLevel)
		app.setLaunchArgument(LaunchArguments.common.appInstallationDays, to: installationDays)
		app.setLaunchArgument(LaunchArguments.common.ENStatus, to: ENStatus.active.stringValue)
		app.launch()
	}
	
	func test_homescreen_riskCardInactive() throws {
		let riskLevel = "inactive"
		app.setPreferredContentSizeCategory(accessibility: .accessibility, size: .XS)
		app.setLaunchArgument(LaunchArguments.risk.riskLevel, to: riskLevel)
		app.setLaunchArgument(LaunchArguments.common.ENStatus, to: ENStatus.active.stringValue)
		app.launch()

		XCTAssertTrue(app.buttons[AccessibilityIdentifiers.Home.submitCardButton].waitForExistence(timeout: .short))

		// Inactive risk card title "Risiko-Ermittlung gestoppt"
		XCTAssertTrue(app.buttons[AccessibilityIdentifiers.Home.RiskTableViewCell.topContainer].waitForExistence(timeout: .short))
		
		XCTAssertTrue(app.buttons[AccessibilityIdentifiers.Home.rightBarButtonDescription].waitForExistence(timeout: .short))
	}
	

	func test_homescreen_riskCardHigh_disabledExposureLogging() throws {
		let riskLevel = "high"
		app.setPreferredContentSizeCategory(accessibility: .accessibility, size: .XS)
		app.setLaunchArgument(LaunchArguments.risk.riskLevel, to: riskLevel)
		app.setLaunchArgument(LaunchArguments.onboarding.isOnboarded, to: true)
		app.setLaunchArgument(LaunchArguments.common.ENStatus, to: ENStatus.disabled.stringValue)
		app.launch()

		XCTAssertTrue(app.buttons[AccessibilityIdentifiers.Home.RiskTableViewCell.topContainer].waitForExistence(timeout: .medium))
		XCTAssertTrue(app.buttons[AccessibilityIdentifiers.Home.submitCardButton].waitForExistence(timeout: .short))
	}
	
	func test_details_riskCardLow_riskOneDay_Ndays() throws {
		let riskLevel = "low"
		let installationDays = "12"
		// change the value based on N
		app.setPreferredContentSizeCategory(accessibility: .accessibility, size: .XS)
		app.setLaunchArgument(LaunchArguments.risk.riskLevel, to: riskLevel)
		app.setLaunchArgument(LaunchArguments.common.appInstallationDays, to: installationDays)
		app.setLaunchArgument(LaunchArguments.common.ENStatus, to: ENStatus.active.stringValue)
		app.launch()
		
		let riskCell = app.cells.element(boundBy: 1)
		riskCell.waitAndTap()
	}
	
	
	func test_homescreen_pcr_rat_negative() throws {
		app.setPreferredContentSizeCategory(accessibility: .accessibility, size: .XS)
		app.setLaunchArgument(LaunchArguments.test.common.showTestResultCards, to: true)
		app.setLaunchArgument(LaunchArguments.test.pcr.testResult, to: TestResult.negative.stringValue)
		app.setLaunchArgument(LaunchArguments.test.antigen.testResult, to: TestResult.negative.stringValue)
		app.launch()

		XCTAssertTrue(app.cells.element(boundBy: 2).waitForExistence(timeout: .medium))
	}

	// MARK: - Screenshots

	func test_screenshot_homescreen_riskCardHigh_riskOneDay() throws {
		var screenshotCounter = 0
		let riskLevel = "high"
		let numberOfDaysWithHighRisk = "1"
		app.setPreferredContentSizeCategory(accessibility: .accessibility, size: .XS)
		app.setLaunchArgument(LaunchArguments.risk.riskLevel, to: riskLevel)
		app.setLaunchArgument(LaunchArguments.risk.numberOfDaysWithRiskLevel, to: numberOfDaysWithHighRisk)
		app.setLaunchArgument(LaunchArguments.common.ENStatus, to: ENStatus.active.stringValue)
		app.launch()
		
		XCTAssertTrue(app.buttons[AccessibilityIdentifiers.Home.RiskTableViewCell.topContainer].waitForExistence(timeout: .medium))
		XCTAssertTrue(app.buttons[AccessibilityIdentifiers.Home.submitCardButton].waitForExistence(timeout: .short))

		// Red risk card title "Erhöhtes Risiko" – the localized text is used as accessibility identifier
		// see HomeRiskLevelCellConfigurator.setupAccessibility()
		XCTAssertTrue(app.buttons[AccessibilityLabels.localized(AppStrings.Home.riskCardHighTitle)].waitForExistence(timeout: .short))
		
		// find an element with localized text "Begegnungen an 1 Tag mit erhöhtem Risiko"
		let highRiskTitle = String(format: AccessibilityLabels.localized(AppStrings.Home.riskCardHighNumberContactsItemTitle), 1)
		XCTAssertTrue(app.otherElements[highRiskTitle].waitForExistence(timeout: .short))
		
		XCTAssertTrue(app.buttons[AccessibilityIdentifiers.Home.rightBarButtonDescription].waitForExistence(timeout: .short))
		snapshot("homescreenrisk_level_\(riskLevel)_risk_one_day_\(String(format: "%04d", (screenshotCounter.inc() )))")
	}

	func test_screenshot_homescreen_riskCardLow_riskNoDays() throws {
		var screenshotCounter = 0
		let riskLevel = "low"
		let numberOfDaysWithLowRisk = 0
		app.setPreferredContentSizeCategory(accessibility: .accessibility, size: .XS)
		app.setLaunchArgument(LaunchArguments.risk.riskLevel, to: riskLevel)
		app.setLaunchArgument(LaunchArguments.common.ENStatus, to: ENStatus.active.stringValue)
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
	}

	func test_screenshot_homescreen_riskCardLow_riskOneDay() throws {
		var screenshotCounter = 0
		let riskLevel = "low"
		let numberOfDaysWithLowRisk = "1"
		app.setPreferredContentSizeCategory(accessibility: .accessibility, size: .XS)
		app.setLaunchArgument(LaunchArguments.risk.riskLevel, to: riskLevel)
		app.setLaunchArgument(LaunchArguments.risk.numberOfDaysWithRiskLevel, to: numberOfDaysWithLowRisk)
		app.setLaunchArgument(LaunchArguments.common.ENStatus, to: ENStatus.active.stringValue)
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
	}

	func test_screenshot_homescreen_riskCardLow_14days() throws {
		var screenshotCounter = 0
		let riskLevel = "low"
		let installationDays = "14"
		app.setPreferredContentSizeCategory(accessibility: .accessibility, size: .XS)
		app.setLaunchArgument(LaunchArguments.risk.riskLevel, to: riskLevel)
		app.setLaunchArgument(LaunchArguments.common.appInstallationDays, to: installationDays)
		app.setLaunchArgument(LaunchArguments.common.ENStatus, to: ENStatus.active.stringValue)
		app.launch()
		
		snapshot("homescreenrisk_level_\(riskLevel)_installation_14days_\(String(format: "%04d", (screenshotCounter.inc() )))")
	}

	
	func test_screenshot_homescreen_invalid_test_result() throws {
		var screenshotCounter = 0
		let riskLevel = "low"
		let numberOfDaysWithLowRisk = "1"
		app.setPreferredContentSizeCategory(accessibility: .accessibility, size: .XS)
		app.setLaunchArgument(LaunchArguments.risk.riskLevel, to: riskLevel)
		app.setLaunchArgument(LaunchArguments.risk.numberOfDaysWithRiskLevel, to: numberOfDaysWithLowRisk)
		app.setLaunchArgument(LaunchArguments.test.pcr.testResult, to: TestResult.invalid.stringValue)
		app.setLaunchArgument(LaunchArguments.common.ENStatus, to: ENStatus.active.stringValue)
		app.launch()

		snapshot("homescreenrisk_show_invalid_test_result_\(String(format: "%04d", (screenshotCounter.inc() )))")
	}

	func test_screenshot_homescreen_pending_test_result() throws {
		var screenshotCounter = 0
		let riskLevel = "low"
		let numberOfDaysWithLowRisk = "1"
		app.setPreferredContentSizeCategory(accessibility: .accessibility, size: .XS)
		app.setLaunchArgument(LaunchArguments.risk.riskLevel, to: riskLevel)
		app.setLaunchArgument(LaunchArguments.risk.numberOfDaysWithRiskLevel, to: numberOfDaysWithLowRisk)
		app.setLaunchArgument(LaunchArguments.test.pcr.testResult, to: TestResult.pending.stringValue)
		app.setLaunchArgument(LaunchArguments.common.ENStatus, to: ENStatus.active.stringValue)
		app.launch()

		snapshot("homescreenrisk_show_pending_test_result_\(String(format: "%04d", (screenshotCounter.inc() )))")
	}
	
	func test_screenshot_homescreen_negative_test_result() throws {
		var screenshotCounter = 0
		let riskLevel = "low"
		let numberOfDaysWithLowRisk = "1"
		app.setPreferredContentSizeCategory(accessibility: .accessibility, size: .XS)
		app.setLaunchArgument(LaunchArguments.risk.riskLevel, to: riskLevel)
		app.setLaunchArgument(LaunchArguments.risk.numberOfDaysWithRiskLevel, to: numberOfDaysWithLowRisk)
		app.setLaunchArgument(LaunchArguments.test.pcr.testResult, to: TestResult.negative.stringValue)
		app.setLaunchArgument(LaunchArguments.common.ENStatus, to: ENStatus.active.stringValue)
		app.launch()

		snapshot("homescreenrisk_show_negative_test_result_\(String(format: "%04d", (screenshotCounter.inc() )))")
	}
	
	func test_screenshot_homescreen_positive_test_result() throws {
		var screenshotCounter = 0
		app.setPreferredContentSizeCategory(accessibility: .accessibility, size: .XS)
		// we just need one launch argument because it is handled separately
		app.setLaunchArgument(LaunchArguments.test.pcr.testResult, to: TestResult.positive.stringValue)
		app.setLaunchArgument(LaunchArguments.test.pcr.positiveTestResultWasShown, to: true)
		app.setLaunchArgument(LaunchArguments.common.ENStatus, to: ENStatus.active.stringValue)
		app.launch()

		snapshot("homescreenrisk_show_positive_test_result_\(String(format: "%04d", (screenshotCounter.inc() )))")
	}
}
