////
// 🦠 Corona-Warn-App
//

import XCTest

// swiftlint:disable type_body_length file_length
class ENAUITests_13_CreateHealthCertificate: CWATestCase {

	// MARK: - Overrides

	override func setUp() {
		super.setUp()
		continueAfterFailure = false
		app = XCUIApplication()
		setupSnapshot(app)
		app.setDefaults()
		app.setLaunchArgument(LaunchArguments.onboarding.isOnboarded, to: true)
		app.setLaunchArgument(LaunchArguments.onboarding.setCurrentOnboardingVersion, to: true)
		app.setLaunchArgument(LaunchArguments.healthCertificate.shouldShowExportCertificatesTooltip, to: false)
	}

	// MARK: - Internal

	var app: XCUIApplication!

	// MARK: - Tests
	
	func test_CreateAntigenTestProfileWithFirstCertificate() throws {
		app.setLaunchArgument(LaunchArguments.infoScreen.healthCertificateInfoScreenShown, to: true)
		app.launch()

		app.buttons[AccessibilityIdentifiers.TabBar.certificates].waitAndTap()

		/// Tap Scan Button
		app.buttons[AccessibilityIdentifiers.TabBar.scanner].waitAndTap()

		// Simulator only Alert will open where you can choose what the QRScanner should scan, we want the first HC here.
		let hc1Button = try XCTUnwrap(app.buttons[AccessibilityIdentifiers.UniversalQRScanner.fakeHC1])
		hc1Button.waitAndTap()

		// Certificate Screen
		let headlineCell = try XCTUnwrap(app.cells[AccessibilityIdentifiers.HealthCertificate.Certificate.headline])
		XCTAssertTrue(headlineCell.waitForExistence(timeout: .short))
	}
	
	func test_HealthCertificateWithBoosterNotification() throws {
		app.setLaunchArgument(LaunchArguments.healthCertificate.firstAndSecondHealthCertificate, to: true)
		app.setLaunchArgument(LaunchArguments.healthCertificate.hasBoosterNotification, to: true)
		app.setLaunchArgument(LaunchArguments.infoScreen.healthCertificateInfoScreenShown, to: true)
		app.launch()

		app.buttons[AccessibilityIdentifiers.TabBar.certificates].waitAndTap()

		let certificateTitle = try XCTUnwrap(app.cells[AccessibilityIdentifiers.HealthCertificate.Overview.healthCertifiedPersonCell])
		certificateTitle.waitAndTap()

		let boosterNotificationCell = try XCTUnwrap(app.cells[AccessibilityIdentifiers.BoosterNotification.Details.boosterNotificationCell])
		boosterNotificationCell.waitAndTap()

		let boosterNotificationDetailsImage = app.images[AccessibilityIdentifiers.BoosterNotification.Details.image]
		XCTAssertTrue(boosterNotificationDetailsImage.waitForExistence(timeout: .medium))
	}
	
	func test_HealthCertificate_printPDF_NonDE_Allowed() throws {
		app.setLaunchArgument(LaunchArguments.healthCertificate.firstAndSecondHealthCertificate, to: true)
		app.setLaunchArgument(LaunchArguments.healthCertificate.firstAndSecondHealthCertificateIssuerDE, to: false)
		app.setLaunchArgument(LaunchArguments.infoScreen.healthCertificateInfoScreenShown, to: true)
		app.launch()

		app.buttons[AccessibilityIdentifiers.TabBar.certificates].waitAndTap()

		let certificateTitle = try XCTUnwrap(app.cells[AccessibilityIdentifiers.HealthCertificate.Overview.healthCertifiedPersonCell])
		certificateTitle.waitAndTap()

		app.swipeUp(velocity: .fast)

		let certificateCell = app.cells[AccessibilityIdentifiers.HealthCertificate.Person.certificateCell].firstMatch
		certificateCell.waitAndTap()

		let moreButton = app.buttons[AccessibilityIdentifiers.General.secondaryFooterButton]
		moreButton.waitAndTap()

		let startPrintButton = app.sheets.buttons.firstMatch
		startPrintButton.waitAndTap()

		let nextButton = app.buttons[AccessibilityIdentifiers.HealthCertificate.PrintPdf.infoPrimaryButton]
		nextButton.waitAndTap()

		let printButton = app.buttons[AccessibilityIdentifiers.HealthCertificate.PrintPdf.printButton]
		XCTAssertTrue(printButton.waitForExistence(timeout: .short))

		let shareButton = app.buttons[AccessibilityIdentifiers.HealthCertificate.PrintPdf.printButton]
		XCTAssertTrue(shareButton.waitForExistence(timeout: .short))
	}
	
