//
// Corona-Warn-App
//
// SAP SE and all other contributors
// copyright owners license this file to you under the Apache
// License, Version 2.0 (the "License"); you may not use this
// file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing,
// software distributed under the License is distributed on an
// "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
// KIND, either express or implied.  See the License for the
// specific language governing permissions and limitations
// under the License.
//

import Foundation
import XCTest

	class ENAUITests_04_ExposureSubmissionUITests: XCTestCase {

	// MARK: - Attributes.
	
	var app: XCUIApplication!

	// MARK: - Setup.

	override func setUpWithError() throws {
		continueAfterFailure = false
		app = XCUIApplication()
		setupSnapshot(app)
		app.setDefaults()
		app.launchArguments.append(contentsOf: ["-isOnboarded", "YES"])
	}

	// MARK: - Test cases.

	func test_NavigateToIntroVC() throws {
		launch()

		// Click submit card.
		XCTAssertTrue(app.collectionViews.buttons["AppStrings.Home.submitCardButton"].waitForExistence(timeout: .long))
		app.collectionViews.buttons["AppStrings.Home.submitCardButton"].tap()

		// Check whether we have entered the info screen.
		XCTAssertTrue(app.images["ExposureSubmissionIntroViewController.image"].waitForExistence(timeout: .medium))
	}

	func test_NavigateToHotlineVC() throws {
		launch()

		// Open Intro screen.
		XCTAssertTrue(app.collectionViews.buttons["AppStrings.Home.submitCardButton"].waitForExistence(timeout: .long))
		app.collectionViews.buttons["AppStrings.Home.submitCardButton"].tap()
		XCTAssertTrue(app.staticTexts["AppStrings.ExposureSubmissionIntroduction.subTitle"].waitForExistence(timeout: .medium))

		// Click next button.
		XCTAssertNotNil(app.buttons["AppStrings.ExposureSubmission.continueText"].waitForExistence(timeout: .medium))
		app.buttons["AppStrings.ExposureSubmission.continueText"].tap()

		// Select hotline button.
		XCTAssertTrue(app
			.buttons["AppStrings.ExposureSubmissionDispatch.hotlineButtonDescription"]
			.waitForExistence(timeout: .medium)
		)
		app.buttons["AppStrings.ExposureSubmissionDispatch.hotlineButtonDescription"].tap()
		XCTAssertNotNil(app.navigationBars.firstMatch.title)
	}

	func test_DataPrivacyDisclaimerShownOnQRCodeScan() throws {
		launch()

		// Open Intro screen.
		XCTAssertTrue(app.collectionViews.buttons["AppStrings.Home.submitCardButton"].waitForExistence(timeout: .long))
		app.collectionViews.buttons["AppStrings.Home.submitCardButton"].tap()
		XCTAssertTrue(app.navigationBars["ExposureSubmissionNavigationController"].waitForExistence(timeout: .medium))

		// Click next button.
		XCTAssertNotNil(app.buttons["AppStrings.ExposureSubmission.continueText"].waitForExistence(timeout: .medium))
		app.buttons["AppStrings.ExposureSubmission.continueText"].tap()

		// Select QRCode screen.
		XCTAssertTrue(app
			.buttons["AppStrings.ExposureSubmissionDispatch.qrCodeButtonDescription"]
			.waitForExistence(timeout: .medium)
		)
		app.buttons["AppStrings.ExposureSubmissionDispatch.qrCodeButtonDescription"].tap()

		// Test that data privacy alert is shown.
		XCTAssertTrue(app.alerts.firstMatch.exists)
	}

	func test_QRCodeScanOpened() throws {
		launch()

		// Open Intro screen.
		XCTAssertTrue(app.collectionViews.buttons["AppStrings.Home.submitCardButton"].waitForExistence(timeout: .long))
		app.collectionViews.buttons["AppStrings.Home.submitCardButton"].tap()
		XCTAssertTrue(app.navigationBars["ExposureSubmissionNavigationController"].waitForExistence(timeout: .medium))

		// Click next button.
		XCTAssertNotNil(app.buttons["AppStrings.ExposureSubmission.continueText"].waitForExistence(timeout: .medium))
		app.buttons["AppStrings.ExposureSubmission.continueText"].tap()

		// Select QRCode screen.
		XCTAssertTrue(app.buttons["AppStrings.ExposureSubmissionDispatch.qrCodeButtonDescription"].waitForExistence(timeout: .medium))
		app.buttons["AppStrings.ExposureSubmissionDispatch.qrCodeButtonDescription"].tap()

		// Accept the alert.
		XCTAssertTrue(app.alerts.firstMatch.exists)
		app.alerts.buttons.firstMatch.tap()
	}

	func test_SubmitTAN_SymptomsOptionNo() {
		navigateToSymptomsScreen()

		let optionYes = app.buttons["AppStrings.ExposureSubmissionSymptoms.answerOptionYes"]
		let optionNo = app.buttons["AppStrings.ExposureSubmissionSymptoms.answerOptionNo"]
		let optionPreferNotToSay = app.buttons["AppStrings.ExposureSubmissionSymptoms.answerOptionPreferNotToSay"]

		XCTAssertTrue(optionYes.waitForExistence(timeout: .medium))
		XCTAssertTrue(optionNo.exists)
		XCTAssertTrue(optionPreferNotToSay.exists)

		XCTAssertFalse(optionYes.isSelected)
		XCTAssertFalse(optionNo.isSelected)
		XCTAssertFalse(optionPreferNotToSay.isSelected)

		// continue is disabled?
		let btnContinue = app.buttons["AppStrings.ExposureSubmission.continueText"]
		XCTAssertTrue(btnContinue.exists)
		XCTAssertTrue(btnContinue.isHittable)
		XCTAssertFalse(btnContinue.isEnabled)

		// test radio buttons
		optionNo.tap()
		XCTAssertFalse(optionYes.isSelected)
		XCTAssertTrue(optionNo.isSelected)
		XCTAssertFalse(optionPreferNotToSay.isSelected)

		XCTAssertTrue(btnContinue.isEnabled)
		btnContinue.tap()

		XCTAssertTrue(app.navigationBars["ENA.ExposureSubmissionWarnOthersView"].waitForExistence(timeout: .medium))
		app.buttons["AppStrings.ExposureSubmission.continueText"].tap()

		XCTAssertTrue(app.navigationBars["ENA.ExposureSubmissionSuccessView"].waitForExistence(timeout: .medium))
		app.buttons["AppStrings.ExposureSubmission.continueText"].tap()
	}

	func test_SubmitTAN_SymptomsOptionPreferNotToSay() {
		navigateToSymptomsScreen()

		let optionYes = app.buttons["AppStrings.ExposureSubmissionSymptoms.answerOptionYes"]
		let optionNo = app.buttons["AppStrings.ExposureSubmissionSymptoms.answerOptionNo"]
		let optionPreferNotToSay = app.buttons["AppStrings.ExposureSubmissionSymptoms.answerOptionPreferNotToSay"]

		XCTAssertTrue(optionYes.waitForExistence(timeout: .medium))
		XCTAssertTrue(optionNo.exists)
		XCTAssertTrue(optionPreferNotToSay.exists)

		XCTAssertFalse(optionYes.isSelected)
		XCTAssertFalse(optionNo.isSelected)
		XCTAssertFalse(optionPreferNotToSay.isSelected)

		// continue is disabled?
		let btnContinue = app.buttons["AppStrings.ExposureSubmission.continueText"]
		XCTAssertTrue(btnContinue.exists)
		XCTAssertTrue(btnContinue.isHittable)
		XCTAssertFalse(btnContinue.isEnabled)

		// test radio buttons
		optionPreferNotToSay.tap()
		XCTAssertFalse(optionYes.isSelected)
		XCTAssertFalse(optionNo.isSelected)
		XCTAssertTrue(optionPreferNotToSay.isSelected)

		XCTAssertTrue(btnContinue.isEnabled)
		btnContinue.tap()

		XCTAssertTrue(app.navigationBars["ENA.ExposureSubmissionWarnOthersView"].waitForExistence(timeout: .medium))
		app.buttons["AppStrings.ExposureSubmission.continueText"].tap()

		XCTAssertTrue(app.navigationBars["ENA.ExposureSubmissionSuccessView"].waitForExistence(timeout: .medium))
		app.buttons["AppStrings.ExposureSubmission.continueText"].tap()
	}

	func test_SubmitTAN_SymptomsOnsetDateOption() {
		navigateToSymptomsOnsetScreen()

		let optionExactDate = app.buttons["AppStrings.DatePickerOption.day"].firstMatch
		let optionLastSevenDays = app.buttons["AppStrings.ExposureSubmissionSymptomsOnset.answerOptionLastSevenDays"]
		let optionOneToTwoWeeksAgo = app.buttons["AppStrings.ExposureSubmissionSymptomsOnset.answerOptionOneToTwoWeeksAgo"]
		let optionMoreThanTwoWeeksAgo = app.buttons["AppStrings.ExposureSubmissionSymptomsOnset.answerOptionMoreThanTwoWeeksAgo"]
		let optionPreferNotToSay = app.buttons["AppStrings.ExposureSubmissionSymptomsOnset.answerOptionPreferNotToSay"]

		XCTAssertTrue(optionExactDate.waitForExistence(timeout: .medium))
		XCTAssertTrue(optionLastSevenDays.exists)
		XCTAssertTrue(optionOneToTwoWeeksAgo.exists)
		XCTAssertTrue(optionMoreThanTwoWeeksAgo.exists)
		XCTAssertTrue(optionPreferNotToSay.exists)

		XCTAssertFalse(optionExactDate.isSelected)
		XCTAssertFalse(optionLastSevenDays.isSelected)
		XCTAssertFalse(optionOneToTwoWeeksAgo.isSelected)
		XCTAssertFalse(optionMoreThanTwoWeeksAgo.isSelected)
		XCTAssertFalse(optionPreferNotToSay.isSelected)

		// continue is disabled?
		let btnContinue = app.buttons["AppStrings.ExposureSubmission.continueText"]
		XCTAssertTrue(btnContinue.exists)
		XCTAssertTrue(btnContinue.isHittable)
		XCTAssertFalse(btnContinue.isEnabled)

		// test radio buttons
		optionExactDate.tap()
		XCTAssertTrue(optionExactDate.isSelected)
		XCTAssertFalse(optionLastSevenDays.isSelected)
		XCTAssertFalse(optionOneToTwoWeeksAgo.isSelected)
		XCTAssertFalse(optionMoreThanTwoWeeksAgo.isSelected)
		XCTAssertFalse(optionPreferNotToSay.isSelected)

		XCTAssertTrue(btnContinue.isEnabled)

		optionLastSevenDays.tap()
		XCTAssertFalse(optionExactDate.isSelected)
		XCTAssertTrue(optionLastSevenDays.isSelected)
		XCTAssertFalse(optionOneToTwoWeeksAgo.isSelected)
		XCTAssertFalse(optionMoreThanTwoWeeksAgo.isSelected)
		XCTAssertFalse(optionPreferNotToSay.isSelected)

		XCTAssertTrue(btnContinue.isEnabled)

		app.swipeUp()

		optionOneToTwoWeeksAgo.tap()
		XCTAssertFalse(optionExactDate.isSelected)
		XCTAssertFalse(optionLastSevenDays.isSelected)
		XCTAssertTrue(optionOneToTwoWeeksAgo.isSelected)
		XCTAssertFalse(optionMoreThanTwoWeeksAgo.isSelected)
		XCTAssertFalse(optionPreferNotToSay.isSelected)

		XCTAssertTrue(btnContinue.isEnabled)

		optionMoreThanTwoWeeksAgo.tap()
		XCTAssertFalse(optionExactDate.isSelected)
		XCTAssertFalse(optionLastSevenDays.isSelected)
		XCTAssertFalse(optionOneToTwoWeeksAgo.isSelected)
		XCTAssertTrue(optionMoreThanTwoWeeksAgo.isSelected)
		XCTAssertFalse(optionPreferNotToSay.isSelected)

		XCTAssertTrue(btnContinue.isEnabled)

		optionPreferNotToSay.tap()
		XCTAssertFalse(optionExactDate.isSelected)
		XCTAssertFalse(optionLastSevenDays.isSelected)
		XCTAssertFalse(optionOneToTwoWeeksAgo.isSelected)
		XCTAssertFalse(optionMoreThanTwoWeeksAgo.isSelected)
		XCTAssertTrue(optionPreferNotToSay.isSelected)

		XCTAssertTrue(btnContinue.isEnabled)
		btnContinue.tap()

		XCTAssertTrue(app.navigationBars["ENA.ExposureSubmissionWarnOthersView"].waitForExistence(timeout: .medium))
		app.buttons["AppStrings.ExposureSubmission.continueText"].tap()

		XCTAssertTrue(app.navigationBars["ENA.ExposureSubmissionSuccessView"].waitForExistence(timeout: .medium))
		app.buttons["AppStrings.ExposureSubmission.continueText"].tap()
	}

}

