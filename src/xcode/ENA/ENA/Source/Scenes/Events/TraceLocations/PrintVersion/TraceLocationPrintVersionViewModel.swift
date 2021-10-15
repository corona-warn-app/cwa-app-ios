//
// 🦠 Corona-Warn-App
//

import Foundation
import PDFKit
import OpenCombine

class TraceLocationPrintVersionViewModel {

	// MARK: - Init

	init(
		pdfView: PDFView,
		traceLocation: TraceLocation
	) {
		self.pdfView = pdfView
		self.traceLocation = traceLocation
	}

	// MARK: - Internal

	let pdfView: PDFView
	let traceLocation: TraceLocation

	var shareTitle: String {
		return traceLocation.description
	}
}
