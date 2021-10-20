//
// 🦠 Corona-Warn-App
//

import XCTest

class ENAUITests_18_RecycleBin: CWATestCase {
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

	func test_RecycleBinCertificateFlow() throws {
		app.setLaunchArgument(LaunchArguments.infoScreen.healthCertificateInfoScreenShown, to: true)
		app.launch()

		// Wait until Home Screen is ready
		XCTAssertTrue(app.buttons[AccessibilityIdentifiers.Home.rightBarButtonDescription].waitForExistence(timeout: .medium))

		// Open Recycling Bin screen
		let moreCell = app.cells[AccessibilityIdentifiers.Home.MoreInfoCell.moreCell]
		let recycleBinLabel = moreCell.buttons[AccessibilityIdentifiers.Home.MoreInfoCell.recycleBinLabel]
		recycleBinLabel.waitAndTap()
		
		XCTAssertTrue(app.staticTexts[AccessibilityLabels.localized(AppStrings.RecycleBin.title)].waitForExistence(timeout: .short))

		// Check that empty state is shown
		XCTAssertTrue(app.staticTexts[AccessibilityLabels.localized(AppStrings.RecycleBin.EmptyState.title)].waitForExistence(timeout: .short))
		XCTAssertTrue(app.staticTexts[AccessibilityLabels.localized(AppStrings.RecycleBin.EmptyState.description)].waitForExistence(timeout: .short))

		// Add new health certificate via universal scanner from the tab bar
		app.buttons[AccessibilityIdentifiers.TabBar.scanner].waitAndTap()

		/// Simulator only Alert will open where you can choose what the QRScanner should scan
		let certificateButton = try XCTUnwrap(app.buttons[AccessibilityIdentifiers.UniversalQRScanner.fakeHC1])
		certificateButton.waitAndTap()

		let headlineCell = try XCTUnwrap(app.cells[AccessibilityIdentifiers.HealthCertificate.Certificate.headline])
		XCTAssertTrue(headlineCell.waitForExistence(timeout: .short))

		// Immediately delete certificate
		app.buttons[AccessibilityIdentifiers.General.secondaryFooterButton].waitAndTap()
		app.buttons[AccessibilityIdentifiers.HealthCertificate.Certificate.deleteButton].waitAndTap()
		app.buttons[AccessibilityIdentifiers.HealthCertificate.Certificate.deletionConfirmationButton].waitAndTap()

		// Check that deleted item is now visible
		let recycleBinItemCell = try XCTUnwrap(app.cells[AccessibilityIdentifiers.RecycleBin.itemCell])
		XCTAssertTrue(recycleBinItemCell.waitForExistence(timeout: .short))

		// Check that certificates tab is empty
		app.buttons[AccessibilityIdentifiers.TabBar.certificates].waitAndTap()

		XCTAssertTrue(app.staticTexts[AccessibilityLabels.localized(AppStrings.HealthCertificate.Overview.emptyTitle)].waitForExistence(timeout: .short))

		// Switch back to recycle bin to restore item
		app.buttons[AccessibilityIdentifiers.TabBar.home].waitAndTap()
		recycleBinItemCell.waitAndTap()
		app.buttons[AccessibilityIdentifiers.RecycleBin.restorationConfirmationButton].waitAndTap()

		// Check that empty state is shown again
		XCTAssertTrue(app.staticTexts[AccessibilityLabels.localized(AppStrings.RecycleBin.EmptyState.title)].waitForExistence(timeout: .short))

		// Check that certificate is restored
		app.buttons[AccessibilityIdentifiers.TabBar.certificates].waitAndTap()

		let personCell = try XCTUnwrap(app.cells[AccessibilityIdentifiers.HealthCertificate.Overview.healthCertifiedPersonCell])
		XCTAssertTrue(personCell.waitForExistence(timeout: .short))
	}

}
