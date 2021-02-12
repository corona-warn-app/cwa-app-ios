////
// 🦠 Corona-Warn-App
//

import XCTest

class ENAUITestsDataDonation: XCTestCase {
	var app: XCUIApplication!

	override func setUp() {
		super.setUp()
		continueAfterFailure = false
		app = XCUIApplication()
		app.setDefaults()
		app.launchArguments.append(contentsOf: ["-resetFinishedDeltaOnboardings", "YES"])
		app.launchArguments.append(contentsOf: ["-userNeedsToBeInformedAboutHowRiskDetectionWorks", "NO"])
	}

	// Tests if the data donation screen is shown during the delta onboarding.
	func test_NavigationThroughDeltaOnboardingShowsDataDonation() throws {
		// check if delta onboarding can be modified to check if screen is shown there
	}

	// Tests if the data donation screen is shown at the settings and if the screen has the different behavior as the one in the onboarding.
	func test_NavigationToSettingsDataDonation() throws {
		// check if settings can be modified to check if screen is shown there
	}

	// Tests if the data in the onboarding data donation screen is set is shown correctly in the settings data donation.
	func test_LogicOfDataDonationViewControllersWorks() throws {
		// test here if key value screens-logic works

	}


}
