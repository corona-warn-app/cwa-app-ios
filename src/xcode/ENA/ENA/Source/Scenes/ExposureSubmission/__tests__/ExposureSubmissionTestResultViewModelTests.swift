//
// 🦠 Corona-Warn-App
//

import XCTest
import HealthCertificateToolkit
@testable import ENA

// swiftlint:disable file_length
// swiftlint:disable:next type_body_length
class ExposureSubmissionTestResultViewModelTests: CWATestCase {
	
	private var store: Store!
	
	override func setUpWithError() throws {
		try super.setUpWithError()
		store = MockTestStore()
	}
	
	func testDidTapPrimaryButtonOnPositiveTestResult() {
		let updateTestResultExpectation = expectation(description: "updateTestResult on service is not called")
		updateTestResultExpectation.isInverted = true

		let onContinueWithSymptomsFlowButtonTapExpectation = expectation(
			description: "onContinueWithSymptomsFlowButtonTap closure is called"
		)
		
		let coronaTestService = MockCoronaTestService()
		coronaTestService.pcrTest.value = PCRTest.mock(testResult: .positive, isSubmissionConsentGiven: true)
		coronaTestService.onUpdateTestResult = { _, _, _ in
			updateTestResultExpectation.fulfill()
		}
		
		let model = ExposureSubmissionTestResultViewModel(
			coronaTestType: .pcr,
			coronaTestService: coronaTestService,
			onSubmissionConsentCellTap: { _ in },
			onContinueWithSymptomsFlowButtonTap: {
				onContinueWithSymptomsFlowButtonTapExpectation.fulfill()
			},
			onContinueWarnOthersButtonTap: { _ in },
			onChangeToPositiveTestResult: { },
			onTestDeleted: { },
			onTestCertificateCellTap: { _, _ in }
		)
		
		XCTAssertFalse(model.shouldShowDeletionConfirmationAlert)
		
		model.didTapPrimaryButton()
		
		XCTAssertFalse(model.shouldShowDeletionConfirmationAlert)
		
		waitForExpectations(timeout: .short)
	}
	
	func testDidTapPrimaryButtonOnNegativeInvalidOrExpiredTestResult() {
		let testResults: [TestResult] = [.negative, .invalid, .expired]
		for testResult in testResults {
			let updateTestResultExpectation = expectation(description: "updateTestResult on service is not called")
			updateTestResultExpectation.isInverted = true

			let onContinueWithSymptomsFlowButtonTapExpectation = expectation(
				description: "onContinueWithSymptomsFlowButtonTap closure is called"
			)
			onContinueWithSymptomsFlowButtonTapExpectation.isInverted = true
			
			let coronaTestService = MockCoronaTestService()
			coronaTestService.pcrTest.value = PCRTest.mock(testResult: testResult)
			coronaTestService.onUpdateTestResult = { _, _, _ in
				updateTestResultExpectation.fulfill()
			}
			
			let model = ExposureSubmissionTestResultViewModel(
				coronaTestType: .pcr,
				coronaTestService: coronaTestService,
				onSubmissionConsentCellTap: { _ in },
				onContinueWithSymptomsFlowButtonTap: {
					onContinueWithSymptomsFlowButtonTapExpectation.fulfill()
				},
				onContinueWarnOthersButtonTap: { _ in },
				onChangeToPositiveTestResult: { },
				onTestDeleted: { },
				onTestCertificateCellTap: { _, _ in }
			)
			
			XCTAssertFalse(model.shouldShowDeletionConfirmationAlert)
			
			model.didTapPrimaryButton()
			
			XCTAssertTrue(model.shouldShowDeletionConfirmationAlert)
			
			waitForExpectations(timeout: .short)
		}
	}
	
