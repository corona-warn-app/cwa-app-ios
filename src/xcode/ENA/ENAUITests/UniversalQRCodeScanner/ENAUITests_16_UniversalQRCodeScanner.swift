////
// 🦠 Corona-Warn-App
//

import XCTest

class ENAUITests_16_UniversalQRCodeScanner: CWATestCase {
	
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

	func test_screenshot_UniversalQRCodeScannerAndQRScannerInfoScreen() throws {
		app.launch()

		app.buttons[AccessibilityIdentifiers.TabBar.scanner].waitAndTap()

		/// Simulator only Alert will open where you can choose what the QRScanner should scan -> dismiss
		let certificateButton = try XCTUnwrap(app.buttons[AccessibilityIdentifiers.UniversalQRScanner.other])
		certificateButton.waitAndTap()

		/// QR scanner screen
		XCTAssertTrue(app.buttons[AccessibilityIdentifiers.UniversalQRScanner.flash].waitForExistence(timeout: .short))

		snapshot("universal_qr_code_scanner")

		/// Open info screen
		app.buttons[AccessibilityIdentifiers.UniversalQRScanner.info].waitAndTap()
		XCTAssertTrue(app.images[AccessibilityIdentifiers.UniversalQRScanner.Info.title].waitForExistence(timeout: .short))

		snapshot("universal_qr_code_scanner_info")

		// find data privacy cell (last cell) and tap it
		let dataPrivacyButton = try XCTUnwrap(app.cells[AccessibilityIdentifiers.UniversalQRScanner.Info.dataPrivacy])

		let maxTries = 10
		var currentTry = 0
		while dataPrivacyButton.isHittable == false && currentTry < maxTries {
			app.swipeUp()
			currentTry += 1
		}
		dataPrivacyButton.waitAndTap()

		XCTAssertTrue(app.staticTexts["AppStrings.AppInformation.privacyTitle"].waitForExistence(timeout: .short))
	}

	func test_RegisterCertificateFromUniversalQRCodeScannerWithInfoScreen() throws {
		app.setLaunchArgument(LaunchArguments.infoScreen.healthCertificateInfoScreenShown, to: false)
		app.launch()

		app.buttons[AccessibilityIdentifiers.TabBar.scanner].waitAndTap()

		/// Simulator only Alert will open where you can choose what the QRScanner should scan
		let certificateButton = try XCTUnwrap(app.buttons[AccessibilityIdentifiers.UniversalQRScanner.fakeHC1])
		certificateButton.waitAndTap()

		/// Certificate Info Screen
		XCTAssertTrue(app.staticTexts[AccessibilityLabels.localized(AppStrings.HealthCertificate.Info.title)].waitForExistence(timeout: .short))

		app.buttons[AccessibilityIdentifiers.General.primaryFooterButton].waitAndTap()

		/// Certificate Screen
		let headlineCell = try XCTUnwrap(app.cells[AccessibilityIdentifiers.HealthCertificate.Certificate.headline])
		XCTAssertTrue(headlineCell.waitForExistence(timeout: .short))
	}

	func test_RegisterCertificateFromUniversalQRCodeScannerWithoutInfoScreen() throws {
		app.setLaunchArgument(LaunchArguments.infoScreen.healthCertificateInfoScreenShown, to: true)
		app.launch()

		app.buttons[AccessibilityIdentifiers.TabBar.scanner].waitAndTap()

		/// Simulator only Alert will open where you can choose what the QRScanner should scan
		let certificateButton = try XCTUnwrap(app.buttons[AccessibilityIdentifiers.UniversalQRScanner.fakeHC1])
		certificateButton.waitAndTap()

		/// Certificate Screen
		let headlineCell = try XCTUnwrap(app.cells[AccessibilityIdentifiers.HealthCertificate.Certificate.headline])
		XCTAssertTrue(headlineCell.waitForExistence(timeout: .short))
	}

	func test_CheckinFromUniversalQRCodeScannerWithInfoScreen() throws {
		app.setLaunchArgument(LaunchArguments.infoScreen.checkinInfoScreenShown, to: false)
		app.launch()

		app.buttons[AccessibilityIdentifiers.TabBar.scanner].waitAndTap()

		// Simulator only Alert will open where you can choose what the QRScanner should scan
		let eventButton = try XCTUnwrap(app.buttons[AccessibilityIdentifiers.UniversalQRScanner.fakeEvent])
		eventButton.waitAndTap()

		// Checkin Info Screen
		XCTAssertTrue(app.staticTexts[AccessibilityIdentifiers.Checkin.Information.descriptionTitle].waitForExistence(timeout: .short))

		app.buttons[AccessibilityIdentifiers.Checkin.Information.primaryButton].waitAndTap()

		// Checkin Screen
		XCTAssertTrue(app.staticTexts[AccessibilityIdentifiers.Checkin.Details.checkinFor].waitForExistence(timeout: .short))
	}

	func test_CheckinFromUniversalQRCodeScannerWithoutInfoScreen() throws {
		app.setLaunchArgument(LaunchArguments.infoScreen.checkinInfoScreenShown, to: true)
		app.launch()

		app.buttons[AccessibilityIdentifiers.TabBar.scanner].waitAndTap()

		/// Simulator only Alert will open where you can choose what the QRScanner should scan
		let eventButton = try XCTUnwrap(app.buttons[AccessibilityIdentifiers.UniversalQRScanner.fakeEvent])
		eventButton.waitAndTap()

		/// Checkin Screen
		XCTAssertTrue(app.staticTexts[AccessibilityIdentifiers.Checkin.Details.checkinFor].waitForExistence(timeout: .short))
	}

	func test_RegisterCoronaTestFromUniversalQRCodeScanner() throws {
		app.launch()

		app.buttons[AccessibilityIdentifiers.TabBar.scanner].waitAndTap()

		/// Simulator only Alert will open where you can choose what the QRScanner should scan
		let pcrButton = try XCTUnwrap(app.buttons[AccessibilityIdentifiers.UniversalQRScanner.fakePCR])
		pcrButton.waitAndTap()

		/// Select user as test owner
		let userButton = try XCTUnwrap(app.cells[AccessibilityIdentifiers.ExposureSubmission.TestOwnerSelection.userButton])
		userButton.waitAndTap()
		
		/// Exposure Submission QR Info Screen
		XCTAssertTrue(app.staticTexts[AccessibilityLabels.localized(AppStrings.ExposureSubmissionQRInfo.title)].waitForExistence(timeout: .short))
	}
}
