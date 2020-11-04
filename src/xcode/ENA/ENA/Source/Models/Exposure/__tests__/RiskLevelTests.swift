@testable import ENA
import Foundation
import XCTest

/// Tests comparing of the `RiskLevel` enum
final class RiskLevelTests: XCTestCase {

	/*
	RiskLevels are ordered according to these rules:
	1. .low is least
	2. .inactive is highest
	3. .increased overrides .unknownInitial & .low
	4. .unknownOutdated overrides .low AND .increased
	5. .unknownInitial overrides .low AND .unknownOutdated
	
	Generally, comparing raw values of the below enum is sufficient to ensure the correct hierarchy, but there is one exception:
	.unknownOutdated should override .increased - in order to ensure that the user always updates the exposure detection.
	*/

	func testRiskLevelCompareLow() {
		// swiftlint:disable:next identical_operands
		XCTAssertFalse(RiskLevel.low < RiskLevel.low)
		
		XCTAssert(RiskLevel.low < RiskLevel.unknownOutdated)
		XCTAssert(RiskLevel.low < RiskLevel.unknownInitial)
		XCTAssert(RiskLevel.low < RiskLevel.increased)
		XCTAssert(RiskLevel.low < RiskLevel.inactive)
		
		// Probably redundant tests...
		XCTAssertFalse(RiskLevel.low > RiskLevel.unknownOutdated)
		XCTAssertFalse(RiskLevel.low > RiskLevel.unknownInitial)
		XCTAssertFalse(RiskLevel.low > RiskLevel.increased)
		XCTAssertFalse(RiskLevel.low > RiskLevel.inactive)
	}

	func testRiskLevelCompareUnknownOutdated() {
		// swiftlint:disable:next identical_operands
		XCTAssertFalse(RiskLevel.unknownOutdated < RiskLevel.unknownOutdated)
		XCTAssert(RiskLevel.unknownOutdated > RiskLevel.low)
		XCTAssert(RiskLevel.unknownOutdated < RiskLevel.unknownInitial)
		XCTAssert(RiskLevel.unknownOutdated < RiskLevel.inactive)
		XCTAssert(RiskLevel.unknownOutdated < RiskLevel.increased)
	}

	func testRiskLevelCompareUnknownInitial() {
		XCTAssertFalse(RiskLevel.unknownInitial < RiskLevel.low)
		XCTAssertFalse(RiskLevel.unknownInitial < RiskLevel.unknownOutdated)
		// swiftlint:disable:next identical_operands
		XCTAssertFalse(RiskLevel.unknownInitial < RiskLevel.unknownInitial)
		XCTAssert(RiskLevel.unknownInitial < RiskLevel.increased)
		XCTAssert(RiskLevel.unknownInitial < RiskLevel.inactive)
	}

	func testRiskLevelCompareIncreased() {
		// swiftlint:disable:next identical_operands
		XCTAssertFalse(RiskLevel.increased < RiskLevel.increased)
		XCTAssert(RiskLevel.increased > RiskLevel.low)
		XCTAssert(RiskLevel.increased > RiskLevel.unknownInitial)
		XCTAssert(RiskLevel.increased > RiskLevel.unknownOutdated)
		XCTAssert(RiskLevel.increased < RiskLevel.inactive)

	}

	func testRiskLevelCompareInactive() {
		XCTAssertFalse(RiskLevel.inactive < RiskLevel.low)
		XCTAssertFalse(RiskLevel.inactive < RiskLevel.unknownOutdated)
		XCTAssertFalse(RiskLevel.inactive < RiskLevel.unknownInitial)
		XCTAssertFalse(RiskLevel.inactive < RiskLevel.increased)
		// swiftlint:disable:next identical_operands
		XCTAssertFalse(RiskLevel.inactive < RiskLevel.inactive)
	}

	func testRiskLevelCompareLowLeast() {
		RiskLevel.allCases.dropFirst().forEach {
			XCTAssert(RiskLevel.low < $0)
		}
	}

	func testRiskLevelCompareInactiveHighest() {
		RiskLevel.allCases.dropLast().forEach {
			XCTAssert(RiskLevel.inactive > $0)
		}
	}
}
