//
// 🦠 Corona-Warn-App
//

import XCTest
import HealthCertificateToolkit
@testable import ENA

class ExposureSubmissionTestResultFamilyMemberViewModelTests: CWATestCase {
	
	private var store: Store!
	
	override func setUpWithError() throws {
		try super.setUpWithError()
		store = MockTestStore()
	}

	func testDidTapPrimaryButtonOnPositiveNegativeOrInvalidTestResult() {
		let familyMemberCoronaTestService = MockFamilyMemberCoronaTestService()
		let postivePCRTest: FamilyMemberCoronaTest = .pcr(.mock(registrationDate: Date(), registrationToken: "regToken", qrCodeHash: "pcrQRCodeHash", testResult: .positive))
		let negativePCRTest: FamilyMemberCoronaTest = .pcr(.mock(registrationDate: Date(), registrationToken: "regToken", qrCodeHash: "pcrQRCodeHash", testResult: .negative))
		let invalidPCRTest: FamilyMemberCoronaTest = .pcr(.mock(registrationDate: Date(), registrationToken: "regToken", qrCodeHash: "pcrQRCodeHash", testResult: .negative))
		familyMemberCoronaTestService.coronaTests.value = [postivePCRTest, negativePCRTest, invalidPCRTest]

		for coronaTest in [postivePCRTest, negativePCRTest, invalidPCRTest] {
			let updateTestResultExpectation = expectation(description: "updateTestResult on service is not called")
			updateTestResultExpectation.isInverted = true
			
			let familyMemberCoronaTestService = MockFamilyMemberCoronaTestService()
			familyMemberCoronaTestService.coronaTests.value = [coronaTest]
			familyMemberCoronaTestService.onUpdateTestResult = { _, _ in
				updateTestResultExpectation.fulfill()
			}
			
			let model = ExposureSubmissionTestResultFamilyMemberViewModel(
				familyMemberCoronaTest: coronaTest,
				familyMemberCoronaTestService: familyMemberCoronaTestService,
				onTestDeleted: { },
				onTestCertificateCellTap: { _, _ in }
			)
			
			XCTAssertFalse(model.shouldShowDeletionConfirmationAlertPublisher.value)
			
			model.didTapPrimaryButton()
			
			XCTAssertTrue(model.shouldShowDeletionConfirmationAlertPublisher.value)
			
			waitForExpectations(timeout: .short)
		}
	}
	
	func testDidTapPrimaryButtonOnPendingTestResult() {
		let updateTestResultExpectation = expectation(description: "updateTestResult on service is called")
		
		let familyMemberCoronaTestService = MockFamilyMemberCoronaTestService()
		let pcrTest: FamilyMemberCoronaTest = .pcr(.mock(registrationDate: Date(), registrationToken: "regToken", qrCodeHash: "pcrQRCodeHash", testResult: .pending))
		familyMemberCoronaTestService.coronaTests.value = [pcrTest]
		familyMemberCoronaTestService.onUpdateTestResult = { _, _ in
			updateTestResultExpectation.fulfill()
		}
		
		let model = ExposureSubmissionTestResultFamilyMemberViewModel(
			familyMemberCoronaTest: pcrTest,
			familyMemberCoronaTestService: familyMemberCoronaTestService,
			onTestDeleted: { },
			onTestCertificateCellTap: { _, _ in }
		)
		
		XCTAssertFalse(model.shouldShowDeletionConfirmationAlertPublisher.value)
		
		model.didTapPrimaryButton()
		
		XCTAssertFalse(model.shouldShowDeletionConfirmationAlertPublisher.value)
		
		waitForExpectations(timeout: .short)
	}
	
