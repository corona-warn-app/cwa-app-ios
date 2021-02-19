//
// 🦠 Corona-Warn-App
//

import XCTest
import ExposureNotification

class ENAUITests_00_Onboarding: XCTestCase {
	var app: XCUIApplication!

	override func setUp() {
		super.setUp()
		continueAfterFailure = false
		app = XCUIApplication()
		setupSnapshot(app)
		app.setDefaults()
		app.launchArguments.append(contentsOf: ["-isOnboarded", "NO"])
		app.launchArguments.append(contentsOf: ["-isDatadonationConsentGiven", "NO"])
		app.launchArguments.append(contentsOf: ["-ENStatus", ENStatus.unknown.stringValue])
	}

	override func tearDownWithError() throws {
		// Put teardown code here. This method is called after the invocation of each test method in the class.
	}

	func test_0000_OnboardingFlow_DisablePermissions_normal_XXXL() throws {
		app.setPreferredContentSizeCategory(accessibililty: .normal, size: .XXXL)
		app.launch()

		// only run if onboarding screen is present
		XCTAssert(app.staticTexts["AppStrings.Onboarding.onboardingInfo_togetherAgainstCoronaPage_title"].waitForExistence(timeout: 5.0))

		// tap through the onboarding screens
		// snapshot("ScreenShot_\(#function)_0000")
		XCTAssertTrue(app.buttons["AppStrings.Onboarding.onboardingLetsGo"].waitForExistence(timeout: 5.0))
		app.buttons["AppStrings.Onboarding.onboardingLetsGo"].tap()
		// snapshot("ScreenShot_\(#function)_0001")
		XCTAssertTrue(app.buttons["AppStrings.Onboarding.onboardingContinue"].waitForExistence(timeout: 5.0))
		app.buttons["AppStrings.Onboarding.onboardingContinue"].tap()
		// snapshot("ScreenShot_\(#function)_0002")
		XCTAssertTrue(app.buttons["AppStrings.Onboarding.onboardingInfo_enableLoggingOfContactsPage_button"].waitForExistence(timeout: 5.0))
		app.buttons["AppStrings.Onboarding.onboardingInfo_enableLoggingOfContactsPage_button"].tap()
		// snapshot("ScreenShot_\(#function)_0003")
		XCTAssertTrue(app.buttons["AppStrings.Onboarding.onboardingContinue"].waitForExistence(timeout: 5.0))
		app.buttons["AppStrings.Onboarding.onboardingContinue"].tap()
		// snapshot("ScreenShot_\(#function)_0004")
		XCTAssertTrue(app.buttons["AppStrings.Onboarding.onboardingDoNotAllow"].waitForExistence(timeout: 5.0))
		app.buttons["AppStrings.Onboarding.onboardingDoNotAllow"].tap()
		// data consent switch must only be visible on settings-data-donation.
		
		XCTAssertFalse(app.switches[AccessibilityIdentifiers.DataDonation.consentSwitch].waitForExistence(timeout: .short))

		// We should only see the two fields. The region should be visible if we tapped on federal state.
		XCTAssertTrue(app.cells[AccessibilityIdentifiers.DataDonation.federalStateName].waitForExistence(timeout: .short))
		XCTAssertFalse(app.cells[AccessibilityIdentifiers.DataDonation.regionName].waitForExistence(timeout: .short))
		XCTAssertTrue(app.cells[AccessibilityIdentifiers.DataDonation.ageGroup].waitForExistence(timeout: .short))

		// Tap on federalState cell. Now we should see the key-value screen and select some.
		app.cells[AccessibilityIdentifiers.DataDonation.federalStateName].tap()
		XCTAssertTrue(app.tables[AccessibilityIdentifiers.DataDonation.federalStateCell].waitForExistence(timeout: .short))

		// Tap on some data entry. Then we should be back on the data donation screen.
		app.cells.element(boundBy: 7).tap()

		// Now we should see the three data fields.
		XCTAssertTrue(app.cells[AccessibilityIdentifiers.DataDonation.federalStateName].waitForExistence(timeout: .short))
		XCTAssertTrue(app.cells[AccessibilityIdentifiers.DataDonation.regionName].waitForExistence(timeout: .short))
		XCTAssertTrue(app.cells[AccessibilityIdentifiers.DataDonation.ageGroup].waitForExistence(timeout: .short))

		// Now we want to select a district. So tap onto the district cell, choose one and return to dataDonation.
		app.cells[AccessibilityIdentifiers.DataDonation.regionName].tap()
		
		XCTAssertTrue(app.tables[AccessibilityIdentifiers.DataDonation.regionCell].waitForExistence(timeout: .short))
		app.cells.element(boundBy: 8).tap()
		XCTAssertTrue(app.cells[AccessibilityIdentifiers.DataDonation.ageGroup].waitForExistence(timeout: .short))

		// Now we want to select a ageGroup. So tap onto the ageGroup cell, choose one and return to dataDonation.
		app.cells[AccessibilityIdentifiers.DataDonation.ageGroup].tap()
		XCTAssertTrue(app.tables[AccessibilityIdentifiers.DataDonation.ageGroupCell].waitForExistence(timeout: .short))
		app.cells.element(boundBy: 7).tap()
		XCTAssertTrue(app.cells[AccessibilityIdentifiers.DataDonation.ageGroup].waitForExistence(timeout: .short))

		XCTAssertFalse(app.switches[AccessibilityIdentifiers.DataDonation.consentSwitch].waitForExistence(timeout: .short))

		// Now proceed with onboarding
		XCTAssertTrue(app.buttons[AccessibilityIdentifiers.General.primaryFooterButton].waitForExistence(timeout: 5.0))
		app.buttons[AccessibilityIdentifiers.General.secondaryFooterButton].tap()

		// check that the homescreen element AppStrings.home.activateTitle is visible onscreen
		XCTAssert(app.buttons[AccessibilityIdentifiers.Home.rightBarButtonDescription].waitForExistence(timeout: 5.0))
	}

