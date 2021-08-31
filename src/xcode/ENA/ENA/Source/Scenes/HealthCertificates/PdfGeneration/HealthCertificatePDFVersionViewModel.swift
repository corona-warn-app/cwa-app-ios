//
// 🦠 Corona-Warn-App
//

import Foundation
import PDFKit
import OpenCombine

class HealthCertificatePDFVersionViewModel {

	// MARK: - Init

	init(
		healthCertificate: HealthCertificate,
		pdfDocument: PDFDocument
	) {
		self.healthCertificate = healthCertificate
		self.pdfDocument = pdfDocument
	}

	// MARK: - Internal

	let healthCertificate: HealthCertificate
	let pdfDocument: PDFDocument

	var certificatePersonName: String {
		return healthCertificate.name.fullName
	}
	
	var shareTitle: String {
		return AppStrings.HealthCertificate.PrintPDF.shareTitle
	}
}
