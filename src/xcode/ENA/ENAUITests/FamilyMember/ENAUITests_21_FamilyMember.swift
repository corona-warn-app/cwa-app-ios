//
// 🦠 Corona-Warn-App
//

import XCTest
import ExposureNotification

class ENAUITests_21_FamilyMember: CWATestCase {

	var app: XCUIApplication!

	override func setUpWithError() throws {
		try super.setUpWithError()
		continueAfterFailure = false
		app = XCUIApplication()
		setupSnapshot(app)
		app.setDefaults()
		app.setLaunchArgument(LaunchArguments.onboarding.isOnboarded, to: true)
		app.setLaunchArgument(LaunchArguments.onboarding.setCurrentOnboardingVersion, to: true)
	}

	func test_screenshot_RegisterCoronaTestFromUniversalQRCodeScanner() throws {
		// launch argument will make
		app.setLaunchArgument(LaunchArguments.familyMemberTest.pcr.testResult, to: TestResult.serverResponseAsString(for: TestResult.positive, on: .pcr))
		app.setLaunchArgument(LaunchArguments.familyMemberTest.pcr.positiveTestResultWasShown, to: true)

		app.launch()
		app.swipeUp()

		// check if family members test news label is invisible
		XCTAssertFalse(app.staticTexts[AccessibilityIdentifiers.FamilyMemberCoronaTestCell.homeCellDetailText].waitForExistence(timeout: .short))
		app.buttons[AccessibilityIdentifiers.TabBar.scanner].waitAndTap()

		try registerFamilyMemberPCRTest()
	}

	func test_RegisterCoronaTestFromSubmitCardButton() throws {
		// launch argument will make
		app.setLaunchArgument(LaunchArguments.familyMemberTest.pcr.testResult, to: TestResult.serverResponseAsString(for: TestResult.positive, on: .pcr))
		app.setLaunchArgument(LaunchArguments.familyMemberTest.pcr.positiveTestResultWasShown, to: true)

		app.launch()
		app.swipeUp()

		// check if family members test news label is invisible
		XCTAssertFalse(app.staticTexts[AccessibilityIdentifiers.FamilyMemberCoronaTestCell.homeCellDetailText].waitForExistence(timeout: .short))

		// open register test
		app.cells.buttons[AccessibilityIdentifiers.Home.submitCardButton].waitAndTap()

		// select QRCode screen.
		app.buttons["AppStrings.ExposureSubmissionDispatch.qrCodeButtonDescription"].waitAndTap()

		try registerFamilyMemberPCRTest()
	}

	private func registerFamilyMemberPCRTest() throws {
		/// Simulator only Alert will open where you can choose what the QRScanner should scan
		let pcrButton = try XCTUnwrap(app.buttons[AccessibilityIdentifiers.UniversalQRScanner.fakePCR])
		pcrButton.waitAndTap()

		/// Select family member as test owner
		let familyButton = try XCTUnwrap(app.cells[AccessibilityIdentifiers.ExposureSubmission.TestOwnerSelection.familyMemberButton])

		snapshot("screenshot_family_member_tests_selection")

		familyButton.waitAndTap()

		/// Exposure submission family member consent screen
		XCTAssertTrue(app.images[AccessibilityIdentifiers.HealthCertificate.FamilyMemberConsent.imageDescription].waitForExistence(timeout: .short))
		XCTAssertTrue(app.cells[AccessibilityIdentifiers.HealthCertificate.FamilyMemberConsent.Legal.acknowledgementTitle].waitForExistence(timeout: .short))

		/// primary button
		let primaryButton = try XCTUnwrap(app.buttons[AccessibilityIdentifiers.HealthCertificate.FamilyMemberConsent.primaryButton])
		XCTAssertFalse(primaryButton.isEnabled)

		/// Exposure submission family member consent screen
		let textField = try XCTUnwrap(app.textFields[AccessibilityIdentifiers.HealthCertificate.FamilyMemberConsent.textInput])
		textField.waitAndTap(.short)
		textField.typeText("Lara")

		app.buttons["Done"].waitAndTap()
		app.swipeDown()

		snapshot("screenshot_family_member_tests_consent_1")

		app.swipeUp()

		snapshot("screenshot_family_member_tests_consent_2")

		/// data privacy screen
		app.cells[AccessibilityIdentifiers.HealthCertificate.FamilyMemberConsent.dataPrivacyTitle].waitAndTap()
		XCTAssertTrue(app.staticTexts["AppStrings.AppInformation.privacyTitle"].waitForExistence(timeout: .short))

		/// back navigation
		app.navigationBars.firstMatch.buttons.element(boundBy: 0).waitAndTap()

		/// primary button enabled after name was given
		XCTAssertTrue(primaryButton.isEnabled)
		primaryButton.waitAndTap(.short)

		/// test certificate consent screen
		XCTAssertTrue(app.images[AccessibilityIdentifiers.ExposureSubmission.TestCertificate.Info.imageDescription].waitForExistence(timeout: .short))
		app.buttons[AccessibilityIdentifiers.General.secondaryFooterButton].waitAndTap()

		/// test certificate screen
		app.buttons[AccessibilityIdentifiers.AccessibilityLabel.close].waitAndTap()

		/// home screen reached
		XCTAssertTrue(app.cells[AccessibilityIdentifiers.FamilyMemberCoronaTestCell.homeCell].exists)
		app.swipeUp()

		// check if family members test news label is now visible
		XCTAssertTrue(app.staticTexts[AccessibilityIdentifiers.FamilyMemberCoronaTestCell.homeCellDetailText].waitForExistence(timeout: .short))
	}

