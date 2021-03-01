////
// 🦠 Corona-Warn-App
//

import XCTest
import ExposureNotification

class ENAUITests_07_ContactJournalUITests: XCTestCase {

	// MARK: - Overrides

	override func setUpWithError() throws {
		continueAfterFailure = false

		app = XCUIApplication()
		app.setDefaults()
		app.launchArguments.append(contentsOf: ["-isOnboarded", "YES"])
		app.launchArguments.append(contentsOf: ["-setCurrentOnboardingVersion", "YES"])
		app.launchArguments.append(contentsOf: ["-userNeedsToBeInformedAboutHowRiskDetectionWorks", "NO"])
		app.launchArguments.append(contentsOf: ["-journalRemoveAllPersons", "YES"])
		app.launchArguments.append(contentsOf: ["-journalRemoveAllLocations", "YES"])
	}

	// MARK: - Internal

	var app: XCUIApplication!

	// MARK: - Test cases.

	func testOpenInformationScreenViaSheet() throws {
		app.launchArguments.append(contentsOf: ["-diaryInfoScreenShown", "YES"])

		openInformationSheet()

		app.sheets.firstMatch.buttons.element(boundBy: 0).tap()

		// Check whether we have entered the info screen.
		XCTAssertTrue(app.images["AppStrings.ContactDiaryInformation.imageDescription"].waitForExistence(timeout: .medium))
	}

	func testOpenExportViaSheet() throws {
		app.launchArguments.append(contentsOf: ["-diaryInfoScreenShown", "YES"])

		openInformationSheet()

		app.sheets.firstMatch.buttons.element(boundBy: 1).tap()

		// Check whether we have entered the share sheet.
		XCTAssertTrue(app.otherElements["ActivityListView"].waitForExistence(timeout: .medium))
	}

	func testDeleteAllPersons() throws {
		app.launchArguments.append(contentsOf: ["-diaryInfoScreenShown", "YES"])

		openEditPersonViaSheet()

		XCTAssertEqual(app.navigationBars.element(boundBy: 0).identifier, app.localized("ContactDiary_EditEntries_ContactPersons_Title"))

		XCTAssertTrue(app.buttons[app.localized("ContactDiary_EditEntries_ContactPersons_DeleteAllButtonTitle")].exists)
		app.buttons[app.localized("ContactDiary_EditEntries_ContactPersons_DeleteAllButtonTitle")].tap()

		XCTAssertEqual(app.alerts.firstMatch.label, app.localized("ContactDiary_EditEntries_ContactPersons_AlertTitle"))
		app.alerts.firstMatch.buttons[app.localized("ContactDiary_EditEntries_ContactPersons_AlertConfirmButtonTitle")].tap()

		XCTAssertEqual(app.tables[AccessibilityIdentifiers.ContactDiaryInformation.EditEntries.tableView].cells.count, 0)
	}

	func testDeleteOnePersonAndEditOnePerson() throws {
		app.launchArguments.append(contentsOf: ["-diaryInfoScreenShown", "YES"])

		openEditPersonViaSheet()

		XCTAssertEqual(app.navigationBars.element(boundBy: 0).identifier, app.localized("ContactDiary_EditEntries_ContactPersons_Title"))

		let personsTableView = app.tables[AccessibilityIdentifiers.ContactDiaryInformation.EditEntries.tableView]
		XCTAssertEqual(personsTableView.cells.count, 2)

		// tap the delete button :-)
		personsTableView.cells.element(boundBy: 1).buttons.element(boundBy: 0).tap()
		// wait for delete confirmation button trailing in the cell
		XCTAssertTrue(personsTableView.cells.element(boundBy: 1).buttons.element(boundBy: 2).waitForExistence(timeout: .medium))

		personsTableView.cells.element(boundBy: 1).buttons.element(boundBy: 2).tap()

		XCTAssertEqual(app.alerts.firstMatch.label, app.localized("ContactDiary_EditEntries_ContactPerson_AlertTitle"))
		app.alerts.firstMatch.buttons[app.localized("ContactDiary_EditEntries_ContactPerson_AlertConfirmButtonTitle")].tap()

		XCTAssertEqual(personsTableView.cells.count, 1)

		// select person to edit
		let originalPerson = personsTableView.cells.firstMatch.staticTexts.firstMatch.label
		personsTableView.cells.firstMatch.tap()

		XCTAssertEqual(app.navigationBars.element(boundBy: 1).identifier, app.localized("ContactDiary_AddEditEntry_PersonTitle"))
		app.textFields.firstMatch.typeText("-Müller")

		XCTAssertTrue(app.buttons[app.localized("ContactDiary_AddEditEntry_PrimaryButton_Title")].waitForExistence(timeout: .medium))
		app.buttons[app.localized("ContactDiary_AddEditEntry_PrimaryButton_Title")].tap()

		XCTAssertNotEqual(originalPerson, personsTableView.cells.firstMatch.staticTexts.firstMatch.label)
		XCTAssertEqual(originalPerson + "-Müller", personsTableView.cells.firstMatch.staticTexts.firstMatch.label)
	}

