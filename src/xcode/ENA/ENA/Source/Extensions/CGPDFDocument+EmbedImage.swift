////
// 🦠 Corona-Warn-App
//

import PDFKit
import UIKit

enum PDFEmbeddingError: Error {
	case noPage
	case noGraphicsContext
	case cgImageCreationFailed
	case pdfDocumentCreationFailed
}

struct PDFText {

	// MARK: - Init

	init(
		text: String,
		size: CGFloat = 10,
		color: UIColor,
		font: UIFont? = nil,
		rect: CGRect,
		upsideDown: Bool = false
	) {
		self.text = text
		self.size = size
		self.color = color
		self.font = font ?? UIFont.preferredFont(forTextStyle: .body).scaledFont(size: size, weight: .regular)
		self.rect = rect
		self.upsideDown = upsideDown
	}

	// MARK: - Internal

	let text: String
	let size: CGFloat
	let color: UIColor
	let font: UIFont
	let rect: CGRect
	let upsideDown: Bool
}

private extension BinaryInteger {
	var degreesToRadians: CGFloat { CGFloat(self) * .pi / 180 }
}

private extension String {

	func drawUpsideDown(in rect: CGRect, withAttributes attributes: [NSAttributedString.Key: Any]) {
		guard let ctx = UIGraphicsGetCurrentContext() else { return }
		ctx.saveGState()
		defer { ctx.restoreGState() }

		ctx.translateBy(x: rect.origin.x + rect.size.width / 2, y: rect.origin.y + rect.size.height / 2)
		ctx.rotate(by: 180.degreesToRadians)
		ctx.translateBy(x: -rect.size.width / 2, y: -rect.size.height / 2)

		self.draw(in: CGRect(origin: .zero, size: rect.size), withAttributes: attributes)
	}

}

extension CGPDFDocument {

	func pdfDocumentEmbeddingImageAndText(
		image: CIImage,
		at imageRect: CGRect,
		texts: [PDFText]
	) throws -> PDFDocument {
		// Pages are numbered starting from 1.
		// Access the `CGPDFPage` object with the original contents.
		guard let page = page(at: 1) else {
			throw PDFEmbeddingError.noPage	// No Pages so we cant insert anything
		}

		let data = NSMutableData()
		UIGraphicsBeginPDFContextToData(data, page.getBoxRect(.mediaBox), nil)

		guard let pdfContext = UIGraphicsGetCurrentContext() else {
			throw PDFEmbeddingError.noGraphicsContext
		}

		let pageSize = UIGraphicsGetPDFContextBounds().size

		// Mark the beginning of the page.
		pdfContext.beginPDFPage(nil)

		// Draw the existing page contents.
		pdfContext.drawPDFPage(page)

		// Save the context state to restore after we are done drawing the image.
		pdfContext.saveGState()

		// Change the PDF context to match the UIKit coordinate system.
		pdfContext.translateBy(x: 0, y: pageSize.height)
		pdfContext.scaleBy(x: 1, y: -1)

		// Because the coordinate system is now upside-down, we revert this only for the image.
		let flippedImage = image.transformed(by: CGAffineTransform(scaleX: 1, y: -1))
		
		// `CGRect` for the image.
		guard let cgImage = CIContext(options: nil).createCGImage(flippedImage, from: flippedImage.extent) else {
			throw PDFEmbeddingError.cgImageCreationFailed
		}

		pdfContext.interpolationQuality = .none
		pdfContext.draw(cgImage, in: imageRect)

		for pdfText in texts {
			let textFontAttributes: [NSAttributedString.Key: Any] = [
				NSAttributedString.Key.font: pdfText.font,
				NSAttributedString.Key.foregroundColor: pdfText.color
			]

			// Draw text onto the context
			if pdfText.upsideDown {
				pdfText.text.drawUpsideDown(in: pdfText.rect, withAttributes: textFontAttributes)
			} else {
				pdfText.text.draw(in: pdfText.rect, withAttributes: textFontAttributes)
			}
		}

		// Restoring the context back to its original state.
		pdfContext.restoreGState()

		// Mark the end of the current page.
		pdfContext.endPDFPage()

		// End the PDF context, essentially closing the PDF document context.
		UIGraphicsEndPDFContext()
		
		// Somehow iOS 12 does not like initialising 'PDFDocument' directly from data so we have to save the data to disk just to read it again into a PDFDocument
		let temporaryDirectoryURL = URL(
			fileURLWithPath: NSTemporaryDirectory(),
			isDirectory: true
		)
		let temporaryFilename = ProcessInfo().globallyUniqueString
		let temporaryFileURL = temporaryDirectoryURL.appendingPathComponent(temporaryFilename)
		
		do {
			try data.write(to: temporaryFileURL)
		} catch {
			throw PDFEmbeddingError.pdfDocumentCreationFailed
		}
				
		guard let pdfDocument = PDFDocument(url: temporaryFileURL) else {
			throw PDFEmbeddingError.pdfDocumentCreationFailed
		}
		
		// Even though we save to a temp folder its nicer to remove the document explicitly
		try FileManager.default.removeItem(at: temporaryFileURL)
		
		return pdfDocument
	}

}
