//
// 🦠 Corona-Warn-App
//


import XCTest
import ExposureNotification
@testable import ENA

class ENARangeTest: XCTestCase {

	func testGIVEN_RangeMinAndMaxInclusive_WHEN_CheckingContainedIntValues_THEN_CheckIsCorrect() {
		// GIVEN
		let range = ENARange(min: 0, max: 1)

		// WHEN
		let containsMinusOne = range.contains(-1)
		let containsZero = range.contains(0)
		let containsOne = range.contains(UInt8(1))
		let containsTwo = range.contains(2)

		// THEN
		XCTAssertFalse(containsMinusOne)
		XCTAssertTrue(containsZero)
		XCTAssertTrue(containsOne)
		XCTAssertFalse(containsTwo)
	}

	func testGIVEN_RangeMinExclusiveAndMaxInclusive_WHEN_CheckingContainedIntValues_THEN_CheckIsCorrect() {
		// GIVEN
		let range = ENARange(min: 0, max: 1, minExclusive: true)

		// WHEN
		let containsMinusOne = range.contains(-1)
		let containsZero = range.contains(0)
		let containsOne = range.contains(1)
		let containsTwo = range.contains(2)

		// THEN
		XCTAssertFalse(containsMinusOne)
		XCTAssertFalse(containsZero)
		XCTAssertTrue(containsOne)
		XCTAssertFalse(containsTwo)
	}

	func testGIVEN_RangeMinInclusiveAndMaxExclusive_WHEN_CheckingContainedIntValues_THEN_CheckIsCorrect() {
		// GIVEN
		let range = ENARange(min: 0, max: 1, maxExclusive: true)

		// WHEN
		let containsMinusOne = range.contains(-1)
		let containsZero = range.contains(0)
		let containsOne = range.contains(1)
		let containsTwo = range.contains(2)

		// THEN
		XCTAssertFalse(containsMinusOne)
		XCTAssertTrue(containsZero)
		XCTAssertFalse(containsOne)
		XCTAssertFalse(containsTwo)
	}

	func testGIVEN_RangeMinExclusiveAndMaxExclusive_WHEN_CheckingContainedIntValues_THEN_CheckIsCorrect() {
		// GIVEN
		let range = ENARange(min: 0, max: 1, minExclusive: true, maxExclusive: true)

		// WHEN
		let containsMinusOne = range.contains(-1)
		let containsZero = range.contains(UInt8(0))
		let containsOne = range.contains(1)
		let containsTwo = range.contains(2)

		// THEN
		XCTAssertFalse(containsMinusOne)
		XCTAssertFalse(containsZero)
		XCTAssertFalse(containsOne)
		XCTAssertFalse(containsTwo)
	}

	func testGIVEN_RangeMinAndMaxInclusive_WHEN_CheckingContainedDoubleValues_THEN_CheckIsCorrect() {
		// GIVEN
		let range = ENARange(min: 0, max: 1)

		// WHEN
		let containsMinusOne = range.contains(-1.0)
		let containsZero = range.contains(0.0)
		let containsPoint1 = range.contains(0.1)
		let containsPoint9 = range.contains(0.9)
		let containsOne = range.contains(UInt8(1.0))
		let containsTwo = range.contains(2.0)

		// THEN
		XCTAssertFalse(containsMinusOne)
		XCTAssertTrue(containsZero)
		XCTAssertTrue(containsPoint1)
		XCTAssertTrue(containsPoint9)
		XCTAssertTrue(containsOne)
		XCTAssertFalse(containsTwo)
	}

	func testGIVEN_RangeMinExclusiveAndMaxInclusive_WHEN_CheckingContainedDoubleValues_THEN_CheckIsCorrect() {
		// GIVEN
		let range = ENARange(min: 0, max: 1, minExclusive: true)

		// WHEN
		let containsMinusOne = range.contains(-1.0)
		let containsZero = range.contains(0.0)
		let containsPoint1 = range.contains(0.1)
		let containsPoint9 = range.contains(0.9)
		let containsOne = range.contains(UInt8(1.0))
		let containsTwo = range.contains(2.0)

		// THEN
		XCTAssertFalse(containsMinusOne)
		XCTAssertFalse(containsZero)
		XCTAssertTrue(containsPoint1)
		XCTAssertTrue(containsPoint9)
		XCTAssertTrue(containsOne)
		XCTAssertFalse(containsTwo)
	}

	func testGIVEN_RangeMinInclusiveAndMaxExclusive_WHEN_CheckingContainedDoubleValues_THEN_CheckIsCorrect() {
		// GIVEN
		let range = ENARange(min: 0, max: 1, maxExclusive: true)

		// WHEN
		let containsMinusOne = range.contains(-1.0)
		let containsZero = range.contains(0.0)
		let containsPoint1 = range.contains(0.1)
		let containsPoint9 = range.contains(0.9)
		let containsOne = range.contains(UInt8(1.0))
		let containsTwo = range.contains(2.0)

		// THEN
		XCTAssertFalse(containsMinusOne)
		XCTAssertTrue(containsZero)
		XCTAssertTrue(containsPoint1)
		XCTAssertTrue(containsPoint9)
		XCTAssertFalse(containsOne)
		XCTAssertFalse(containsTwo)
	}

	func testGIVEN_RangeMinExclusiveAndMaxExclusive_WHEN_CheckingContainedDoubleValues_THEN_CheckIsCorrect() {
		// GIVEN
		let range = ENARange(min: 0, max: 1, minExclusive: true, maxExclusive: true)

		// WHEN
		let containsMinusOne = range.contains(-1.0)
		let containsZero = range.contains(0.0)
		let containsPoint1 = range.contains(0.1)
		let containsPoint9 = range.contains(0.9)
		let containsOne = range.contains(UInt8(1.0))
		let containsTwo = range.contains(2.0)

		// THEN
		XCTAssertFalse(containsMinusOne)
		XCTAssertFalse(containsZero)
		XCTAssertTrue(containsPoint1)
		XCTAssertTrue(containsPoint9)
		XCTAssertFalse(containsOne)
		XCTAssertFalse(containsTwo)
	}

}

private extension ENARange {

	init(min: Double, max: Double, minExclusive: Bool = false, maxExclusive: Bool = false) {
		var sapRange = SAP_Internal_V2_Range()

		sapRange.min = min
		sapRange.max = max
		sapRange.minExclusive = minExclusive
		sapRange.maxExclusive = maxExclusive

		self.init(from: sapRange)
	}

}