	func testDidTapPrimaryButtonOnPendingTestResultUpdatesButtons() throws {
		let updateTestResultExpectation = expectation(description: "updateTestResult on service is called")
		
		let familyMemberCoronaTestService = MockFamilyMemberCoronaTestService()
		let pcrTest: FamilyMemberCoronaTest = .pcr(.mock(registrationDate: Date(), registrationToken: "regToken", qrCodeHash: "pcrQRCodeHash", testResult: .pending))
		familyMemberCoronaTestService.coronaTests.value = [pcrTest]
		familyMemberCoronaTestService.onUpdateTestResult = { familyMemberCoronaTest, presentNotification in
			XCTAssertEqual(familyMemberCoronaTest.type, .pcr)
			XCTAssertFalse(presentNotification)

			updateTestResultExpectation.fulfill()
		}

		let model = ExposureSubmissionTestResultFamilyMemberViewModel(
			familyMemberCoronaTest: pcrTest,
			familyMemberCoronaTestService: familyMemberCoronaTestService,
			onTestDeleted: { },
			onTestCertificateCellTap: { _, _ in }
		)
		
		let modelBefore = try XCTUnwrap(model.footerViewModelPublisher.value)

		XCTAssertFalse(modelBefore.isPrimaryLoading)
		XCTAssertTrue(modelBefore.isPrimaryButtonEnabled)
		XCTAssertFalse(modelBefore.isPrimaryButtonHidden)

		XCTAssertFalse(modelBefore.isSecondaryLoading)
		XCTAssertTrue(modelBefore.isSecondaryButtonEnabled)
		XCTAssertFalse(modelBefore.isSecondaryButtonHidden)

		model.didTapPrimaryButton()

		waitForExpectations(timeout: .short)

		let modelAfter = try XCTUnwrap(model.footerViewModelPublisher.value)

		XCTAssertFalse(modelAfter.isPrimaryLoading)
		XCTAssertTrue(modelAfter.isPrimaryButtonEnabled)
		XCTAssertFalse(modelAfter.isPrimaryButtonHidden)

		XCTAssertFalse(modelAfter.isSecondaryLoading)
		XCTAssertTrue(modelAfter.isSecondaryButtonEnabled)
		XCTAssertFalse(modelAfter.isSecondaryButtonHidden)
	}
	
	func testDidTapPrimaryButtonOnPendingTestResultSetsError() {
		let updateTestResultExpectation = expectation(description: "updateTestResult on service is called")

		let familyMemberCoronaTestService = MockFamilyMemberCoronaTestService()
		let pcrTest: FamilyMemberCoronaTest = .pcr(.mock(registrationDate: Date(), registrationToken: "regToken", qrCodeHash: "pcrQRCodeHash", testResult: .pending))
		familyMemberCoronaTestService.coronaTests.value = [pcrTest]
		familyMemberCoronaTestService.updateTestResultResult = .failure(.testResultError(.invalidResponse))
		familyMemberCoronaTestService.onUpdateTestResult = { familyMemberCoronaTest, presentNotification in
			XCTAssertEqual(familyMemberCoronaTest.type, .pcr)
			XCTAssertFalse(presentNotification)

			updateTestResultExpectation.fulfill()
		}
		
		let model = ExposureSubmissionTestResultFamilyMemberViewModel(
			familyMemberCoronaTest: pcrTest,
			familyMemberCoronaTestService: familyMemberCoronaTestService,
			onTestDeleted: { },
			onTestCertificateCellTap: { _, _ in }
		)
		
		model.didTapPrimaryButton()
		
		waitForExpectations(timeout: .short)
		
		XCTAssertEqual(model.errorPublisher.value, .testResultError(.invalidResponse))
	}
	
	func testDidTapSecondaryButtonOnPendingTestResult() {
		let familyMemberCoronaTestService = MockFamilyMemberCoronaTestService()
		let pcrTest: FamilyMemberCoronaTest = .pcr(.mock(registrationDate: Date(), registrationToken: "regToken", qrCodeHash: "pcrQRCodeHash", testResult: .pending))
		familyMemberCoronaTestService.coronaTests.value = [pcrTest]
		
		let model = ExposureSubmissionTestResultFamilyMemberViewModel(
			familyMemberCoronaTest: pcrTest,
			familyMemberCoronaTestService: familyMemberCoronaTestService,
			onTestDeleted: { },
			onTestCertificateCellTap: { _, _ in }
		)
		
		XCTAssertFalse(model.shouldShowDeletionConfirmationAlertPublisher.value)
		XCTAssertFalse(model.shouldAttemptToDismissPublisher.value)
		
		model.didTapSecondaryButton()
		
		XCTAssertTrue(model.shouldShowDeletionConfirmationAlertPublisher.value)
		XCTAssertFalse(model.shouldAttemptToDismissPublisher.value)
	}
	
