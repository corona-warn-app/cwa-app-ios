////
// 🦠 Corona-Warn-App
//

import XCTest
import PDFKit
@testable import ENA

class CGPDFDocument_EmbedImageTests: CWATestCase {
	
	// swiftlint:disable force_unwrapping
	/// Not proud of this test, if you have a nicer idea, please go ahead.
    func testEmbeddingImageAndText() throws {
		let testBundle = Bundle(for: type(of: self))
		
		let documentURL = testBundle.url(forResource: "qr-code-print-template", withExtension: "pdf")!
		let documentData = FileManager.default.contents(atPath: documentURL.path)!
		let dataProvider = CGDataProvider(data: documentData as CFData)!
		let pdfDocument = CGPDFDocument(dataProvider)!
				
		let image = CIImage(contentsOf: testBundle.url(forResource: "qr-code-to-embed", withExtension: "png")!)
		
		let descriptionText = PDFText(text: "Event title <Insert Phun here>", size: 10, color: .black, rect: CGRect(x: 80, y: 510, width: 400, height: 15))
		let adressText = PDFText(text: "Hauptstr 3, 69115 Heidelberg", size: 10, color: .black, rect: CGRect(x: 80, y: 525, width: 400, height: 15))
		
		
		_ = try pdfDocument.pdfDocumentEmbeddingImageAndText(image: image!, at: CGRect(x: 100, y: 100, width: 400, height: 400), texts: [descriptionText, adressText])
    }
	// swiftlint:enable force_unwrapping

}
