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
		app.launchArguments.append(contentsOf: [UITestingLaunchArguments.onboarding.isOnboarded, YES])
		app.launchArguments.append(contentsOf: [UITestingLaunchArguments.onboarding.setCurrentOnboardingVersion, YES])
		app.launchArguments.append(contentsOf: [UITestingLaunchArguments.infoScreen.antigenTestProfileInfoScreenShown, NO])
		app.launchArguments.append(contentsOf: [UITestingLaunchArguments.test.antigen.removeAntigenTestProfile, YES])
	}
	
	// MARK: - Internal

	var app: XCUIApplication!
	
	// MARK: - Tests
	
	func test_FIRST_CreateAntigenTestProfile_THEN_DeleteProfile() throws {
		
		app.launch()
		
		/// Home Screen

		let registerTestButton = try XCTUnwrap(app.buttons[AccessibilityIdentifiers.Home.submitCardButton])
		XCTAssertTrue(registerTestButton.waitForExistence(timeout: .short))
		registerTestButton.tap()
		
		/// Register Test Screen

		let createProfileButton = try XCTUnwrap(app.buttons[AccessibilityIdentifiers.ExposureSubmission.AntigenTest.Profile.createProfileTile_Description])
		XCTAssertTrue(createProfileButton.waitForExistence(timeout: .short))
		createProfileButton.tap()
		
		/// Antigen Test Information Screen
		
		// header image exists
		XCTAssertTrue(app.images[AccessibilityIdentifiers.ExposureSubmission.AntigenTest.Information.imageDescription].waitForExistence(timeout: .short))
		// title exists
		XCTAssertTrue(app.staticTexts[AccessibilityIdentifiers.ExposureSubmission.AntigenTest.Information.descriptionTitle].waitForExistence(timeout: .short))
		// subtitle exists
		XCTAssertTrue(app.staticTexts[AccessibilityIdentifiers.ExposureSubmission.AntigenTest.Information.descriptionSubHeadline].waitForExistence(timeout: .short))
		// legal text exists
		XCTAssertTrue(app.cells[AccessibilityIdentifiers.ExposureSubmission.AntigenTest.Information.acknowledgementTitle].waitForExistence(timeout: .short))
		
		let dataPrivacyButton = try XCTUnwrap(app.cells[AccessibilityIdentifiers.ExposureSubmission.AntigenTest.Information.dataPrivacyTitle])
		XCTAssertTrue(dataPrivacyButton.waitForExistence(timeout: .short))
		dataPrivacyButton.tap()
		
		/// Legal Text Screen

		let backButton = try XCTUnwrap(app.navigationBars.buttons.element(boundBy: 0))
		XCTAssertTrue(backButton.waitForExistence(timeout: .short))
		backButton.tap()
		
		/// -> Antigen Test Information Screen
		
		let continueButton = app.buttons[AccessibilityIdentifiers.ExposureSubmission.AntigenTest.Information.continueButton]
		XCTAssertTrue(continueButton.waitForExistence(timeout: .short))
		continueButton.tap()
		
		/// Create Antigen Test Profile Screen

		let saveProfileButton = try XCTUnwrap(app.buttons[AccessibilityIdentifiers.ExposureSubmission.AntigenTest.Create.saveButton])
		XCTAssertTrue(saveProfileButton.waitForExistence(timeout: .short))
		XCTAssertFalse(saveProfileButton.isEnabled)
		
		let firstNameTextField = try XCTUnwrap(app.cells.textFields[AccessibilityIdentifiers.AntigenProfile.Create.firstNameTextField])
		XCTAssertTrue(firstNameTextField.waitForExistence(timeout: .short))
		firstNameTextField.tap()
		firstNameTextField.typeText("Bastian")
		
		let lastNameTextField = try XCTUnwrap(app.cells.textFields[AccessibilityIdentifiers.AntigenProfile.Create.lastNameTextField])
		XCTAssertTrue(lastNameTextField.waitForExistence(timeout: .short))
		lastNameTextField.tap()
		lastNameTextField.typeText("Kohlbauer")
		
		let birthDateTextField = try XCTUnwrap(app.cells.textFields[AccessibilityIdentifiers.AntigenProfile.Create.birthDateTextField])
		XCTAssertTrue(birthDateTextField.waitForExistence(timeout: .short))
		birthDateTextField.tap()
		birthDateTextField.typeText("15-12-1986")
		
		let streetTextField = try XCTUnwrap(app.cells.textFields[AccessibilityIdentifiers.AntigenProfile.Create.streetTextField])
		XCTAssertTrue(streetTextField.waitForExistence(timeout: .short))
		streetTextField.tap()
		streetTextField.typeText("Herr Bastian Kohlbauer Str. 1")
		
		let postalCodeTextField = try XCTUnwrap(app.cells.textFields[AccessibilityIdentifiers.AntigenProfile.Create.postalCodeTextField])
		XCTAssertTrue(postalCodeTextField.waitForExistence(timeout: .short))
		postalCodeTextField.tap()
		postalCodeTextField.typeText("80639")
		
		let cityTextField = try XCTUnwrap(app.cells.textFields[AccessibilityIdentifiers.AntigenProfile.Create.cityTextField])
		XCTAssertTrue(cityTextField.waitForExistence(timeout: .short))
		cityTextField.tap()
		cityTextField.typeText("München")
		
		let phoneNumberTextField = try XCTUnwrap(app.cells.textFields[AccessibilityIdentifiers.AntigenProfile.Create.phoneNumberTextField])
		XCTAssertTrue(phoneNumberTextField.waitForExistence(timeout: .short))
		phoneNumberTextField.tap()
		phoneNumberTextField.typeText("089123456")
		
		let emailAddressTextField = try XCTUnwrap(app.cells.textFields[AccessibilityIdentifiers.AntigenProfile.Create.emailAddressTextField])
		XCTAssertTrue(emailAddressTextField.waitForExistence(timeout: .short))
		emailAddressTextField.tap()
		emailAddressTextField.typeText("bastian@bastian.codes")
		
		XCTAssertTrue(saveProfileButton.isEnabled)
		saveProfileButton.tap()
		
		/// Antigen Test Profile Screen

		// continues button exists
		XCTAssertTrue(app.buttons[AccessibilityIdentifiers.ExposureSubmission.AntigenTest.Profile.continueButton].waitForExistence(timeout: .short))
		// delete profile button exists
		XCTAssertTrue(app.buttons[AccessibilityIdentifiers.ExposureSubmission.AntigenTest.Profile.deleteButton].waitForExistence(timeout: .short))
		
		let closeButton = try XCTUnwrap(app.navigationBars.buttons.element(boundBy: 1))
		XCTAssertTrue(closeButton.waitForExistence(timeout: .short))
		closeButton.tap()
		
		/// -> Home Screen

		registerTestButton.tap()
		
		/// Register Test Screen
		
		// test profile button exists
		let testProfileButton = try XCTUnwrap(app.buttons[AccessibilityIdentifiers.ExposureSubmission.AntigenTest.Profile.profileTile_Description])
		XCTAssertTrue(testProfileButton.waitForExistence(timeout: .short))
		testProfileButton.tap()
		
		/// Antigen Test Profile Screen
		
		// delete profile button exists
		let deleteTestProfileButton = try XCTUnwrap(app.buttons[AccessibilityIdentifiers.ExposureSubmission.AntigenTest.Profile.deleteButton])
		XCTAssertTrue(deleteTestProfileButton.waitForExistence(timeout: .short))
		deleteTestProfileButton.tap()
		
		// confirm deletion on popup
		let popupDeleteButton = try XCTUnwrap(app.alerts.firstMatch.buttons.element(boundBy: 1))
		XCTAssertTrue(deleteTestProfileButton.waitForExistence(timeout: .short))
		popupDeleteButton.tap()
		
		/// -> Register Test Screen
		
		// create test profile button exists
		XCTAssertTrue(app.buttons[AccessibilityIdentifiers.ExposureSubmission.AntigenTest.Profile.createProfileTile_Description].waitForExistence(timeout: .short))
	}
}
