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
		pdfView: PDFView
	) {
		self.healthCertificate = healthCertificate
		self.pdfView = pdfView
	}

	// MARK: - Internal

	let healthCertificate: HealthCertificate
	let pdfView: PDFView

	var certificatePersonName: String {
		return healthCertificate.name.fullName
	}
	
	var shareTitle: String {
		return AppStrings.HealthCertificate.PrintPDF.shareTitle
	}
}