	func test_HealthCertificateInvalid() throws {
		app.setLaunchArgument(LaunchArguments.healthCertificate.isCertificateInvalid, to: true)
		app.setLaunchArgument(LaunchArguments.healthCertificate.firstAndSecondHealthCertificate, to: true)
		app.setLaunchArgument(LaunchArguments.infoScreen.healthCertificateInfoScreenShown, to: true)
		app.launch()

		app.buttons[AccessibilityIdentifiers.TabBar.certificates].waitAndTap()

		let certificateTitle = try XCTUnwrap(app.cells[AccessibilityIdentifiers.HealthCertificate.Overview.healthCertifiedPersonCell])
		
		certificateTitle.waitAndTap()

		let headerCell = app.cells[AccessibilityIdentifiers.HealthCertificate.header]
		XCTAssertTrue(headerCell.waitForExistence(timeout: .short))
		
		app.swipeUp(velocity: .slow)
		
		// Certified Person screen
		let certificateCells = try XCTUnwrap(app.cells[AccessibilityIdentifiers.HealthCertificate.Person.certificateCell])
		XCTAssertTrue(certificateCells.waitForExistence(timeout: .short))
		XCTAssertEqual(app.cells.matching(identifier: AccessibilityIdentifiers.HealthCertificate.Person.certificateCell).count, 2)
	}
	
	func test_HealthCertificateExpired() throws {
		app.setLaunchArgument(LaunchArguments.healthCertificate.hasCertificateExpired, to: true)
		app.setLaunchArgument(LaunchArguments.healthCertificate.firstAndSecondHealthCertificate, to: true)
		app.setLaunchArgument(LaunchArguments.infoScreen.healthCertificateInfoScreenShown, to: true)
		app.launch()

		app.buttons[AccessibilityIdentifiers.TabBar.certificates].waitAndTap()

		let certificateTitle = try XCTUnwrap(app.cells[AccessibilityIdentifiers.HealthCertificate.Overview.healthCertifiedPersonCell])
		
		certificateTitle.waitAndTap()

		let headerCell = app.cells[AccessibilityIdentifiers.HealthCertificate.header]
		XCTAssertTrue(headerCell.waitForExistence(timeout: .short))

		app.swipeUp(velocity: .slow)
		
		// Certified Person screen
		let certificateCells = try XCTUnwrap(app.cells[AccessibilityIdentifiers.HealthCertificate.Person.certificateCell])
		XCTAssertTrue(certificateCells.waitForExistence(timeout: .short))
		XCTAssertEqual(app.cells.matching(identifier: AccessibilityIdentifiers.HealthCertificate.Person.certificateCell).count, 2)
	}
	
	func test_NewTestCertificate() throws {
		app.setLaunchArgument(LaunchArguments.infoScreen.healthCertificateInfoScreenShown, to: true)
		app.setLaunchArgument(LaunchArguments.healthCertificate.newTestCertificateRegistered, to: true)
		app.launch()

		// Navigate to Certificates Tab.
		app.buttons[AccessibilityIdentifiers.TabBar.certificates].waitAndTap()

		// Navigate to the person screen
		app.cells[AccessibilityIdentifiers.HealthCertificate.Overview.healthCertifiedPersonCell].waitAndTap()
	}
	
	func test_HealthCertificateExpiring() throws {
		app.setLaunchArgument(LaunchArguments.healthCertificate.isCertificateExpiring, to: true)
		app.setLaunchArgument(LaunchArguments.healthCertificate.firstAndSecondHealthCertificate, to: true)
		app.setLaunchArgument(LaunchArguments.infoScreen.healthCertificateInfoScreenShown, to: true)
		app.launch()

		app.buttons[AccessibilityIdentifiers.TabBar.certificates].waitAndTap()

		let certificateTitle = try XCTUnwrap(app.cells[AccessibilityIdentifiers.HealthCertificate.Overview.healthCertifiedPersonCell])
		
		snapshot("screenshot_vaccination_certificate_expiring_overview")

		certificateTitle.waitAndTap()

		let headerCell = app.cells[AccessibilityIdentifiers.HealthCertificate.header]
		XCTAssertTrue(headerCell.waitForExistence(timeout: .short))

		app.swipeUp(velocity: .slow)
		
		// Certified Person screen
		let certificateCells = try XCTUnwrap(app.cells[AccessibilityIdentifiers.HealthCertificate.Person.certificateCell])
		XCTAssertTrue(certificateCells.waitForExistence(timeout: .short))
		XCTAssertEqual(app.cells.matching(identifier: AccessibilityIdentifiers.HealthCertificate.Person.certificateCell).count, 2)
	}
	
	func test_TestCertificateInvalid() throws {
		app.setLaunchArgument(LaunchArguments.healthCertificate.isCertificateInvalid, to: true)
		app.setLaunchArgument(LaunchArguments.infoScreen.healthCertificateInfoScreenShown, to: true)
		app.setLaunchArgument(LaunchArguments.healthCertificate.testCertificateRegistered, to: true)
		app.launch()

		// Navigate to Certificates Tab.
		app.buttons[AccessibilityIdentifiers.TabBar.certificates].waitAndTap()
		
		// Navigate to the person screen
		app.cells[AccessibilityIdentifiers.HealthCertificate.Overview.healthCertifiedPersonCell].waitAndTap()
		
		app.swipeUp(velocity: .slow)

		// Navigatate to test certificate details screen
		app.cells[AccessibilityIdentifiers.HealthCertificate.Person.certificateCell].waitAndTap()
	}
	