	func test_0001_OnboardingFlow_EnablePermissions_normal_XS() throws {
		app.setPreferredContentSizeCategory(accessibililty: .normal, size: .XS)
		app.launch()

		// only run if onboarding screen is present
		XCTAssert(app.staticTexts["AppStrings.Onboarding.onboardingInfo_togetherAgainstCoronaPage_title"].waitForExistence(timeout: 5.0))

		// tap through the onboarding screens
		// snapshot("ScreenShot_\(#function)_0000")
		XCTAssertTrue(app.buttons["AppStrings.Onboarding.onboardingLetsGo"].waitForExistence(timeout: 5.0))
		app.buttons["AppStrings.Onboarding.onboardingLetsGo"].tap()
		// snapshot("ScreenShot_\(#function)_0001")
		XCTAssertTrue(app.buttons["AppStrings.Onboarding.onboardingContinue"].waitForExistence(timeout: 5.0))
		app.buttons["AppStrings.Onboarding.onboardingContinue"].tap()
		// snapshot("ScreenShot_\(#function)_0002")
		XCTAssertTrue(app.buttons["AppStrings.Onboarding.onboardingInfo_enableLoggingOfContactsPage_button"].waitForExistence(timeout: 5.0))
		app.buttons["AppStrings.Onboarding.onboardingInfo_enableLoggingOfContactsPage_button"].tap()
		// snapshot("ScreenShot_\(#function)_0003")
		XCTAssertTrue(app.buttons["AppStrings.Onboarding.onboardingContinue"].waitForExistence(timeout: 5.0))
		app.buttons["AppStrings.Onboarding.onboardingContinue"].tap()
		// snapshot("ScreenShot_\(#function)_0004")
		XCTAssertTrue(app.buttons["AppStrings.Onboarding.onboardingContinue"].waitForExistence(timeout: 5.0))
		app.buttons["AppStrings.Onboarding.onboardingContinue"].tap()
		// data consent switch must only be visible on settings-data-donation.
		XCTAssertFalse(app.switches[AccessibilityIdentifiers.DataDonation.consentSwitch].waitForExistence(timeout: .short))

		// We should only see the two fields. The region should be visible if we tapped on federal state.
		XCTAssertTrue(app.cells[AccessibilityIdentifiers.DataDonation.federalStateName].waitForExistence(timeout: .short))
		XCTAssertFalse(app.cells[AccessibilityIdentifiers.DataDonation.regionName].waitForExistence(timeout: .short))
		XCTAssertTrue(app.cells[AccessibilityIdentifiers.DataDonation.ageGroup].waitForExistence(timeout: .short))

		// Tap on federalState cell. Now we should see the key-value screen and select some.
		app.cells[AccessibilityIdentifiers.DataDonation.federalStateName].tap()
		XCTAssertTrue(app.tables[AccessibilityIdentifiers.DataDonation.federalStateCell].waitForExistence(timeout: .short))

		// Tap on some data entry. Then we should be back on the data donation screen.
		app.cells.element(boundBy: 7).tap()

		// Now we should see the three data fields.
		XCTAssertTrue(app.cells[AccessibilityIdentifiers.DataDonation.federalStateName].waitForExistence(timeout: .short))
		XCTAssertTrue(app.cells[AccessibilityIdentifiers.DataDonation.regionName].waitForExistence(timeout: .short))
		XCTAssertTrue(app.cells[AccessibilityIdentifiers.DataDonation.ageGroup].waitForExistence(timeout: .short))

		// Now we want to select a district. So tap onto the district cell, choose one and return to dataDonation.
		app.cells[AccessibilityIdentifiers.DataDonation.regionName].tap()
		
		XCTAssertTrue(app.tables[AccessibilityIdentifiers.DataDonation.regionCell].waitForExistence(timeout: .short))
		app.cells.element(boundBy: 8).tap()
		XCTAssertTrue(app.cells[AccessibilityIdentifiers.DataDonation.ageGroup].waitForExistence(timeout: .short))

		// Now we want to select a ageGroup. So tap onto the ageGroup cell, choose one and return to dataDonation.
		app.cells[AccessibilityIdentifiers.DataDonation.ageGroup].tap()
		XCTAssertTrue(app.tables[AccessibilityIdentifiers.DataDonation.ageGroupCell].waitForExistence(timeout: .short))
		app.cells.element(boundBy: 7).tap()
		XCTAssertTrue(app.cells[AccessibilityIdentifiers.DataDonation.ageGroup].waitForExistence(timeout: .short))

		XCTAssertFalse(app.switches[AccessibilityIdentifiers.DataDonation.consentSwitch].waitForExistence(timeout: .short))

		// Now proceed with onboarding
		XCTAssertTrue(app.buttons[AccessibilityIdentifiers.General.primaryFooterButton].waitForExistence(timeout: 5.0))
		app.buttons[AccessibilityIdentifiers.General.secondaryFooterButton].tap()

		// check that the homescreen element AppStrings.home.activateTitle is visible onscreen
		XCTAssert(app.buttons[AccessibilityIdentifiers.Home.rightBarButtonDescription].waitForExistence(timeout: 5.0))
	}

	
	// MARK: -

