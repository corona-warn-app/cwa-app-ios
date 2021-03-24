////
// 🦠 Corona-Warn-App
//

import PDFKit
import UIKit

enum PDFEmbeddingError: Error {
	case noPage // PDF does not contain a Page where the Image could be embedded
	case pageCreation // Could not create a new Page containing the image
}

extension PDFDocument {
	
	/// Embeds image and text on the first Page on given position
	/// Inspired  by https://pspdfkit.com/blog/2019/insert-image-into-pdf-with-swift/
	func embedImageAndText(image: UIImage, at position: CGPoint, text: String, of textSize: CGFloat?, and textColor: UIColor, with textRect: CGRect) throws {
		
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
			
			// Set the font as per the font size provided
			let font = UIFont.preferredFont(forTextStyle: .body).scaledFont(size: textSize, weight: .regular)

			let textFontAttributes: [NSAttributedString.Key: Any] = [
				NSAttributedString.Key.font: font,
				NSAttributedString.Key.foregroundColor: textColor
			]
			
			// Draw text onto the context
			text.draw(in: textRect, withAttributes: textFontAttributes)
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