	func test_RecoveryCertificateInvalid() throws {
		app.setLaunchArgument(LaunchArguments.healthCertificate.isCertificateInvalid, to: true)
		app.setLaunchArgument(LaunchArguments.infoScreen.healthCertificateInfoScreenShown, to: true)
		app.setLaunchArgument(LaunchArguments.healthCertificate.recoveryCertificateRegistered, to: true)
		app.launch()

		// Navigate to Certificates Tab.
		app.buttons[AccessibilityIdentifiers.TabBar.certificates].waitAndTap()

		// Navigate to the person screen
		app.cells[AccessibilityIdentifiers.HealthCertificate.Overview.healthCertifiedPersonCell].waitAndTap()

		snapshot("screenshot_recovery_certificate_invalid_overview_part1")
		app.swipeUp(velocity: .slow)
	
		// Navigatate to recovery certificate details screen
		app.cells[AccessibilityIdentifiers.HealthCertificate.Person.certificateCell].waitAndTap()
	}
	
	func test_RecoveryCertificateExpiring() throws {
		app.setLaunchArgument(LaunchArguments.healthCertificate.isCertificateExpiring, to: true)
		app.setLaunchArgument(LaunchArguments.infoScreen.healthCertificateInfoScreenShown, to: true)
		app.setLaunchArgument(LaunchArguments.healthCertificate.recoveryCertificateRegistered, to: true)
		app.launch()
		
		// Navigate to Certificates Tab.
		app.buttons[AccessibilityIdentifiers.TabBar.certificates].waitAndTap()
		
		// Navigate to the person screen
		app.cells[AccessibilityIdentifiers.HealthCertificate.Overview.healthCertifiedPersonCell].waitAndTap()
		
		app.swipeUp(velocity: .slow)
		
		// Navigatate to recovery certificate details screen
		app.cells[AccessibilityIdentifiers.HealthCertificate.Person.certificateCell].waitAndTap()
		
		app.swipeUp(velocity: .slow)
	}
	
	func test_CompleteVaccinationProtectionWithTestCertificate() throws {
		app.setLaunchArgument(LaunchArguments.healthCertificate.firstAndSecondHealthCertificate, to: true)
		app.setLaunchArgument(LaunchArguments.infoScreen.healthCertificateInfoScreenShown, to: true)
		app.setLaunchArgument(LaunchArguments.healthCertificate.testCertificateRegistered, to: true)
		app.launch()

		// Navigate to Certificates Tab.
		app.buttons[AccessibilityIdentifiers.TabBar.certificates].waitAndTap()

		let healthCertificateCell = app.cells[AccessibilityIdentifiers.HealthCertificate.Overview.healthCertifiedPersonCell]
		XCTAssertTrue(healthCertificateCell.waitForExistence(timeout: .short))
	}

	func test_CompleteVaccination_AdmissionState() {
		app.setLaunchArgument(LaunchArguments.healthCertificate.firstAndSecondHealthCertificate, to: true)
		app.setLaunchArgument(LaunchArguments.infoScreen.healthCertificateInfoScreenShown, to: true)
		app.setLaunchArgument(LaunchArguments.healthCertificate.testCertificateRegistered, to: true)
		app.launch()

		// Navigate to Certificates Tab.
		app.buttons[AccessibilityIdentifiers.TabBar.certificates].waitAndTap()

		// Navigate to Persons Tab.
		app.cells[AccessibilityIdentifiers.HealthCertificate.Overview.healthCertifiedPersonCell].waitAndTap()

		app.swipeUp(velocity: .slow)
		XCTAssertTrue(app.otherElements[AccessibilityIdentifiers.HealthCertificate.AdmissionState.roundedView].waitForExistence(timeout: .short))
		XCTAssertTrue(app.staticTexts[AccessibilityIdentifiers.HealthCertificate.AdmissionState.title].waitForExistence(timeout: .short))
		XCTAssertTrue(app.staticTexts[AccessibilityIdentifiers.HealthCertificate.AdmissionState.subtitle].waitForExistence(timeout: .short))
		XCTAssertTrue(app.staticTexts[AccessibilityIdentifiers.HealthCertificate.AdmissionState.description].waitForExistence(timeout: .short))
		XCTAssertTrue(app.buttons[AccessibilityIdentifiers.HealthCertificate.AdmissionState.faq].waitForExistence(timeout: .short))
	}
	
	func test_AdmissionStateChanges_Then_StateChangeIndicatorIsVisible() {
		app.setLaunchArgument(LaunchArguments.healthCertificate.firstAndSecondHealthCertificate, to: true)
		app.setLaunchArgument(LaunchArguments.infoScreen.healthCertificateInfoScreenShown, to: true)
		app.setLaunchArgument(LaunchArguments.healthCertificate.testCertificateRegistered, to: true)
		app.launch()
		
		// Navigate to Certificates Tab.
		app.buttons[AccessibilityIdentifiers.TabBar.certificates].waitAndTap(.long)
		
		// Navigate to Persons Tab.
		app.cells[AccessibilityIdentifiers.HealthCertificate.Overview.healthCertifiedPersonCell].waitAndTap(.long)
		
		XCTAssertTrue(app.otherElements[AccessibilityIdentifiers.HealthCertificate.AdmissionState.unseenNewsIndicator].waitForExistence(timeout: .long))
	}
	
