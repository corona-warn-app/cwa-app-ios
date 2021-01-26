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

		XCTAssertEqual(app.navigationBars.element(boundBy: 1).identifier, app.localized("ContactDiary_EditEntries_ContactPersons_Title"))

		XCTAssertTrue(app.buttons[app.localized("ContactDiary_EditEntries_ContactPersons_DeleteAllButtonTitle")].exists)
		app.buttons[app.localized("ContactDiary_EditEntries_ContactPersons_DeleteAllButtonTitle")].tap()

		XCTAssertEqual(app.alerts.firstMatch.label, app.localized("ContactDiary_EditEntries_ContactPersons_AlertTitle"))
		app.alerts.firstMatch.buttons[app.localized("ContactDiary_EditEntries_ContactPersons_AlertConfirmButtonTitle")].tap()

		XCTAssertEqual(app.descendants(matching: .table).element(boundBy: 1).cells.count, 0)
	}

	func testDeleteOnePersonAndEditOnePerson() throws {
		app.launchArguments.append(contentsOf: ["-diaryInfoScreenShown", "YES"])

		openEditPersonViaSheet()

		XCTAssertEqual(app.navigationBars.element(boundBy: 1).identifier, app.localized("ContactDiary_EditEntries_ContactPersons_Title"))

		let personsTableView = app.descendants(matching: .table).element(boundBy: 1)
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

		XCTAssertEqual(app.navigationBars.element(boundBy: 2).identifier, app.localized("ContactDiary_AddEditEntry_PersonTitle"))
		app.textFields.firstMatch.typeText("-Müller")

		XCTAssertTrue(app.buttons[app.localized("ContactDiary_AddEditEntry_PrimaryButton_Title")].waitForExistence(timeout: .medium))
		app.buttons[app.localized("ContactDiary_AddEditEntry_PrimaryButton_Title")].tap()

		XCTAssertNotEqual(originalPerson, personsTableView.cells.firstMatch.staticTexts.firstMatch.label)
		XCTAssertEqual(originalPerson + "-Müller", personsTableView.cells.firstMatch.staticTexts.firstMatch.label)
	}

	func testDeleteOneLocationAndEditOneLocation() throws {
		app.launchArguments.append(contentsOf: ["-diaryInfoScreenShown", "YES"])

		openEditLocationsViaSheet()

		XCTAssertEqual(app.navigationBars.element(boundBy: 1).identifier, app.localized("ContactDiary_EditEntries_Locations_Title"))

		let locationsTableView = app.descendants(matching: .table).element(boundBy: 1)
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

		XCTAssertEqual(app.navigationBars.element(boundBy: 2).identifier, app.localized("ContactDiary_AddEditEntry_LocationTitle"))
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
		app.descendants(matching: .table).firstMatch.cells.element(boundBy: 1).tap()

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

		addPersonToDayEntry("Marcus Mustermann")

		// check count for day entries: 1 add entry cell + 1 person added
		XCTAssertEqual(app.descendants(matching: .table).firstMatch.cells.count, 2)

		addPersonToDayEntry("Maria Musterfrau")

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

		addLocationToDayEntry("Pommesbude")

		// check count for day entries: 1 add entry cell + 1 location added
		XCTAssertEqual(app.descendants(matching: .table).firstMatch.cells.count, 2)

		addLocationToDayEntry("Supermarkt")

		// check count for day entries: 1 add entry cell + 2 locations added
		XCTAssertEqual(app.descendants(matching: .table).firstMatch.cells.count, 3)
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
		app.launchArguments.append(contentsOf: ["-riskLevel", "high"])

		navigateToJournalOverview()

		// check count for overview: day cell 15 days plus 1 description cell
		XCTAssertEqual(app.descendants(matching: .table).firstMatch.cells.count, 15 + 1)

		let highRiskCell = app.descendants(matching: .table).firstMatch.cells.element(boundBy: 1)
		XCTAssertNotNil( highRiskCell.staticTexts[AccessibilityIdentifiers.ContactDiaryInformation.Overview.riskLevelHigh])

		let lowRiskCell = app.descendants(matching: .table).firstMatch.cells.element(boundBy: 4)
		XCTAssertNotNil( lowRiskCell.staticTexts[AccessibilityIdentifiers.ContactDiaryInformation.Overview.riskLevelLow])
	}

	// MARK: - Private

	private func navigateToJournalOverview() {
		launch()

		// Click submit card.
		
		XCTAssertTrue(app.cells.buttons[AccessibilityIdentifiers.Home.submitCardButton].waitForExistence(timeout: .long))

		let homeTableView = app.descendants(matching: .table).firstMatch
		search("AppStrings.Home.diaryCardButton", element: homeTableView)?.tap()
        
        XCTAssertTrue(app.navigationBars.staticTexts[app.localized("ContactDiary_Information_Title")].waitForExistence(timeout: .medium))
	}

	private func addPersonToDayEntry(_ personName: String) {
		let addCell = app.descendants(matching: .table).firstMatch.cells.firstMatch
		addCell.tap()

		XCTAssertEqual(app.navigationBars.element(boundBy: 1).identifier, app.localized("ContactDiary_AddEditEntry_PersonTitle"))
		app.textFields.firstMatch.typeText(personName)

		XCTAssertTrue(app.buttons[app.localized("ContactDiary_AddEditEntry_PrimaryButton_Title")].waitForExistence(timeout: .medium))
		app.buttons[app.localized("ContactDiary_AddEditEntry_PrimaryButton_Title")].tap()
	}

	private func addLocationToDayEntry(_ locationName: String) {
		let addCell = app.descendants(matching: .table).firstMatch.cells.firstMatch
		addCell.tap()

		XCTAssertEqual(app.navigationBars.element(boundBy: 1).identifier, app.localized("ContactDiary_AddEditEntry_LocationTitle"))
		app.textFields.firstMatch.typeText(locationName)

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

		XCTAssertTrue(app.navigationBars.firstMatch.buttons.element(boundBy: 1).waitForExistence(timeout: .medium))
		app.navigationBars.firstMatch.buttons.element(boundBy: 1).tap()

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

		while !allElementsFound {
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
		}
		return nil
	}
}
