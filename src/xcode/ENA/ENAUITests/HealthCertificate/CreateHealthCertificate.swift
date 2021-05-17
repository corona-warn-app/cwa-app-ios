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

		// HealthCertificate consent screen -> qr code scanner
		let primaryButton = try XCTUnwrap(app.buttons[AccessibilityIdentifiers.General.primaryFooterButton])
		XCTAssertTrue(primaryButton.waitForExistence(timeout: .short))
		primaryButton.tap()

		// will disappear in simulator automatically
		let headline = try XCTUnwrap(app.staticTexts[AccessibilityIdentifiers.HealthCertificate.Person.title])
		XCTAssertTrue(headline.waitForExistence(timeout: .short))
	}
}
