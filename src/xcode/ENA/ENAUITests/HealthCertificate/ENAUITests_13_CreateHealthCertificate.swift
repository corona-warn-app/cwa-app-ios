////
// 🦠 Corona-Warn-App
//

import XCTest

class ENAUITests_13_CreateHealthCertificate: CWATestCase {

	// MARK: - Overrides

	override func setUp() {
		super.setUp()
		continueAfterFailure = false
		app = XCUIApplication()
		setupSnapshot(app)
		app.setDefaults()
		app.setLaunchArgument(LaunchArguments.onboarding.isOnboarded, to: true)
		app.setLaunchArgument(LaunchArguments.onboarding.setCurrentOnboardingVersion, to: true)
	}

	// MARK: - Internal

	var app: XCUIApplication!

	// MARK: - Tests

	func test_screenshot_shownConsentScreenAndDisclaimer() throws {
		app.launch()

		app.buttons[AccessibilityIdentifiers.TabBar.certificates].waitAndTap()

		// HealthCertificate consent screen tap on disclaimer
		let disclaimerButton = try XCTUnwrap(app.cells[AccessibilityIdentifiers.HealthCertificate.Info.disclaimer])
		
		snapshot("screenshot_health_certificate_consent_screen")
		disclaimerButton.waitAndTap()

		// data privacy
		XCTAssertTrue(app.images[AccessibilityIdentifiers.AppInformation.privacyImageDescription].waitForExistence(timeout: .extraLong))

		let backButton = try XCTUnwrap(app.navigationBars.buttons.element(boundBy: 0))
		backButton.waitAndTap()

		// Close consent
		let primaryButton = try XCTUnwrap(app.buttons[AccessibilityIdentifiers.General.primaryFooterButton])
		primaryButton.waitAndTap()

		XCTAssertTrue(app.cells[AccessibilityIdentifiers.HealthCertificate.Overview.addCertificateCell].waitForExistence(timeout: .short))
	}

	func test_screenshot_CreateAntigenTestProfileWithFirstCertificate() throws {
		app.setLaunchArgument(LaunchArguments.infoScreen.healthCertificateInfoScreenShown, to: true)
		app.launch()

		app.buttons[AccessibilityIdentifiers.TabBar.certificates].waitAndTap()

		/// Home Screen
		let registerCertificateTitle = try XCTUnwrap(app.cells[AccessibilityIdentifiers.HealthCertificate.Overview.addCertificateCell])
		registerCertificateTitle.waitAndTap()

		// QRCode Scanner - close via flash will submit a healthCertificate
		let flashBarButton = try XCTUnwrap(app.buttons[AccessibilityIdentifiers.ExposureSubmissionQRScanner.flash])
		flashBarButton.waitAndTap()

		// Certificate Screen
		let headlineCell = try XCTUnwrap(app.cells[AccessibilityIdentifiers.HealthCertificate.Certificate.headline])
		XCTAssertTrue(headlineCell.waitForExistence(timeout: .short))

		snapshot("screenshot_first_health_certificate")
	}

	func test_screenshot_CreateAntigenTestProfileWithLastCertificate() throws {
		app.setLaunchArgument(LaunchArguments.healthCertificate.firstHealthCertificate, to: true)
		app.setLaunchArgument(LaunchArguments.infoScreen.healthCertificateInfoScreenShown, to: true)
		app.launch()

		app.buttons[AccessibilityIdentifiers.TabBar.certificates].waitAndTap()

		snapshot("screenshot_certificate_overview_vaccination_grey")

		/// Home Screen
		let registerCertificateTitle = try XCTUnwrap(app.cells[AccessibilityIdentifiers.HealthCertificate.Overview.addCertificateCell])
		registerCertificateTitle.waitAndTap()

		// QRCode Scanner - close via flash will submit a healthCertificate
		let flashBarButton = try XCTUnwrap(app.buttons[AccessibilityIdentifiers.ExposureSubmissionQRScanner.flash])
		flashBarButton.waitAndTap()

		// Certificate Screen
		let headlineCell = try XCTUnwrap(app.cells[AccessibilityIdentifiers.HealthCertificate.Certificate.headline])
		XCTAssertTrue(headlineCell.waitForExistence(timeout: .short))

		snapshot("screenshot_second_health_certificate")
	}

