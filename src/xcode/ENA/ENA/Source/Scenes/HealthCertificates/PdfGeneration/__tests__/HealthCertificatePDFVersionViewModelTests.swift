//
// 🦠 Corona-Warn-App
//

import XCTest
import HealthCertificateToolkit
import PDFKit
@testable import ENA

class HealthCertificatePDFVersionViewModelTests: XCTestCase {

	func testGIVEN_HealthCertificatePDFGenerationInfoViewModel_WHEN_Created_THEN_ShareTitleIsCorrect() {
		
		// GIVEN
		let healthCertificate = HealthCertificate.mock()
		
		// WHEN
		let viewModel = HealthCertificatePDFVersionViewModel(
			healthCertificate: healthCertificate,
			pdfDocument: PDFDocument()
		)
	
		// THEN
		XCTAssertEqual(viewModel.shareTitle, AppStrings.HealthCertificate.PrintPDF.shareTitle)
	}
	
	func testGIVEN_HealthCertificatePDFGenerationInfoViewModel_WHEN_Created_THEN_PersonNameIsCorrect() throws {
		
		// GIVEN
		let healthCertificate = try HealthCertificate(
			base45: try base45Fake(
					  digitalCovidCertificate: DigitalCovidCertificate.fake(
						  name: Name.fake(
							  familyName: "Duck", givenName: "Donald"
						  )
					  )
				  )
			  )
		
		// WHEN
		let viewModel = HealthCertificatePDFVersionViewModel(
			healthCertificate: healthCertificate,
			pdfDocument: PDFDocument()
		)
	
		// THEN
		XCTAssertEqual(viewModel.certificatePersonName, "Donald Duck")
	}

}
