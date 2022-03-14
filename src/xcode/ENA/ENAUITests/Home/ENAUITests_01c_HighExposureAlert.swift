//
// 🦠 Corona-Warn-App
//

import XCTest

class ENAUITests_01c_HighExposureAlert: XCTestCase {

	var app: XCUIApplication!

	override func setUp() {
		super.setUp()
		continueAfterFailure = false
		app = XCUIApplication()
		app.setDefaults()
		app.setLaunchArgument(LaunchArguments.onboarding.isOnboarded, to: true)
		app.setLaunchArgument(LaunchArguments.onboarding.setCurrentOnboardingVersion, to: true)
		app.setLaunchArgument(LaunchArguments.infoScreen.userNeedsToBeInformedAboutHowRiskDetectionWorks, to: false)
	}

	func test_StoreHasBool_AlertGetsShown() {
		app.setLaunchArgument(LaunchArguments.risk.anotherHighEncounter, to: true)
		app.launch()
		app.alerts.buttons[AccessibilityIdentifiers.Home.Alerts.anotherHighExposureButtonOK].waitAndTap()
	}

}