	func testDidTapPrimaryButtonOnPendingTestResult() {
		let updateTestResultExpectation = expectation(description: "updateTestResult on service is called")
		
		let onContinueWithSymptomsFlowButtonTapExpectation = expectation(
			description: "onContinueWithSymptomsFlowButtonTap closure is called"
		)
		onContinueWithSymptomsFlowButtonTapExpectation.isInverted = true
		
		let coronaTestService = MockCoronaTestService()
		coronaTestService.pcrTest.value = PCRTest.mock(registrationToken: "asdf", testResult: .pending)
		coronaTestService.onUpdateTestResult = { coronaTestType, force, presentNotification in
			XCTAssertEqual(coronaTestType, .pcr)
			XCTAssertTrue(force)
			XCTAssertFalse(presentNotification)

			updateTestResultExpectation.fulfill()
		}
		
		let model = ExposureSubmissionTestResultViewModel(
			coronaTestType: .pcr,
			coronaTestService: coronaTestService,
			onSubmissionConsentCellTap: { _ in },
			onContinueWithSymptomsFlowButtonTap: {
				onContinueWithSymptomsFlowButtonTapExpectation.fulfill()
			},
			onContinueWarnOthersButtonTap: { _ in },
			onChangeToPositiveTestResult: { },
			onTestDeleted: { },
			onTestCertificateCellTap: { _, _ in }
		)
		
		XCTAssertFalse(model.shouldShowDeletionConfirmationAlert)
		
		model.didTapPrimaryButton()
		
		XCTAssertFalse(model.shouldShowDeletionConfirmationAlert)
		
		waitForExpectations(timeout: .short)
	}
	
	func testDidTapPrimaryButtonOnPendingTestResultUpdatesButtons() throws {
		let updateTestResultExpectation = expectation(description: "updateTestResult on service is called")
		
		let coronaTestService = MockCoronaTestService()
		coronaTestService.pcrTest.value = PCRTest.mock(registrationToken: "asdf", testResult: .pending)
		coronaTestService.onUpdateTestResult = { coronaTestType, force, presentNotification in
			XCTAssertEqual(coronaTestType, .pcr)
			XCTAssertTrue(force)
			XCTAssertFalse(presentNotification)

			coronaTestService.pcrTest.value?.testResult = .negative
			updateTestResultExpectation.fulfill()
		}
		
		let model = ExposureSubmissionTestResultViewModel(
			coronaTestType: .pcr,
			coronaTestService: coronaTestService,
			onSubmissionConsentCellTap: { _ in },
			onContinueWithSymptomsFlowButtonTap: { },
			onContinueWarnOthersButtonTap: { _ in },
			onChangeToPositiveTestResult: { },
			onTestDeleted: { },
			onTestCertificateCellTap: { _, _ in }
		)
		
		let modelBefore = try XCTUnwrap(model.footerViewModel)

		XCTAssertFalse(modelBefore.isPrimaryLoading)
		XCTAssertTrue(modelBefore.isPrimaryButtonEnabled)
		XCTAssertFalse(modelBefore.isPrimaryButtonHidden)

		XCTAssertFalse(modelBefore.isSecondaryLoading)
		XCTAssertTrue(modelBefore.isSecondaryButtonEnabled)
		XCTAssertFalse(modelBefore.isSecondaryButtonHidden)

		model.didTapPrimaryButton()

		waitForExpectations(timeout: .short)

		let modelAfter = try XCTUnwrap(model.footerViewModel)

		XCTAssertFalse(modelAfter.isPrimaryLoading)
		XCTAssertTrue(modelAfter.isPrimaryButtonEnabled)
		XCTAssertFalse(modelAfter.isPrimaryButtonHidden)

		XCTAssertFalse(modelAfter.isSecondaryLoading)
		XCTAssertTrue(modelAfter.isSecondaryButtonEnabled)
		XCTAssertTrue(modelAfter.isSecondaryButtonHidden)
	}
	