	func testDeleteOneLocationAndEditOneLocation() throws {
		app.launchArguments.append(contentsOf: ["-diaryInfoScreenShown", "YES"])

		openEditLocationsViaSheet()

		XCTAssertEqual(app.navigationBars.element(boundBy: 0).identifier, app.localized("ContactDiary_EditEntries_Locations_Title"))

		let locationsTableView = app.tables[AccessibilityIdentifiers.ContactDiaryInformation.EditEntries.tableView]
		XCTAssertEqual(locationsTableView.cells.count, 2)

		// tap the delete button :-)
		locationsTableView.cells.element(boundBy: 1).buttons.element(boundBy: 0).tap()
		// wait for delete confirmation button trailing in the cell
		XCTAssertTrue(locationsTableView.cells.element(boundBy: 1).buttons.element(boundBy: 2).waitForExistence(timeout: .medium))

		locationsTableView.cells.element(boundBy: 1).buttons.element(boundBy: 2).tap()

		XCTAssertEqual(app.alerts.firstMatch.label, app.localized("ContactDiary_EditEntries_Location_AlertTitle"))
		app.alerts.firstMatch.buttons[app.localized("ContactDiary_EditEntries_Location_AlertConfirmButtonTitle")].tap()

		XCTAssertEqual(locationsTableView.cells.count, 1)

		// select location to edit
		let originalLocation = locationsTableView.cells.firstMatch.staticTexts.firstMatch.label
		locationsTableView.cells.firstMatch.tap()

		XCTAssertEqual(app.navigationBars.element(boundBy: 1).identifier, app.localized("ContactDiary_AddEditEntry_LocationTitle"))
		app.textFields.firstMatch.typeText("-RotWeiss")

		XCTAssertTrue(app.textFields.firstMatch.buttons.firstMatch.waitForExistence(timeout: .medium))
		// tap the clear button inside textfield to clear input
		app.textFields.firstMatch.buttons.firstMatch.tap()
		app.textFields.firstMatch.typeText("PommesBude-RotWeiss")

		XCTAssertTrue(app.buttons[app.localized("ContactDiary_AddEditEntry_PrimaryButton_Title")].waitForExistence(timeout: .medium))
		app.buttons[app.localized("ContactDiary_AddEditEntry_PrimaryButton_Title")].tap()

		XCTAssertNotEqual(originalLocation, locationsTableView.cells.firstMatch.staticTexts.firstMatch.label)
		XCTAssertEqual("PommesBude-RotWeiss", locationsTableView.cells.firstMatch.staticTexts.firstMatch.label)
	}

	func testScreenshotTwoPersonsOneLocationAndMessages() throws {
		var screenshotCounter = 0
		// setting up launch arguments
		app.launchArguments.append(contentsOf: ["-diaryInfoScreenShown", "YES"])
		app.launchArguments.append(contentsOf: ["-riskLevel", "high"])
		
		// navigate to desired screen
		navigateToJournalOverview()
		
		// select first cell
		app.cells.element(boundBy: 1).tap()
		
		// add a person
		addPersonToDayEntry("Andrea")

		// switch to places
		app.segmentedControls.firstMatch.buttons[app.localized("ContactDiary_Day_LocationsSegment")].tap()
		
		// add a location
		addLocationToDayEntry("Physiotherapie")
		
		// go back
		app.navigationBars.firstMatch.buttons.element(boundBy: 0).tap()
		
		// select fourth cell
		app.cells.element(boundBy: 4).tap()
		
		// add a person
		addPersonToDayEntry("Michael")
		
		// go back
		app.navigationBars.firstMatch.buttons.element(boundBy: 0).tap()
		
		app.swipeDown()
		// take screenshot
		snapshot("contact_journal_listing1_\(String(format: "%04d", (screenshotCounter.inc() )))")
		
		app.swipeUp()
		// take screenshot
		snapshot("contact_journal_listing1_\(String(format: "%04d", (screenshotCounter.inc() )))")
	}

