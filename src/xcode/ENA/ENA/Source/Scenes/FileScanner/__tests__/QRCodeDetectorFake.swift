//
// 🦠 Corona-Warn-App
//

import UIKit
@testable import ENA

class QRCodeDetectorFake: QRCodeDetecting {

	// MARK: - Init
	init(_ result: String? = nil) {
		guard let result = result else {
			self.fakeResult = nil
			return
		}
		self.fakeResult = [result]
	}

	// MARK: - Overrides

	// MARK: - Protocol QRCodeDetector

	func findQRCodes(in image: UIImage) -> [String]? {
		return fakeResult
	}

	// MARK: - Public

	// MARK: - Internal

	// MARK: - Private
	private let fakeResult: [String]?

}
