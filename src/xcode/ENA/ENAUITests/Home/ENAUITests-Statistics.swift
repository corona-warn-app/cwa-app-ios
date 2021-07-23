//
// 🦠 Corona-Warn-App
//

import XCTest
import ExposureNotification

class ENAUITests_01b_Statistics: CWATestCase {
	var app: XCUIApplication!
	
	override func setUp() {
		super.setUp()
		continueAfterFailure = false
		app = XCUIApplication()
		app.setDefaults()
		app.setLaunchArgument(LaunchArguments.onboarding.isOnboarded, to: true)
		app.setLaunchArgument(LaunchArguments.onboarding.setCurrentOnboardingVersion, to: true)
		app.setLaunchArgument(LaunchArguments.infoScreen.userNeedsToBeInformedAboutHowRiskDetectionWorks, to: false)
	}

	func test_AddStatisticsButton_maximumNumberOfCards() {
		let addButtonIdentifier = AccessibilityIdentifiers.LocalStatistics.addLocalIncidencesButton
		let modifyButton = AccessibilityIdentifiers.LocalStatistics.modifyLocalIncidencesButton
		let localStatisticsViewTitle = AccessibilityIdentifiers.LocalStatistics.localStatisticsCard

		app.setPreferredContentSizeCategory(accessibility: .normal, size: .S)
		app.launch()
		app.swipeUp(velocity: .slow)
		let statisticsCell = app.cells[AccessibilityIdentifiers.Statistics.General.tableViewCell]
		XCTAssertTrue(statisticsCell.waitForExistence(timeout: .medium))
		statisticsCell.swipeRight()

		// Management card(s) pt.1 - addition
		XCTAssertTrue(self.app.buttons[addButtonIdentifier].waitForExistence(timeout: .medium))
		XCTAssertTrue(statisticsCell.buttons[addButtonIdentifier].isHittable)
		XCTAssertFalse(statisticsCell.buttons[modifyButton].isHittable) // assuming empty statistics
		statisticsCell.buttons[addButtonIdentifier].waitAndTap()
		
		// ADDING Card number: 1
		XCTAssertTrue(app.tables[AccessibilityIdentifiers.LocalStatistics.selectState].waitForExistence(timeout: .short))
		app.cells.element(boundBy: 1).waitAndTap()
		XCTAssertTrue(app.tables[AccessibilityIdentifiers.LocalStatistics.selectDistrict].waitForExistence(timeout: .short))
		app.cells.element(boundBy: 6).waitAndTap()
		// the Local statistics card will appear.
		XCTAssertTrue(statisticsCell.waitForExistence(timeout: .short))
		app.swipeDown(velocity: .slow) // glitch
		let localStatisticCell = statisticsCell.staticTexts[localStatisticsViewTitle]
		XCTAssertTrue(localStatisticCell.waitForExistence(timeout: .short))
		
		// ADDING Card number: 2
		localStatisticCell.swipeRight()
		statisticsCell.buttons[addButtonIdentifier].waitAndTap()
		XCTAssertTrue(app.tables[AccessibilityIdentifiers.LocalStatistics.selectState].waitForExistence(timeout: .short))
		app.cells.element(boundBy: 1).waitAndTap()
		XCTAssertTrue(app.tables[AccessibilityIdentifiers.LocalStatistics.selectDistrict].waitForExistence(timeout: .short))
		app.cells.element(boundBy: 2).waitAndTap()
		// the Local statistics card will appear.
		XCTAssertTrue(statisticsCell.waitForExistence(timeout: .short))
		app.swipeDown(velocity: .slow) // glitch
		XCTAssertTrue(localStatisticCell.waitForExistence(timeout: .short))

		// ADDING Card number: 3
		statisticsCell.swipeRight()
		statisticsCell.buttons[addButtonIdentifier].waitAndTap()
		XCTAssertTrue(app.tables[AccessibilityIdentifiers.LocalStatistics.selectState].waitForExistence(timeout: .short))
		app.cells.element(boundBy: 1).waitAndTap()
		XCTAssertTrue(app.tables[AccessibilityIdentifiers.LocalStatistics.selectDistrict].waitForExistence(timeout: .short))
		app.cells.element(boundBy: 7).waitAndTap()
		// the Local statistics card will appear.
		XCTAssertTrue(statisticsCell.waitForExistence(timeout: .short))
		XCTAssertTrue(localStatisticCell.waitForExistence(timeout: .short))

		// ADDING Card number: 4
		statisticsCell.swipeRight()
		statisticsCell.buttons[addButtonIdentifier].waitAndTap()
		XCTAssertTrue(app.tables[AccessibilityIdentifiers.LocalStatistics.selectState].waitForExistence(timeout: .short))
		app.cells.element(boundBy: 1).waitAndTap()
		XCTAssertTrue(app.tables[AccessibilityIdentifiers.LocalStatistics.selectDistrict].waitForExistence(timeout: .short))
		app.cells.element(boundBy: 4).waitAndTap()
		// the Local statistics card will appear.
		XCTAssertTrue(statisticsCell.waitForExistence(timeout: .short))
		XCTAssertTrue(localStatisticCell.waitForExistence(timeout: .short))
		
		// ADDING Card number: 5
		statisticsCell.swipeRight()
		statisticsCell.buttons[addButtonIdentifier].waitAndTap()
		XCTAssertTrue(app.tables[AccessibilityIdentifiers.LocalStatistics.selectState].waitForExistence(timeout: .short))
		app.cells.element(boundBy: 1).waitAndTap()
		XCTAssertTrue(app.tables[AccessibilityIdentifiers.LocalStatistics.selectDistrict].waitForExistence(timeout: .short))
		app.cells.element(boundBy: 9).waitAndTap()

		// the Local statistics card will appear.
		XCTAssertTrue(statisticsCell.waitForExistence(timeout: .short))
		XCTAssertTrue(localStatisticCell.waitForExistence(timeout: .short))
		statisticsCell.swipeRight()
		
		// check for the text for the add button
		let addButton = app.buttons[addButtonIdentifier]
		let expectTitle = AccessibilityLabels.localized(AppStrings.Statistics.AddCard.disabledAddTitle)
		XCTAssertEqual(addButton.label, expectTitle, "label should show the disabled message")
		XCTAssertFalse(addButton.isEnabled, "button should be disabled after 5 cards")
	}
	
