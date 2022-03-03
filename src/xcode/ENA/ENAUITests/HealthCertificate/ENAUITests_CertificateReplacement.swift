//
// 🦠 Corona-Warn-App
//

import XCTest

class ENAUITests_CertificateReplacement: CWATestCase {

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

	func test_CertificateReplacement() throws {
		app.setLaunchArgument(LaunchArguments.healthCertificate.firstAndSecondHealthCertificate, to: true)
		app.setLaunchArgument(LaunchArguments.infoScreen.healthCertificateInfoScreenShown, to: true)
		app.setLaunchArgument(LaunchArguments.healthCertificate.hasCertificateReissuance, to: true)
		app.launch()

		// Navigate to Certificates Tab.
		app.buttons[AccessibilityIdentifiers.TabBar.certificates].waitAndTap()

		// Navigate to the person screen
		app.cells[AccessibilityIdentifiers.HealthCertificate.Overview.healthCertifiedPersonCell].waitAndTap()
		
		app.swipeUp(velocity: .slow)

		// Certificate Screen
		app.cells[AccessibilityIdentifiers.HealthCertificate.Reissuance.cell].waitAndTap()
		
		// Accept Consent
		app.buttons[AccessibilityIdentifiers.General.primaryFooterButton].waitAndTap()
		
		// Check if success screen is visible.
		app.staticTexts[AccessibilityIdentifiers.HealthCertificate.Reissuance.successTitle].wait()
	}

}