	func testAddTwoPersonsAndOneLocationToDate() throws {
		var screenshotCounter = 0
		app.launchArguments.append(contentsOf: ["-diaryInfoScreenShown", "YES"])
		app.launchArguments.append(contentsOf: ["-riskLevel", "high"])

		navigateToJournalOverview()

		// check count for overview: day cell 15 days plus 1 description cell
		XCTAssertEqual(app.descendants(matching: .table).firstMatch.cells.count, 15 + 1)

		// select 3th cell
		XCTAssertTrue(app.descendants(matching: .table).firstMatch.cells.element(boundBy: 3).waitForExistence(timeout: .medium))
		app.descendants(matching: .table).firstMatch.cells.element(boundBy: 3).tap()

		// check count for day entries: 1 add entry cell
		XCTAssertEqual(app.descendants(matching: .table).firstMatch.cells.count, 1)

		addPersonToDayEntry("Marcus Mustermann")
		addPersonToDayEntry("Manu Mustermann")

		// check count for day entries: 1 add entry cell + 1 person added
		XCTAssertEqual(app.descendants(matching: .table).firstMatch.cells.count, 3)

		// deselect Manu Mustermann - 1 because new persons get entered on top
		app.descendants(matching: .table).firstMatch.cells.element(boundBy: 1).staticTexts["Manu Mustermann"].tap()

		XCTAssertTrue(app.segmentedControls.firstMatch.waitForExistence(timeout: .medium))
		app.segmentedControls.firstMatch.buttons[app.localized("ContactDiary_Day_LocationsSegment")].tap()

		// check count for day entries: 1 add entry cell
		XCTAssertEqual(app.descendants(matching: .table).firstMatch.cells.count, 1)

		addLocationToDayEntry("Pommesbude")

		// check count for day entries: 1 add entry cell + 1 location added
		XCTAssertEqual(app.descendants(matching: .table).firstMatch.cells.count, 2)

		XCTAssertTrue(app.navigationBars.firstMatch.buttons.element(boundBy: 0).waitForExistence(timeout: .medium))
		app.navigationBars.firstMatch.buttons.element(boundBy: 0).tap()
		snapshot("contact_journal_listing2_\(String(format: "%04d", (screenshotCounter.inc() )))")

		// check count for overview: day cell 15 days plus 1 description cell
		XCTAssertEqual(app.descendants(matching: .table).firstMatch.cells.count, 15 + 1)

		XCTAssertTrue(app.descendants(matching: .table).firstMatch.cells.element(boundBy: 3).waitForExistence(timeout: .medium))
		let dayCell = app.descendants(matching: .table).firstMatch.cells.element(boundBy: 3)

		XCTAssertTrue(dayCell.staticTexts["Marcus Mustermann"].exists)
		XCTAssertTrue(dayCell.staticTexts["Pommesbude"].exists)
		XCTAssertFalse(dayCell.staticTexts["Manu Mustermann"].exists)
	}

