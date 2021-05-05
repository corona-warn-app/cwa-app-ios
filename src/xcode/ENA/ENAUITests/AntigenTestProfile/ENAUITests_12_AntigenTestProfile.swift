////
// 🦠 Corona-Warn-App
//

import XCTest

class ENAUITests_12_AntigenTestProfile: XCTestCase {
	
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
	
	func test_FIRST_CreateAntigenTestProfile_THEN_DeleteProfile() throws {
		
		app.launch()
		
		/// Home Screen

		let registerTestButton = try XCTUnwrap(app.buttons[AccessibilityIdentifiers.Home.submitCardButton])
		registerTestButton.tap()
		
		/// Register Test Screen

		let createProfileButton = try XCTUnwrap(app.buttons[AccessibilityIdentifiers.ExposureSubmission.AntigenTest.Profile.createProfileTile_Description])
		XCTAssertTrue(createProfileButton.waitForExistence(timeout: .short))
		createProfileButton.tap()
		
		/// Antigen Test Information Screen
		
		// header image exists
		XCTAssertTrue(app.images[AccessibilityIdentifiers.ExposureSubmission.AntigenTest.Information.imageDescription].exists)
		// title exists
		XCTAssertTrue(app.staticTexts[AccessibilityIdentifiers.ExposureSubmission.AntigenTest.Information.descriptionTitle].exists)
		// subtitle exists
		XCTAssertTrue(app.staticTexts[AccessibilityIdentifiers.ExposureSubmission.AntigenTest.Information.descriptionSubHeadline].exists)
		// legal text exists
		XCTAssertTrue(app.cells[AccessibilityIdentifiers.ExposureSubmission.AntigenTest.Information.acknowledgementTitle].exists)
		
		let dataPrivacyButton = try XCTUnwrap(app.cells[AccessibilityIdentifiers.ExposureSubmission.AntigenTest.Information.dataPrivacyTitle])
		dataPrivacyButton.tap()
		
		/// Legal Text Screen
		
		XCTAssertTrue(app.cells[AccessibilityIdentifiers.ExposureSubmission.AntigenTest.Information.dataPrivacyTitle].exists)
		
		let backButton = try XCTUnwrap(app.navigationBars.buttons.element(boundBy: 0))
		backButton.tap()
		
		/// -> Antigen Test Information Screen
		
		let continueButton = app.buttons[AccessibilityIdentifiers.ExposureSubmission.AntigenTest.Information.continueButton]
		XCTAssertTrue(continueButton.waitForExistence(timeout: .short))
		continueButton.tap()
		
		/// Create Antigen Test Profile Screen

		let saveProfileButton = try XCTUnwrap(app.buttons[AccessibilityIdentifiers.ExposureSubmission.AntigenTest.Create.saveButton])
		XCTAssertFalse(saveProfileButton.isEnabled)
		
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
		
		XCTAssertTrue(saveProfileButton.isEnabled)
		saveProfileButton.tap()
		
		/// Antigen Test Profile Screen

		// continues button exists
		XCTAssertTrue(app.buttons[AccessibilityIdentifiers.ExposureSubmission.AntigenTest.Profile.continueButton].exists)
		// delete profile button exists
		XCTAssertTrue(app.buttons[AccessibilityIdentifiers.ExposureSubmission.AntigenTest.Profile.deleteButton].exists)
		
		let closeButton = try XCTUnwrap(app.navigationBars.buttons.element(boundBy: 1))
		closeButton.tap()
		
		/// -> Home Screen

		registerTestButton.tap()
		
		/// Register Test Screen
		
		// test profile button exists
		let testProfileButton = try XCTUnwrap(app.buttons[AccessibilityIdentifiers.ExposureSubmission.AntigenTest.Profile.profileTile_Description])
		testProfileButton.tap()
		
		/// Antigen Test Profile Screen
		
		// delete profile button exists
		let deleteTestProfileButton = try XCTUnwrap(app.buttons[AccessibilityIdentifiers.ExposureSubmission.AntigenTest.Profile.deleteButton])
		XCTAssertTrue(deleteTestProfileButton.waitForExistence(timeout: .short))
		deleteTestProfileButton.tap()
		
		/// -> Register Test Screen
		
		// create test profile button exists
		_ = try XCTUnwrap(app.buttons[AccessibilityIdentifiers.ExposureSubmission.AntigenTest.Profile.createProfileTile_Description])
	}
}
