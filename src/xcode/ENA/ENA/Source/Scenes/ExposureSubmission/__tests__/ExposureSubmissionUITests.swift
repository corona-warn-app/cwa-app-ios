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

class ExposureSubmissionUITests: XCTestCase {

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
		XCTAssert(app.collectionViews.buttons["AppStrings.Home.submitCardButton"].waitForExistence(timeout: .long))
		app.collectionViews.buttons["AppStrings.Home.submitCardButton"].tap()

		// Check whether we have entered the info screen.
		XCTAssert(app.images["ExposureSubmissionIntroViewController.image"].waitForExistence(timeout: .medium))
	}

	func test_NavigateToHotlineVC() throws {
		launch()

		// Open Intro screen.
		XCTAssert(app.collectionViews.buttons["AppStrings.Home.submitCardButton"].waitForExistence(timeout: .long))
		app.collectionViews.buttons["AppStrings.Home.submitCardButton"].tap()
		XCTAssert(app.staticTexts["AppStrings.ExposureSubmissionIntroduction.subTitle"].waitForExistence(timeout: .medium))

		// Click next button.
		XCTAssertNotNil(app.buttons["AppStrings.ExposureSubmission.continueText"].waitForExistence(timeout: .medium))
		app.buttons["AppStrings.ExposureSubmission.continueText"].tap()

		// Select hotline button.
		XCTAssert(app
			.buttons["AppStrings.ExposureSubmissionDispatch.hotlineButtonDescription"]
			.waitForExistence(timeout: .medium)
		)
		app.buttons["AppStrings.ExposureSubmissionDispatch.hotlineButtonDescription"].tap()
		XCTAssertNotNil(app.navigationBars.firstMatch.title)
	}

	func test_DataPrivacyDisclaimerShownOnQRCodeScan() throws {
		launch()

		// Open Intro screen.
		XCTAssert(app.collectionViews.buttons["AppStrings.Home.submitCardButton"].waitForExistence(timeout: .long))
		app.collectionViews.buttons["AppStrings.Home.submitCardButton"].tap()
		XCTAssert(app.navigationBars["ExposureSubmissionNavigationController"].waitForExistence(timeout: .medium))

		// Click next button.
		XCTAssertNotNil(app.buttons["AppStrings.ExposureSubmission.continueText"].waitForExistence(timeout: .medium))
		app.buttons["AppStrings.ExposureSubmission.continueText"].tap()

		// Select QRCode screen.
		XCTAssert(app
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
		XCTAssert(app.collectionViews.buttons["AppStrings.Home.submitCardButton"].waitForExistence(timeout: .long))
		app.collectionViews.buttons["AppStrings.Home.submitCardButton"].tap()
		XCTAssert(app.navigationBars["ExposureSubmissionNavigationController"].waitForExistence(timeout: .medium))

		// Click next button.
		XCTAssertNotNil(app.buttons["AppStrings.ExposureSubmission.continueText"].waitForExistence(timeout: .medium))
		app.buttons["AppStrings.ExposureSubmission.continueText"].tap()

		// Select QRCode screen.
		XCTAssert(app.buttons["AppStrings.ExposureSubmissionDispatch.qrCodeButtonDescription"].waitForExistence(timeout: .medium))
		app.buttons["AppStrings.ExposureSubmissionDispatch.qrCodeButtonDescription"].tap()

		// Accept the alert.
		XCTAssertTrue(app.alerts.firstMatch.exists)
		app.alerts.buttons.firstMatch.tap()

	}

	func test_SubmitTAN() {
		// Setup service mocks.
		app.launchArguments += [UITestingParameters.ExposureSubmission.useMock.rawValue]
		app.launchArguments += [UITestingParameters.ExposureSubmission.getRegistrationTokenSuccess.rawValue]
		app.launchArguments += [UITestingParameters.ExposureSubmission.submitExposureSuccess.rawValue]
		launch()

		// Open Intro screen.
		XCTAssert(app.collectionViews.buttons["AppStrings.Home.submitCardButton"].waitForExistence(timeout: .long))
		app.collectionViews.buttons["AppStrings.Home.submitCardButton"].tap()

		// Click next button.
		XCTAssertNotNil(app.buttons["AppStrings.ExposureSubmission.continueText"].waitForExistence(timeout: .medium))
		app.buttons["AppStrings.ExposureSubmission.continueText"].tap()

		// Click TAN button.
		XCTAssert(app
			.buttons["AppStrings.ExposureSubmissionDispatch.tanButtonDescription"]
			.waitForExistence(timeout: .medium)
		)
		app.buttons["AppStrings.ExposureSubmissionDispatch.tanButtonDescription"].tap()

		// Fill in dummy TAN.
		XCTAssert(app.buttons["AppStrings.ExposureSubmission.continueText"].waitForExistence(timeout: .medium))
		type(app, text: "qwdzxcsrhe")

		// Click continue button.
		XCTAssert(app.buttons["AppStrings.ExposureSubmission.continueText"].isEnabled)
		app.buttons["AppStrings.ExposureSubmission.continueText"].tap()

		// TAN tests are ALWAYS positive!

		// Click next.
		XCTAssert(app.buttons["AppStrings.ExposureSubmission.continueText"].waitForExistence(timeout: .medium))
		app.buttons["AppStrings.ExposureSubmission.continueText"].tap()

		// Click next to warn others.
		XCTAssert(app.buttons["AppStrings.ExposureSubmission.continueText"].waitForExistence(timeout: .medium))
		app.buttons["AppStrings.ExposureSubmission.continueText"].tap()

		#if INTEROP
		XCTAssert(app.navigationBars["ENA.ExposureSubmissionWarnEuropeConsentView"].waitForExistence(timeout: .medium))
		#else
		XCTAssert(app.navigationBars["ENA.ExposureSubmissionSuccessView"].waitForExistence(timeout: .medium))
		app.buttons["AppStrings.ExposureSubmission.continueText"].tap()
		#endif
	}
	
	#if INTEROP
	func testEUSubmission_Consent() throws {
		// navigate to key submission
		fastForwardToKeySubmission()

		// Testing EU submission

		// ExposureSubmissionWarnEuropeConsentViewController
		let consentSwitch = app.switches["AppStrings.ExposureSubmissionWarnEuropeConsent.consentSwitch"]
		XCTAssertTrue(consentSwitch.waitForExistence(timeout: .medium))
		XCTAssertTrue(consentSwitch.isHittable)
		XCTAssertTrue(consentSwitch.isEnabled)
		XCTAssertFalse(consentSwitch.isSelected) //disabled by default
		consentSwitch.tap()

		XCTAssert(app.buttons["AppStrings.ExposureSubmission.continueText"].exists)
		app.buttons["AppStrings.ExposureSubmission.continueText"].tap()
	}

	func testEUSubmission_TravelConfirmation() throws {
		// navigate to key submission
		fastForwardToKeySubmission()
		let consentSwitch = app.switches["AppStrings.ExposureSubmissionWarnEuropeConsent.consentSwitch"]
		XCTAssertTrue(consentSwitch.waitForExistence(timeout: .medium))
		consentSwitch.tap()
		XCTAssert(app.buttons["AppStrings.ExposureSubmission.continueText"].exists)
		app.buttons["AppStrings.ExposureSubmission.continueText"].tap()

		// ExposureSubmissionWarnEuropeTravelConfirmationViewController

		let optionYes = app.buttons["AppStrings.ExposureSubmissionWarnEuropeTravelConfirmation.optionYes"]
		let optionNo = app.buttons["AppStrings.ExposureSubmissionWarnEuropeTravelConfirmation.optionNo"]
		let optionNone = app.buttons["AppStrings.ExposureSubmissionWarnEuropeTravelConfirmation.optionNone"]
		XCTAssertTrue(optionYes.waitForExistence(timeout: .medium))
		XCTAssertTrue(optionNo.exists)
		XCTAssertTrue(optionNone.exists)

		XCTAssertTrue(optionYes.isHittable)
		XCTAssertTrue(optionNo.isHittable)
		XCTAssertTrue(optionNone.isHittable)

		XCTAssertFalse(optionYes.isSelected)
		XCTAssertFalse(optionNo.isSelected)
		XCTAssertFalse(optionNone.isSelected)

		// continue is disabled?
		let btnContinue = app.buttons["AppStrings.ExposureSubmission.continueText"]
		XCTAssertTrue(btnContinue.exists)
		XCTAssertTrue(btnContinue.isHittable)
		XCTAssertFalse(btnContinue.isEnabled)

		// test radio buttons
		optionNo.tap()
		optionYes.tap()
		XCTAssertTrue(optionYes.isSelected)
		XCTAssertFalse(optionNo.isSelected)
		XCTAssertFalse(optionNone.isSelected)

		XCTAssertTrue(btnContinue.isEnabled)
		btnContinue.tap()
	}

	func testEUSubmission_CountrySelection() throws {
		fastForwardToWarnEuropeCountrySelection()

		// ExposureSubmissionWarnEuropeCountrySelectionViewController
		let selectCountriesGroup = app.buttons["AppStrings.ExposureSubmissionWarnEuropeTravelConfirmation.answerOptionOtherCountries"]
		let optionNoSelection = app.buttons["AppStrings.ExposureSubmissionWarnEuropeTravelConfirmation.answerOptionNone"]
		XCTAssertTrue(selectCountriesGroup.waitForExistence(timeout: .medium))
		XCTAssertTrue(optionNoSelection.exists)

		XCTAssertTrue(selectCountriesGroup.isHittable)
		XCTAssertTrue(optionNoSelection.isHittable)

		XCTAssertFalse(selectCountriesGroup.isSelected)
		XCTAssertFalse(optionNoSelection.isSelected)

		// continue is disabled?
		let btnContinue = app.buttons["AppStrings.ExposureSubmission.continueText"]
		XCTAssertTrue(btnContinue.exists)
		XCTAssertTrue(btnContinue.isHittable)
		XCTAssertFalse(btnContinue.isEnabled)

		optionNoSelection.tap()
		selectCountriesGroup.tap()
		XCTAssertTrue(selectCountriesGroup.isSelected)
		XCTAssertFalse(optionNoSelection.isSelected)

		XCTAssertTrue(btnContinue.isEnabled)
		btnContinue.tap()
	}
	#endif
}

