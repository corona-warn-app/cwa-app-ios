////
// 🦠 Corona-Warn-App
//

import XCTest
import PDFKit
@testable import ENA

class PDFDocument_EmbedImageTests: XCTestCase {
	
	// swiftlint:disable force_unwrapping
	/// Not proud of this test, if you have a nicer idea, please go ahead.
    func testEmbedingImage() throws {

		let testBundle = Bundle(for: type(of: self))
		
		let documentURL = testBundle.url(forResource: "qr-code-print-template", withExtension: "pdf")!
			
		let pdfDocument = PDFDocument(url: documentURL)!
				
		let image = UIImage(contentsOfFile: testBundle.path(forResource: "qr-code-to-embed", ofType: "png")!)
		
		// try pdfDocument.embed(image: image!, at: CGPoint(x: 100, y: 100))
    }
	// swiftlint:enable force_unwrapping

}