	func test_CompleteVaccination_MaskState() {
		app.setLaunchArgument(LaunchArguments.healthCertificate.firstAndSecondHealthCertificate, to: true)
		app.setLaunchArgument(LaunchArguments.infoScreen.healthCertificateInfoScreenShown, to: true)
		app.launch()
		
		// Navigate to Certificates Tab.
		app.buttons[AccessibilityIdentifiers.TabBar.certificates].waitAndTap()
		
		// Navigate to Persons Tab.
		app.cells[AccessibilityIdentifiers.HealthCertificate.Overview.healthCertifiedPersonCell].waitAndTap()
		
		XCTAssertTrue(app.otherElements[AccessibilityIdentifiers.HealthCertificate.MaskState.roundedView].waitForExistence(timeout: .short))
		XCTAssertTrue(app.staticTexts[AccessibilityIdentifiers.HealthCertificate.MaskState.title].waitForExistence(timeout: .short))
		XCTAssertTrue(app.staticTexts[AccessibilityIdentifiers.HealthCertificate.MaskState.subtitle].waitForExistence(timeout: .short))
		 XCTAssertTrue(app.images[AccessibilityIdentifiers.HealthCertificate.MaskState.badgeImage].waitForExistence(timeout: .short))
		XCTAssertTrue(app.staticTexts[AccessibilityIdentifiers.HealthCertificate.MaskState.description].waitForExistence(timeout: .short))
		XCTAssertTrue(app.buttons[AccessibilityIdentifiers.HealthCertificate.MaskState.faq].waitForExistence(timeout: .short))
	}
	