	func testDidTapPrimaryButtonOnPendingTestResultSetsError() {
		let updateTestResultExpectation = expectation(description: "updateTestResult on service is called")

		let coronaTestService = MockCoronaTestService()
		coronaTestService.pcrTest.value = PCRTest.mock(registrationToken: "asdf", testResult: .pending)
		coronaTestService.updateTestResultResult = .failure(.testResultError(.invalidResponse))
		coronaTestService.onUpdateTestResult = { coronaTestType, force, presentNotification in
			XCTAssertEqual(coronaTestType, .pcr)
			XCTAssertTrue(force)
			XCTAssertFalse(presentNotification)

			updateTestResultExpectation.fulfill()
		}
		
		let model = ExposureSubmissionTestResultViewModel(
			coronaTestType: .pcr,
			coronaTestService: coronaTestService,
			onSubmissionConsentCellTap: { _ in },
			onContinueWithSymptomsFlowButtonTap: { },
			onContinueWarnOthersButtonTap: { _ in },
			onChangeToPositiveTestResult: { },
			onTestDeleted: { },
			onTestCertificateCellTap: { _, _ in }
		)
		
		model.didTapPrimaryButton()
		
		waitForExpectations(timeout: .short)
		
		XCTAssertEqual(model.error, .testResultError(.invalidResponse))
	}
	
	func testDidTapPrimaryButtonOnPendingTestResultUpdatesButtonsLoadingState() throws {
		let updateTestResultExpectation = expectation(description: "updateTestResult on service is called")

		let coronaTestService = MockCoronaTestService()
		coronaTestService.pcrTest.value = PCRTest.mock(registrationToken: "asdf", testResult: .pending)
		
		let model = ExposureSubmissionTestResultViewModel(
			coronaTestType: .pcr,
			coronaTestService: coronaTestService,
			onSubmissionConsentCellTap: { _ in },
			onContinueWithSymptomsFlowButtonTap: { },
			onContinueWarnOthersButtonTap: { _ in },
			onChangeToPositiveTestResult: { },
			onTestDeleted: { },
			onTestCertificateCellTap: { _, _ in }
		)

		let footerViewModel = try XCTUnwrap(model.footerViewModel)

		coronaTestService.onUpdateTestResult = { coronaTestType, force, presentNotification in
			XCTAssertEqual(coronaTestType, .pcr)
			XCTAssertTrue(force)
			XCTAssertFalse(presentNotification)

			// Buttons should be in loading state when getTestResult is called on the exposure submission service
			XCTAssertFalse(footerViewModel.isPrimaryButtonEnabled)
			XCTAssertTrue(footerViewModel.isPrimaryLoading)
			XCTAssertFalse(footerViewModel.isSecondaryButtonEnabled)

			// Return to pending state
			coronaTestService.pcrTest.value?.testResult = .pending
			updateTestResultExpectation.fulfill()
		}
		
		model.didTapPrimaryButton()

		waitForExpectations(timeout: .short)
	}
	
	func testDidTapSecondaryButtonOnPendingTestResult() {
		let coronaTestService = MockCoronaTestService()
		coronaTestService.pcrTest.value = PCRTest.mock(testResult: .pending)
		
		let model = ExposureSubmissionTestResultViewModel(
			coronaTestType: .pcr,
			coronaTestService: coronaTestService,
			onSubmissionConsentCellTap: { _ in },
			onContinueWithSymptomsFlowButtonTap: { },
			onContinueWarnOthersButtonTap: { _ in },
			onChangeToPositiveTestResult: { },
			onTestDeleted: { },
			onTestCertificateCellTap: { _, _ in }
		)
		
		XCTAssertFalse(model.shouldShowDeletionConfirmationAlert)
		XCTAssertFalse(model.shouldAttemptToDismiss)
		
		model.didTapSecondaryButton()
		
		XCTAssertTrue(model.shouldShowDeletionConfirmationAlert)
		XCTAssertFalse(model.shouldAttemptToDismiss)
	}
	
