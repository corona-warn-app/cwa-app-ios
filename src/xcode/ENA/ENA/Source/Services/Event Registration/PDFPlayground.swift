////
// 🦠 Corona-Warn-App
//

import UIKit
import PDFKit


enum PDFPlayground {
	static func generatePDF(with image: UIImage, on position: CGRect) -> URL {
		
		/// https://pspdfkit.com/blog/2019/insert-image-into-pdf-with-swift/
		let documentURL = Bundle.main.url(forResource: "qr-code-print-template", withExtension: "pdf")!
		
		// Create a `PDFDocument` object using the URL.
		let pdfDocument = PDFDocument(url: documentURL)!

		// `page` is of type `PDFPage`.
		let page = pdfDocument.page(at: 0)!

		 // Extract the crop box of the PDF. We need this to create an appropriate graphics context.
		let bounds = page.bounds(for: .cropBox)

		// Create a `UIGraphicsImageRenderer` to use for drawing an image.
		let renderer = UIGraphicsImageRenderer(bounds: bounds, format: UIGraphicsImageRendererFormat.default())

		// This method returns an image and takes a block in which you can perform any kind of drawing.
		let image = renderer.image { (context) in
			// We transform the CTM to match the PDF's coordinate system, but only long enough to draw the page.
			context.cgContext.saveGState()

			context.cgContext.translateBy(x: 0, y: bounds.height)
			context.cgContext.concatenate(CGAffineTransform.init(scaleX: 1, y: -1))
			page.draw(with: .mediaBox, to: context.cgContext)

			context.cgContext.restoreGState()

			let myImage = image // A `UIImage` object of the image you want to draw.

			let imageRect = position // `CGRect` for the image.

			// Draw your image onto the context.
			myImage.draw(in: imageRect)
		}

		// Create a new `PDFPage` with the image that was generated above.
		let newPage = PDFPage(image: image)!

		// Add the existing annotations from the existing page to the new page we created.
		for annotation in page.annotations {
			newPage.addAnnotation(annotation)
		}

		// Insert the newly created page at the position of the original page.
		pdfDocument.insert(newPage, at: 0)

		// Remove the original page.
		pdfDocument.removePage(at: 1)

		
		let destinationURL = URL(string: "/")

		let temporaryDirectoryURL = FileManager.default.temporaryDirectory

		let temporaryFilename = ProcessInfo().globallyUniqueString + ".pdf"

		let temporaryFileURL =
			temporaryDirectoryURL.appendingPathComponent(temporaryFilename)
		
		
		let saveURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent(temporaryFilename)
		
		// Save the document changes.
		pdfDocument.write(to: saveURL)
		print(saveURL)
		return saveURL
	}
}
