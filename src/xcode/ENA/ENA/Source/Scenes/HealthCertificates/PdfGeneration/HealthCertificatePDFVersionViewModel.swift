//
// 🦠 Corona-Warn-App
//

import Foundation
import PDFKit
import OpenCombine

class HealthCertificatePDFVersionViewModel {

	// MARK: - Init

	init(
		pdfView: PDFView
	) {
		self.pdfView = pdfView
	}

	// MARK: - Internal

	let pdfView: PDFView

	var shareTitle: String {
		return ""
	}
}