	func testDeletion() {
		let moveTestToBinExpectation = expectation(description: "moveTestToBin on service is called")

		let familyMemberCoronaTestService = MockFamilyMemberCoronaTestService()
		let pcrTest: FamilyMemberCoronaTest = .pcr(.mock(registrationDate: Date(), registrationToken: "regToken", qrCodeHash: "pcrQRCodeHash", testResult: .invalid))
		familyMemberCoronaTestService.coronaTests.value = [pcrTest]
		familyMemberCoronaTestService.onMoveTestToBin = { familyMemberCoronaTest in
			XCTAssertEqual(familyMemberCoronaTest.type, .pcr)

			moveTestToBinExpectation.fulfill()
		}

		let onTestDeletedCalledExpectation = expectation(description: "onTestDeleted closure is called")
		
		let model = ExposureSubmissionTestResultFamilyMemberViewModel(
			familyMemberCoronaTest: pcrTest,
			familyMemberCoronaTestService: familyMemberCoronaTestService,
			onTestDeleted: {
				onTestDeletedCalledExpectation.fulfill()
			},
			onTestCertificateCellTap: { _, _ in }
		)
		
		model.deleteTest()
		
		waitForExpectations(timeout: .short)
	}
	
	func testNavigationFooterItemForPendingTestResult() throws {
		let familyMemberCoronaTestService = MockFamilyMemberCoronaTestService()
		let pcrTest: FamilyMemberCoronaTest = .pcr(.mock(registrationDate: Date(), registrationToken: "regToken", qrCodeHash: "pcrQRCodeHash", testResult: .pending))
		familyMemberCoronaTestService.coronaTests.value = [pcrTest]
		
		let model = ExposureSubmissionTestResultFamilyMemberViewModel(
			familyMemberCoronaTest: pcrTest,
			familyMemberCoronaTestService: familyMemberCoronaTestService,
			onTestDeleted: { },
			onTestCertificateCellTap: { _, _ in }
		)

		let footerViewModel = try XCTUnwrap(model.footerViewModelPublisher.value)

		XCTAssertFalse(footerViewModel.isPrimaryLoading)
		XCTAssertTrue(footerViewModel.isPrimaryButtonEnabled)
		XCTAssertFalse(footerViewModel.isPrimaryButtonHidden)

		XCTAssertFalse(footerViewModel.isSecondaryLoading)
		XCTAssertTrue(footerViewModel.isSecondaryButtonEnabled)
		XCTAssertFalse(footerViewModel.isSecondaryButtonHidden)
	}
	
	func testNavigationFooterItemForPositiveNegativeOrInvalidTestResult() throws {
		let familyMemberCoronaTestService = MockFamilyMemberCoronaTestService()
		let postivePCRTest: FamilyMemberCoronaTest = .pcr(.mock(registrationDate: Date(), registrationToken: "regToken", qrCodeHash: "pcrQRCodeHash", testResult: .positive))
		let negativePCRTest: FamilyMemberCoronaTest = .pcr(.mock(registrationDate: Date(), registrationToken: "regToken", qrCodeHash: "pcrQRCodeHash", testResult: .negative))
		let invalidPCRTest: FamilyMemberCoronaTest = .pcr(.mock(registrationDate: Date(), registrationToken: "regToken", qrCodeHash: "pcrQRCodeHash", testResult: .negative))
		familyMemberCoronaTestService.coronaTests.value = [postivePCRTest, negativePCRTest, invalidPCRTest]

		for coronaTest in [postivePCRTest, negativePCRTest, invalidPCRTest] {
			let model = ExposureSubmissionTestResultFamilyMemberViewModel(
				familyMemberCoronaTest: coronaTest,
				familyMemberCoronaTestService: familyMemberCoronaTestService,
				onTestDeleted: { },
				onTestCertificateCellTap: { _, _ in }
			)

			let footerViewModel = try XCTUnwrap(model.footerViewModelPublisher.value)

			XCTAssertFalse(footerViewModel.isPrimaryLoading)
			XCTAssertTrue(footerViewModel.isPrimaryButtonEnabled)
			XCTAssertFalse(footerViewModel.isPrimaryButtonHidden)

			XCTAssertFalse(footerViewModel.isSecondaryLoading)
			XCTAssertFalse(footerViewModel.isSecondaryButtonEnabled)
			XCTAssertTrue(footerViewModel.isSecondaryButtonHidden)
		}
	}
	