// MARK: - Helpers.

extension ENAUITests_04_ExposureSubmissionUITests {

	private func type(_ app: XCUIApplication, text: String) {
		text.forEach {
			app.keys[String($0)].tap()
		}
	}

	/// Launch and wait until the app is ready.
	private func launch() {
		app.launch()
		XCTAssertTrue(app.buttons["AppStrings.Home.rightBarButtonDescription"].waitForExistence(timeout: .long))
	}

	/// Use this method to grab localized strings correctly.
	private func localized(_ string: String) -> String {
		if let path =
			Bundle(for: ENAUITests_04_ExposureSubmissionUITests.self)
				.path(
					forResource: deviceLanguage,
					ofType: "lproj"
			),
			let bundle = Bundle(path: path) {
			return NSLocalizedString(
				string,
				bundle: bundle,
				comment: ""
			)
		}
		fatalError("Localization could not be loaded.")
	}

	func navigateToSymptomsScreen() {
		// Setup service mocks.
		app.launchArguments += [UITestingParameters.ExposureSubmission.useMock.rawValue]
		app.launchArguments += [UITestingParameters.ExposureSubmission.getRegistrationTokenSuccess.rawValue]
		app.launchArguments += [UITestingParameters.ExposureSubmission.submitExposureSuccess.rawValue]
		launch()

		// Open Intro screen.
		XCTAssertTrue(app.collectionViews.buttons["AppStrings.Home.submitCardButton"].waitForExistence(timeout: .long))
		app.collectionViews.buttons["AppStrings.Home.submitCardButton"].tap()

		// Click next button.
		XCTAssertNotNil(app.buttons["AppStrings.ExposureSubmission.continueText"].waitForExistence(timeout: .medium))
		app.buttons["AppStrings.ExposureSubmission.continueText"].tap()

		// Click TAN button.
		XCTAssertTrue(app
			.buttons["AppStrings.ExposureSubmissionDispatch.tanButtonDescription"]
			.waitForExistence(timeout: .medium)
		)
		app.buttons["AppStrings.ExposureSubmissionDispatch.tanButtonDescription"].tap()

		// Fill in dummy TAN.
		XCTAssertTrue(app.buttons["AppStrings.ExposureSubmission.continueText"].waitForExistence(timeout: .medium))
		type(app, text: "qwdzxcsrhe")

		// Click continue button.
		XCTAssertTrue(app.buttons["AppStrings.ExposureSubmission.continueText"].isEnabled)
		app.buttons["AppStrings.ExposureSubmission.continueText"].tap()

		// TAN tests are ALWAYS positive!

		// Click next.
		XCTAssertTrue(app.buttons["AppStrings.ExposureSubmission.continueText"].waitForExistence(timeout: .medium))
		app.buttons["AppStrings.ExposureSubmission.continueText"].tap()

		// Click next to warn others.
		XCTAssertTrue(app.buttons["AppStrings.ExposureSubmission.continueText"].waitForExistence(timeout: .medium))
		app.buttons["AppStrings.ExposureSubmission.continueText"].tap()
	}

	func navigateToSymptomsOnsetScreen() {
		navigateToSymptomsScreen()

		let optionYes = app.buttons["AppStrings.ExposureSubmissionSymptoms.answerOptionYes"]

		XCTAssertTrue(optionYes.waitForExistence(timeout: .medium))
		optionYes.tap()

		app.buttons["AppStrings.ExposureSubmission.continueText"].tap()
	}

}

private extension TimeInterval {
	static let short = 1.0
	static let medium = 3.0
	static let long = 5.0
}