	func testDidTapSecondaryButtonOnNegativeInvalidOrExpiredTestResult() {
		let testResults: [TestResult] = [.negative, .invalid, .expired]
		for testResult in testResults {
			let coronaTestService = MockCoronaTestService()
			coronaTestService.pcrTest.value = PCRTest.mock(testResult: testResult)
			
			let model = ExposureSubmissionTestResultViewModel(
				coronaTestType: .pcr,
				coronaTestService: coronaTestService,
				onSubmissionConsentCellTap: { _ in },
				onContinueWithSymptomsFlowButtonTap: { },
				onContinueWarnOthersButtonTap: { _ in },
				onChangeToPositiveTestResult: { },
				onTestDeleted: { },
				onTestCertificateCellTap: { _, _ in }
			)
			
			XCTAssertFalse(model.shouldShowDeletionConfirmationAlert)
			XCTAssertFalse(model.shouldAttemptToDismiss)
			
			model.didTapSecondaryButton()
			
			XCTAssertFalse(model.shouldShowDeletionConfirmationAlert)
			XCTAssertFalse(model.shouldAttemptToDismiss)
		}
	}
	
	func testDeletion() {
		let moveTestToBinExpectation = expectation(description: "moveTestToBin on service is called")

		let coronaTestService = MockCoronaTestService()
		coronaTestService.pcrTest.value = PCRTest.mock(testResult: .expired)
		coronaTestService.onMoveTestToBin = { coronaTestType in
			XCTAssertEqual(coronaTestType, .pcr)

			moveTestToBinExpectation.fulfill()
		}

		let onTestDeletedCalledExpectation = expectation(description: "onTestDeleted closure is called")
		
		let model = ExposureSubmissionTestResultViewModel(
			coronaTestType: .pcr,
			coronaTestService: coronaTestService,
			onSubmissionConsentCellTap: { _ in },
			onContinueWithSymptomsFlowButtonTap: { },
			onContinueWarnOthersButtonTap: { _ in },
			onChangeToPositiveTestResult: { },
			onTestDeleted: {
				onTestDeletedCalledExpectation.fulfill()
			},
			onTestCertificateCellTap: { _, _ in }
		)
		
		model.deleteTest()
		
		waitForExpectations(timeout: .short)
	}
	
	func testNavigationFooterItemForPendingTestResult() throws {
		let coronaTestService = MockCoronaTestService()
		coronaTestService.pcrTest.value = PCRTest.mock(testResult: .pending)

		let model = ExposureSubmissionTestResultViewModel(
			coronaTestType: .pcr,
			coronaTestService: coronaTestService,
			onSubmissionConsentCellTap: { _ in },
			onContinueWithSymptomsFlowButtonTap: { },
			onContinueWarnOthersButtonTap: { _ in },
			onChangeToPositiveTestResult: { },
			onTestDeleted: { },
			onTestCertificateCellTap: { _, _ in }
		)

		let footerViewModel = try XCTUnwrap(model.footerViewModel)

		XCTAssertFalse(footerViewModel.isPrimaryLoading)
		XCTAssertTrue(footerViewModel.isPrimaryButtonEnabled)
		XCTAssertFalse(footerViewModel.isPrimaryButtonHidden)

		XCTAssertFalse(footerViewModel.isSecondaryLoading)
		XCTAssertTrue(footerViewModel.isSecondaryButtonEnabled)
		XCTAssertFalse(footerViewModel.isSecondaryButtonHidden)
	}
	
	func testNavigationFooterItemForPositiveTestResult() throws {
		let coronaTestService = MockCoronaTestService()
		coronaTestService.pcrTest.value = PCRTest.mock(testResult: .positive)

		let model = ExposureSubmissionTestResultViewModel(
			coronaTestType: .pcr,
			coronaTestService: coronaTestService,
			onSubmissionConsentCellTap: { _ in },
			onContinueWithSymptomsFlowButtonTap: { },
			onContinueWarnOthersButtonTap: { _ in },
			onChangeToPositiveTestResult: { },
			onTestDeleted: { },
			onTestCertificateCellTap: { _, _ in }
		)

		let footerViewModel = try XCTUnwrap(model.footerViewModel)

		XCTAssertFalse(footerViewModel.isPrimaryLoading)
		XCTAssertTrue(footerViewModel.isPrimaryButtonEnabled)
		XCTAssertFalse(footerViewModel.isPrimaryButtonHidden)

		XCTAssertFalse(footerViewModel.isSecondaryLoading)
		XCTAssertTrue(footerViewModel.isSecondaryButtonEnabled)
		XCTAssertFalse(footerViewModel.isSecondaryButtonHidden)
	}
	
