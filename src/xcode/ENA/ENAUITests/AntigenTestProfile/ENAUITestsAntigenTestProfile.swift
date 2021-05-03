////
// 🦠 Corona-Warn-App
//

import XCTest

class ENAUITestsAntigenTestProfile: XCTestCase {
	
	// MARK: - Overrides
	
	override func setUp() {
		super.setUp()
		continueAfterFailure = false
		app = XCUIApplication()
		app.setDefaults()
		app.launchArguments.append(contentsOf: ["-isOnboarded", "YES"])
		app.launchArguments.append(contentsOf: ["-setCurrentOnboardingVersion", "YES"])
		app.launchArguments.append(contentsOf: ["-antigenTestProfileInfoScreenShown", "NO"])
		app.launchArguments.append(contentsOf: ["-removeAntigenTestProfile", "YES"])
	}
	
	// MARK: - Internal

	var app: XCUIApplication!
	
	// MARK: - Tests
	
	func test_() throws {
		
		app.launch()
		
		/// Home Screen

		let registerTestButton = try XCTUnwrap(app.buttons[AccessibilityIdentifiers.Home.submitCardButton])
		//XCTAssertTrue(registerTestButton.waitForExistence(timeout: .short))
		registerTestButton.tap()
		
		/// Register Test Screen

		let createProfileButton = try XCTUnwrap(app.buttons[AccessibilityIdentifiers.ExposureSubmission.AntigenTest.Profile.createProfileTile_Description])
		//XCTAssertTrue(createProfileButton.waitForExistence(timeout: .short))
		createProfileButton.tap()
		
		/// Antigen Test Information Screen
		
		// header image exists
		_ = try XCTUnwrap(app.images[AccessibilityIdentifiers.ExposureSubmission.AntigenTest.Information.imageDescription])
		// title exists
		_ = try XCTUnwrap(app.staticTexts[AccessibilityIdentifiers.ExposureSubmission.AntigenTest.Information.descriptionTitle])
		// subtitle exists
		_ = try XCTUnwrap(app.staticTexts[AccessibilityIdentifiers.ExposureSubmission.AntigenTest.Information.descriptionSubHeadline])
		// legal text exists
		_ = try XCTUnwrap(app.cells[AccessibilityIdentifiers.ExposureSubmission.AntigenTest.Information.acknowledgementTitle])
		
		let dataPrivacyButton = try XCTUnwrap(app.cells[AccessibilityIdentifiers.ExposureSubmission.AntigenTest.Information.dataPrivacyTitle])
		dataPrivacyButton.tap()
		
		/// Legal Text Screen
		
		XCTAssertTrue(app.cells[AccessibilityIdentifiers.ExposureSubmission.AntigenTest.Information.dataPrivacyTitle].exists)
		
		let backButton = try XCTUnwrap(app.navigationBars.buttons.element(boundBy: 0))
		backButton.tap()
		
		/// -> Antigen Test Information Screen
		
		let continueButton = try XCTUnwrap(app.buttons[AccessibilityIdentifiers.General.primaryFooterButton])
		continueButton.tap()
		
		/// Create Antigen Test Profile Screen
		
		_ = try XCTUnwrap(app.images[AccessibilityIdentifiers.ExposureSubmission.AntigenTest.Information.imageDescription])
		
		let saveButton = try XCTUnwrap(app.buttons[AccessibilityIdentifiers.General.primaryFooterButton])
		XCTAssertFalse(saveButton.isEnabled)
		
		let firstNameTextField = try XCTUnwrap(app.cells.textFields[AccessibilityIdentifiers.AntigenProfile.Create.firstNameTextField])
		firstNameTextField.tap()
		firstNameTextField.typeText("Bastian")
		
		let lastNameTextField = try XCTUnwrap(app.cells.textFields[AccessibilityIdentifiers.AntigenProfile.Create.lastNameTextField])
		lastNameTextField.tap()
		lastNameTextField.typeText("Kohlbauer")
		
		let birthDateTextField = try XCTUnwrap(app.cells.textFields[AccessibilityIdentifiers.AntigenProfile.Create.birthDateTextField])
		birthDateTextField.tap()
		birthDateTextField.typeText("15-12-1986")
		
		let streetTextField = try XCTUnwrap(app.cells.textFields[AccessibilityIdentifiers.AntigenProfile.Create.streetTextField])
		streetTextField.tap()
		streetTextField.typeText("Herr Bastian Kohlbauer Str. 1")
		
		let postalCodeTextField = try XCTUnwrap(app.cells.textFields[AccessibilityIdentifiers.AntigenProfile.Create.postalCodeTextField])
		postalCodeTextField.tap()
		postalCodeTextField.typeText("80639")
		
		let cityTextField = try XCTUnwrap(app.cells.textFields[AccessibilityIdentifiers.AntigenProfile.Create.cityTextField])
		cityTextField.tap()
		cityTextField.typeText("München")
		
		let phoneNumberTextField = try XCTUnwrap(app.cells.textFields[AccessibilityIdentifiers.AntigenProfile.Create.phoneNumberTextField])
		phoneNumberTextField.tap()
		phoneNumberTextField.typeText("089123456")
		
		let emailAddressTextField = try XCTUnwrap(app.cells.textFields[AccessibilityIdentifiers.AntigenProfile.Create.emailAddressTextField])
		emailAddressTextField.tap()
		emailAddressTextField.typeText("bastian@bastian.codes")
		
		XCTAssertTrue(saveButton.isEnabled)
		saveButton.tap()
	}
}
