//
// 🦠 Corona-Warn-App
//

import XCTest

class ENAUITests_FileScanner: CWATestCase {

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

	func test_OpenUniversalScannerAndSelectFile_CheckForSheet() throws {
		app.setLaunchArgument(LaunchArguments.infoScreen.checkinInfoScreenShown, to: true)
		app.launch()

		app.buttons[AccessibilityIdentifiers.TabBar.scanner].waitAndTap()

		/// Simulator only Alert will open where you can choose what the QRScanner should scan
		let otherButton = try XCTUnwrap(app.buttons[AccessibilityIdentifiers.UniversalQRScanner.other])
		otherButton.waitAndTap()

		let openFileButton = try XCTUnwrap(app.buttons[AccessibilityIdentifiers.UniversalQRScanner.file])
		openFileButton.waitAndTap()

		let cancelSheetButton = try XCTUnwrap(app.buttons[AccessibilityIdentifiers.FileScanner.cancelSheet])
		cancelSheetButton.waitAndTap()
	}

	func test_OpenUniversalScannerAndSelectFile_OpensDocumentPicker() throws {
		app.setLaunchArgument(LaunchArguments.infoScreen.checkinInfoScreenShown, to: true)
		app.launch()

		app.buttons[AccessibilityIdentifiers.TabBar.scanner].waitAndTap()

		/// Simulator only Alert will open where you can choose what the QRScanner should scan
		let otherButton = try XCTUnwrap(app.buttons[AccessibilityIdentifiers.UniversalQRScanner.other])
		otherButton.waitAndTap()

		let sheetOpenFileButton = try XCTUnwrap(app.buttons[AccessibilityIdentifiers.UniversalQRScanner.file])
		sheetOpenFileButton.waitAndTap()

		let fileButton = try XCTUnwrap(app.buttons[AccessibilityIdentifiers.FileScanner.file])
		fileButton.waitAndTap()

		let pickerView = try XCTUnwrap(app.navigationBars["UIDocumentPickerView"])
		XCTAssertTrue(pickerView.waitForExistence(timeout: .medium))
	}

	func test_OpenUniversalScannerAndSelectFile_OpenImage() throws {
		app.setLaunchArgument(LaunchArguments.infoScreen.checkinInfoScreenShown, to: true)
		app.launch()

		app.buttons[AccessibilityIdentifiers.TabBar.scanner].waitAndTap()

		/// Simulator only Alert will open where you can choose what the QRScanner should scan
		let otherButton = try XCTUnwrap(app.buttons[AccessibilityIdentifiers.UniversalQRScanner.other])
		otherButton.waitAndTap()

		let openFileButton = try XCTUnwrap(app.buttons[AccessibilityIdentifiers.UniversalQRScanner.file])
		openFileButton.waitAndTap()

		let photoButton = try XCTUnwrap(app.buttons[AccessibilityIdentifiers.FileScanner.photo])
		photoButton.wait()
	}
}
