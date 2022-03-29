//
// 🦠 Corona-Warn-App
//

import XCTest
import ExposureNotification

// swiftlint:disable type_body_length
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
		app.setLaunchArgument(LaunchArguments.statistics.maximumRegionsSelected, to: true)
		let addButtonIdentifier = AccessibilityIdentifiers.LocalStatistics.addLocalIncidencesButton
		let localStatisticsViewTitle = AccessibilityIdentifiers.LocalStatistics.localStatisticsCardTitle
		
		app.setPreferredContentSizeCategory(accessibility: .normal, size: .S)
		app.launch()
		app.swipeUp(velocity: .slow)
		let statisticsCell = app.cells[AccessibilityIdentifiers.Statistics.General.tableViewCell]
		XCTAssertTrue(statisticsCell.waitForExistence(timeout: .medium))
		
		let localStatisticCell = statisticsCell.staticTexts[localStatisticsViewTitle]
		XCTAssertTrue(localStatisticCell.waitForExistence(timeout: .long))
		statisticsCell.swipeRight()

		// check for the text for the add button
		let addButton = app.buttons[addButtonIdentifier]
		let expectTitle = AccessibilityLabels.localized(AppStrings.Statistics.AddCard.disabledAddTitle)
		XCTAssertEqual(addButton.label, expectTitle, "label should show the disabled message")
		XCTAssertFalse(addButton.isEnabled, "button should be disabled after 5 cards")
	}
	
	func test_AddStatisticsButton_flow() {
		let addButtonIdentifier = AccessibilityIdentifiers.LocalStatistics.addLocalIncidencesButton
		let modifyButtonIdentifier = AccessibilityIdentifiers.LocalStatistics.modifyLocalIncidencesButton
		let localStatisticsCardIdentifier = AccessibilityIdentifiers.LocalStatistics.localStatisticsCard

		app.setPreferredContentSizeCategory(accessibility: .normal, size: .S)
		app.launch()
		
		// Wait and check for the navbar to make sure App is really launched, otherwise the swipe will do nothing
		let leftNavbarButton = app.images[AccessibilityIdentifiers.Home.leftBarButtonDescription]
		XCTAssertTrue(leftNavbarButton.waitForExistence(timeout: .medium))
		app.swipeUp(velocity: .slow)
		let statisticsCell = app.cells[AccessibilityIdentifiers.Statistics.General.tableViewCell]
		XCTAssertTrue(statisticsCell.waitForExistence(timeout: .medium))
		statisticsCell.swipeRight()

		// Management card(s) pt.1 - addition
		XCTAssertTrue(self.app.buttons[addButtonIdentifier].waitForExistence(timeout: .medium))
		XCTAssertTrue(statisticsCell.buttons[addButtonIdentifier].isHittable)
		XCTAssertFalse(statisticsCell.buttons[modifyButtonIdentifier].isHittable) // assuming empty statistics
		statisticsCell.buttons[addButtonIdentifier].waitAndTap()

		// Data selection
		XCTAssertTrue(app.tables[AccessibilityIdentifiers.LocalStatistics.selectState].waitForExistence(timeout: .long))
		// Tap on some data entry. Then we should be on select district screen.
		app.cells.element(boundBy: 1).waitAndTap()
		XCTAssertTrue(app.tables[AccessibilityIdentifiers.LocalStatistics.selectDistrict].waitForExistence(timeout: .long))
		// Tap on some data entry. Then we should be back on the homescreen.
		app.cells.element(boundBy: 14).waitAndTap()

		// the Local statistics card will appear.
		XCTAssertTrue(statisticsCell.waitForExistence(timeout: .long))
		app.swipeDown(velocity: .slow) // glitch
		let localStatisticCard = statisticsCell.otherElements[localStatisticsCardIdentifier]
		XCTAssertTrue(localStatisticCard.waitForExistence(timeout: .long))
		
		let deleteButtonNotHittable = statisticsCell.buttons[AccessibilityIdentifiers.General.deleteButton].firstMatch
		XCTAssertFalse(deleteButtonNotHittable.isHittable)
	}

	func test_RemoveStatisticsButton_flow() {
		let localStatisticsViewTitle = AccessibilityIdentifiers.LocalStatistics.localStatisticsCardTitle
		let addButtonIdentifier = AccessibilityIdentifiers.LocalStatistics.addLocalIncidencesButton
		let modifyButtonIdentifier = AccessibilityIdentifiers.LocalStatistics.modifyLocalIncidencesButton
		
		app.setLaunchArgument(LaunchArguments.statistics.maximumRegionsSelected, to: true)
		app.setPreferredContentSizeCategory(accessibility: .normal, size: .S)
		app.launch()
		app.swipeUp(velocity: .slow)
		let statisticsCell = app.cells[AccessibilityIdentifiers.Statistics.General.tableViewCell]
		XCTAssertTrue(statisticsCell.waitForExistence(timeout: .medium))
		
		let localStatisticCell = statisticsCell.staticTexts[localStatisticsViewTitle]
		XCTAssertTrue(localStatisticCell.waitForExistence(timeout: .long))
		statisticsCell.swipeRight()
		
		let addButton = app.buttons[addButtonIdentifier]
		XCTAssertTrue(addButton.waitForElementToBecomeHittable(timeout: .long))
		XCTAssertTrue(addButton.isHittable)
		XCTAssertTrue(statisticsCell.buttons[modifyButtonIdentifier].isHittable)
		statisticsCell.buttons[modifyButtonIdentifier].waitAndTap()
		
		let deleteButton = statisticsCell.buttons[AccessibilityIdentifiers.General.deleteButton].firstMatch
		XCTAssertTrue(deleteButton.waitForElementToBecomeHittable(timeout: .long))
		XCTAssertTrue(deleteButton.isHittable)
		deleteButton.waitAndTap()
		XCTAssertFalse(statisticsCell.buttons[modifyButtonIdentifier].isHittable)
	}

	func test_StatisticsCardTitles() throws {
		// flow for 2.13 and later versions
		// GIVEN
		let title1 = AccessibilityIdentifiers.Statistics.Combined7DayIncidence.title
		let title2 = AccessibilityIdentifiers.Statistics.IntensiveCare.title
		let title3 = AccessibilityIdentifiers.Statistics.Infections.title
		let title4 = AccessibilityIdentifiers.Statistics.KeySubmissions.title
		let title5 = AccessibilityIdentifiers.Statistics.ReproductionNumber.title
		let title6 = AccessibilityIdentifiers.Statistics.AtLeastOneVaccination.title
		let title7 = AccessibilityIdentifiers.Statistics.FullyVaccinated.title
		let title8 = AccessibilityIdentifiers.Statistics.BoosterVaccination.title
		let title9 = AccessibilityIdentifiers.Statistics.Doses.title

		let layoutDirection = UIView.userInterfaceLayoutDirection(for: UIView().semanticContentAttribute)

		// WHEN
		app.setPreferredContentSizeCategory(accessibility: .normal, size: .S)
		app.launch()
		app.swipeUp(velocity: .slow)

		// THEN
		switch layoutDirection {
		case .rightToLeft:
			XCTAssertTrue(self.app.staticTexts[title9].waitForExistence(timeout: .medium))
			app.staticTexts[title9].swipeLeft()
			XCTAssertTrue(self.app.staticTexts[title8].waitForExistence(timeout: .medium))
			app.staticTexts[title8].swipeLeft()
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
			app.swipeLeft()
			XCTAssertTrue(self.app.staticTexts[title1].waitForExistence(timeout: .extraLong))
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
			app.staticTexts[title7].swipeLeft()
			XCTAssertTrue(self.app.staticTexts[title8].waitForExistence(timeout: .medium))
			app.staticTexts[title8].swipeLeft()
			XCTAssertTrue(self.app.staticTexts[title9].waitForExistence(timeout: .medium))
			app.staticTexts[title9].swipeRight()
		}
	}
	
	func test_StatisticsCardInfoButtons() throws {
		// GIVEN
		let title1 = AccessibilityIdentifiers.Statistics.Combined7DayIncidence.title
		let title2 = AccessibilityIdentifiers.Statistics.IntensiveCare.title
		let title3 = AccessibilityIdentifiers.Statistics.Infections.title
		let title4 = AccessibilityIdentifiers.Statistics.KeySubmissions.title
		let title5 = AccessibilityIdentifiers.Statistics.ReproductionNumber.title
		let title6 = AccessibilityIdentifiers.Statistics.AtLeastOneVaccination.title
		let title7 = AccessibilityIdentifiers.Statistics.FullyVaccinated.title
		let title8 = AccessibilityIdentifiers.Statistics.BoosterVaccination.title
		let title9 = AccessibilityIdentifiers.Statistics.Doses.title

		let layoutDirection = UIView.userInterfaceLayoutDirection(for: UIView().semanticContentAttribute)
		
		// WHEN
		app.setPreferredContentSizeCategory(accessibility: .normal, size: .S)
		app.launch()
		app.swipeUp(velocity: .slow)
		
		// THEN
		switch layoutDirection {
		case .rightToLeft:
			cardDosesInfoScreenTest(title9)
			app.staticTexts[title8].swipeLeft()
		
			cardBoosterVaccinationInfoScreen(title8)
			app.staticTexts[title8].swipeLeft()
			
			cardFullyVaccinatedInfoScreenTest(title7)
			app.staticTexts[title7].swipeLeft()

			cardAtLeastOneVaccinationInfoScreenTest(title6)
			app.staticTexts[title6].swipeLeft()

			cardReproductionNumberInfoScreenTest(title5)
			app.staticTexts[title5].swipeLeft()

			cardKeySubmissionsInfoScreenTest(title4)
			app.staticTexts[title4].swipeLeft()
			
			cardInfectionsInfoScreenTest(title3)
			app.staticTexts[title3].swipeLeft()

			cardIntensiveCareInfoScreenTest(title2)
			app.staticTexts[title2].swipeLeft()

			cardCombinedIncidencesInfoScreenTest(title1)
			app.staticTexts[title1].swipeRight()
		default:
			app.swipeLeft()
			
			cardCombinedIncidencesInfoScreenTest(title1)
			app.staticTexts[title1].swipeLeft()
						
			cardIntensiveCareInfoScreenTest(title2)
			app.staticTexts[title2].swipeLeft()
			
			cardInfectionsInfoScreenTest(title3)
			app.staticTexts[title3].swipeLeft()
			
			cardKeySubmissionsInfoScreenTest(title4)
			app.staticTexts[title4].swipeLeft()
			
			cardReproductionNumberInfoScreenTest(title5)
			app.staticTexts[title5].swipeLeft()
			
			cardAtLeastOneVaccinationInfoScreenTest(title6)
			app.staticTexts[title6].swipeLeft()
			
			cardFullyVaccinatedInfoScreenTest(title7)
			app.staticTexts[title7].swipeLeft()
			
			cardBoosterVaccinationInfoScreen(title8)
			app.staticTexts[title8].swipeLeft()
			
			cardDosesInfoScreenTest(title9)
			app.staticTexts[title9].swipeRight()
		}
	}
	
	// MARK: - Screenshots
	
	func test_screenshot_local_statistics_card() throws {
		// GIVEN
		let addStatisticsButtonTitle = AccessibilityIdentifiers.LocalStatistics.addLocalIncidencesButton
		let localStatisticsTitle = AccessibilityIdentifiers.LocalStatistics.localStatisticsCardTitle

		// WHEN
		app.setPreferredContentSizeCategory(accessibility: .normal, size: .S)
		app.launch()
		app.swipeUp(velocity: .slow)
		
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
		
		let moreCell = app.cells[AccessibilityIdentifiers.Home.MoreInfoCell.moreCell]
		let appInformationLabel = moreCell.buttons[AccessibilityIdentifiers.Home.MoreInfoCell.appInformationLabel]
		XCTAssertTrue(appInformationLabel.waitForExistence(timeout: .medium))

		app.swipeDown(velocity: .slow)
		XCTAssert(self.app.staticTexts[localStatisticsTitle].waitForExistence(timeout: .medium))
		snapshot("statistics_local_7day_values")
	}

	func test_screenshot_statistics_card_titles() throws {
		// GIVEN
		let combinedIncidenceTitle = AccessibilityIdentifiers.Statistics.Combined7DayIncidence.title
		let intensiveCareTitle = AccessibilityIdentifiers.Statistics.IntensiveCare.title
		let infectionsTitle = AccessibilityIdentifiers.Statistics.Infections.title
		let keySubmissionsTitle = AccessibilityIdentifiers.Statistics.KeySubmissions.title
		let reproductionNumberTitle = AccessibilityIdentifiers.Statistics.ReproductionNumber.title
		let atLeastOneVaccinationTitle = AccessibilityIdentifiers.Statistics.AtLeastOneVaccination.title
		let fullyVaccinatedTitle = AccessibilityIdentifiers.Statistics.FullyVaccinated.title
		let boosterVaccinationTitle = AccessibilityIdentifiers.Statistics.BoosterVaccination.title
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
			XCTAssert(self.app.staticTexts[dosesTitle].waitForExistence(timeout: .medium))
			app.staticTexts[dosesTitle].swipeLeft()
			
			XCTAssert(self.app.staticTexts[boosterVaccinationTitle].waitForExistence(timeout: .medium))
			app.staticTexts[boosterVaccinationTitle].swipeLeft()

			XCTAssert(self.app.staticTexts[fullyVaccinatedTitle].waitForExistence(timeout: .medium))
			app.staticTexts[fullyVaccinatedTitle].swipeLeft()
			
			XCTAssert(self.app.staticTexts[atLeastOneVaccinationTitle].waitForExistence(timeout: .medium))
			app.staticTexts[atLeastOneVaccinationTitle].swipeLeft()
			
			XCTAssert(self.app.staticTexts[reproductionNumberTitle].waitForExistence(timeout: .medium))
			app.staticTexts[reproductionNumberTitle].swipeLeft()
			
			XCTAssert(self.app.staticTexts[keySubmissionsTitle].waitForExistence(timeout: .medium))
			app.staticTexts[keySubmissionsTitle].swipeLeft()
			
			XCTAssert(self.app.staticTexts[infectionsTitle].waitForExistence(timeout: .medium))
			app.staticTexts[infectionsTitle].swipeLeft()
			
			XCTAssert(self.app.staticTexts[intensiveCareTitle].waitForExistence(timeout: .medium))
			app.staticTexts[intensiveCareTitle].swipeLeft()
						
			XCTAssert(self.app.staticTexts[combinedIncidenceTitle].waitForExistence(timeout: .medium))
			app.staticTexts[combinedIncidenceTitle].swipeRight()
		default:
			app.swipeLeft()

			XCTAssert(self.app.staticTexts[combinedIncidenceTitle].waitForExistence(timeout: .medium))
			snapshot("statistics_7day_combined_incidences")
			app.staticTexts[combinedIncidenceTitle].swipeLeft()
			
			XCTAssert(self.app.staticTexts[intensiveCareTitle].waitForExistence(timeout: .medium))
			snapshot("statistics_intensive_care")
			app.staticTexts[intensiveCareTitle].swipeLeft()
			
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

			XCTAssert(self.app.staticTexts[boosterVaccinationTitle].waitForExistence(timeout: .medium))
			snapshot("statistics_booster_vaccination")
			app.staticTexts[boosterVaccinationTitle].swipeLeft()
			
			XCTAssert(self.app.staticTexts[dosesTitle].waitForExistence(timeout: .medium))
			snapshot("statistics_doses")
			app.staticTexts[dosesTitle].swipeRight()
			
			cardBoosterVaccinationOpenInfoScreen(boosterVaccinationTitle)
			
			snapshot("statistics_info_screen_\(String(format: "%04d", (screenshotCounter.inc() )))")
			app.swipeUp(velocity: .slow)
			snapshot("statistics_info_screen_\(String(format: "%04d", (screenshotCounter.inc() )))")
		}
	}

	// MARK: - Private
	
	private func cardCombinedIncidencesInfoScreenTest(_ title1: String) {
		XCTAssertTrue(app.staticTexts[title1].waitForExistence(timeout: .medium))
		app.buttons[AccessibilityIdentifiers.Statistics.Combined7DayIncidence.infoButton].waitAndTap()
		app.buttons["AppStrings.AccessibilityLabel.close"].waitAndTap()
	}

	private func cardIntensiveCareInfoScreenTest(_ title3: String) {
		XCTAssertTrue(app.staticTexts[title3].waitForExistence(timeout: .medium))
		app.buttons[AccessibilityIdentifiers.Statistics.IntensiveCare.infoButton].waitAndTap()
		app.buttons["AppStrings.AccessibilityLabel.close"].waitAndTap()
	}
	
	private func cardInfectionsInfoScreenTest(_ title4: String) {
		XCTAssertTrue(app.staticTexts[title4].waitForExistence(timeout: .medium))
		app.buttons[AccessibilityIdentifiers.Statistics.Infections.infoButton].waitAndTap()
		app.buttons["AppStrings.AccessibilityLabel.close"].waitAndTap()
	}
	
	private func cardKeySubmissionsInfoScreenTest(_ title5: String) {
		XCTAssertTrue(app.staticTexts[title5].waitForExistence(timeout: .medium))
		app.buttons[AccessibilityIdentifiers.Statistics.KeySubmissions.infoButton].waitAndTap()
		app.buttons["AppStrings.AccessibilityLabel.close"].waitAndTap()
	}
	
	private func cardReproductionNumberInfoScreenTest(_ title6: String) {
		XCTAssertTrue(app.staticTexts[title6].waitForExistence(timeout: .medium))
		app.buttons[AccessibilityIdentifiers.Statistics.ReproductionNumber.infoButton].waitAndTap()
		app.buttons["AppStrings.AccessibilityLabel.close"].waitAndTap()
	}
	
	private func cardAtLeastOneVaccinationInfoScreenTest(_ title7: String) {
		XCTAssertTrue(app.staticTexts[title7].waitForExistence(timeout: .medium))
		app.buttons[AccessibilityIdentifiers.Statistics.AtLeastOneVaccination.infoButton].waitAndTap()
		app.buttons["AppStrings.AccessibilityLabel.close"].waitAndTap()
	}
	
	private func cardFullyVaccinatedInfoScreenTest(_ title8: String) {
		XCTAssertTrue(app.staticTexts[title8].waitForExistence(timeout: .medium))
		app.buttons[AccessibilityIdentifiers.Statistics.FullyVaccinated.infoButton].waitAndTap()
		app.buttons["AppStrings.AccessibilityLabel.close"].waitAndTap()
	}
	
	private func cardDosesInfoScreenTest(_ title9: String) {
		XCTAssertTrue(app.staticTexts[title9].waitForExistence(timeout: .medium))
		app.buttons[AccessibilityIdentifiers.Statistics.Doses.infoButton].waitAndTap()
		app.buttons["AppStrings.AccessibilityLabel.close"].waitAndTap()
	}
	
	private func cardBoosterVaccinationInfoScreen(_ title9: String) {
		XCTAssert(app.staticTexts[title9].waitForExistence(timeout: .medium))
		app.buttons[AccessibilityIdentifiers.Statistics.BoosterVaccination.infoButton].waitAndTap()
		app.buttons["AppStrings.AccessibilityLabel.close"].waitAndTap()
	}

	private func cardBoosterVaccinationOpenInfoScreen(_ title: String) {
		XCTAssert(app.staticTexts[title].waitForExistence(timeout: .medium))
		app.buttons[AccessibilityIdentifiers.Statistics.BoosterVaccination.infoButton].waitAndTap()
	}
}
