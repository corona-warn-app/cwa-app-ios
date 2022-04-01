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
		// launch argument will make
		app.setLaunchArgument(LaunchArguments.familyTest.pcr.testResult, to: TestResult.positive.stringValue)
		app.setLaunchArgument(LaunchArguments.familyTest.pcr.positiveTestResultWasShown, to: true)

		app.launch()
		app.buttons[AccessibilityIdentifiers.TabBar.scanner].waitAndTap()

		/// Simulator only Alert will open where you can choose what the QRScanner should scan
		let pcrButton = try XCTUnwrap(app.buttons[AccessibilityIdentifiers.UniversalQRScanner.fakePCR])
		pcrButton.waitAndTap()

		/// Select family member as test owner
		let familyButton = try XCTUnwrap(app.cells[AccessibilityIdentifiers.ExposureSubmission.TestOwnerSelection.familyMemberButton])
		familyButton.waitAndTap()

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
		app.buttons[AccessibilityIdentifiers.General.secondaryFooterButton].waitAndTap()

		/// test certificate screen
		app.buttons[AccessibilityIdentifiers.AccessibilityLabel.close].waitAndTap()

		/// home screen reached
		XCTAssertTrue(app.cells[AccessibilityIdentifiers.FamilyMemberCoronaTestCell.homeCell].exists)

	}

}
