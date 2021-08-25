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
			pdfView: PDFView()
		)
	
		// THEN
		XCTAssertEqual(viewModel.shareTitle, AppStrings.HealthCertificate.PrintPDF.shareTitle)
	}
	
	func testGIVEN_HealthCertificatePDFGenerationInfoViewModel_WHEN_Created_THEN_PersonNameIsCorrect() throws {
		
		// GIVEN
		let healthCertificate = try HealthCertificate(
			base45: try base45Fake(
					  from: DigitalCovidCertificate.fake(
						  name: Name.fake(
							  familyName: "Duck", givenName: "Donald"
						  ),
						  vaccinationEntries: [
							  VaccinationEntry.fake(
								  vaccineMedicinalProduct: "EU/1/11/9999",
								  doseNumber: 1,
								  totalSeriesOfDoses: 1,
								  dateOfVaccination: "2021-08-25"
							  )
						  ]
					  )
				  )
			  )
		
		// WHEN
		let viewModel = HealthCertificatePDFVersionViewModel(
			healthCertificate: healthCertificate,
			pdfView: PDFView()
		)
	
		// THEN
		XCTAssertEqual(viewModel.certificatePersonName, "Donald Duck")
	}

}