	func testAddPersonToDate() throws {
		app.launchArguments.append(contentsOf: ["-diaryInfoScreenShown", "YES"])

		navigateToJournalOverview()

		// check count for overview: day cell 15 days plus 1 description cell
		XCTAssertEqual(app.descendants(matching: .table).firstMatch.cells.count, 15 + 1)

		// select 3th cell
		XCTAssertTrue(app.descendants(matching: .table).firstMatch.cells.element(boundBy: 3).waitForExistence(timeout: .medium))
		app.descendants(matching: .table).firstMatch.cells.element(boundBy: 3).tap()

		// check count for day entries: 1 add entry cell
		XCTAssertEqual(app.descendants(matching: .table).firstMatch.cells.count, 1)

		addPersonToDayEntry("Marcus Mustermann", phoneNumber: "12345678", eMail: "marcus@mustermann.de")

		// check count for day entries: 1 add entry cell + 1 person added
		XCTAssertEqual(app.descendants(matching: .table).firstMatch.cells.count, 2)

		addPersonToDayEntry("Maria Musterfrau", phoneNumber: "12345678", eMail: "maria@musterfrau.de")

		// check count for day entries: 1 add entry cell + 2 persons added
		XCTAssertEqual(app.descendants(matching: .table).firstMatch.cells.count, 3)
	}

	func testAddLocationToDate() throws {
		app.launchArguments.append(contentsOf: ["-diaryInfoScreenShown", "YES"])

		navigateToJournalOverview()

		// check count for overview: day cell 15 days plus 1 description cell
		XCTAssertEqual(app.descendants(matching: .table).firstMatch.cells.count, 15 + 1)

		// select 3rd cell
		XCTAssertTrue(app.descendants(matching: .table).firstMatch.cells.element(boundBy: 3).waitForExistence(timeout: .medium))
		app.descendants(matching: .table).firstMatch.cells.element(boundBy: 3).tap()

		XCTAssertTrue(app.segmentedControls.firstMatch.waitForExistence(timeout: .medium))
		app.segmentedControls.firstMatch.buttons[app.localized("ContactDiary_Day_LocationsSegment")].tap()

		// check count for day entries: 1 add entry cell
		XCTAssertEqual(app.descendants(matching: .table).firstMatch.cells.count, 1)

		addLocationToDayEntry("Pommesbude", phoneNumber: "12345678", eMail: "pommes@bude.de")

		// check count for day entries: 1 add entry cell + 1 location added
		XCTAssertEqual(app.descendants(matching: .table).firstMatch.cells.count, 2)

		addLocationToDayEntry("Supermarkt", phoneNumber: "12345678", eMail: "super@markt.de")

		// check count for day entries: 1 add entry cell + 2 locations added
		XCTAssertEqual(app.descendants(matching: .table).firstMatch.cells.count, 3)
	}

	func testDetailsSelectionOfPersonEncounter() {
		app.launchArguments.append(contentsOf: ["-diaryInfoScreenShown", "YES"])

		navigateToJournalOverview()

		// Select 3rd cell.

		XCTAssertTrue(app.descendants(matching: .table).firstMatch.cells.element(boundBy: 3).waitForExistence(timeout: .medium))
		app.descendants(matching: .table).firstMatch.cells.element(boundBy: 3).tap()

		// Add person.

		addPersonToDayEntry("Marcus Mustermann")

		// Select details of encounter.

		XCTAssertTrue(app.segmentedControls[AccessibilityIdentifiers.ContactDiaryInformation.Day.maskSituationSegmentedControl].firstMatch.buttons.element(boundBy: 1).waitForExistence(timeout: .medium))
		app.segmentedControls[AccessibilityIdentifiers.ContactDiaryInformation.Day.maskSituationSegmentedControl].firstMatch.buttons.element(boundBy: 1).tap()

		XCTAssertTrue(app.segmentedControls[AccessibilityIdentifiers.ContactDiaryInformation.Day.settingSegmentedControl].firstMatch.buttons.element(boundBy: 1).waitForExistence(timeout: .medium))
		app.segmentedControls[AccessibilityIdentifiers.ContactDiaryInformation.Day.settingSegmentedControl].firstMatch.buttons.element(boundBy: 1).tap()

		// Enter note

		app.textFields[AccessibilityIdentifiers.ContactDiaryInformation.Day.notesTextField].firstMatch.tap()
		app.textFields[AccessibilityIdentifiers.ContactDiaryInformation.Day.notesTextField].firstMatch.typeText("Some note!")

		// Navigate back.

		XCTAssertTrue(app.navigationBars.firstMatch.buttons.element(boundBy: 0).waitForExistence(timeout: .medium))
		app.navigationBars.firstMatch.buttons.element(boundBy: 0).tap()

		// Check if the label for the settings exists on the overview.

		XCTAssertTrue(app.staticTexts[app.localized("ContactDiary_Day_Encounter_WithoutMask") + ", " + app.localized("ContactDiary_Day_Encounter_Inside")].exists)
		XCTAssertTrue(app.staticTexts["Some note!"].exists)
	}

