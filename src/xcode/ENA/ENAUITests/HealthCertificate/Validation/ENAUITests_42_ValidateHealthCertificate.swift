////
// 🦠 Corona-Warn-App
//

import XCTest
import Foundation

class ENAUITests_42_ValidateHealthCertificate: CWATestCase {

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

		// Tap on Country Selection
		app.cells[AccessibilityIdentifiers.HealthCertificate.Validation.countrySelection].waitAndTap()

		snapshot("screenshot_certificate_validation")

		// Select Country

		let country = try XCTUnwrap(Locale.current.localizedString(forRegionCode: "DE"))
		app.pickerWheels.element.adjust(toPickerWheelValue: country)

		snapshot("screenshot_certificate_validation_country_selection")
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
		app.cells[AccessibilityIdentifiers.HealthCertificate.Validation.dateTimeSelection].waitAndTap()

		snapshot("screenshot_certificate_validation_date_selection")
	}
}

extension XCUIGestureVelocity {
	public static let justATinyBit: XCUIGestureVelocity = 0.3
}
