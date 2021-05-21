////
// 🦠 Corona-Warn-App
//

import XCTest

class ENAUITests_13_CreateHealthCertificate: XCTestCase {

	// MARK: - Overrides

	override func setUp() {
		super.setUp()
		continueAfterFailure = false
		app = XCUIApplication()
		app.setDefaults()
		app.launchArguments.append(contentsOf: [UITestingLaunchArguments.onboarding.isOnboarded, YES])
		app.launchArguments.append(contentsOf: [UITestingLaunchArguments.onboarding.setCurrentOnboardingVersion, YES])
	}

	// MARK: - Internal

	var app: XCUIApplication!

	// MARK: - Tests

	func test_shownConsentScreenAndDisclaimer() throws {
		app.launch()

		/// Home Screen
		let registerCertificateTitle = try XCTUnwrap(app.buttons[AccessibilityIdentifiers.Home.registerHealthCertificateButton])
		registerCertificateTitle.waitAndTap()

		// HealthCertificate consent screen tap on disclaimer
		let disclaimerButton = try XCTUnwrap(app.cells[AccessibilityIdentifiers.HealthCertificate.Info.disclaimer])
		disclaimerButton.waitAndTap()

		// data privacy
		let backButton = try XCTUnwrap(app.navigationBars.buttons.element(boundBy: 0))
		backButton.waitAndTap()
	}

	func test_CreateAntigenTestProfileWithFirstCertificate_THEN_DeleteProfile() throws {
		app.launch()

		/// Home Screen
		let registerCertificateTitle = try XCTUnwrap(app.buttons[AccessibilityIdentifiers.Home.registerHealthCertificateButton])
		registerCertificateTitle.waitAndTap()

		// HealthCertificate consent screen
		let primaryButton = try XCTUnwrap(app.buttons[AccessibilityIdentifiers.General.primaryFooterButton])
		primaryButton.waitAndTap()

		// QRCode Scanner - close via flash will submit a healthCertificate
		let flashBarButton = try XCTUnwrap(app.buttons[AccessibilityIdentifiers.ExposureSubmissionQRScanner.flash])
		flashBarButton.waitAndTap()

		// Certified Person screen
		let certificateCell = try XCTUnwrap(app.cells[AccessibilityIdentifiers.HealthCertificate.Person.certificateCell])
		certificateCell.waitAndTap()

		// Certificate Screen
		let headlineCell = try XCTUnwrap(app.cells[AccessibilityIdentifiers.HealthCertificate.Certificate.headline])
		XCTAssertTrue(headlineCell.waitForExistence(timeout: .short))
	}

	func test_CreateAntigenTestProfileWithLastCertificate_THEN_DeleteProfile() throws {

		app.launchArguments.append(contentsOf: [UITestingLaunchArguments.healthCertificate.firstHealthCertificate, YES])
		app.launch()

		/// Home Screen
		let registerCertificateTitle = try XCTUnwrap(app.buttons[AccessibilityIdentifiers.Home.registerHealthCertificateButton])
		registerCertificateTitle.waitAndTap()

		// HealthCertificate consent screen
		let primaryButton = try XCTUnwrap(app.buttons[AccessibilityIdentifiers.General.primaryFooterButton])
		primaryButton.waitAndTap()

		// QRCode Scanner - close via flash will submit a healthCertificate
		let flashBarButton = try XCTUnwrap(app.buttons[AccessibilityIdentifiers.ExposureSubmissionQRScanner.flash])
		flashBarButton.waitAndTap()

		// Certified Person screen
		let certificateCell = try XCTUnwrap(app.cells[AccessibilityIdentifiers.HealthCertificate.Person.certificateCell])
		certificateCell.waitAndTap()

		// Certificate Screen
		let headlineCell = try XCTUnwrap(app.cells[AccessibilityIdentifiers.HealthCertificate.Certificate.headline])
		XCTAssertTrue(headlineCell.waitForExistence(timeout: .short))
	}

	func test_ShowCertificate() throws {
		app.launchArguments.append(contentsOf: [UITestingLaunchArguments.healthCertificate.firstAndSecondHealthCertificate, YES])

		app.launch()

		/// Home Screen
		let certificateTitle = try XCTUnwrap(app.cells[AccessibilityIdentifiers.Home.healthCertificateButton])
		certificateTitle.waitAndTap()

		// Certified Person screen
		let certificateCells = try XCTUnwrap(app.cells[AccessibilityIdentifiers.HealthCertificate.Person.certificateCell])
		XCTAssertTrue(certificateCells.waitForExistence(timeout: .short))
		XCTAssertEqual(app.cells.matching(identifier: AccessibilityIdentifiers.HealthCertificate.Person.certificateCell).count, 2)
	}

}
