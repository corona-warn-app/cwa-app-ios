//
// 🦠 Corona-Warn-App
//

import XCTest
import PDFKit
@testable import ENA

class FileManager_TemporaryDirectoryTests: CWATestCase {
	
	func testPDFRemoval() throws {
		// removing all previous files
		let temporaryDirectoryURL = FileManager.default.temporaryDirectory
		let temporaryDirectory = try FileManager.default.contentsOfDirectory(atPath: temporaryDirectoryURL.path)
		try temporaryDirectory.forEach { file in
			let fileUrl = temporaryDirectoryURL.appendingPathComponent(file)
			try FileManager.default.removeItem(atPath: fileUrl.path)
		}
		
		// creating a dummy pdf document
		let format = UIGraphicsPDFRendererFormat()
		let metaData = [
			kCGPDFContextTitle: "Hello, World!",
			kCGPDFContextAuthor: "Naveed Khalid"
		  ]
		format.documentInfo = metaData as [String: Any]
		
		let pageRect = CGRect(x: 0, y: 0, width: 595, height: 842)
		let renderer = UIGraphicsPDFRenderer(bounds: pageRect, format: format)
		let data = renderer.pdfData { context in
		  context.beginPage()
		  
		  let paragraphStyle = NSMutableParagraphStyle()
		  paragraphStyle.alignment = .center
		  let attributes = [
			NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 14),
			NSAttributedString.Key.paragraphStyle: paragraphStyle
		  ]
		  let text = "Hello, World!"
		  let textRect = CGRect(x: 100, y: 100, width: 200, height: 20)

		  text.draw(in: textRect, withAttributes: attributes)
		}
		
		// naming the pdf file and writing the content
		let pdfFileName = "healthCertificates.pdf"
		let pdfFileURL = temporaryDirectoryURL.appendingPathComponent(pdfFileName)
		
		do {
			try data.write(to: pdfFileURL)
		} catch {
			XCTFail("Could not write content to pdf file")
		}
		
		var updatedTemporaryDirectory = try FileManager.default.contentsOfDirectory(atPath: temporaryDirectoryURL.path)
		XCTAssertEqual(updatedTemporaryDirectory.count, 1)
		
		// removing all pdf documents
		FileManager.default.removePDFsFromTemporaryDirectory()
		
		updatedTemporaryDirectory = try FileManager.default.contentsOfDirectory(atPath: temporaryDirectoryURL.path)
		XCTAssertEqual(updatedTemporaryDirectory.count, 0)
	}
	
}
