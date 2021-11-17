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
	
	func test_isFirstConsentShown() throws {
		app.launch()
		
		app.buttons[AccessibilityIdentifiers.TabBar.scanner].waitAndTap()
		
		/// Simulator only Alert will open where you can choose what the QRScanner should scan
		let ticketValidationButton = try XCTUnwrap(app.buttons[AccessibilityIdentifiers.UniversalQRScanner.fakeTicketValidation])
		ticketValidationButton.waitAndTap()
		
		XCTAssertTrue(app.images[AccessibilityIdentifiers.TicketValidation.FirstConsent.image].waitForExistence(timeout: .short))
		XCTAssertTrue(app.cells[AccessibilityIdentifiers.TicketValidation.FirstConsent.legalBox].waitForExistence(timeout: .short))
		XCTAssertTrue(app.cells[AccessibilityIdentifiers.TicketValidation.FirstConsent.dataPrivacy].waitForExistence(timeout: .short))
	
		XCTAssertTrue(app.buttons[AccessibilityIdentifiers.General.primaryFooterButton].waitForExistence(timeout: .short))
		XCTAssertTrue(app.buttons[AccessibilityIdentifiers.General.secondaryFooterButton].waitForExistence(timeout: .short))
	}
	
	func test_screenshot_ticket_validation_firstConsent() throws {
		app.launch()
		
		app.buttons[AccessibilityIdentifiers.TabBar.scanner].waitAndTap()
		
		/// Simulator only Alert will open where you can choose what the QRScanner should scan
		let ticketValidationButton = try XCTUnwrap(app.buttons[AccessibilityIdentifiers.UniversalQRScanner.fakeTicketValidation])
		ticketValidationButton.waitAndTap()
		
		XCTAssertTrue(app.cells[AccessibilityIdentifiers.TicketValidation.FirstConsent.legalBox].waitForExistence(timeout: .short))
		
		snapshot("screenshot_ticket_validation_first_consent_1")
		app.swipeDown()
		snapshot("screenshot_ticket_validation_first_consent_2")
		app.swipeDown()
		snapshot("screenshot_ticket_validation_first_consent_3")
		app.swipeDown()
		snapshot("screenshot_ticket_validation_first_consent_4")
	}
}