	func testDynamicTableViewModelForPositiveTestResult() {
		let familyMemberCoronaTestService = MockFamilyMemberCoronaTestService()
		let pcrTest: FamilyMemberCoronaTest = .pcr(.mock(registrationDate: Date(), registrationToken: "regToken", qrCodeHash: "pcrQRCodeHash", testResult: .positive))
		familyMemberCoronaTestService.coronaTests.value = [pcrTest]
		
		let model = ExposureSubmissionTestResultFamilyMemberViewModel(
			familyMemberCoronaTest: pcrTest,
			familyMemberCoronaTestService: familyMemberCoronaTestService,
			onTestDeleted: { },
			onTestCertificateCellTap: { _, _ in }
		)
		
		XCTAssertEqual(model.dynamicTableViewModelPublisher.value.numberOfSection, 1)
		XCTAssertNotNil(model.dynamicTableViewModelPublisher.value.section(0).header)
		
		let section = model.dynamicTableViewModelPublisher.value.section(0)
		let cells = section.cells
		XCTAssertEqual(cells.count, 9)
		
		let firstItem = cells[0]
		var id = firstItem.cellReuseIdentifier
		XCTAssertEqual(id.rawValue, "labelCell")
		
		let secondItem = cells[1]
		id = secondItem.cellReuseIdentifier
		XCTAssertEqual(id.rawValue, "stepCell")
		
		let thirdItem = cells[2]
		id = thirdItem.cellReuseIdentifier
		XCTAssertEqual(id.rawValue, "stepCell")
		
		let fourthItem = cells[3]
		id = fourthItem.cellReuseIdentifier
		XCTAssertEqual(id.rawValue, "stepCell")
		
		let fifthItem = cells[4]
		id = fifthItem.cellReuseIdentifier
		XCTAssertEqual(id.rawValue, "labelCell")
		
		let sixthItem = cells[5]
		id = sixthItem.cellReuseIdentifier
		XCTAssertEqual(id.rawValue, "bulletPointCell")
		
		let seventhItem = cells[6]
		id = seventhItem.cellReuseIdentifier
		XCTAssertEqual(id.rawValue, "bulletPointCell")
		
		let eigthItem = cells[7]
		id = eigthItem.cellReuseIdentifier
		XCTAssertEqual(id.rawValue, "bulletPointCell")
		
		let ninthItem = cells[8]
		id = ninthItem.cellReuseIdentifier
		XCTAssertEqual(id.rawValue, "bulletPointCell")
	}
	
	func testDynamicTableViewModelForNegativeTestResult() {
		let familyMemberCoronaTestService = MockFamilyMemberCoronaTestService()
		let pcrTest: FamilyMemberCoronaTest = .pcr(.mock(registrationDate: Date(), registrationToken: "regToken", qrCodeHash: "pcrQRCodeHash", testResult: .negative))
		familyMemberCoronaTestService.coronaTests.value = [pcrTest]
		
		let model = ExposureSubmissionTestResultFamilyMemberViewModel(
			familyMemberCoronaTest: pcrTest,
			familyMemberCoronaTestService: familyMemberCoronaTestService,
			onTestDeleted: { },
			onTestCertificateCellTap: { _, _ in }
		)
		
		XCTAssertEqual(model.dynamicTableViewModelPublisher.value.numberOfSection, 1)
		XCTAssertNotNil(model.dynamicTableViewModelPublisher.value.section(0).header)
		
		let section = model.dynamicTableViewModelPublisher.value.section(0)
		let cells = section.cells
		XCTAssertEqual(cells.count, 9)
		
		let firstItem = cells[0]
		var id = firstItem.cellReuseIdentifier
		XCTAssertEqual(id.rawValue, "labelCell")
		
		let secondItem = cells[1]
		id = secondItem.cellReuseIdentifier
		XCTAssertEqual(id.rawValue, "labelCell")
		
		let thirdItem = cells[2]
		id = thirdItem.cellReuseIdentifier
		XCTAssertEqual(id.rawValue, "stepCell")
		
		let fourthItem = cells[3]
		id = fourthItem.cellReuseIdentifier
		XCTAssertEqual(id.rawValue, "stepCell")
		
		let fifthItem = cells[4]
		id = fifthItem.cellReuseIdentifier
		XCTAssertEqual(id.rawValue, "labelCell")
		
		let sixthItem = cells[5]
		id = sixthItem.cellReuseIdentifier
		XCTAssertEqual(id.rawValue, "labelCell")
		
		let seventhItem = cells[6]
		id = seventhItem.cellReuseIdentifier
		XCTAssertEqual(id.rawValue, "bulletPointCell")
		
		let eigthItem = cells[7]
		id = eigthItem.cellReuseIdentifier
		XCTAssertEqual(id.rawValue, "bulletPointCell")
		
		let ninthItem = cells[8]
		id = ninthItem.cellReuseIdentifier
		XCTAssertEqual(id.rawValue, "bulletPointCell")
	}
	