	func testNavigationFooterItemForNegativeInvalidOrExpiredTestResult() throws {
		let testResults: [TestResult] = [.negative, .invalid, .expired]
		for testResult in testResults {
			let coronaTestService = MockCoronaTestService()
			coronaTestService.pcrTest.value = PCRTest.mock(testResult: testResult)

			let model = ExposureSubmissionTestResultViewModel(
				coronaTestType: .pcr,
				coronaTestService: coronaTestService,
				onSubmissionConsentCellTap: { _ in },
				onContinueWithSymptomsFlowButtonTap: { },
				onContinueWarnOthersButtonTap: { _ in },
				onChangeToPositiveTestResult: { },
				onTestDeleted: { },
				onTestCertificateCellTap: { _, _ in }
			)

			let footerViewModel = try XCTUnwrap(model.footerViewModel)

			XCTAssertFalse(footerViewModel.isPrimaryLoading)
			XCTAssertTrue(footerViewModel.isPrimaryButtonEnabled)
			XCTAssertFalse(footerViewModel.isPrimaryButtonHidden)

			XCTAssertFalse(footerViewModel.isSecondaryLoading)
			XCTAssertFalse(footerViewModel.isSecondaryButtonEnabled)
			XCTAssertTrue(footerViewModel.isSecondaryButtonHidden)
		}
	}
	
