//
// 🦠 Corona-Warn-App
//

import Foundation
import PDFKit
import OpenCombine

class TraceLocationPrintVersionViewModel {

	// MARK: - Init

	init(
		pdfView: PDFView
	) {
		self.pdfView = pdfView
	}

	// MARK: - Internal

	let pdfView: PDFView

}