	func test_CheckinFromCertificatesTabWithInfoScreen() throws {
		app.setLaunchArgument(LaunchArguments.infoScreen.healthCertificateInfoScreenShown, to: true)
		app.setLaunchArgument(LaunchArguments.infoScreen.checkinInfoScreenShown, to: false)
		app.launch()

		app.buttons[AccessibilityIdentifiers.TabBar.certificates].waitAndTap()

		/// Tap Scan Button
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

	func test_CheckinFromCertificatesTabWithoutInfoScreen() throws {
		app.setLaunchArgument(LaunchArguments.infoScreen.healthCertificateInfoScreenShown, to: true)
		app.setLaunchArgument(LaunchArguments.infoScreen.checkinInfoScreenShown, to: true)
		app.launch()

		app.buttons[AccessibilityIdentifiers.TabBar.certificates].waitAndTap()

		/// Tap Scan Button
		app.buttons[AccessibilityIdentifiers.TabBar.scanner].waitAndTap()

		/// Simulator only Alert will open where you can choose what the QRScanner should scan
		let eventButton = try XCTUnwrap(app.buttons[AccessibilityIdentifiers.UniversalQRScanner.fakeEvent])
		eventButton.waitAndTap()

		/// Checkin Screen
		XCTAssertTrue(app.staticTexts[AccessibilityIdentifiers.Checkin.Details.checkinFor].waitForExistence(timeout: .short))
	}

	func test_RegisterCoronaTestFromCertificatesTab() throws {
		app.setLaunchArgument(LaunchArguments.infoScreen.healthCertificateInfoScreenShown, to: true)
		app.launch()

		app.buttons[AccessibilityIdentifiers.TabBar.certificates].waitAndTap()

		/// Tap Scan Button
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
	
	func test_HealthCertificate_FederalState_Flow() throws {
		app.setLaunchArgument(LaunchArguments.healthCertificate.firstAndSecondHealthCertificate, to: true)
		app.setLaunchArgument(LaunchArguments.healthCertificate.isDCCAdmissionCheckScenariosEnabled, to: true)
		app.setLaunchArgument(LaunchArguments.infoScreen.healthCertificateInfoScreenShown, to: true)
		app.launch()
		
		app.buttons[AccessibilityIdentifiers.TabBar.certificates].waitAndTap()
		
		// Check if the selection button exists
		let selectionButtonCell = try XCTUnwrap(app.cells[AccessibilityIdentifiers.HealthCertificate.Overview.changeAdmissionScenarioCell])
		
		// Navigate to the scenario selection screen
		selectionButtonCell.waitAndTap()
		
		// Select federal state Berlin
		app.cells.element(boundBy: 2).waitAndTap()
		
		// Check if the button with label Berlin exists
		let selectedStateButton = try XCTUnwrap(app.buttons[app.localized("FederalState_Berlin")])
		XCTAssertTrue(selectedStateButton.waitForExistence(timeout: .medium))
	}

	// MARK: - Screenshots
	
	func test_screenshot_shownConsentScreenAndDisclaimer() throws {
		app.launch()

		app.buttons[AccessibilityIdentifiers.TabBar.certificates].waitAndTap()

		// HealthCertificate consent screen tap on disclaimer
		let disclaimerButton = try XCTUnwrap(app.cells[AccessibilityIdentifiers.HealthCertificate.Info.disclaimer])
		
		snapshot("screenshot_health_certificate_consent_screen")
		
		disclaimerButton.waitAndTap()

		// data privacy
		XCTAssertTrue(app.images[AccessibilityIdentifiers.AppInformation.privacyImageDescription].waitForExistence(timeout: .extraLong))

		let backButton = try XCTUnwrap(app.navigationBars.buttons.element(boundBy: 0))
		backButton.waitAndTap()

		// Close consent
		let primaryButton = try XCTUnwrap(app.buttons[AccessibilityIdentifiers.General.primaryFooterButton])
		primaryButton.waitAndTap()

		XCTAssertFalse(app.cells[AccessibilityIdentifiers.HealthCertificate.Overview.changeAdmissionScenarioCell].waitForExistence(timeout: .short))
		
		snapshot("screenshot_health_certificate_empty_screen")
	}

	func test_screenshot_CreateAntigenTestProfileWithLastCertificate() throws {
		app.setLaunchArgument(LaunchArguments.healthCertificate.firstHealthCertificate, to: true)
		app.setLaunchArgument(LaunchArguments.infoScreen.healthCertificateInfoScreenShown, to: true)
		app.launch()

		app.buttons[AccessibilityIdentifiers.TabBar.certificates].waitAndTap()

		/// Tap Scan Button
		app.buttons[AccessibilityIdentifiers.TabBar.scanner].waitAndTap()

		// Simulator only Alert will open where you can choose what the QRScanner should scan, we want the first HC here.
		let hc2Button = try XCTUnwrap(app.buttons[AccessibilityIdentifiers.UniversalQRScanner.fakeHC2])
		hc2Button.waitAndTap()

		// Certificate Screen
		let headlineCell = try XCTUnwrap(app.cells[AccessibilityIdentifiers.HealthCertificate.Certificate.headline])
		XCTAssertTrue(headlineCell.waitForExistence(timeout: .short))

		snapshot("screenshot_second_vaccination_certificate_details_part1")
		app.swipeUp(velocity: .slow)
		snapshot("screenshot_second_vaccination_certificate_details_part2")
	}

	func test_screenshot_HealthCertificate() throws {
		app.setLaunchArgument(LaunchArguments.healthCertificate.firstAndSecondHealthCertificate, to: true)
		app.setLaunchArgument(LaunchArguments.infoScreen.healthCertificateInfoScreenShown, to: true)
		app.launch()

		app.buttons[AccessibilityIdentifiers.TabBar.certificates].waitAndTap()

		let certificateTitle = try XCTUnwrap(app.cells[AccessibilityIdentifiers.HealthCertificate.Overview.healthCertifiedPersonCell])
		
		certificateTitle.waitAndTap()

		let headerCell = app.cells[AccessibilityIdentifiers.HealthCertificate.header]
		XCTAssertTrue(headerCell.waitForExistence(timeout: .short))

		snapshot("screenshot_vaccination_certificate_valid_details_part1")
		app.swipeUp(velocity: .slow)
		snapshot("screenshot_vaccination_certificate_valid_details_part2")

		// Certified Person screen
		let certificateCells = try XCTUnwrap(app.cells[AccessibilityIdentifiers.HealthCertificate.Person.certificateCell])
		XCTAssertTrue(certificateCells.waitForExistence(timeout: .short))
		XCTAssertEqual(app.cells.matching(identifier: AccessibilityIdentifiers.HealthCertificate.Person.certificateCell).count, 2)
	}
	
	func test_screenshot_HealthCertificate_printPDF() throws {
		app.setLaunchArgument(LaunchArguments.healthCertificate.firstAndSecondHealthCertificate, to: true)
		app.setLaunchArgument(LaunchArguments.healthCertificate.firstAndSecondHealthCertificateIssuerDE, to: true)
		app.setLaunchArgument(LaunchArguments.infoScreen.healthCertificateInfoScreenShown, to: true)
		app.launch()

		app.buttons[AccessibilityIdentifiers.TabBar.certificates].waitAndTap()

		let certificateTitle = try XCTUnwrap(app.cells[AccessibilityIdentifiers.HealthCertificate.Overview.healthCertifiedPersonCell])
		certificateTitle.waitAndTap()

		app.swipeUp(velocity: .fast)

		let certificateCell = app.cells[AccessibilityIdentifiers.HealthCertificate.Person.certificateCell].firstMatch
		certificateCell.waitAndTap()

		let moreButton = app.buttons[AccessibilityIdentifiers.General.secondaryFooterButton]
		moreButton.waitAndTap()

		snapshot("screenshot_vaccination_certificate_print_pdf_actionsheet")

		let startPrintButton = app.sheets.buttons.firstMatch
		startPrintButton.waitAndTap()

		snapshot("screenshot_vaccination_certificate_print_pdf_infoscreen")

		let nextButton = app.buttons[AccessibilityIdentifiers.HealthCertificate.PrintPdf.infoPrimaryButton]
		nextButton.waitAndTap()

		snapshot("screenshot_vaccination_certificate_print_pdf_pdfscreen")

		let printButton = app.buttons[AccessibilityIdentifiers.HealthCertificate.PrintPdf.printButton]
		XCTAssertTrue(printButton.waitForExistence(timeout: .short))

		let shareButton = app.buttons[AccessibilityIdentifiers.HealthCertificate.PrintPdf.printButton]
		XCTAssertTrue(shareButton.waitForExistence(timeout: .short))
	}
	
	func test_screenshot_TestCertificate() throws {
		app.setLaunchArgument(LaunchArguments.infoScreen.healthCertificateInfoScreenShown, to: true)
		app.setLaunchArgument(LaunchArguments.healthCertificate.testCertificateRegistered, to: true)
		app.launch()

		// Navigate to Certificates Tab.
		app.buttons[AccessibilityIdentifiers.TabBar.certificates].waitAndTap()
		
		// Navigate to the person screen
		app.cells[AccessibilityIdentifiers.HealthCertificate.Overview.healthCertifiedPersonCell].waitAndTap()
		
		snapshot("screenshot_test_certificate_valid_overview")

		// Navigate to test certificate details screen
		app.cells[AccessibilityIdentifiers.HealthCertificate.Person.certificateCell].waitAndTap()

		snapshot("screenshot_test_certificate_valid_details_part1")
		app.swipeUp(velocity: .slow)
		snapshot("screenshot_test_certificate_valid_details_part2")
	}
  
	func test_screenshot_RecoveryCertificate() throws {
		app.setLaunchArgument(LaunchArguments.infoScreen.healthCertificateInfoScreenShown, to: true)
		app.setLaunchArgument(LaunchArguments.healthCertificate.recoveryCertificateRegistered, to: true)
		app.launch()

		// Navigate to Certificates Tab.
		app.buttons[AccessibilityIdentifiers.TabBar.certificates].waitAndTap()

		// Navigate to the person screen
		app.cells[AccessibilityIdentifiers.HealthCertificate.Overview.healthCertifiedPersonCell].waitAndTap()

		snapshot("screenshot_recovery_certificate_valid_overview")
	
		// Navigatate to recovery certificate details screen
		app.cells[AccessibilityIdentifiers.HealthCertificate.Person.certificateCell].waitAndTap()

		snapshot("screenshot_recovery_certificate_valid_details_part1")
		app.swipeUp(velocity: .slow)
		snapshot("screenshot_recovery_certificate_valid_details_part2")
	}
	
	func test_screenshot_RecoveryCertificateExpired() throws {
		app.setLaunchArgument(LaunchArguments.healthCertificate.hasCertificateExpired, to: true)
		app.setLaunchArgument(LaunchArguments.infoScreen.healthCertificateInfoScreenShown, to: true)
		app.setLaunchArgument(LaunchArguments.healthCertificate.recoveryCertificateRegistered, to: true)
		app.launch()

		// Navigate to Certificates Tab.
		app.buttons[AccessibilityIdentifiers.TabBar.certificates].waitAndTap()

		// Navigate to the person screen
		app.cells[AccessibilityIdentifiers.HealthCertificate.Overview.healthCertifiedPersonCell].waitAndTap()
	
		// Navigatate to recovery certificate details screen
		app.cells[AccessibilityIdentifiers.HealthCertificate.Person.certificateCell].waitAndTap()

		snapshot("screenshot_recovery_certificate_expired_details_part1")
		app.swipeUp(velocity: .slow)
		snapshot("screenshot_recovery_certificate_expired_details_part2")
	}
	
	func test_screenshot_MultipleFamilyTestCertificates() throws {
		app.setLaunchArgument(LaunchArguments.infoScreen.healthCertificateInfoScreenShown, to: true)
		app.setLaunchArgument(LaunchArguments.healthCertificate.familyCertificates, to: true)
		app.launch()

		// Navigate to Certificates Tab.
		app.buttons[AccessibilityIdentifiers.TabBar.certificates].waitAndTap()
		
		var healthCertificateCell = app.cells[AccessibilityIdentifiers.HealthCertificate.Overview.healthCertifiedPersonCell]
		XCTAssertTrue(healthCertificateCell.waitForExistence(timeout: .short))
		snapshot("screenshot_certificate_family_certificate-cert-1")
		
		app.swipeUp(velocity: .slow)
		
		healthCertificateCell = app.cells[AccessibilityIdentifiers.HealthCertificate.Overview.healthCertifiedPersonCell]
		snapshot("screenshot_certificate_family_certificate-cert-2")
		
		app.swipeUp(velocity: .slow)
		
		healthCertificateCell = app.cells[AccessibilityIdentifiers.HealthCertificate.Overview.healthCertifiedPersonCell]
		
		app.swipeUp(velocity: .slow)

		healthCertificateCell = app.cells[AccessibilityIdentifiers.HealthCertificate.Overview.healthCertifiedPersonCell]
		
		XCTAssertEqual(app.cells.matching(identifier: AccessibilityIdentifiers.HealthCertificate.Overview.healthCertifiedPersonCell).count, 4)
	}

	func test_screenshot_2GPlusCertificate() throws {
		app.setLaunchArgument(LaunchArguments.infoScreen.healthCertificateInfoScreenShown, to: true)
		app.setLaunchArgument(LaunchArguments.healthCertificate.recoveryCertificateRegistered, to: true)
		app.setLaunchArgument(LaunchArguments.healthCertificate.testCertificateRegistered, to: true)
		app.launch()

		// Navigate to Certificates Tab.
		app.buttons[AccessibilityIdentifiers.TabBar.certificates].waitAndTap()

		snapshot("screenshot_2g_plus_certificate_overview")
	}
	
	func test_screenshot_maskRequiredForFederalStateBW() throws {
		app.setLaunchArgument(LaunchArguments.healthCertificate.firstAndSecondHealthCertificate, to: true)
		app.setLaunchArgument(LaunchArguments.healthCertificate.isDCCAdmissionCheckScenariosEnabled, to: true)
		app.setLaunchArgument(LaunchArguments.infoScreen.healthCertificateInfoScreenShown, to: true)
		app.launch()
		
		// Navigate to Certificates Tab.
		app.buttons[AccessibilityIdentifiers.TabBar.certificates].waitAndTap()
		
		// Check if the selection button exists
		let selectionButtonCell = try XCTUnwrap(app.cells[AccessibilityIdentifiers.HealthCertificate.Overview.changeAdmissionScenarioCell])
		
		// Navigate to the scenario selection screen
		selectionButtonCell.waitAndTap()
		
		// Select federal state Baden Württemberg
		app.cells.element(boundBy: 1).waitAndTap()
		
		snapshot("screenshot_maskRequiredForFederalStateBW")
		
		// check the Mask State
		XCTAssertTrue(app.otherElements[AccessibilityIdentifiers.HealthCertificate.MaskState.roundedView].waitForExistence(timeout: .medium))
	}
	
	func test_screenshot_maskOptionalForFederalStateBW() throws {
		app.setLaunchArgument(LaunchArguments.healthCertificate.testCertificateRegistered, to: true)
		app.setLaunchArgument(LaunchArguments.healthCertificate.isDCCAdmissionCheckScenariosEnabled, to: true)
		app.setLaunchArgument(LaunchArguments.infoScreen.healthCertificateInfoScreenShown, to: true)
		app.launch()
		
		// Navigate to Certificates Tab.
		app.buttons[AccessibilityIdentifiers.TabBar.certificates].waitAndTap()
		
		// Check if the selection button exists
		let selectionButtonCell = try XCTUnwrap(app.cells[AccessibilityIdentifiers.HealthCertificate.Overview.changeAdmissionScenarioCell])
		
		// Navigate to the scenario selection screen
		selectionButtonCell.waitAndTap()
		
		// Select federal state Baden Württemberg
		app.cells.element(boundBy: 1).waitAndTap()
		
		snapshot("screenshot_maskOptionalForFederalStateBW")
		
		// check the Mask State
		XCTAssertTrue(app.otherElements[AccessibilityIdentifiers.HealthCertificate.MaskState.roundedView].waitForExistence(timeout: .medium))
	}
	
	func test_screenshot_maskRequiredForFederalRules() throws {
		app.setLaunchArgument(LaunchArguments.healthCertificate.firstAndSecondHealthCertificate, to: true)
		app.setLaunchArgument(LaunchArguments.healthCertificate.isDCCAdmissionCheckScenariosEnabled, to: true)
		app.setLaunchArgument(LaunchArguments.infoScreen.healthCertificateInfoScreenShown, to: true)
		app.launch()
		
		// Navigate to Certificates Tab.
		app.buttons[AccessibilityIdentifiers.TabBar.certificates].waitAndTap()
		
		// Check if the selection button exists
		let selectionButtonCell = try XCTUnwrap(app.cells[AccessibilityIdentifiers.HealthCertificate.Overview.changeAdmissionScenarioCell])
		
		// Navigate to the scenario selection screen
		selectionButtonCell.waitAndTap()
		
		// Select federal rules
		app.cells.element(boundBy: 0).waitAndTap()
		
		snapshot("screenshot_maskRequiredForFederalRules")
		
		// check the Mask State
		XCTAssertTrue(app.otherElements[AccessibilityIdentifiers.HealthCertificate.MaskState.roundedView].waitForExistence(timeout: .medium))
	}
	
	func test_screenshot_maskOptionalForFederalRules() throws {
		app.setLaunchArgument(LaunchArguments.healthCertificate.testCertificateRegistered, to: true)
		app.setLaunchArgument(LaunchArguments.healthCertificate.isDCCAdmissionCheckScenariosEnabled, to: true)
		app.setLaunchArgument(LaunchArguments.infoScreen.healthCertificateInfoScreenShown, to: true)
		app.launch()
		
		// Navigate to Certificates Tab.
		app.buttons[AccessibilityIdentifiers.TabBar.certificates].waitAndTap()
		
		// Check if the selection button exists
		let selectionButtonCell = try XCTUnwrap(app.cells[AccessibilityIdentifiers.HealthCertificate.Overview.changeAdmissionScenarioCell])
		
		// Navigate to the scenario selection screen
		selectionButtonCell.waitAndTap()
		
		// Select federal rules
		app.cells.element(boundBy: 0).waitAndTap()
		
		snapshot("screenshot_maskOptionalForFederalRules")
		
		// check the Mask State
		XCTAssertTrue(app.otherElements[AccessibilityIdentifiers.HealthCertificate.MaskState.roundedView].waitForExistence(timeout: .medium))
	}

	func test_screenshot_maskRequiredDetailScreen() throws {
		app.setLaunchArgument(LaunchArguments.healthCertificate.firstAndSecondHealthCertificate, to: true)
		app.setLaunchArgument(LaunchArguments.infoScreen.healthCertificateInfoScreenShown, to: true)
		app.launch()
		
		// Navigate to Certificates Tab.
		app.buttons[AccessibilityIdentifiers.TabBar.certificates].waitAndTap()
		
		// Navigate to Persons Tab.
		app.cells[AccessibilityIdentifiers.HealthCertificate.Overview.healthCertifiedPersonCell].waitAndTap()
		
		snapshot("screenshot_maskRequiredDetailScreen")
		
		// check the Mask State.
		XCTAssertTrue(app.otherElements[AccessibilityIdentifiers.HealthCertificate.MaskState.roundedView].waitForExistence(timeout: .medium))
		XCTAssertTrue(app.staticTexts[AccessibilityIdentifiers.HealthCertificate.MaskState.title].waitForExistence(timeout: .medium))
		XCTAssertTrue(app.staticTexts[AccessibilityIdentifiers.HealthCertificate.MaskState.subtitle].waitForExistence(timeout: .medium))
		XCTAssertTrue(app.images[AccessibilityIdentifiers.HealthCertificate.MaskState.badgeImage].waitForExistence(timeout: .medium))
		XCTAssertTrue(app.staticTexts[AccessibilityIdentifiers.HealthCertificate.MaskState.description].waitForExistence(timeout: .medium))
		XCTAssertTrue(app.buttons[AccessibilityIdentifiers.HealthCertificate.MaskState.faq].waitForExistence(timeout: .medium))
	}
	
	func test_screenshot_maskOptionalDetailScreen() throws {
		app.setLaunchArgument(LaunchArguments.healthCertificate.testCertificateRegistered, to: true)
		app.setLaunchArgument(LaunchArguments.infoScreen.healthCertificateInfoScreenShown, to: true)
		app.launch()
		
		// Navigate to Certificates Tab.
		app.buttons[AccessibilityIdentifiers.TabBar.certificates].waitAndTap()
		
		// Navigate to Persons Tab.
		app.cells[AccessibilityIdentifiers.HealthCertificate.Overview.healthCertifiedPersonCell].waitAndTap()
		
		snapshot("screenshot_maskOptionalDetailScreen")
		
		// check the Mask State.
		XCTAssertTrue(app.otherElements[AccessibilityIdentifiers.HealthCertificate.MaskState.roundedView].waitForExistence(timeout: .medium))
		XCTAssertTrue(app.staticTexts[AccessibilityIdentifiers.HealthCertificate.MaskState.title].waitForExistence(timeout: .medium))
		XCTAssertTrue(app.staticTexts[AccessibilityIdentifiers.HealthCertificate.MaskState.subtitle].waitForExistence(timeout: .medium))
		XCTAssertTrue(app.images[AccessibilityIdentifiers.HealthCertificate.MaskState.badgeImage].waitForExistence(timeout: .medium))
		XCTAssertTrue(app.staticTexts[AccessibilityIdentifiers.HealthCertificate.MaskState.description].waitForExistence(timeout: .medium))
		XCTAssertTrue(app.buttons[AccessibilityIdentifiers.HealthCertificate.MaskState.faq].waitForExistence(timeout: .medium))
	}
	
	func test_screenshot_ExportCertificatesTooltip() throws {
		app.setLaunchArgument(LaunchArguments.infoScreen.healthCertificateInfoScreenShown, to: true)
		app.setLaunchArgument(LaunchArguments.healthCertificate.recoveryCertificateRegistered, to: true)
		app.setLaunchArgument(LaunchArguments.healthCertificate.shouldShowExportCertificatesTooltip, to: true)
		app.launch()
		
		// Navigate to Certificates Tab.
		app.buttons[AccessibilityIdentifiers.TabBar.certificates].waitAndTap()
		
		XCTAssertTrue(app.staticTexts[AccessibilityLabels.localized(AppStrings.Tooltip.ExportCertificates.title)].waitForExistence(timeout: .medium))
		XCTAssertTrue(app.staticTexts[AccessibilityLabels.localized(AppStrings.Tooltip.ExportCertificates.description)].waitForExistence(timeout: .short))
	}
}
