//
// 🦠 Corona-Warn-App
//

@testable import ENA
import XCTest

final class DeltaCalculationResultTests: XCTestCase {
	func testMissingDays_EmptyStore() {
		let emptyDelta = DeltaCalculationResult(
			remoteDays: [],
			remoteHours: [],
			localDays: [],
			localHours: []
		)
		XCTAssertEqual(emptyDelta.missingDays, [])
		XCTAssertEqual(emptyDelta.missingHours, [])

		let singleRemoteDay = DeltaCalculationResult(
			remoteDays: ["a"],
			remoteHours: [],
			localDays: [],
			localHours: []
		)
		XCTAssertEqual(singleRemoteDay.missingDays, ["a"])
		XCTAssertEqual(singleRemoteDay.missingHours, [])

		let multipleRemoteDays = DeltaCalculationResult(
			remoteDays: ["a", "b"],
			remoteHours: [],
			localDays: [],
			localHours: []
		)
		XCTAssertEqual(multipleRemoteDays.missingDays, ["a", "b"])
		XCTAssertEqual(multipleRemoteDays.missingHours, [])
	}

	func testMissingDays() {
		let delta = DeltaCalculationResult(
			remoteDays: ["a", "b"],
			remoteHours: [],
			localDays: ["b"],
			localHours: []
		)

		XCTAssertEqual(delta.missingDays, ["a"])
		XCTAssertEqual(delta.missingHours, [])
	}

	func testMissingHours() {
		let delta = DeltaCalculationResult(
			remoteDays: [],
			remoteHours: [1, 2, 3, 4],
			localDays: [],
			localHours: [2]
		)

		XCTAssertEqual(delta.missingDays, [])
		XCTAssertEqual(delta.missingHours, [1, 3, 4])
	}
}
