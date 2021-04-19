////
// 🦠 Corona-Warn-App
//

import XCTest
@testable import ENA

class Sequence_NSAttributedTextTests: XCTestCase {

	func testGIVEN_sequenceOfAttrigbutedString_WHEN_joined_THEN_ANewAttributesStringGetsCreted() {
		// GIVEN
		let leftAttributedString = NSAttributedString(string: "left")
		let rightAttributedString = NSAttributedString(string: "right")
		let sequence = [leftAttributedString, rightAttributedString]

		// WHEN
		let joinedWithSeparatorAttributedString = sequence.joined(with: ",")
		let joinedWithoutSeparatorAttributedString = sequence.joined()

		// THEN
		XCTAssertEqual(NSAttributedString(string: "left,right"), joinedWithSeparatorAttributedString)
		XCTAssertEqual(NSAttributedString(string: "leftright"), joinedWithoutSeparatorAttributedString)
	}

}