// MARK: - Helpers.

extension ExposureSubmissionUITests {

	private func type(_ app: XCUIApplication, text: String) {
		text.forEach {
			app.keys[String($0)].tap()
		}
	}

	/// Launch and wait until the app is ready.
	private func launch() {
		app.launch()
		XCTAssert(app.buttons["AppStrings.Home.rightBarButtonDescription"].waitForExistence(timeout: .long))
	}

	/// Use this method to grab localized strings correctly.
	private func localized(_ string: String) -> String {
		if let path =
			Bundle(for: ExposureSubmissionUITests.self)
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

	#if INTEROP
	/// A simplified version of the `test_SubmitTAN` test to navigate to the following key submission screens
	private func fastForwardToKeySubmission() {
		// Setup service mocks.
		app.launchArguments += [UITestingParameters.ExposureSubmission.useMock.rawValue]
		app.launchArguments += [UITestingParameters.ExposureSubmission.getRegistrationTokenSuccess.rawValue]
		app.launchArguments += [UITestingParameters.ExposureSubmission.submitExposureSuccess.rawValue]
		launch()

		// fast forward to EU submission screens
		XCTAssert(app.collectionViews.buttons["AppStrings.Home.submitCardButton"].waitForExistence(timeout: .long))
		app.collectionViews.buttons["AppStrings.Home.submitCardButton"].tap()
		XCTAssertNotNil(app.buttons["AppStrings.ExposureSubmission.continueText"].waitForExistence(timeout: .medium))
		app.buttons["AppStrings.ExposureSubmission.continueText"].tap()
		//TAN button.
		XCTAssert(app
			.buttons["AppStrings.ExposureSubmissionDispatch.tanButtonDescription"]
			.waitForExistence(timeout: .medium)
		)
		app.buttons["AppStrings.ExposureSubmissionDispatch.tanButtonDescription"].tap()
		XCTAssert(app.buttons["AppStrings.ExposureSubmission.continueText"].waitForExistence(timeout: .medium))
		type(app, text: "qwdzxcsrhe")
		XCTAssert(app.buttons["AppStrings.ExposureSubmission.continueText"].isEnabled)
		app.buttons["AppStrings.ExposureSubmission.continueText"].tap()
		XCTAssert(app.buttons["AppStrings.ExposureSubmission.continueText"].waitForExistence(timeout: .medium))
		app.buttons["AppStrings.ExposureSubmission.continueText"].tap()
		XCTAssert(app.buttons["AppStrings.ExposureSubmission.continueText"].waitForExistence(timeout: .medium))
		app.buttons["AppStrings.ExposureSubmission.continueText"].tap()
	}

	private func fastForwardToWarnEuropeCountrySelection() {
		// navigate to key submission
		fastForwardToKeySubmission()
		let consentSwitch = app.switches["AppStrings.ExposureSubmissionWarnEuropeConsent.consentSwitch"]
		XCTAssertTrue(consentSwitch.waitForExistence(timeout: .medium))
		consentSwitch.tap()
		XCTAssert(app.buttons["AppStrings.ExposureSubmission.continueText"].exists)
		app.buttons["AppStrings.ExposureSubmission.continueText"].tap()

		let optionYes = app.buttons["AppStrings.ExposureSubmissionWarnEuropeTravelConfirmation.optionYes"]
		XCTAssertTrue(optionYes.waitForExistence(timeout: .medium))
		optionYes.tap()
		app.buttons["AppStrings.ExposureSubmission.continueText"].tap()
	}
	#endif
}

private extension TimeInterval {
	static let short = 1.0
	static let medium = 3.0
	static let long = 5.0
}
