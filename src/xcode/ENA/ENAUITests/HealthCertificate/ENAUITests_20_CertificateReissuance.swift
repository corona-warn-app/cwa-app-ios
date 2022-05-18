//
// 🦠 Corona-Warn-App
//

import XCTest

class ENAUITests_20_CertificateReissuance: CWATestCase {

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
	
	// MARK: - Screenshots

	func test_screenshot_CertificateReissuance() throws {
		app.setLaunchArgument(LaunchArguments.healthCertificate.reissuanceCertificates, to: true)
		app.setLaunchArgument(LaunchArguments.infoScreen.healthCertificateInfoScreenShown, to: true)
		app.setLaunchArgument(LaunchArguments.healthCertificate.hasCertificateReissuance, to: true)
		app.launch()

		// Navigate to Certificates Tab.
		app.buttons[AccessibilityIdentifiers.TabBar.certificates].firstMatch.waitAndTap(5)

		// Navigate to the person screen
		app.cells[AccessibilityIdentifiers.HealthCertificate.Overview.healthCertifiedPersonCell].waitAndTap()

		snapshot("screenshot_health_certificate_reissuance_refresh_certificate")

		// Certificate Screen
		app.cells[AccessibilityIdentifiers.HealthCertificate.Reissuance.cell].waitAndTap()
		snapshot("screenshot_health_certificate_reissuance_consentScreen")
		
		// Accompanying Certificates Screen
		app.cells[AccessibilityIdentifiers.HealthCertificate.Reissuance.accompanyingCertificatesTitle].waitAndTap()
		snapshot("screenshot_health_certificate_reissuance_accompanyingCertificates")
		
		// close the modal view
		app.buttons[AccessibilityIdentifiers.HealthCertificate.Reissuance.accompanyingCertificatesCloseButton].waitAndTap()
		
		// Accompanying Certificates Screen
		app.cells[AccessibilityIdentifiers.HealthCertificate.Reissuance.cell].waitAndTap()

		// Accept Consent
		app.buttons[AccessibilityIdentifiers.General.primaryFooterButton].waitAndTap()
		
		// Check if success screen is visible.
		app.staticTexts[AccessibilityIdentifiers.HealthCertificate.Reissuance.successTitle].wait()
		snapshot("screenshot_health_certificate_reissuance_success")
	}
}
