//
// 🦠 Corona-Warn-App
//

import XCTest
import PDFKit
@testable import ENA

class FileManager_TemporaryDirectoryTests: CWATestCase {
	
	func testPDFRemoval() throws {
		let pdfView = PDFView()
		guard let data = pdfView.document?.dataRepresentation() else {
			XCTFail("Could not create data representation of pdf to print")
			return
		}

		let temporaryFolder = FileManager.default.temporaryDirectory
		let pdfFileName = "healthCertificates.pdf"
		let pdfFileURL = temporaryFolder.appendingPathComponent(pdfFileName)
		
		do {
			try data.write(to: pdfFileURL)
		} catch {
			XCTFail("Could not write the template data to the pdf file")
		}
		
		XCTAssertEqual(temporaryFolder.pathComponents.count, 1)
		
		FileManager.default.removePDFsFromTemporaryDirectory()
		
		XCTAssertEqual(temporaryFolder.pathComponents.count, 0)
	}
	
}
