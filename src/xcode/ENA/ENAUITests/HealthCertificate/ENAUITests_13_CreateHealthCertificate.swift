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

		snapshot("screenshot_health_certificate_data_privacy")

		let backButton = try XCTUnwrap(app.navigationBars.buttons.element(boundBy: 0))
		backButton.waitAndTap()

		// Close consent
		let primaryButton = try XCTUnwrap(app.buttons[AccessibilityIdentifiers.General.primaryFooterButton])
		primaryButton.waitAndTap()

		XCTAssertTrue(app.cells[AccessibilityIdentifiers.HealthCertificate.Overview.addCertificateCell].waitForExistence(timeout: .short))
		
		snapshot("screenshot_health_certificate_empty_screen")
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

		snapshot("screenshot_first_vaccination_certificate_details_part1")
		app.swipeUp(velocity: .slow)
		snapshot("screenshot_first_vaccination_certificate_details_part2")
	}

	func test_screenshot_CreateAntigenTestProfileWithLastCertificate() throws {
		app.setLaunchArgument(LaunchArguments.healthCertificate.firstHealthCertificate, to: true)
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

		snapshot("screenshot_second_vaccination_certificate_details_part1")
		app.swipeUp(velocity: .slow)
		snapshot("screenshot_second_vaccination_certificate_details_part2")
	}

	func test_screenshot_ShowCertificate() throws {
		app.setLaunchArgument(LaunchArguments.healthCertificate.firstAndSecondHealthCertificate, to: true)
		app.setLaunchArgument(LaunchArguments.infoScreen.healthCertificateInfoScreenShown, to: true)
		app.launch()

		app.buttons[AccessibilityIdentifiers.TabBar.certificates].waitAndTap()

		let certificateTitle = try XCTUnwrap(app.cells[AccessibilityIdentifiers.HealthCertificate.Overview.healthCertifiedPersonCell])
		
		snapshot("screenshot_vaccination_certificate_overview")
		certificateTitle.waitAndTap()

		let qrCodeCell = app.cells[AccessibilityIdentifiers.HealthCertificate.qrCodeCell]
		XCTAssertTrue(qrCodeCell.waitForExistence(timeout: .short))

		snapshot("screenshot_vaccination_certificate_overview_part1")
		app.swipeUp(velocity: .slow)
		snapshot("screenshot_vaccination_certificate_overview_part2")
		
		// Certified Person screen
		let certificateCells = try XCTUnwrap(app.cells[AccessibilityIdentifiers.HealthCertificate.Person.certificateCell])
		XCTAssertTrue(certificateCells.waitForExistence(timeout: .short))
		XCTAssertEqual(app.cells.matching(identifier: AccessibilityIdentifiers.HealthCertificate.Person.certificateCell).count, 2)
	}

	func test_screenshot_TestCertificate() throws {
		app.setLaunchArgument(LaunchArguments.infoScreen.healthCertificateInfoScreenShown, to: true)
		app.setLaunchArgument(LaunchArguments.healthCertificate.testCertificateRegistered, to: true)
		app.launch()

		// Navigate to Certificates Tab.
		app.buttons[AccessibilityIdentifiers.TabBar.certificates].waitAndTap()
		
		// Navigate to the person screen
		app.cells[AccessibilityIdentifiers.HealthCertificate.Overview.healthCertifiedPersonCell].waitAndTap()
		
		snapshot("screenshot_test_certificate_overview_part1")
		app.swipeUp(velocity: .slow)
		snapshot("screenshot_test_certificate_overview_part2")

		// Navigatate to test certificate details screen
		app.cells[AccessibilityIdentifiers.HealthCertificate.Person.certificateCell].waitAndTap()

		snapshot("screenshot_test_certificate_details_part1")
		app.swipeUp(velocity: .slow)
		snapshot("screenshot_test_certificate_details_part2")
	}
  
	func test_screenshot_RecoveryCertificate() throws {
		app.setLaunchArgument(LaunchArguments.infoScreen.healthCertificateInfoScreenShown, to: true)
		app.setLaunchArgument(LaunchArguments.healthCertificate.recoveryCertificateRegistered, to: true)
		app.launch()

		// Navigate to Certificates Tab.
		app.buttons[AccessibilityIdentifiers.TabBar.certificates].waitAndTap()

		// Navigate to the person screen
		app.cells[AccessibilityIdentifiers.HealthCertificate.Overview.healthCertifiedPersonCell].waitAndTap()

		snapshot("screenshot_recovery_certificate_overview_part1")
		app.swipeUp(velocity: .slow)
		snapshot("screenshot_recovery_certificate_overview_part2")
	
		// Navigatate to recovery certificate details screen
		app.cells[AccessibilityIdentifiers.HealthCertificate.Person.certificateCell].waitAndTap()

		snapshot("screenshot_recovery_certificate_details_part1")
		app.swipeUp(velocity: .slow)
		snapshot("screenshot_recovery_certificate_details_part2")
	}

	func test_screenshot_CompleteVaccinationProtectionWithTestCertificate() throws {
		app.setLaunchArgument(LaunchArguments.healthCertificate.firstAndSecondHealthCertificate, to: true)
		app.setLaunchArgument(LaunchArguments.infoScreen.healthCertificateInfoScreenShown, to: true)
		app.setLaunchArgument(LaunchArguments.healthCertificate.testCertificateRegistered, to: true)
		app.launch()

		// Navigate to Certificates Tab.
		app.buttons[AccessibilityIdentifiers.TabBar.certificates].waitAndTap()

		let healthCertificateCell = app.cells[AccessibilityIdentifiers.HealthCertificate.Overview.healthCertifiedPersonCell]
		XCTAssertTrue(healthCertificateCell.waitForExistence(timeout: .short))

		snapshot("screenshot_certificate_overview_vaccination_and_test_certificate")
	}
	
	func test_screenshot_MultipleFamilyTestCertificates() throws {
		app.setLaunchArgument(LaunchArguments.infoScreen.healthCertificateInfoScreenShown, to: true)
		app.setLaunchArgument(LaunchArguments.healthCertificate.familyCertificates, to: true)
		app.launch()

		// Navigate to Certificates Tab.
		app.buttons[AccessibilityIdentifiers.TabBar.certificates].waitAndTap()
		
		var healthCertificateCell = app.cells[AccessibilityIdentifiers.HealthCertificate.Overview.healthCertifiedPersonCell]
		XCTAssertTrue(healthCertificateCell.waitForExistence(timeout: .short))
		snapshot("screenshot_certificate_family_certificate-cert-1")
		
		app.swipeUp(velocity: .slow)
		
		healthCertificateCell = app.cells[AccessibilityIdentifiers.HealthCertificate.Overview.healthCertifiedPersonCell]
		snapshot("screenshot_certificate_family_certificate-cert-2")
		
		app.swipeUp(velocity: .slow)
		
		healthCertificateCell = app.cells[AccessibilityIdentifiers.HealthCertificate.Overview.healthCertifiedPersonCell]
		snapshot("screenshot_certificate_family_certificate-cert-3")
		
		app.swipeUp(velocity: .slow)

		healthCertificateCell = app.cells[AccessibilityIdentifiers.HealthCertificate.Overview.healthCertifiedPersonCell]
		snapshot("screenshot_certificate_family_certificate-cert-4")
		
		XCTAssertEqual(app.cells.matching(identifier: AccessibilityIdentifiers.HealthCertificate.Overview.healthCertifiedPersonCell).count, 4)
	}

}