	func testDynamicTableViewModelForPendingTestResult() {
		let familyMemberCoronaTestService = MockFamilyMemberCoronaTestService()
		let pcrTest: FamilyMemberCoronaTest = .pcr(.mock(registrationDate: Date(), registrationToken: "regToken", qrCodeHash: "pcrQRCodeHash", testResult: .pending))
		familyMemberCoronaTestService.coronaTests.value = [pcrTest]
		
		let model = ExposureSubmissionTestResultFamilyMemberViewModel(
			familyMemberCoronaTest: pcrTest,
			familyMemberCoronaTestService: familyMemberCoronaTestService,
			onTestDeleted: { },
			onTestCertificateCellTap: { _, _ in }
		)
		
		XCTAssertEqual(model.dynamicTableViewModelPublisher.value.numberOfSection, 1)
		XCTAssertNotNil(model.dynamicTableViewModelPublisher.value.section(0).header)
		
		let section = model.dynamicTableViewModelPublisher.value.section(0)
		let cells = section.cells
		XCTAssertEqual(cells.count, 4)
		
		let firstItem = cells[0]
		var id = firstItem.cellReuseIdentifier
		XCTAssertEqual(id.rawValue, "labelCell")
		
		let secondItem = cells[1]
		id = secondItem.cellReuseIdentifier
		XCTAssertEqual(id.rawValue, "stepCell")
		
		let thirdItem = cells[2]
		id = thirdItem.cellReuseIdentifier
		XCTAssertEqual(id.rawValue, "stepCell")
		
		let fourthItem = cells[3]
		id = fourthItem.cellReuseIdentifier
		XCTAssertEqual(id.rawValue, "stepCell")
	}

	func testDynamicTableViewModelForInvalidTestResult() {
		let familyMemberCoronaTestService = MockFamilyMemberCoronaTestService()
		let pcrTest: FamilyMemberCoronaTest = .pcr(.mock(registrationDate: Date(), registrationToken: "regToken", qrCodeHash: "pcrQRCodeHash", testResult: .invalid))
		familyMemberCoronaTestService.coronaTests.value = [pcrTest]
		
		let model = ExposureSubmissionTestResultFamilyMemberViewModel(
			familyMemberCoronaTest: pcrTest,
			familyMemberCoronaTestService: familyMemberCoronaTestService,
			onTestDeleted: { },
			onTestCertificateCellTap: { _, _ in }
		)
		
		XCTAssertEqual(model.dynamicTableViewModelPublisher.value.numberOfSection, 1)
		XCTAssertNotNil(model.dynamicTableViewModelPublisher.value.section(0).header)
		
		let section = model.dynamicTableViewModelPublisher.value.section(0)
		let cells = section.cells
		XCTAssertEqual(cells.count, 3)
		
		let firstItem = cells[0]
		var id = firstItem.cellReuseIdentifier
		XCTAssertEqual(id.rawValue, "labelCell")
		
		let secondItem = cells[1]
		id = secondItem.cellReuseIdentifier
		XCTAssertEqual(id.rawValue, "stepCell")
		
		let thirdItem = cells[2]
		id = thirdItem.cellReuseIdentifier
		XCTAssertEqual(id.rawValue, "stepCell")
	}
	
}
