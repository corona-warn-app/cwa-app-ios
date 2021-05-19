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
		app.launchArguments.append(contentsOf: ["-isOnboarded", YES])
		app.launchArguments.append(contentsOf: ["-setCurrentOnboardingVersion", YES])
		app.launchArguments.append(contentsOf: ["-antigenTestProfileInfoScreenShown", NO])
		app.launchArguments.append(contentsOf: ["-removeAntigenTestProfile", YES])
	}
	
	// MARK: - Internal

	var app: XCUIApplication!
	
	// MARK: - Tests
	
	func test_FIRST_CreateAntigenTestProfile_THEN_DeleteProfile() throws {
		
		app.launch()
		
		/// Home Screen

		let registerTestButton = try XCTUnwrap(app.buttons[AccessibilityIdentifiers.Home.submitCardButton])
		registerTestButton.waitAndTap()
		
		/// Register Test Screen

		let createProfileButton = try XCTUnwrap(app.buttons[AccessibilityIdentifiers.ExposureSubmission.AntigenTest.Profile.createProfileTile_Description])
		createProfileButton.waitAndTap()
		
		/// Antigen Test Information Screen
		
		// header image exists
		XCTAssertTrue(app.images[AccessibilityIdentifiers.ExposureSubmission.AntigenTest.Information.imageDescription].waitForExistence(timeout: .short))
		// title exists
		XCTAssertTrue(app.staticTexts[AccessibilityIdentifiers.ExposureSubmission.AntigenTest.Information.descriptionTitle].waitForExistence(timeout: .short))
		// subtitle exists
		XCTAssertTrue(app.staticTexts[AccessibilityIdentifiers.ExposureSubmission.AntigenTest.Information.descriptionSubHeadline].waitForExistence(timeout: .long))
		// legal text exists
		XCTAssertTrue(app.cells[AccessibilityIdentifiers.ExposureSubmission.AntigenTest.Information.acknowledgementTitle].waitForExistence(timeout: .long))
		
		// find data privacy cell (last cell) and tap it
		let dataPrivacyButton = try XCTUnwrap(app.cells[AccessibilityIdentifiers.ExposureSubmission.AntigenTest.Information.dataPrivacyTitle])
		
		let maxTries = 10
		var actualTry = 0
		while dataPrivacyButton.isHittable == false && actualTry < maxTries {
			app.swipeUp()
			actualTry += 1
		}
		dataPrivacyButton.waitAndTap()
		
		/// Legal Text Screen

		XCTAssertTrue(app.images[AccessibilityIdentifiers.AppInformation.privacyImageDescription].waitForExistence(timeout: .extraLong))

		let backButton = try XCTUnwrap(app.navigationBars.buttons.element(boundBy: 0))
		backButton.waitAndTap()
		
		/// -> Antigen Test Information Screen
		
		let continueButton = app.buttons[AccessibilityIdentifiers.ExposureSubmission.AntigenTest.Information.continueButton]
		continueButton.waitAndTap()
		
		/// Create Antigen Test Profile Screen

		let saveProfileButton = try XCTUnwrap(app.buttons[AccessibilityIdentifiers.ExposureSubmission.AntigenTest.Create.saveButton])
		XCTAssertTrue(saveProfileButton.waitForExistence(timeout: .short))
		XCTAssertFalse(saveProfileButton.isEnabled)
		
		let firstNameTextField = try XCTUnwrap(app.cells.textFields[AccessibilityIdentifiers.AntigenProfile.Create.firstNameTextField])
		firstNameTextField.waitAndTap()
		firstNameTextField.typeText("Bastian")
		
		let lastNameTextField = try XCTUnwrap(app.cells.textFields[AccessibilityIdentifiers.AntigenProfile.Create.lastNameTextField])
		lastNameTextField.waitAndTap()
		lastNameTextField.typeText("Kohlbauer")
		
		let birthDateTextField = try XCTUnwrap(app.cells.textFields[AccessibilityIdentifiers.AntigenProfile.Create.birthDateTextField])
		birthDateTextField.waitAndTap()
		birthDateTextField.typeText("15-12-1986")
		
		let streetTextField = try XCTUnwrap(app.cells.textFields[AccessibilityIdentifiers.AntigenProfile.Create.streetTextField])
		streetTextField.waitAndTap()
		streetTextField.typeText("Herr Bastian Kohlbauer Str. 1")
		
		let postalCodeTextField = try XCTUnwrap(app.cells.textFields[AccessibilityIdentifiers.AntigenProfile.Create.postalCodeTextField])
		postalCodeTextField.waitAndTap()
		postalCodeTextField.typeText("80639")
		
		let cityTextField = try XCTUnwrap(app.cells.textFields[AccessibilityIdentifiers.AntigenProfile.Create.cityTextField])
		cityTextField.waitAndTap()
		cityTextField.typeText("München")
		
		let phoneNumberTextField = try XCTUnwrap(app.cells.textFields[AccessibilityIdentifiers.AntigenProfile.Create.phoneNumberTextField])
		phoneNumberTextField.waitAndTap()
		phoneNumberTextField.typeText("089123456")
		
		let emailAddressTextField = try XCTUnwrap(app.cells.textFields[AccessibilityIdentifiers.AntigenProfile.Create.emailAddressTextField])
		emailAddressTextField.waitAndTap()
		emailAddressTextField.typeText("bastian@bastian.codes")
		
		XCTAssertTrue(saveProfileButton.isEnabled)
		saveProfileButton.waitAndTap()
		
		/// Antigen Test Profile Screen

		// continues button exists
		XCTAssertTrue(app.buttons[AccessibilityIdentifiers.ExposureSubmission.AntigenTest.Profile.continueButton].waitForExistence(timeout: .short))
		// delete profile button exists
		XCTAssertTrue(app.buttons[AccessibilityIdentifiers.ExposureSubmission.AntigenTest.Profile.deleteButton].waitForExistence(timeout: .short))
		
		let closeButton = try XCTUnwrap(app.navigationBars.buttons.element(boundBy: 1))
		closeButton.waitAndTap()
		
		/// -> Home Screen

		registerTestButton.waitAndTap()
		
		/// Register Test Screen
		
		// test profile button exists
		let testProfileButton = try XCTUnwrap(app.buttons[AccessibilityIdentifiers.ExposureSubmission.AntigenTest.Profile.profileTile_Description])
		testProfileButton.waitAndTap()
		
		/// Antigen Test Profile Screen
		
		// delete profile button exists
		let deleteTestProfileButton = try XCTUnwrap(app.buttons[AccessibilityIdentifiers.ExposureSubmission.AntigenTest.Profile.deleteButton])
		deleteTestProfileButton.waitAndTap()
		
		// confirm deletion on popup
		let popupDeleteButton = try XCTUnwrap(app.alerts.firstMatch.buttons.element(boundBy: 1))
		popupDeleteButton.waitAndTap()
		
		/// -> Register Test Screen
		
		// create test profile button exists
		XCTAssertTrue(app.buttons[AccessibilityIdentifiers.ExposureSubmission.AntigenTest.Profile.createProfileTile_Description].waitForExistence(timeout: .short))
	}
}