	func test_familyMemberViewOverview() throws {
		// launch argument will make
		app.setLaunchArgument(LaunchArguments.familyMemberTest.antigen.testResult, to: TestResult.serverResponseAsString(for: TestResult.negative, on: .antigen))
		app.setLaunchArgument(LaunchArguments.familyMemberTest.antigen.positiveTestResultWasShown, to: true)
		app.setLaunchArgument(LaunchArguments.familyMemberTest.pcr.testResult, to: TestResult.serverResponseAsString(for: TestResult.negative, on: .pcr))
		app.setLaunchArgument(LaunchArguments.familyMemberTest.pcr.positiveTestResultWasShown, to: true)

		app.launch()
		app.swipeUp()

		// select familyMember test cell
		app.cells[AccessibilityIdentifiers.FamilyMemberCoronaTestCell.homeCell].waitAndTap(.short)

		// check if family members overview is shown
		XCTAssertTrue(app.navigationBars[app.localized(AppStrings.FamilyMemberCoronaTest.title)].waitForExistence(timeout: .short))

		// check if family members test news label is invisible
		XCTAssertFalse(app.staticTexts[AccessibilityIdentifiers.FamilyMemberCoronaTestCell.homeCellDetailText].waitForExistence(timeout: .short))

		// lookup for both tests cells
		XCTAssertEqual(app.cells.matching(identifier: AccessibilityIdentifiers.FamilyMemberCoronaTestCell.Overview.testCell).count, 2)

		// tap on second cell
		app.cells.matching(identifier: AccessibilityIdentifiers.FamilyMemberCoronaTestCell.Overview.testCell).lastMatch.waitAndTap()

		// check for negative test of Anni
		XCTAssertTrue(app.navigationBars["Anni"].waitForExistence(timeout: .short))
		// Text only in valid test
		XCTAssertTrue(app.staticTexts[AccessibilityIdentifiers.ExposureSubmissionResult.Antigen.proofDesc].waitForExistence(timeout: .short))
		// Now delete Anni's Test
		app.buttons[AccessibilityIdentifiers.ExposureSubmission.primaryButton].waitAndTap()
		// Confirm delete in alert
		app.alerts.buttons[AccessibilityIdentifiers.ExposureSubmissionResult.RemoveAlert.deleteButton].waitAndTap()

		// lookup that only Pauls test is remaining
		XCTAssertEqual(app.cells.matching(identifier: AccessibilityIdentifiers.FamilyMemberCoronaTestCell.Overview.testCell).count, 1)

		// Swipe to delete for Pauls test
		app.cells[AccessibilityIdentifiers.FamilyMemberCoronaTestCell.Overview.testCell].swipeLeft()
		// Take first and only button, which is the system delete button
		app.cells[AccessibilityIdentifiers.FamilyMemberCoronaTestCell.Overview.testCell].buttons.firstMatch.waitAndTap()
		// Confirm delete in alert
		app.alerts.buttons[AccessibilityIdentifiers.ExposureSubmissionResult.RemoveAlert.deleteButton].waitAndTap()

		// check if family members test
		XCTAssertFalse(app.cells[AccessibilityIdentifiers.FamilyMemberCoronaTestCell.homeCell].waitForExistence(timeout: .short))
	}

	func test_screenshot_familyMemberViewOverviewDeleteAll() throws {
		// Show for screenshots RAT negative test on home screen with active ENF
		app.setLaunchArgument(LaunchArguments.common.ENStatus, to: ENStatus.active.stringValue)
		app.setLaunchArgument(LaunchArguments.test.antigen.testResult, to: TestResult.serverResponseAsString(for: TestResult.negative, on: .antigen))
		app.setLaunchArgument(LaunchArguments.test.antigen.positiveTestResultWasShown, to: false)
		// Show for screenshots a lot of tests in the family overview
		app.setLaunchArgument(LaunchArguments.familyMemberTest.fakeOverview, to: true)

		app.launch()
		snapshot("screenshot_family_member_tests_home_1")
		app.swipeUp()
		snapshot("screenshot_family_member_tests_home_2")
		// select familyMember test cell
		app.cells[AccessibilityIdentifiers.FamilyMemberCoronaTestCell.homeCell].waitAndTap(.short)

		// check if family members overview is shown
		XCTAssertTrue(app.navigationBars[app.localized(AppStrings.FamilyMemberCoronaTest.title)].waitForExistence(timeout: .short))

		// check if family members test news label is invisible
		XCTAssertFalse(app.staticTexts[AccessibilityIdentifiers.FamilyMemberCoronaTestCell.homeCellDetailText].waitForExistence(timeout: .short))

		// lookup for both tests cells
		XCTAssertEqual(app.cells.matching(identifier: AccessibilityIdentifiers.FamilyMemberCoronaTestCell.Overview.testCell).count, 4)

		snapshot("screenshot_family_member_tests_family_list_1")
		app.swipeUp()
		snapshot("screenshot_family_member_tests_family_list_2")

		// Tap on edit
		app.navigationBars.buttons.lastMatch.waitAndTap()

		// Tap on delete all
		app.buttons[AccessibilityIdentifiers.General.primaryFooterButton].waitAndTap()

		// Confirm delete in alert
		app.alerts.buttons[AccessibilityIdentifiers.ExposureSubmissionResult.RemoveAlert.deleteButton].waitAndTap()

		// check if family members test
		XCTAssertFalse(app.cells[AccessibilityIdentifiers.FamilyMemberCoronaTestCell.homeCell].waitForExistence(timeout: .short))
	}
}
