//
// 🦠 Corona-Warn-App
//

import XCTest
import HealthCertificateToolkit
import PDFKit
@testable import ENA

class HealthCertificatePDFGenerationInfoViewModelTests: CWATestCase {

	func testGIVEN_HealthCertificatePDFGenerationInfoViewModel_WHEN_Created_THEN_SectionsAreCorrect() {
		// GIVEN
		
		let healthCertificate = HealthCertificate.mock()
		let vaccinationValueSetsProvider = VaccinationValueSetsProvider(
			client: CachingHTTPClientMock(),
			store: MockTestStore()
		)
		
		// WHEN
		let viewModel = HealthCertificatePDFGenerationInfoViewModel(
			healthCertificate: healthCertificate,
			vaccinationValueSetsProvider: vaccinationValueSetsProvider
		)
	
		// THEN
		XCTAssertEqual(viewModel.dynamicTableViewModel.numberOfSection, 1)
	}
	
	func testGIVEN_HealthCertificatePDFGenerationInfoViewModel_WHEN_Created_THEN_TitleIsCorrect() {
		// GIVEN
		
		let healthCertificate = HealthCertificate.mock()
		let vaccinationValueSetsProvider = VaccinationValueSetsProvider(
			client: CachingHTTPClientMock(),
			store: MockTestStore()
		)
		
		// WHEN
		let viewModel = HealthCertificatePDFGenerationInfoViewModel(
			healthCertificate: healthCertificate,
			vaccinationValueSetsProvider: vaccinationValueSetsProvider
		)
	
		// THEN
		XCTAssertEqual(viewModel.title, AppStrings.HealthCertificate.PrintPDF.Info.title)
	}
	
	func testGIVEN_HealthCertificatePDFGenerationInfoViewModel_WHEN_generatePDFDataIsCalled_THEN_PDFViewIsReturned() {
		// GIVEN
	
		let healthCertificate = HealthCertificate.mock()
		let vaccinationValueSetsProvider = VaccinationValueSetsProvider(
			client: CachingHTTPClientMock(),
			store: MockTestStore()
		)
		
		let viewModel = HealthCertificatePDFGenerationInfoViewModel(
			healthCertificate: healthCertificate,
			vaccinationValueSetsProvider: vaccinationValueSetsProvider
		)
		let expectation = self.expectation(description: "Test should succeed")

		var pdfViewResult: PDFView?
		
		// WHEN
		viewModel.generatePDFData(completion: { pdfView in
			pdfViewResult = pdfView
			expectation.fulfill()
		})
	
		// THEN
		waitForExpectations(timeout: .short)
		XCTAssertNotNil(pdfViewResult)
	}
}
