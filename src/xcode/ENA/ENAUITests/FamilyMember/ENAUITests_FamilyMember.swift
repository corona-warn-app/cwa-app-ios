//
// 🦠 Corona-Warn-App
//

import XCTest

class ENAUITests_FamilyMember: CWATestCase {

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

	func test_RegisterCoronaTestFromUniversalQRCodeScanner() throws {
		app.launch()

		app.buttons[AccessibilityIdentifiers.TabBar.scanner].waitAndTap()

		/// Simulator only Alert will open where you can choose what the QRScanner should scan
		let pcrButton = try XCTUnwrap(app.buttons[AccessibilityIdentifiers.UniversalQRScanner.fakePCR])
		pcrButton.waitAndTap()

		/// Select user as test owner
		let userButton = try XCTUnwrap(app.cells[AccessibilityIdentifiers.ExposureSubmission.TestOwnerSelection.familyMemberButton])
		userButton.waitAndTap()

		/// Exposure submission family member consent screen
		XCTAssertTrue(app.images[AccessibilityIdentifiers.HealthCertificate.FamilyMemberConsent.imageDescription].waitForExistence(timeout: .short))
		XCTAssertTrue(app.cells[AccessibilityIdentifiers.HealthCertificate.FamilyMemberConsent.Legal.acknowledgementTitle].waitForExistence(timeout: .short))

		/// data privacy screen
		app.cells[AccessibilityIdentifiers.HealthCertificate.FamilyMemberConsent.dataPrivacyTitle].waitAndTap()
		XCTAssertTrue(app.staticTexts["AppStrings.AppInformation.privacyTitle"].waitForExistence(timeout: .short))

		/// back navigation
		app.navigationBars.firstMatch.buttons.element(boundBy: 0).waitAndTap()

		/// primary button
		let primaryButton = try XCTUnwrap(app.buttons[AccessibilityIdentifiers.HealthCertificate.FamilyMemberConsent.primaryButton])
		XCTAssertFalse(primaryButton.isEnabled)

		/// Exposure submission family member consent screen
		let textField = try XCTUnwrap(app.textFields[AccessibilityIdentifiers.HealthCertificate.FamilyMemberConsent.textInput])
		textField.waitAndTap(.short)
		textField.typeText("Lara")

		/// primary button enabled after name was given
		XCTAssertTrue(primaryButton.isEnabled)
		primaryButton.waitAndTap(.short)

		/// test certificate consent screen
		XCTAssertTrue(app.images[AccessibilityIdentifiers.ExposureSubmission.TestCertificate.Info.imageDescription].waitForExistence(timeout: .short))
		app.buttons[AccessibilityIdentifiers.AccessibilityLabel.close].waitAndTap()

		/// close alert
		app.alerts.buttons[AccessibilityIdentifiers.ExposureSubmission.TestCertificate.Alert.cancelRegistration].waitAndTap()

		/// home screen reached
		app.cells[AccessibilityIdentifiers.Home.activateCardOffTitle].wait()
	}

}
