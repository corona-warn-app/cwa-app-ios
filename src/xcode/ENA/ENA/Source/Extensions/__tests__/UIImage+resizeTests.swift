////
// 🦠 Corona-Warn-App
//

import XCTest
import UIKit
@testable import ENA

class UIImage_resizeTests: XCTestCase {

	func testGIVEN_SquareImage_WHEN_Resize_THEN_AspectRatioGetsRespected() {
		// GIVEN
		let squareImage = UIImage.image(with: CGSize(width: 10, height: 10))

		// WHEN
		let resizedImage = squareImage.resize(with: CGSize(width: 5, height: 2))

		// THEN
		XCTAssertEqual(CGSize(width: 5, height: 2), resizedImage.size)
	}
}

/// Helper to create an image of specific size
private extension UIImage {

	static func image(with size: CGSize) -> UIImage {
		UIGraphicsImageRenderer(size: size)
			.image { $0.fill(CGRect(origin: .zero, size: size)) }
	}
}