	func test_AddStatisticsButton_flow() {
		let addButton = AccessibilityIdentifiers.LocalStatistics.addLocalIncidencesButton
		let modifyButton = AccessibilityIdentifiers.LocalStatistics.modifyLocalIncidencesButton
		let localStatisticsViewTitle = AccessibilityIdentifiers.LocalStatistics.localStatisticsCard

		app.setPreferredContentSizeCategory(accessibility: .normal, size: .S)
		app.launch()
		app.swipeUp(velocity: .slow)
		let statisticsCell = app.cells[AccessibilityIdentifiers.Statistics.General.tableViewCell]
		XCTAssertTrue(statisticsCell.waitForExistence(timeout: .medium))
		statisticsCell.swipeRight()

		// Management card(s) pt.1 - addition
		XCTAssertTrue(self.app.buttons[addButton].waitForExistence(timeout: .medium))
		XCTAssertTrue(statisticsCell.buttons[addButton].isHittable)
		XCTAssertFalse(statisticsCell.buttons[modifyButton].isHittable) // assuming empty statistics
		statisticsCell.buttons[addButton].waitAndTap()

		// Data selection
		XCTAssertTrue(app.tables[AccessibilityIdentifiers.LocalStatistics.selectState].waitForExistence(timeout: .short))
		// Tap on some data entry. Then we should be on select district screen.
		app.cells.element(boundBy: 1).waitAndTap()
		XCTAssertTrue(app.tables[AccessibilityIdentifiers.LocalStatistics.selectDistrict].waitForExistence(timeout: .short))
		// Tap on some data entry. Then we should be back on the homescreen.
		app.cells.element(boundBy: 14).waitAndTap()

		// the Local statistics card will appear.
		XCTAssertTrue(statisticsCell.waitForExistence(timeout: .short))
		app.swipeDown(velocity: .slow) // glitch
		let localStatisticCell = statisticsCell.staticTexts[localStatisticsViewTitle]
		XCTAssertTrue(localStatisticCell.waitForExistence(timeout: .short))
		
		let deleteButton = statisticsCell.buttons[AccessibilityIdentifiers.General.deleteButton].firstMatch
		XCTAssertFalse(deleteButton.isHittable)

		// Management card(s) pt.2 - removal
		statisticsCell.swipeRight() // because of ui reset
		XCTAssertTrue(statisticsCell.buttons[addButton].isHittable)
		XCTAssertTrue(statisticsCell.buttons[modifyButton].isHittable)
		statisticsCell.buttons[modifyButton].waitAndTap()
		
		app.buttons[modifyButton].swipeLeft()
		XCTAssertTrue(deleteButton.waitForExistence(timeout: .short))
		XCTAssertTrue(deleteButton.isHittable)
		deleteButton.waitAndTap()
		XCTAssertFalse(localStatisticCell.exists)
		XCTAssertFalse(statisticsCell.buttons[modifyButton].isHittable)
	}