	func testDetailsSelectionOfLocationVisit() {
		app.launchArguments.append(contentsOf: ["-diaryInfoScreenShown", "YES"])

		navigateToJournalOverview()

		// Select 3th cell.

		XCTAssertTrue(app.descendants(matching: .table).firstMatch.cells.element(boundBy: 3).waitForExistence(timeout: .medium))
		app.descendants(matching: .table).firstMatch.cells.element(boundBy: 3).tap()

		// Navigate to locatin section.

		XCTAssertTrue(app.segmentedControls.firstMatch.waitForExistence(timeout: .medium))
		app.segmentedControls.firstMatch.buttons[app.localized("ContactDiary_Day_LocationsSegment")].tap()

		// Add location.

		addLocationToDayEntry("Pizzabude")

		// Select details of locaton visit.

		// Select duration.

		app.otherElements["Hours"].firstMatch.tap()
		app.keys["0"].tap()
		app.keys["4"].tap()
		app.keys["2"].tap()
		// Close keyboard.
		app.tap()

		// Wait for closing.

		let textField = app.textFields[AccessibilityIdentifiers.ContactDiaryInformation.Day.notesTextField].firstMatch
		let exists = NSPredicate(format: "exists == 1")
		expectation(for: exists, evaluatedWith: textField, handler: nil)
		waitForExpectations(timeout: .medium, handler: nil)

		// Enter note

		app.textFields[AccessibilityIdentifiers.ContactDiaryInformation.Day.notesTextField].firstMatch.tap()
		app.textFields[AccessibilityIdentifiers.ContactDiaryInformation.Day.notesTextField].firstMatch.typeText("Some note!")

		// Navigate back.

		XCTAssertTrue(app.navigationBars.firstMatch.buttons.element(boundBy: 0).waitForExistence(timeout: .medium))
		app.navigationBars.firstMatch.buttons.element(boundBy: 0).tap()

		// Check if the label for the settings exists on the overview.

		XCTAssertTrue(app.staticTexts["00:42 " + app.localized("ContactDiary_Overview_LocationVisit_Abbreviation_Hours")].exists)
		XCTAssertTrue(app.staticTexts["Some note!"].exists)
	}

	func testNavigateToPersonEncounterDayInfo() {
		app.launchArguments.append(contentsOf: ["-diaryInfoScreenShown", "YES"])

		navigateToJournalOverview()

		// Select 3rd cell.
		XCTAssertTrue(app.descendants(matching: .table).firstMatch.cells.element(boundBy: 3).waitForExistence(timeout: .medium))
		app.descendants(matching: .table).firstMatch.cells.element(boundBy: 3).tap()

		addPersonToDayEntry("Marcus Mustermann")

		// Tap info button.
		app.buttons[AccessibilityIdentifiers.ContactDiaryInformation.Day.notesInfoButton].tap()

		// Wait for info screen.
		XCTAssertTrue(app.navigationBars[app.localized("Contact_Journal_Notes_Description_Title")].waitForExistence(timeout: .medium))
	}

	func testNavigateToLocationDayInfo() {
		app.launchArguments.append(contentsOf: ["-diaryInfoScreenShown", "YES"])

		navigateToJournalOverview()

		// Select 3rd cell.
		XCTAssertTrue(app.descendants(matching: .table).firstMatch.cells.element(boundBy: 3).waitForExistence(timeout: .medium))
		app.descendants(matching: .table).firstMatch.cells.element(boundBy: 3).tap()

		// Navigate to locatin section.
		XCTAssertTrue(app.segmentedControls.firstMatch.waitForExistence(timeout: .medium))
		app.segmentedControls.firstMatch.buttons[app.localized("ContactDiary_Day_LocationsSegment")].tap()

		addLocationToDayEntry("Pizzabude")

		// Tap info button.
		app.buttons[AccessibilityIdentifiers.ContactDiaryInformation.Day.notesInfoButton].tap()

		// Wait for info screen.
		XCTAssertTrue(app.navigationBars[app.localized("Contact_Journal_Notes_Description_Title")].waitForExistence(timeout: .medium))
	}

