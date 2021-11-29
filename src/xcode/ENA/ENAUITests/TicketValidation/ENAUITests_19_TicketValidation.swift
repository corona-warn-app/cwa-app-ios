//
// 🦠 Corona-Warn-App
//

import XCTest

class ENAUITests_19_TicketValidation: CWATestCase {
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
	
	func test_ticketValidation_flow_open() throws {
		app.setLaunchArgument(LaunchArguments.healthCertificate.secondHealthCertificate, to: true)
		app.setLaunchArgument(LaunchArguments.ticketValidation.result.isOpen, to: true)
		app.launch()
		
		app.buttons[AccessibilityIdentifiers.TabBar.scanner].waitAndTap()
		
		/// Simulator only Alert will open where you can choose what the QRScanner should scan
		let ticketValidationButton = try XCTUnwrap(app.buttons[AccessibilityIdentifiers.UniversalQRScanner.fakeTicketValidation])
		ticketValidationButton.waitAndTap()
		
		/// check for the content on first consent screen
		XCTAssertTrue(app.images[AccessibilityIdentifiers.TicketValidation.FirstConsent.image].waitForExistence(timeout: .short))
		XCTAssertTrue(app.cells[AccessibilityIdentifiers.TicketValidation.FirstConsent.legalBox].waitForExistence(timeout: .short))
		XCTAssertTrue(app.cells[AccessibilityIdentifiers.TicketValidation.FirstConsent.dataPrivacy].waitForExistence(timeout: .short))
	
		/// check for the action buttons on first consent screen
		XCTAssertTrue(app.buttons[AccessibilityIdentifiers.General.primaryFooterButton].waitForExistence(timeout: .short))
		XCTAssertTrue(app.buttons[AccessibilityIdentifiers.General.secondaryFooterButton].waitForExistence(timeout: .short))
		
		/// navigate to the certificate selection screen
		app.buttons[AccessibilityIdentifiers.TicketValidation.FirstConsent.primaryButton].waitAndTap()
		
		/// check for the number of certificates on certificate selection screen
		let certificateCells = try XCTUnwrap(app.cells[AccessibilityIdentifiers.HealthCertificate.Person.certificateCell])
		XCTAssertTrue(certificateCells.waitForExistence(timeout: .short))
		XCTAssertEqual(app.cells.matching(identifier: AccessibilityIdentifiers.HealthCertificate.Person.certificateCell).count, 1)
		
		/// navigate to the second consent screen
		certificateCells.firstMatch.waitAndTap()
		
		/// check for the content on second consent screen
		XCTAssertTrue(app.cells[AccessibilityIdentifiers.TicketValidation.SecondConsent.legalBox].waitForExistence(timeout: .short))
		XCTAssertTrue(app.cells[AccessibilityIdentifiers.TicketValidation.SecondConsent.dataPrivacy].waitForExistence(timeout: .short))
		
		/// check for the action buttons on second consent screen
		XCTAssertTrue(app.buttons[AccessibilityIdentifiers.General.primaryFooterButton].waitForExistence(timeout: .short))
		XCTAssertTrue(app.buttons[AccessibilityIdentifiers.General.secondaryFooterButton].waitForExistence(timeout: .short))
		
		/// navigate to the validation result screen
		app.buttons[AccessibilityIdentifiers.TicketValidation.SecondConsent.primaryButton].waitAndTap()
		
		/// check for the content on validation result screen
		XCTAssertTrue(app.images[AccessibilityIdentifiers.TicketValidation.ValidationResult.Open.headerImageWithTitle].waitForExistence(timeout: .short))
		XCTAssertTrue(app.staticTexts[AccessibilityIdentifiers.TicketValidation.ValidationResult.Open.subtitle].waitForExistence(timeout: .short))
	}
	
