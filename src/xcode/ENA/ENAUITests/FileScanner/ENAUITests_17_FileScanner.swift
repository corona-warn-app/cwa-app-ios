//
// 🦠 Corona-Warn-App
//

import XCTest

class ENAUITests_17_FileScanner: CWATestCase {

	var app: XCUIApplication!

    override func setUpWithError() throws {
		try super.setUpWithError()
		continueAfterFailure = false
		app = XCUIApplication()
		setupSnapshot(app)
		app.setDefaults()
		app.setLaunchArgument(LaunchArguments.onboarding.isOnboarded, to: true)
		app.setLaunchArgument(LaunchArguments.onboarding.setCurrentOnboardingVersion, to: true)
    }

	func test_OpenUniversamScannerAndSelectFile_CheckForSheet() throws {
		app.setLaunchArgument(LaunchArguments.infoScreen.checkinInfoScreenShown, to: true)
		app.launch()

		app.buttons[AccessibilityIdentifiers.TabBar.scanner].waitAndTap()

		/// Simulator only Alert will open where you can choose what the QRScanner should scan
		let otherButton = try XCTUnwrap(app.buttons[AccessibilityIdentifiers.UniversalQRScanner.other])
		otherButton.waitAndTap()

		let openFileButton = try XCTUnwrap(app.buttons[AccessibilityIdentifiers.UniversalQRScanner.file])
		openFileButton.waitAndTap()
	}

}