	func testNavigationToInformationVC() throws {
		app.launchArguments.append(contentsOf: ["-diaryInfoScreenShown", "NO"])

		navigateToJournalOverview()

		// Check whether we have entered the info screen.
		XCTAssertTrue(app.images["AppStrings.ContactDiaryInformation.imageDescription"].waitForExistence(timeout: .medium))

		app.swipeUp(velocity: .fast)
		app.swipeUp(velocity: .fast)

		let privacyCell = try XCTUnwrap(app.cells["AppStrings.ContactDiaryInformation.dataPrivacyTitle"].firstMatch, "Privacy Cell not found")
		privacyCell.tap()

		XCTAssertTrue(app.images["AppStrings.AppInformation.privacyImageDescription"].waitForExistence(timeout: .medium))
	}

	func testCloseInformationVC() throws {
		app.launchArguments.append(contentsOf: ["-diaryInfoScreenShown", "NO"])

		navigateToJournalOverview()

		// Check whether we have entered the info screen.
		XCTAssertTrue(app.images["AppStrings.ContactDiaryInformation.imageDescription"].waitForExistence(timeout: .medium))

		// Select diary button
		XCTAssertTrue(app
			.buttons["AppStrings.ExposureSubmission.primaryButton"]
			.waitForExistence(timeout: .medium)
		)
		app.buttons["AppStrings.ExposureSubmission.primaryButton"].tap()

		XCTAssertEqual(app.navigationBars.firstMatch.identifier, app.localized("ContactDiary_Overview_Title"))
	}

	func testOverviewWithRiskLevelHighOnToday() throws {
		app.launchArguments.append(contentsOf: ["-diaryInfoScreenShown", "YES"])
		app.launchArguments.append(contentsOf: ["-riskLevel", "high"])
		app.launchArguments.append(contentsOf: ["-diaryInfoScreenShown", "YES"])

		navigateToJournalOverview()

        // check if overview is visible
        XCTAssertEqual(app.navigationBars.firstMatch.identifier, app.localized("ContactDiary_Overview_Title"))

		let highRiskCell = app.descendants(matching: .table).firstMatch.cells.element(boundBy: 1)
		XCTAssertNotNil( highRiskCell.staticTexts[AccessibilityIdentifiers.ContactDiaryInformation.Overview.riskLevelHigh])

		let lowRiskCell = app.descendants(matching: .table).firstMatch.cells.element(boundBy: 4)
		XCTAssertNotNil( lowRiskCell.staticTexts[AccessibilityIdentifiers.ContactDiaryInformation.Overview.riskLevelLow])
	}

	// MARK: - Private

	private func navigateToJournalOverview() {
		launch()

		XCTAssertTrue(app.buttons[AccessibilityIdentifiers.Tabbar.diary].waitForExistence(timeout: .medium))

		app.buttons[AccessibilityIdentifiers.Tabbar.diary].tap()
  
	}

	private func addPersonToDayEntry(_ personName: String, phoneNumber: String = "", eMail: String = "") {
		let addCell = app.descendants(matching: .table).firstMatch.cells.firstMatch
		addCell.tap()

		XCTAssertEqual(app.navigationBars.element(boundBy: 0).identifier, app.localized("ContactDiary_AddEditEntry_PersonTitle"))

		app.textFields[AccessibilityIdentifiers.ContactDiaryInformation.EditEntries.nameTextField].typeText(personName)
		app.textFields[AccessibilityIdentifiers.ContactDiaryInformation.EditEntries.phoneNumberTextField].tap()
		app.textFields[AccessibilityIdentifiers.ContactDiaryInformation.EditEntries.phoneNumberTextField].typeText(phoneNumber)
		app.textFields[AccessibilityIdentifiers.ContactDiaryInformation.EditEntries.eMailTextField].tap()
		app.textFields[AccessibilityIdentifiers.ContactDiaryInformation.EditEntries.eMailTextField].typeText(eMail)

		XCTAssertTrue(app.buttons[app.localized("ContactDiary_AddEditEntry_PrimaryButton_Title")].waitForExistence(timeout: .medium))
		app.buttons[app.localized("ContactDiary_AddEditEntry_PrimaryButton_Title")].tap()
	}

