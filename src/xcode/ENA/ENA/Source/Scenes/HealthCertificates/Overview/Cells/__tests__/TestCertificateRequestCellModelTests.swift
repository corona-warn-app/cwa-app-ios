////
// 🦠 Corona-Warn-App
//

import XCTest
import OpenCombine
@testable import ENA

class TestCertificateRequestCellModelTests: XCTestCase {

	func testGIVEN_TestCertificateRequestCellModel_THEN_IsInitializedCorrect() {
		// GIVEN
		let testCertificateRequest = TestCertificateRequest(
			coronaTestType: .pcr,
			registrationToken: "regToken",
			registrationDate: Date()
		)
		let viewModel = TestCertificateRequestCellModel(testCertificateRequest: testCertificateRequest)

		// THEN
		XCTAssertEqual(viewModel.title, AppStrings.HealthCertificate.Overview.TestCertificateRequest.title)
		XCTAssertEqual(viewModel.subtitle, AppStrings.HealthCertificate.Overview.TestCertificateRequest.loadingSubtitle)
		XCTAssertEqual(viewModel.registrationDate, String(format: AppStrings.HealthCertificate.Overview.TestCertificateRequest.registrationDate, DateFormatter.localizedString(from: testCertificateRequest.registrationDate, dateStyle: .medium, timeStyle: .short)))

		XCTAssertEqual(viewModel.loadingStateDescription, AppStrings.HealthCertificate.Overview.TestCertificateRequest.loadingStateDescription)
		XCTAssertEqual(viewModel.tryAgainButtonTitle, AppStrings.HealthCertificate.Overview.TestCertificateRequest.tryAgainButtonTitle)
		XCTAssertEqual(viewModel.removeButtonTitle, AppStrings.HealthCertificate.Overview.TestCertificateRequest.removeButtonTitle)
		XCTAssertFalse(viewModel.isLoadingStateHidden)
		XCTAssertTrue(viewModel.buttonsHidden)
	}


	func testGIVEN_TestCertificateRequestCellModel_WHEN_UpdateIsLoading_THEN_StatesChanged() {
		// GIVEN
		let testCertificateRequest = TestCertificateRequest(
			coronaTestType: .pcr,
			registrationToken: "regToken",
			registrationDate: Date(),
			isLoading: false
		)
		let viewModel = TestCertificateRequestCellModel(testCertificateRequest: testCertificateRequest)

		XCTAssertTrue(viewModel.isLoadingStateHidden)
		XCTAssertFalse(viewModel.buttonsHidden)
		XCTAssertEqual(viewModel.subtitle, AppStrings.HealthCertificate.Overview.TestCertificateRequest.errorSubtitle)

		// WHEN
		let isLoadingTestCertificateRequest = TestCertificateRequest(
			coronaTestType: .pcr,
			registrationToken: "regToken",
			registrationDate: Date(),
			isLoading: true
		)

		testCertificateRequest.objectDidChange.send(isLoadingTestCertificateRequest)

		// THEN
		XCTAssertFalse(viewModel.isLoadingStateHidden)
		XCTAssertTrue(viewModel.buttonsHidden)
		XCTAssertEqual(viewModel.subtitle, AppStrings.HealthCertificate.Overview.TestCertificateRequest.loadingSubtitle)

	}


}
