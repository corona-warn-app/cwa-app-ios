////
// 🦠 Corona-Warn-App
//

import XCTest
import Foundation

class ENAUITests_ValidateHealthCertificate: CWATestCase {

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
	
	func test_validation_result_valid() throws {
		app.setLaunchArgument(LaunchArguments.healthCertificate.firstAndSecondHealthCertificate, to: true)
		app.setLaunchArgument(LaunchArguments.healthCertificate.invalidCertificateCheck, to: false)
		app.setLaunchArgument(LaunchArguments.infoScreen.healthCertificateInfoScreenShown, to: true)
		app.launch()
		
		// Navigate to Certificates Tab.
		app.buttons[AccessibilityIdentifiers.TabBar.certificates].waitAndTap()

		// Navigate to the person screen
		app.cells[AccessibilityIdentifiers.HealthCertificate.Overview.healthCertifiedPersonCell].firstMatch.waitAndTap()

		// Open Validation Screen
		app.buttons[AccessibilityIdentifiers.HealthCertificate.Person.validationButton].waitAndTap(.extraLong)

		// Tap on Date Time Selection
		app.cells[AccessibilityIdentifiers.HealthCertificate.Validation.dateTimeSelection].waitAndTap(.extraLong)
		
		// Tap on Check button
		app.buttons[AccessibilityIdentifiers.General.primaryFooterButton].waitAndTap()

	}
	
	func test_validation_result_invalid() throws {
		app.setLaunchArgument(LaunchArguments.healthCertificate.firstHealthCertificate, to: true)
		app.setLaunchArgument(LaunchArguments.healthCertificate.invalidCertificateCheck, to: true)
		app.setLaunchArgument(LaunchArguments.infoScreen.healthCertificateInfoScreenShown, to: true)
		app.launch()
		
		// Navigate to Certificates Tab.
		app.buttons[AccessibilityIdentifiers.TabBar.certificates].waitAndTap()

		// Navigate to the person screen
		app.cells[AccessibilityIdentifiers.HealthCertificate.Overview.healthCertifiedPersonCell].firstMatch.waitAndTap()

		// Open Validation Screen
		app.buttons[AccessibilityIdentifiers.HealthCertificate.Person.validationButton].waitAndTap(.extraLong)

		// Tap on Date Time Selection
		app.cells[AccessibilityIdentifiers.HealthCertificate.Validation.dateTimeSelection].waitAndTap()
		
		// Tap on button to validate
		app.buttons[AccessibilityIdentifiers.General.primaryFooterButton].waitAndTap()
	}
	
	// MARK: - Screenshots
	
	func test_screenshot_validation_country_picker() throws {
		app.setLaunchArgument(LaunchArguments.healthCertificate.firstHealthCertificate, to: true)
		app.setLaunchArgument(LaunchArguments.infoScreen.healthCertificateInfoScreenShown, to: true)
		app.launch()

		// Navigate to Certificates Tab.
		app.buttons[AccessibilityIdentifiers.TabBar.certificates].waitAndTap()

		// Navigate to the person screen
		app.cells[AccessibilityIdentifiers.HealthCertificate.Overview.healthCertifiedPersonCell].waitAndTap()
		
		// Open Validation Screen
		app.buttons[AccessibilityIdentifiers.HealthCertificate.Person.validationButton].waitAndTap(.extraLong)

		snapshot("screenshot_certificate_validation")
		
		// Tap on Country Selection
		app.cells[AccessibilityIdentifiers.HealthCertificate.Validation.countrySelection].waitAndTap()

		snapshot("screenshot_certificate_validation_country_selection")

		// Select Country
		let country = try XCTUnwrap(Locale.current.localizedString(forRegionCode: "DE"))
		app.pickerWheels.element.adjust(toPickerWheelValue: country)
	}

	func test_screenshot_validation_datetime_picker() throws {
		app.setLaunchArgument(LaunchArguments.healthCertificate.firstHealthCertificate, to: true)
		app.setLaunchArgument(LaunchArguments.infoScreen.healthCertificateInfoScreenShown, to: true)
		app.launch()

		// Navigate to Certificates Tab.
		app.buttons[AccessibilityIdentifiers.TabBar.certificates].waitAndTap()

		// Navigate to the person screen
		app.cells[AccessibilityIdentifiers.HealthCertificate.Overview.healthCertifiedPersonCell].firstMatch.waitAndTap()

		// Open Validation Screen
		app.buttons[AccessibilityIdentifiers.HealthCertificate.Person.validationButton].waitAndTap(.extraLong)

		// Tap on Date Time Selection
		app.cells[AccessibilityIdentifiers.HealthCertificate.Validation.dateTimeSelection].waitAndTap(.extraLong)

		snapshot("screenshot_certificate_validation_date_selection")
	}
	

}
