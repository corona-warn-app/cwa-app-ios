////
// 🦠 Corona-Warn-App
//

import XCTest

class CreateHealthCertificate: XCTestCase {

	// MARK: - Overrides

	override func setUp() {
		super.setUp()
		continueAfterFailure = false
		app = XCUIApplication()
		app.setDefaults()
		app.launchArguments.append(contentsOf: ["-isOnboarded", YES])
		app.launchArguments.append(contentsOf: ["-setCurrentOnboardingVersion", YES])
		app.launchArguments.append(contentsOf: ["-antigenTestProfileInfoScreenShown", NO])
		app.launchArguments.append(contentsOf: ["-removeAntigenTestProfile", YES])
	}

	// MARK: - Internal

	var app: XCUIApplication!

	// MARK: - Tests

	func test_FIRST_CreateAntigenTestProfile_THEN_DeleteProfile() throws {

		app.launch()

		/// Home Screen
		let registerCertificateTitle = try XCTUnwrap(app.buttons[AccessibilityIdentifiers.Home.registerHealthCertificateButton])
		XCTAssertTrue(registerCertificateTitle.waitForExistence(timeout: .short))
		registerCertificateTitle.tap()

		// HealthCertificate consent screen tap on disclaimer
		let disclaimerButton = try XCTUnwrap(app.cells[AccessibilityIdentifiers.HealthCertificate.Info.disclaimer])
		XCTAssertTrue(disclaimerButton.waitForExistence(timeout: .short))
		disclaimerButton.tap()

		// data privacy
		let backButton = try XCTUnwrap(app.navigationBars.buttons.element(boundBy: 0))
		XCTAssertTrue(backButton.waitForExistence(timeout: .short))
		backButton.tap()

		// HealthCertificate consent screen
		let primaryButton = try XCTUnwrap(app.buttons[AccessibilityIdentifiers.General.primaryFooterButton])
		XCTAssertTrue(primaryButton.waitForExistence(timeout: .short))
		primaryButton.tap()

		// QRCode Scanner - close via flash will submit a healthCertificate
		let flashBarButton = try XCTUnwrap(app.buttons[AccessibilityIdentifiers.ExposureSubmissionQRScanner.flash])
		flashBarButton.waitAndTap(.short)

		// Certified Person screen
		let continuePrimaryButton = try XCTUnwrap(app.cells[AccessibilityIdentifiers.HealthCertificate.Person.certificateCell])
		continuePrimaryButton.waitAndTap(.short)

		// Certificate Screen

	}
}