	func test_StatisticsCardTitles() throws {
		// GIVEN
		let title1 = AccessibilityIdentifiers.Statistics.Incidence.title
		let title2 = AccessibilityIdentifiers.Statistics.Infections.title
		let title3 = AccessibilityIdentifiers.Statistics.KeySubmissions.title
		let title4 = AccessibilityIdentifiers.Statistics.ReproductionNumber.title
		let title5 = AccessibilityIdentifiers.Statistics.AtLeastOneVaccination.title
		let title6 = AccessibilityIdentifiers.Statistics.FullyVaccinated.title
		let title7 = AccessibilityIdentifiers.Statistics.Doses.title

		let layoutDirection = UIView.userInterfaceLayoutDirection(for: UIView().semanticContentAttribute)

		// WHEN
		app.setPreferredContentSizeCategory(accessibility: .normal, size: .S)
		app.launch()
		app.swipeUp(velocity: .slow)
		
		// THEN
		switch layoutDirection {
		case .rightToLeft:
			XCTAssertTrue(self.app.staticTexts[title7].waitForExistence(timeout: .medium))
			app.staticTexts[title7].swipeLeft()
			XCTAssertTrue(self.app.staticTexts[title6].waitForExistence(timeout: .medium))
			app.staticTexts[title6].swipeLeft()
			XCTAssertTrue(self.app.staticTexts[title5].waitForExistence(timeout: .medium))
			app.staticTexts[title5].swipeLeft()
			XCTAssertTrue(self.app.staticTexts[title4].waitForExistence(timeout: .medium))
			app.staticTexts[title4].swipeLeft()
			XCTAssertTrue(self.app.staticTexts[title3].waitForExistence(timeout: .medium))
			app.staticTexts[title3].swipeLeft()
			XCTAssertTrue(self.app.staticTexts[title2].waitForExistence(timeout: .medium))
			app.staticTexts[title2].swipeLeft()
			XCTAssertTrue(self.app.staticTexts[title1].waitForExistence(timeout: .medium))
			app.staticTexts[title1].swipeRight()
		default:
			XCTAssertTrue(self.app.staticTexts[title1].waitForExistence(timeout: .medium))
			app.staticTexts[title1].swipeLeft()
			XCTAssertTrue(self.app.staticTexts[title2].waitForExistence(timeout: .medium))
			app.staticTexts[title2].swipeLeft()
			XCTAssertTrue(self.app.staticTexts[title3].waitForExistence(timeout: .medium))
			app.staticTexts[title3].swipeLeft()
			XCTAssertTrue(self.app.staticTexts[title4].waitForExistence(timeout: .medium))
			app.staticTexts[title4].swipeLeft()
			XCTAssertTrue(self.app.staticTexts[title5].waitForExistence(timeout: .medium))
			app.staticTexts[title5].swipeLeft()
			XCTAssertTrue(self.app.staticTexts[title6].waitForExistence(timeout: .medium))
			app.staticTexts[title6].swipeLeft()
			XCTAssertTrue(self.app.staticTexts[title7].waitForExistence(timeout: .medium))
			app.staticTexts[title7].swipeRight()

		}
	}
	
	func test_StatisticsCardInfoButtons() throws {
		// GIVEN
		let title1 = AccessibilityIdentifiers.Statistics.Incidence.title
		let title2 = AccessibilityIdentifiers.Statistics.Infections.title
		let title3 = AccessibilityIdentifiers.Statistics.KeySubmissions.title
		let title4 = AccessibilityIdentifiers.Statistics.ReproductionNumber.title
		let layoutDirection = UIView.userInterfaceLayoutDirection(for: UIView().semanticContentAttribute)
		
		// WHEN
		app.setPreferredContentSizeCategory(accessibility: .normal, size: .S)
		app.launch()
		app.swipeUp(velocity: .slow)
		
		// THEN
		switch layoutDirection {
		case .rightToLeft:
			cardReproductionNumberInfoScreenTest(title4)
			app.staticTexts[title4].swipeLeft()

			cardIncidenceInfoScreenTest(title3)
			app.staticTexts[title3].swipeLeft()

			cardKeySubmissionsInfoScreenTest(title2)
			app.staticTexts[title2].swipeLeft()

			cardInfectionsInfoScreenTest(title1)
			app.staticTexts[title1].swipeRight()

		default:
			cardIncidenceInfoScreenTest(title1)
			app.staticTexts[title1].swipeLeft()
			
			cardInfectionsInfoScreenTest(title2)
			app.staticTexts[title2].swipeLeft()
			
			cardKeySubmissionsInfoScreenTest(title3)
			app.staticTexts[title3].swipeLeft()
			
			cardReproductionNumberInfoScreenTest(title4)
			app.staticTexts[title4].swipeRight()
		}
	}
	
