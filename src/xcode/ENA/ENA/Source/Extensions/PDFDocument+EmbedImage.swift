////
// 🦠 Corona-Warn-App
//

import PDFKit
import UIKit

enum PDFEmbeddingError: Error {
	case noPage // PDF does not contain a Page where the Image could be embedded
	case pageCreation // Could not create a new Page containing the image
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

extension PDFDocument {
	
	/// Embeds image and text on the first Page on given position
	/// Inspired  by https://pspdfkit.com/blog/2019/insert-image-into-pdf-with-swift/
	func embedImageAndText(image: UIImage, at position: CGPoint, texts: [PDFText]) throws {
		
		// `page` is of type `PDFPage`.
		guard let page = page(at: 0) else {
			throw PDFEmbeddingError.noPage	// No Pages so we cant insert anything
		}
		
		// Extract the crop box of the PDF. We need this to create an appropriate graphics context.
		let bounds = page.bounds(for: .cropBox)
		
		// Create a `UIGraphicsImageRenderer` to use for drawing an image.
		let renderer = UIGraphicsImageRenderer(bounds: bounds, format: .default())
		
		// This method returns an image and takes a block in which you can perform any kind of drawing.
		let image = renderer.image { context in
			// We transform the CTM to match the PDF's coordinate system, but only long enough to draw the page.
			context.cgContext.saveGState()
			
			context.cgContext.translateBy(x: 0, y: bounds.height)
			context.cgContext.concatenate(CGAffineTransform(scaleX: 1, y: -1))
			page.draw(with: .mediaBox, to: context.cgContext)
			
			context.cgContext.restoreGState()
			
			// `CGRect` for the image.
			let imageRect = CGRect(x: position.x, y: position.y, width: image.size.width, height: image.size.height)
			
			// Draw your image onto the context.
			image.draw(in: imageRect)
			
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
			
		}
		
		// Create a new `PDFPage` with the image that was generated above.
		guard let newPage = PDFPage(image: image) else {
			// Unable to create new PDFPage
			throw PDFEmbeddingError.pageCreation
		}
		
		// Add the existing annotations from the existing page to the new page we created.
		for annotation in page.annotations {
			newPage.addAnnotation(annotation)
		}
		
		// Insert the newly created page at the position of the original page.
		insert(newPage, at: 0)
		
		// Remove the original page.
		removePage(at: 1)
	}
}