	private func addLocationToDayEntry(_ locationName: String, phoneNumber: String = "", eMail: String = "") {
		let addCell = app.descendants(matching: .table).firstMatch.cells.firstMatch
		addCell.tap()

		XCTAssertEqual(app.navigationBars.element(boundBy: 0).identifier, app.localized("ContactDiary_AddEditEntry_LocationTitle"))

		app.textFields[AccessibilityIdentifiers.ContactDiaryInformation.EditEntries.nameTextField].typeText(locationName)
		app.textFields[AccessibilityIdentifiers.ContactDiaryInformation.EditEntries.phoneNumberTextField].tap()
		app.textFields[AccessibilityIdentifiers.ContactDiaryInformation.EditEntries.phoneNumberTextField].typeText(phoneNumber)
		app.textFields[AccessibilityIdentifiers.ContactDiaryInformation.EditEntries.eMailTextField].tap()
		app.textFields[AccessibilityIdentifiers.ContactDiaryInformation.EditEntries.eMailTextField].typeText(eMail)

		XCTAssertTrue(app.buttons[app.localized("ContactDiary_AddEditEntry_PrimaryButton_Title")].waitForExistence(timeout: .medium))
		app.buttons[app.localized("ContactDiary_AddEditEntry_PrimaryButton_Title")].tap()
	}

	private func prepareDataInOverview() {
		navigateToJournalOverview()

		// select 3rd cell
		XCTAssertTrue(app.descendants(matching: .table).firstMatch.cells.element(boundBy: 3).waitForExistence(timeout: .medium))
		app.descendants(matching: .table).firstMatch.cells.element(boundBy: 3).tap()

		addPersonToDayEntry("Marcus Mustermann")
		addPersonToDayEntry("Manu Mustermann")
		app.segmentedControls.firstMatch.buttons[app.localized("ContactDiary_Day_LocationsSegment")].tap()
		addLocationToDayEntry("Pommesbude")
		addLocationToDayEntry("Dönerstand")

		XCTAssertTrue(app.navigationBars.firstMatch.buttons.element(boundBy: 0).waitForExistence(timeout: .medium))
		app.navigationBars.firstMatch.buttons.element(boundBy: 0).tap()
	}

	private func openInformationSheet() {
		prepareDataInOverview()

		XCTAssertTrue(app.navigationBars.firstMatch.buttons.element(boundBy: 0).waitForExistence(timeout: .medium))
		app.navigationBars.firstMatch.buttons.element(boundBy: 0).tap()

		XCTAssertTrue(app.sheets.firstMatch.waitForExistence(timeout: .medium))
	}

	private func openEditPersonViaSheet() {
		openInformationSheet()

		app.sheets.firstMatch.buttons.element(boundBy: 2).tap()
	}

	private func openEditLocationsViaSheet() {
		openInformationSheet()

		app.sheets.firstMatch.buttons.element(boundBy: 3).tap()
	}

	private func launch() {
		app.launch()
		XCTAssertTrue(app.buttons[AccessibilityIdentifiers.Home.rightBarButtonDescription].waitForExistence(timeout: .long))
	}

	/// we will search for the given identifier inside a scrollable element
	/// scroll and collect all visible elements until the collection doen't change
	private func search(_ identifier: String, element: XCUIElement) -> XCUIElement? {
		var allElementsFound = false
		var lastLoopSeenElements: [String] = []
		var retryCount = 0

		while !allElementsFound, retryCount < 10 /* max retries is arbitrary but required to prevent infinite loops */ {
			/** search for a possible button */
			guard !element.buttons[identifier].exists else {
				return element.buttons[identifier]
			}

			/** search for a possible cell */
			guard !element.cells[identifier].exists else {
				return element.cells[identifier]
			}

			let allElements = element.cells.allElementsBoundByIndex.map { $0.identifier } + element.buttons.allElementsBoundByIndex.map { $0.identifier }
			allElementsFound = allElements == lastLoopSeenElements
			lastLoopSeenElements = allElements

			app.swipeUp()
			retryCount += 1
		}
		return nil
	}
}