	// MARK: - Screenshots
	
	func test_screenshot_local_statistics_card() throws {
		// GIVEN
		let incidenceTitle = AccessibilityIdentifiers.Statistics.Incidence.title
		let addStatisticsButtonTitle = AccessibilityIdentifiers.LocalStatistics.addLocalIncidencesButton
		let localStatisticsTitle = AccessibilityIdentifiers.LocalStatistics.localStatisticsCard

		// WHEN
		app.setPreferredContentSizeCategory(accessibility: .normal, size: .S)
		app.launch()
		app.swipeUp(velocity: .slow)


		XCTAssert(self.app.staticTexts[incidenceTitle].waitForExistence(timeout: .medium))
		app.staticTexts[incidenceTitle].swipeRight()
		
		XCTAssert(app.buttons[addStatisticsButtonTitle].waitForExistence(timeout: .medium))
		snapshot("statistics_add_local_statistics")
		app.buttons[addStatisticsButtonTitle].waitAndTap()

		XCTAssert(app.tables[AccessibilityIdentifiers.LocalStatistics.selectState].waitForExistence(timeout: .medium))
		
		/*
		CAUTION: the mocked Local statistics only return districts within BadenWürttemberg so for the state
		always choose BadenWürttemberg 'i.e (boundBy: 1)' then you can select the whole state or a specific district
		*/
		
		app.tables[AccessibilityIdentifiers.LocalStatistics.selectState].cells.element(boundBy: 1).waitAndTap()
			
		XCTAssert(app.tables[AccessibilityIdentifiers.LocalStatistics.selectDistrict].waitForExistence(timeout: .medium))
		app.tables[AccessibilityIdentifiers.LocalStatistics.selectDistrict].cells.element(boundBy: 2).waitAndTap()
		
		XCTAssertTrue(app.cells["AppStrings.Home.appInformationCardTitle"].waitForExistence(timeout: .medium))
		
		app.swipeDown(velocity: .slow)
		XCTAssert(self.app.staticTexts[localStatisticsTitle].waitForExistence(timeout: .medium))
		snapshot("statistics_local_7day_values")
	}

