//
// 🦠 Corona-Warn-App
//

import XCTest
@testable import ENA

final class UIFont_DynamicTypeTests: XCTestCase {
    func testWeightFromString() {
		XCTAssertEqual(UIFont.Weight("ultraLight").rawValue, UIFont.Weight.ultraLight.rawValue, accuracy: .high)
		XCTAssertEqual(UIFont.Weight("thin").rawValue, UIFont.Weight.thin.rawValue, accuracy: .high)
		XCTAssertEqual(UIFont.Weight("light").rawValue, UIFont.Weight.light.rawValue, accuracy: .high)
		XCTAssertEqual(UIFont.Weight("regular").rawValue, UIFont.Weight.regular.rawValue, accuracy: .high)
		XCTAssertEqual(UIFont.Weight("medium").rawValue, UIFont.Weight.medium.rawValue, accuracy: .high)
		XCTAssertEqual(UIFont.Weight("semibold").rawValue, UIFont.Weight.semibold.rawValue, accuracy: .high)
		XCTAssertEqual(UIFont.Weight("bold").rawValue, UIFont.Weight.bold.rawValue, accuracy: .high)
		XCTAssertEqual(UIFont.Weight("heavy").rawValue, UIFont.Weight.heavy.rawValue, accuracy: .high)
		XCTAssertEqual(UIFont.Weight("black").rawValue, UIFont.Weight.black.rawValue, accuracy: .high)
		XCTAssertEqual(UIFont.Weight(nil).rawValue, UIFont.Weight.regular.rawValue, accuracy: .high)
	}
}

private extension CGFloat {
	static let high: CGFloat = 0.01
}
