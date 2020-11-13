//
// 🦠 Corona-Warn-App
//

import XCTest
@testable import ENA

final class DynamicTypeLabelTests: XCTestCase {
    func testDesignatedInitializer() {
		XCTAssertNotNil(DynamicTypeLabel())
    }

	func testBoldWeight() {
		let sut = DynamicTypeLabel()
		sut.dynamicTypeWeight = "bold"
		// swiftlint:disable:next force_cast
		let traits = sut.font.fontDescriptor.object(forKey: .traits) as! [UIFontDescriptor.TraitKey: AnyObject]
		let weight = traits[.weight] as? NSNumber ?? NSNumber(-1)
		XCTAssertEqual(CGFloat(weight.doubleValue), UIFont.Weight.bold.rawValue, accuracy: 0.001)
	}

	func testSemboldWeight() {
		let sut = DynamicTypeLabel()
		sut.dynamicTypeWeight = "semibold"
		// swiftlint:disable:next force_cast
		let traits = sut.font.fontDescriptor.object(forKey: .traits) as! [UIFontDescriptor.TraitKey: AnyObject]
		let weight = traits[.weight] as? NSNumber ?? NSNumber(-1)
		XCTAssertEqual(CGFloat(weight.doubleValue), UIFont.Weight.semibold.rawValue, accuracy: 0.001)
	}
}
