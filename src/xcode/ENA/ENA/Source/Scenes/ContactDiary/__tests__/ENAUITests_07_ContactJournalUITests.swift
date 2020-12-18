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
		app.launchArguments.append(contentsOf: ["-diaryInfoScreenShown", "YES"])

		app.launchArguments.append(contentsOf: ["-journalRemoveAllPersons", "YES"])
	}

	// MARK: - Internal

	var app: XCUIApplication!

	// MARK: - Test cases.

	private func addPersonToDayEntry(_ personName: String) {
		let addCell = app.descendants(matching: .table).firstMatch.cells.firstMatch
		addCell.tap()

		XCTAssertEqual(app.navigationBars.element(boundBy: 1).identifier, app.localized("ContactDiary_AddEditEntry_PersonTitle"))
		app.textFields.firstMatch.typeText(personName)

		XCTAssertTrue(app.buttons[app.localized("ContactDiary_AddEditEntry_PrimaryButton_Title")].waitForExistence(timeout: .medium))
		app.buttons[app.localized("ContactDiary_AddEditEntry_PrimaryButton_Title")].tap()
	}

	func testAddPersonAndLocationToADate() {

		navigateToJournalOverview()

		// check count for overview: day cell 14 days plus 1 description cell
		XCTAssertEqual(app.descendants(matching: .table).firstMatch.cells.count, 14 + 1)

		// select 3th cell
		XCTAssertTrue(app.descendants(matching: .table).firstMatch.cells.element(boundBy: 3).waitForExistence(timeout: .medium))
		app.descendants(matching: .table).firstMatch.cells.element(boundBy: 3).tap()

		// check count for day entries: 1 add entry cell
		XCTAssertEqual(app.descendants(matching: .table).firstMatch.cells.count, 1)

		addPersonToDayEntry("Marcus Mustermann")

		// check count for day entries: 1 add entry cell + 1 person added
		XCTAssertEqual(app.descendants(matching: .table).firstMatch.cells.count, 2)

		addPersonToDayEntry("Maria Musterfrau")

		// check count for day entries: 1 add entry cell + 2 person added
		XCTAssertEqual(app.descendants(matching: .table).firstMatch.cells.count, 3)
	}


	func testNavigationToInformationVC() throws {
		app.launchArguments.append(contentsOf: ["-diaryInfoScreenShown", "NO"])

		navigateToJournalOverview()

		// Check whether we have entered the info screen.
		XCTAssertTrue(app.images["AppStrings.ContactDiaryInformation.imageDescription"].waitForExistence(timeout: .medium))

		// search for data privacy cell and tap
		search("AppStrings.ContactDiaryInformation.dataPrivacyTitle", element: app)?.tap()

		XCTAssertTrue(app.navigationBars.element(boundBy: 1).waitForExistence(timeout: .medium))
		XCTAssertEqual(app.navigationBars.element(boundBy: 1).identifier, app.localized("App_Information_Privacy_Navigation"))
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


	// MARK: - Private

	private func navigateToJournalOverview() {
		launch()

		// Click submit card.
		XCTAssertTrue(app.collectionViews.buttons["AppStrings.Home.submitCardButton"].waitForExistence(timeout: .long))

		let collectionView = app.descendants(matching: .collectionView).firstMatch
		search("AppStrings.Home.diaryCardButton", element: collectionView)?.tap()
	}

	private func launch() {
		app.launch()
		XCTAssertTrue(app.buttons["AppStrings.Home.rightBarButtonDescription"].waitForExistence(timeout: .long))
	}

	/// we will search for the given identifier inside a scrollable element
	/// scroll and collect all visible elements until the collection doen't change
	private func search(_ identifier: String, element: XCUIElement) -> XCUIElement? {
		var allElementsFound = false
		var seenElementIdentifiers: [String] = []

		while !allElementsFound {
			// search for a possibel button
			guard !element.buttons[identifier].exists else {
				return element.buttons[identifier]
			}

			// search for a possible cell
			guard !element.cells[identifier].exists else {
				return element.cells[identifier]
			}

			let allElements = element.cells.allElementsBoundByIndex.map { $0.identifier } + element.buttons.allElementsBoundByIndex.map { $0.identifier }
			allElementsFound = allElements == seenElementIdentifiers
			seenElementIdentifiers = allElements

			let coordinateToStartFrom = element.coordinate(
				withNormalizedOffset: CGVector(
					dx: 0.99,
					dy: 0.9
				)
			)

			coordinateToStartFrom.press(
				forDuration: 0.01,
				thenDragTo: element.coordinate(
					withNormalizedOffset: CGVector(
						dx: 0.99,
						dy: 0.1)
				)
			)
		}
		return nil
	}

}
