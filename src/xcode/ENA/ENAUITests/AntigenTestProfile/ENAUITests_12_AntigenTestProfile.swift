////
// 🦠 Corona-Warn-App
//

import XCTest

class ENAUITests_12_AntigenTestProfile: CWATestCase {
	
	// MARK: - Overrides
	
	override func setUp() {
		super.setUp()
		continueAfterFailure = false
		app = XCUIApplication()
		app.setDefaults()
		app.setLaunchArgument(LaunchArguments.onboarding.isOnboarded, to: true)
		app.setLaunchArgument(LaunchArguments.onboarding.setCurrentOnboardingVersion, to: true)
		app.setLaunchArgument(LaunchArguments.infoScreen.antigenTestProfileInfoScreenShown, to: false)
		app.setLaunchArgument(LaunchArguments.test.antigen.removeAntigenTestProfile, to: true)
	}
	
	// MARK: - Internal

	var app: XCUIApplication!
	
	// MARK: - Tests
	
	/* EXPOSUREAPP-12650
	func test_FIRST_CreateAntigenTestProfile_THEN_EditProfile_THEN_DeleteProfile() throws {
		
		app.launch()
		
		/// Home Screen

		let registerTestButton = try XCTUnwrap(app.buttons[AccessibilityIdentifiers.Home.submitCardButton])
		registerTestButton.waitAndTap()
		
		/// Register Test Screen
		
		// don't take this swipe up otherwise this test will fail!
		app.swipeUp(velocity: .slow)

		let createProfileButton = try XCTUnwrap(app.buttons[AccessibilityIdentifiers.ExposureSubmission.AntigenTest.Profile.profileTile_Description])
		createProfileButton.waitAndTap()
		
		/// Antigen Test Information Screen
		
		// header image exists
		XCTAssertTrue(app.images[AccessibilityIdentifiers.ExposureSubmission.AntigenTest.Information.imageDescription].waitForExistence(timeout: .long))
		// title exists
		XCTAssertTrue(app.staticTexts[AccessibilityIdentifiers.ExposureSubmission.AntigenTest.Information.descriptionTitle].waitForExistence(timeout: .long))
		// subtitle exists
		XCTAssertTrue(app.staticTexts[AccessibilityIdentifiers.ExposureSubmission.AntigenTest.Information.descriptionSubHeadline].waitForExistence(timeout: .long))
		// legal text exists
		XCTAssertTrue(app.cells[AccessibilityIdentifiers.ExposureSubmission.AntigenTest.Information.acknowledgementTitle].waitForExistence(timeout: .long))
		
		// find data privacy cell (last cell) and tap it
		let dataPrivacyButton = try XCTUnwrap(app.cells[AccessibilityIdentifiers.ExposureSubmission.AntigenTest.Information.dataPrivacyTitle])
		
		let maxTries = 10
		var currentTry = 0
		while dataPrivacyButton.isHittable == false && currentTry < maxTries {
			app.swipeUp()
			currentTry += 1
		}
		dataPrivacyButton.waitAndTap()
		
		/// Legal Text Screen

		XCTAssertTrue(app.images[AccessibilityIdentifiers.AppInformation.privacyImageDescription].waitForExistence(timeout: .extraLong))

		let backButton = try XCTUnwrap(app.navigationBars.buttons.element(boundBy: 0))
		backButton.waitAndTap()

		/// -> Antigen Test Information Screen
		
		var continueButton = app.buttons[AccessibilityIdentifiers.ExposureSubmission.AntigenTest.Information.continueButton]
		continueButton.waitAndTap()

		/// Add Antigen Test Profile

		createProfileButton.waitAndTap()
		
		app.buttons[AccessibilityLabels.localized(AppStrings.AntigenProfile.Overview.addButtonTitle)].waitAndTap()

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
		XCTAssertTrue(app.buttons[AccessibilityIdentifiers.ExposureSubmission.AntigenTest.Profile.continueButton].waitForExistence(timeout: .long))
		// edit profile button exists
		XCTAssertTrue(app.buttons[AccessibilityIdentifiers.ExposureSubmission.AntigenTest.Profile.editButton].waitForExistence(timeout: .long))

		app.swipeUp(velocity: .slow)

		let personSimpleText = app.staticTexts["Bastian Kohlbauer Herr Bastian Kohlbauer Str. 1 München 80639 089123456 bastian@bastian.codes"]
		XCTAssertTrue(personSimpleText.exists)
				
		let closeButton = try XCTUnwrap(app.navigationBars.buttons.element(boundBy: 1))
		closeButton.waitAndTap()
		
		// Add a second person
		registerTestButton.waitAndTap()
		
		let testProfileButton = try XCTUnwrap(app.buttons[AccessibilityIdentifiers.ExposureSubmission.AntigenTest.Profile.profileTile_Description])
		testProfileButton.waitAndTap()

		app.buttons[AccessibilityLabels.localized(AppStrings.AntigenProfile.Overview.addButtonTitle)].waitAndTap()

		/// Create Antigen Test Profile Screen
		
		let firstNameTextField2 = try XCTUnwrap(app.cells.textFields[AccessibilityIdentifiers.AntigenProfile.Create.firstNameTextField])
		firstNameTextField2.waitAndTap()
		firstNameTextField2.typeText("Omar")
		
		let lastNameTextField2 = try XCTUnwrap(app.cells.textFields[AccessibilityIdentifiers.AntigenProfile.Create.lastNameTextField])
		lastNameTextField2.waitAndTap()
		lastNameTextField2.typeText("Ahmed")
		
		XCTAssertTrue(saveProfileButton.isEnabled)
		saveProfileButton.waitAndTap()
		
		closeButton.waitAndTap()
		
		// Add a second person
		registerTestButton.waitAndTap()
		
		testProfileButton.waitAndTap()
		
		XCTAssertEqual(app.tables[AccessibilityIdentifiers.AntigenProfile.Overview.tableView].cells.count, 3, "should have 3 cells, the add cell and 2 persons")
		let personProfileTile = try XCTUnwrap(app.cells[AccessibilityIdentifiers.AntigenProfile.Overview.antigenTestPersonProfileCell].firstMatch)
		personProfileTile.waitAndTap()

		// edit profile button exists
		var editTestProfileButton = try XCTUnwrap(app.buttons[AccessibilityIdentifiers.ExposureSubmission.AntigenTest.Profile.editButton])
		editTestProfileButton.waitAndTap()

		/// Edit Antigen Test Profile Screen
				let editTestProfileAction = try XCTUnwrap(app.sheets.buttons[AccessibilityLabels.localized(AppStrings.AntigenProfile.Profile.editActionTitle)])
		editTestProfileAction.waitAndTap()

		let editSaveProfileButton = try XCTUnwrap(app.buttons[AccessibilityIdentifiers.ExposureSubmission.AntigenTest.Create.saveButton])
		XCTAssertTrue(editSaveProfileButton.waitForExistence(timeout: .short))
		XCTAssertTrue(editSaveProfileButton.isEnabled)

		let editFirstNameTextField = try XCTUnwrap(app.cells.textFields[AccessibilityIdentifiers.AntigenProfile.Create.firstNameTextField])
		editFirstNameTextField.waitAndTap()
		editFirstNameTextField.typeText("Ronaldo")

		XCTAssertTrue(editSaveProfileButton.isEnabled)
		editSaveProfileButton.waitAndTap()

		/// Antigen Test Profile Screen

		// continues button exists
		continueButton = app.buttons[AccessibilityIdentifiers.ExposureSubmission.AntigenTest.Profile.continueButton]
		XCTAssertTrue(continueButton.waitForExistence(timeout: .short))

		// edit profile button exists
		editTestProfileButton = try XCTUnwrap(app.buttons[AccessibilityIdentifiers.ExposureSubmission.AntigenTest.Profile.editButton])
		editTestProfileButton.waitAndTap()
		let deleteTestProfileButton = try XCTUnwrap(app.sheets.buttons[AccessibilityLabels.localized(AppStrings.AntigenProfile.Profile.deleteActionTitle)])
		deleteTestProfileButton.waitAndTap()

		// confirm deletion on popup
		let popupDeleteButton = try XCTUnwrap(app.alerts.firstMatch.buttons.element(boundBy: 1))
		popupDeleteButton.waitAndTap()
		
		/// -> Register Test Screen
		
		// create test profile button exists

		XCTAssertTrue(app.buttons[AccessibilityLabels.localized(AppStrings.AntigenProfile.Overview.addButtonTitle)].waitForExistence(timeout: .short))
	}
	*/
}