	func test_0002_Screenshots_OnboardingFlow_EnablePermissions_normal_S() throws {
		var screenshotCounter = 0
		app.launchArguments.append(contentsOf: ["-userNeedsToBeInformedAboutHowRiskDetectionWorks", "YES"])
		app.setPreferredContentSizeCategory(accessibililty: .normal, size: .S)
		app.launch()
		
		let prefix = "OnboardingFlow_EnablePermission_"
		
		snapshot(prefix + (String(format: "%04d", (screenshotCounter.inc() ))))
		
		app.buttons["AppStrings.Onboarding.onboardingLetsGo"].tap()
		snapshot(prefix + (String(format: "%04d", (screenshotCounter.inc() ))))
		app.swipeUp()
		snapshot(prefix + (String(format: "%04d", (screenshotCounter.inc() ))))
		app.swipeUp()
		snapshot(prefix + (String(format: "%04d", (screenshotCounter.inc() ))))
		
		app.buttons["AppStrings.Onboarding.onboardingContinue"].tap()
		snapshot(prefix + (String(format: "%04d", (screenshotCounter.inc() ))))
		app.swipeUp()
		snapshot(prefix + (String(format: "%04d", (screenshotCounter.inc() ))))
		app.swipeUp()
		snapshot(prefix + (String(format: "%04d", (screenshotCounter.inc() ))))
		
		app.buttons["AppStrings.Onboarding.onboardingInfo_enableLoggingOfContactsPage_button"].tap()
		snapshot(prefix + (String(format: "%04d", (screenshotCounter.inc() ))))
		
		app.buttons["AppStrings.Onboarding.onboardingContinue"].tap()
		snapshot(prefix + (String(format: "%04d", (screenshotCounter.inc() ))))
		
		app.buttons["AppStrings.Onboarding.onboardingContinue"].tap()
		snapshot(prefix + (String(format: "%04d", (screenshotCounter.inc() ))))

		app.buttons[AccessibilityIdentifiers.General.primaryFooterButton].tap()
		snapshot(prefix + (String(format: "%04d", (screenshotCounter.inc() ))))
		
//		Onboarding ends here. Next screen is the home screen.
	}
}