	func test_screenshot_statistics_card_titles() throws {
		// GIVEN
		let incidenceTitle = AccessibilityIdentifiers.Statistics.Incidence.title
		let infectionsTitle = AccessibilityIdentifiers.Statistics.Infections.title
		let keySubmissionsTitle = AccessibilityIdentifiers.Statistics.KeySubmissions.title
		let reproductionNumberTitle = AccessibilityIdentifiers.Statistics.ReproductionNumber.title
		let atLeastOneVaccinationTitle = AccessibilityIdentifiers.Statistics.AtLeastOneVaccination.title
		let fullyVaccinatedTitle = AccessibilityIdentifiers.Statistics.FullyVaccinated.title
		let dosesTitle = AccessibilityIdentifiers.Statistics.Doses.title
		
		let layoutDirection = UIView.userInterfaceLayoutDirection(for: UIView().semanticContentAttribute)
		var screenshotCounter = 0

		// WHEN
		app.setPreferredContentSizeCategory(accessibility: .normal, size: .S)
		app.launch()
		app.swipeUp(velocity: .slow)

		// THEN
		switch layoutDirection {
		case .rightToLeft:
			XCTAssert(self.app.staticTexts[reproductionNumberTitle].waitForExistence(timeout: .medium))
			app.staticTexts[reproductionNumberTitle].swipeLeft()
			XCTAssert(self.app.staticTexts[incidenceTitle].waitForExistence(timeout: .medium))
			app.staticTexts[incidenceTitle].swipeLeft()
			XCTAssert(self.app.staticTexts[keySubmissionsTitle].waitForExistence(timeout: .medium))
			app.staticTexts[keySubmissionsTitle].swipeLeft()
			cardKeySubmissionsInfoScreenTest(keySubmissionsTitle)
			XCTAssert(self.app.staticTexts[infectionsTitle].waitForExistence(timeout: .medium))
			cardInfectionsInfoScreenTest(infectionsTitle)
			app.staticTexts[infectionsTitle].swipeRight()
		default:
			XCTAssert(self.app.staticTexts[incidenceTitle].waitForExistence(timeout: .medium))
			snapshot("statistics_7day_incidences")
			app.staticTexts[incidenceTitle].swipeLeft()

			XCTAssert(self.app.staticTexts[infectionsTitle].waitForExistence(timeout: .medium))
			snapshot("statistics_confirmed_new_infections")
			app.staticTexts[infectionsTitle].swipeLeft()
			
			XCTAssert(self.app.staticTexts[keySubmissionsTitle].waitForExistence(timeout: .medium))
			snapshot("statistics_key_submissions")
			app.staticTexts[keySubmissionsTitle].swipeLeft()
			
			XCTAssert(self.app.staticTexts[reproductionNumberTitle].waitForExistence(timeout: .medium))
			snapshot("statistics_7Day_rvalue")
			app.staticTexts[reproductionNumberTitle].swipeLeft()
			
			XCTAssert(self.app.staticTexts[atLeastOneVaccinationTitle].waitForExistence(timeout: .medium))
			snapshot("statistics_at_least_one_vaccination")
			app.staticTexts[atLeastOneVaccinationTitle].swipeLeft()

			XCTAssert(self.app.staticTexts[fullyVaccinatedTitle].waitForExistence(timeout: .medium))
			snapshot("statistics_fully_vaccinated")
			app.staticTexts[fullyVaccinatedTitle].swipeLeft()

			XCTAssert(self.app.staticTexts[dosesTitle].waitForExistence(timeout: .medium))
			snapshot("statistics_doses")
			app.staticTexts[dosesTitle].swipeRight()
			
			cardFullyVaccinatedTitleOpenInfoScreen(fullyVaccinatedTitle)
			
			snapshot("statistics_info_screen_\(String(format: "%04d", (screenshotCounter.inc() )))")
			app.swipeUp(velocity: .slow)
			snapshot("statistics_info_screen_\(String(format: "%04d", (screenshotCounter.inc() )))")
		}
	}

	// MARK: - Private
	
	private func cardInfectionsInfoScreenTest(_ title1: String) {
		XCTAssertTrue(app.staticTexts[title1].waitForExistence(timeout: .medium))
		app.buttons[AccessibilityIdentifiers.Statistics.Infections.infoButton].waitAndTap()
		app.buttons["AppStrings.AccessibilityLabel.close"].waitAndTap()
	}
	
	private func cardKeySubmissionsInfoScreenTest(_ title2: String) {
		XCTAssertTrue(app.staticTexts[title2].waitForExistence(timeout: .medium))
		app.buttons[AccessibilityIdentifiers.Statistics.KeySubmissions.infoButton].waitAndTap()
		app.buttons["AppStrings.AccessibilityLabel.close"].waitAndTap()
	}
	
	private func cardIncidenceInfoScreenTest(_ title3: String) {
		XCTAssertTrue(app.staticTexts[title3].waitForExistence(timeout: .medium))
		app.buttons[AccessibilityIdentifiers.Statistics.Incidence.infoButton].waitAndTap()
		app.buttons["AppStrings.AccessibilityLabel.close"].waitAndTap()
	}
	
	private func cardReproductionNumberInfoScreenTest(_ title4: String) {
		XCTAssertTrue(app.staticTexts[title4].waitForExistence(timeout: .medium))
		app.buttons[AccessibilityIdentifiers.Statistics.ReproductionNumber.infoButton].waitAndTap()
		app.buttons["AppStrings.AccessibilityLabel.close"].waitAndTap()
	}
	
	private func cardReproductionNumberOpenInfoScreen(_ title4: String) {
		XCTAssert(app.staticTexts[title4].waitForExistence(timeout: .medium))
		app.buttons[AccessibilityIdentifiers.Statistics.ReproductionNumber.infoButton].waitAndTap()
	}
	
	private func cardFullyVaccinatedTitleOpenInfoScreen(_ title: String) {
		XCTAssert(app.staticTexts[title].waitForExistence(timeout: .medium))
		app.buttons[AccessibilityIdentifiers.Statistics.FullyVaccinated.infoButton].waitAndTap()
	}

}