	func test_screenshot_ShowCertificate() throws {
		app.setLaunchArgument(LaunchArguments.healthCertificate.firstAndSecondHealthCertificate, to: true)
		app.setLaunchArgument(LaunchArguments.infoScreen.healthCertificateInfoScreenShown, to: true)
		app.launch()

		app.buttons[AccessibilityIdentifiers.TabBar.certificates].waitAndTap()

		let certificateTitle = try XCTUnwrap(app.cells[AccessibilityIdentifiers.HealthCertificate.Overview.vaccinationCertificateCell])
		
		snapshot("screenshot_certificate_overview_vaccination_blue")
		certificateTitle.waitAndTap()

		let qrCodeCell = app.cells[AccessibilityIdentifiers.HealthCertificate.qrCodeCell]
		XCTAssertTrue(qrCodeCell.waitForExistence(timeout: .short))

		snapshot("screenshot_health_certificate_blue")

		// Certified Person screen
		let certificateCells = try XCTUnwrap(app.cells[AccessibilityIdentifiers.HealthCertificate.Person.certificateCell])
		XCTAssertTrue(certificateCells.waitForExistence(timeout: .short))
		XCTAssertEqual(app.cells.matching(identifier: AccessibilityIdentifiers.HealthCertificate.Person.certificateCell).count, 2)
	}

	/*
	func test_screenshot_TestCertificate() throws {
		app.setLaunchArgument(LaunchArguments.infoScreen.healthCertificateInfoScreenShown, to: true)
		app.setLaunchArgument(LaunchArguments.healthCertificate.testCertificateRegistered, to: true)
		app.launch()

		// Navigate to Certificates Tab.
		app.buttons[AccessibilityIdentifiers.TabBar.certificates].waitAndTap()

		app.cells[AccessibilityIdentifiers.HealthCertificate.Overview.testCertificateRequestCell].waitAndTap()

		app.cells[AccessibilityIdentifiers.HealthCertificate.Person.certificateCell].waitAndTap()

		snapshot("screenshot_test_certificate")
	}
	*/

	/*
	func test_screenshot_RecoveryCertificate() throws {
		app.setLaunchArgument(LaunchArguments.infoScreen.healthCertificateInfoScreenShown, to: true)
		app.setLaunchArgument(LaunchArguments.healthCertificate.recoveryCertificateRegistered, to: true)
		app.launch()

		// Navigate to Certificates Tab.
		app.buttons[AccessibilityIdentifiers.TabBar.certificates].waitAndTap()

		app.cells[AccessibilityIdentifiers.HealthCertificate.Overview.vaccinationCertificateCell].waitAndTap()

		app.cells[AccessibilityIdentifiers.HealthCertificate.Person.certificateCell].waitAndTap()

		snapshot("screenshot_recovery_certificate_part1")
		
		app.swipeUp(velocity: .slow)
		snapshot("screenshot_recovery_certificate_part2")
	}
	*/

	func test_screenshot_CompleteVaccinationProtectionWithTestCertificate() throws {
		app.setLaunchArgument(LaunchArguments.healthCertificate.firstAndSecondHealthCertificate, to: true)
		app.setLaunchArgument(LaunchArguments.infoScreen.healthCertificateInfoScreenShown, to: true)
		app.setLaunchArgument(LaunchArguments.healthCertificate.testCertificateRegistered, to: true)
		app.launch()

		// Navigate to Certificates Tab.
		app.buttons[AccessibilityIdentifiers.TabBar.certificates].waitAndTap()

		let healthCertificateCell = app.cells[AccessibilityIdentifiers.HealthCertificate.Overview.vaccinationCertificateCell]
		XCTAssertTrue(healthCertificateCell.waitForExistence(timeout: .short))

		snapshot("screenshot_certificate_overview_vaccination_and_test_certificate")
	}

}