	func test_screenshot_ticketValidation_passed() throws {
		app.setLaunchArgument(LaunchArguments.healthCertificate.secondHealthCertificate, to: true)
		app.launch()
		
		app.buttons[AccessibilityIdentifiers.TabBar.scanner].waitAndTap()
		
		/// Simulator only Alert will open where you can choose what the QRScanner should scan
		let ticketValidationButton = try XCTUnwrap(app.buttons[AccessibilityIdentifiers.UniversalQRScanner.fakeTicketValidation])
		ticketValidationButton.waitAndTap()
		
		/// check for the content on first consent screen
		XCTAssertTrue(app.cells[AccessibilityIdentifiers.TicketValidation.FirstConsent.legalBox].waitForExistence(timeout: .short))
		
		/// take screenshot on first consent screen
		snapshot("screenshot_ticket_validation_first_consent_1")
		app.swipeUp()
		snapshot("screenshot_ticket_validation_first_consent_2")
		app.swipeUp()
		snapshot("screenshot_ticket_validation_first_consent_3")
		
		/// navigate to certificate selection screen
		app.buttons[AccessibilityIdentifiers.TicketValidation.FirstConsent.primaryButton].waitAndTap()
		
		/// check for health certificate cell on certificate selection screen
		let certificateCells = try XCTUnwrap(app.cells[AccessibilityIdentifiers.HealthCertificate.Person.certificateCell])
		XCTAssertTrue(certificateCells.waitForExistence(timeout: .short))
		XCTAssertEqual(app.cells.matching(identifier: AccessibilityIdentifiers.HealthCertificate.Person.certificateCell).count, 1)
		
		/// take screenshot on certificate selection screen
		snapshot("screenshot_ticket_validation_certificate_selection")
		
		/// navigate to second consent screen
		app.cells[AccessibilityIdentifiers.HealthCertificate.Person.certificateCell].firstMatch.waitAndTap()
		
		/// check the conent on second consent screen
		XCTAssertTrue(app.cells[AccessibilityIdentifiers.TicketValidation.SecondConsent.legalBox].waitForExistence(timeout: .short))
		
		/// take screenshot on second consent screen
		snapshot("screenshot_ticket_validation_second_consent_1")
		app.swipeUp()
		snapshot("screenshot_ticket_validation_second_consent_2")
		app.swipeUp()
		snapshot("screenshot_ticket_validation_second_consent_3")
		app.swipeUp()
		snapshot("screenshot_ticket_validation_second_consent_4")
		
		/// navigate to the validation result screen
		app.buttons[AccessibilityIdentifiers.TicketValidation.SecondConsent.primaryButton].waitAndTap()
		
		/// check for the content on validation result screen
		XCTAssertTrue(app.images[AccessibilityIdentifiers.TicketValidation.ValidationResult.Passed.headerImageWithTitle].waitForExistence(timeout: .short))
		XCTAssertTrue(app.staticTexts[AccessibilityIdentifiers.TicketValidation.ValidationResult.Passed.subtitle].waitForExistence(timeout: .short))
		
		/// take screenshot on validation result screen
		snapshot("screenshot_ticket_validation_result_passed")
	}
	
	func test_screenshot_ticketValidation_failed() throws {
		app.setLaunchArgument(LaunchArguments.healthCertificate.secondHealthCertificate, to: true)
		app.setLaunchArgument(LaunchArguments.ticketValidation.result.isFailed, to: true)
		app.launch()
		
		app.buttons[AccessibilityIdentifiers.TabBar.scanner].waitAndTap()
		
		/// Simulator only Alert will open where you can choose what the QRScanner should scan
		let ticketValidationButton = try XCTUnwrap(app.buttons[AccessibilityIdentifiers.UniversalQRScanner.fakeTicketValidation])
		ticketValidationButton.waitAndTap()
		
		/// check for the content on first consent screen
		XCTAssertTrue(app.cells[AccessibilityIdentifiers.TicketValidation.FirstConsent.legalBox].waitForExistence(timeout: .short))
		
		/// navigate to certificate selection screen
		app.buttons[AccessibilityIdentifiers.TicketValidation.FirstConsent.primaryButton].waitAndTap()
		
		/// check for health certificate cell on certificate selection screen
		let certificateCells = try XCTUnwrap(app.cells[AccessibilityIdentifiers.HealthCertificate.Person.certificateCell])
		XCTAssertTrue(certificateCells.waitForExistence(timeout: .short))
		XCTAssertEqual(app.cells.matching(identifier: AccessibilityIdentifiers.HealthCertificate.Person.certificateCell).count, 1)
		
		/// navigate to second consent screen
		app.cells[AccessibilityIdentifiers.HealthCertificate.Person.certificateCell].firstMatch.waitAndTap()
		
		/// check the conent on second consent screen
		XCTAssertTrue(app.cells[AccessibilityIdentifiers.TicketValidation.SecondConsent.legalBox].waitForExistence(timeout: .short))
		
		/// navigate to the validation result screen
		app.buttons[AccessibilityIdentifiers.TicketValidation.SecondConsent.primaryButton].waitAndTap()
		
		/// check for the content on validation result screen
		XCTAssertTrue(app.images[AccessibilityIdentifiers.TicketValidation.ValidationResult.Failed.headerImageWithTitle].waitForExistence(timeout: .short))
		XCTAssertTrue(app.staticTexts[AccessibilityIdentifiers.TicketValidation.ValidationResult.Failed.subtitle].waitForExistence(timeout: .short))
		
		/// take screenshot on validation result screen
		snapshot("screenshot_ticket_validation_result_failed")
	}
}