	func testDynamicTableViewModelForPositiveTestResult() {
		let coronaTestService = MockCoronaTestService()
		coronaTestService.pcrTest.value = PCRTest.mock(testResult: .positive)
		
		let model = ExposureSubmissionTestResultViewModel(
			coronaTestType: .pcr,
			coronaTestService: coronaTestService,
			onSubmissionConsentCellTap: { _ in },
			onContinueWithSymptomsFlowButtonTap: { },
			onContinueWarnOthersButtonTap: { _ in },
			onChangeToPositiveTestResult: { },
			onTestDeleted: { },
			onTestCertificateCellTap: { _, _ in }
		)
		
		XCTAssertEqual(model.dynamicTableViewModel.numberOfSection, 1)
		XCTAssertNotNil(model.dynamicTableViewModel.section(0).header)
		
		let section = model.dynamicTableViewModel.section(0)
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
	
	func testDynamicTableViewModelForNegativeTestResult() {
		let coronaTestService = MockCoronaTestService()
		coronaTestService.pcrTest.value = PCRTest.mock(testResult: .negative)
		
		let model = ExposureSubmissionTestResultViewModel(
			coronaTestType: .pcr,
			coronaTestService: coronaTestService,
			onSubmissionConsentCellTap: { _ in },
			onContinueWithSymptomsFlowButtonTap: { },
			onContinueWarnOthersButtonTap: { _ in },
			onChangeToPositiveTestResult: { },
			onTestDeleted: { },
			onTestCertificateCellTap: { _, _ in }
		)
		
		XCTAssertEqual(model.dynamicTableViewModel.numberOfSection, 1)
		XCTAssertNotNil(model.dynamicTableViewModel.section(0).header)
		
		let section = model.dynamicTableViewModel.section(0)
		let cells = section.cells
		XCTAssertEqual(cells.count, 10)
		
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
		XCTAssertEqual(id.rawValue, "stepCell")
		
		let sixthItem = cells[5]
		id = sixthItem.cellReuseIdentifier
		XCTAssertEqual(id.rawValue, "labelCell")
		
		let seventhItem = cells[6]
		id = seventhItem.cellReuseIdentifier
		XCTAssertEqual(id.rawValue, "labelCell")
		
		let eigthItem = cells[7]
		id = eigthItem.cellReuseIdentifier
		XCTAssertEqual(id.rawValue, "bulletPointCell")
		
		let ninthItem = cells[8]
		id = ninthItem.cellReuseIdentifier
		XCTAssertEqual(id.rawValue, "bulletPointCell")
		
		let tenthItem = cells[9]
		id = tenthItem.cellReuseIdentifier
		XCTAssertEqual(id.rawValue, "bulletPointCell")
	}
	
	func testDynamicTableViewModelForInvalidTestResult() {
		let coronaTestService = MockCoronaTestService()
		coronaTestService.pcrTest.value = PCRTest.mock(testResult: .invalid)
		
		let model = ExposureSubmissionTestResultViewModel(
			coronaTestType: .pcr,
			coronaTestService: coronaTestService,
			onSubmissionConsentCellTap: { _ in },
			onContinueWithSymptomsFlowButtonTap: { },
			onContinueWarnOthersButtonTap: { _ in },
			onChangeToPositiveTestResult: { },
			onTestDeleted: { },
			onTestCertificateCellTap: { _, _ in }
		)
		
		XCTAssertEqual(model.dynamicTableViewModel.numberOfSection, 1)
		XCTAssertNotNil(model.dynamicTableViewModel.section(0).header)
		
		let section = model.dynamicTableViewModel.section(0)
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
	
	func testDynamicTableViewModelForPendingTestResult() {
		let coronaTestService = MockCoronaTestService()
		coronaTestService.pcrTest.value = PCRTest.mock(testResult: .pending)
		
		let model = ExposureSubmissionTestResultViewModel(
			coronaTestType: .pcr,
			coronaTestService: coronaTestService,
			onSubmissionConsentCellTap: { _ in },
			onContinueWithSymptomsFlowButtonTap: { },
			onContinueWarnOthersButtonTap: { _ in },
			onChangeToPositiveTestResult: { },
			onTestDeleted: { },
			onTestCertificateCellTap: { _, _ in }
		)
		
		XCTAssertEqual(model.dynamicTableViewModel.numberOfSection, 2)
		XCTAssertNotNil(model.dynamicTableViewModel.section(0).header)
		
		let section = model.dynamicTableViewModel.section(0)
		let cells = section.cells
		XCTAssertEqual(cells.count, 5)
		
		let firstItem = cells[0]
		var id = firstItem.cellReuseIdentifier
		XCTAssertEqual(id.rawValue, "labelCell")
		
		let secondItem = cells[1]
		id = secondItem.cellReuseIdentifier
		XCTAssertEqual(id.rawValue, "stepCell")
		
		let thirdItem = cells[2]
		id = thirdItem.cellReuseIdentifier
		XCTAssertEqual(id.rawValue, "stepCell")
		
		let section2 = model.dynamicTableViewModel.section(1)
		let iconCell = section2.cells
		XCTAssertEqual(iconCell.count, 1)
		
		let iconCellFirstItem = iconCell[0]
		let iconId = iconCellFirstItem.cellReuseIdentifier
		XCTAssertEqual(iconId.rawValue, "iconCell")
	}
	
	func testDynamicTableViewModelForExpiredTestResult() {
		let coronaTestService = MockCoronaTestService()
		coronaTestService.pcrTest.value = PCRTest.mock(testResult: .expired)
		
		let model = ExposureSubmissionTestResultViewModel(
			coronaTestType: .pcr,
			coronaTestService: coronaTestService,
			onSubmissionConsentCellTap: { _ in },
			onContinueWithSymptomsFlowButtonTap: { },
			onContinueWarnOthersButtonTap: { _ in },
			onChangeToPositiveTestResult: { },
			onTestDeleted: { },
			onTestCertificateCellTap: { _, _ in }
		)
		
		XCTAssertEqual(model.dynamicTableViewModel.numberOfSection, 1)
		XCTAssertNotNil(model.dynamicTableViewModel.section(0).header)
		
		let section = model.dynamicTableViewModel.section(0)
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
	
}
