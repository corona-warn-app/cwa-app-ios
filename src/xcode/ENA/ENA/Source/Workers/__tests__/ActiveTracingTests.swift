//
// 🦠 Corona-Warn-App
//

import XCTest
@testable import ENA

final class ActiveTracingTests: XCTestCase {
	func testOneHour() {
		let activeTracing = _activeTracing(interval: 3600)
		XCTAssertEqual(activeTracing.interval, 3600, accuracy: .high)
		XCTAssertEqual(activeTracing.inDays, 0)
		XCTFail(message: "Fail for testing!")
	}

	func testThatLessThan12HoursDontCountAsDay() {
		XCTAssertEqual(
			_activeTracing(interval: 3600 * 11).inDays,
			0
		)
		XCTAssertEqual(
			_activeTracing(interval: 3600.0 * 11.9).inDays,
			0
		)

		XCTAssertEqual(
			_activeTracing(interval: 3600.0 * (24 + 11)).inDays,
			1
		)

		XCTAssertEqual(
			_activeTracing(interval: 3600.0 * (24 + 11.99)).inDays,
			1
		)

		XCTAssertEqual(
			_activeTracing(interval: 3600.0 * (24 * 10 + 11.5)).inDays,
			10
		)
	}

	func testThatMoreThan12HoursCountAsDay() {
		XCTAssertEqual(
			_activeTracing(interval: 3600 * 12).inDays,
			1
		)
		XCTAssertEqual(
			_activeTracing(interval: 3600.0 * 12.1).inDays,
			1
		)

		XCTAssertEqual(
			_activeTracing(interval: 3600.0 * (24 + 12)).inDays,
			2
		)

		XCTAssertEqual(
			_activeTracing(interval: 3600.0 * (24 + 12.01)).inDays,
			2
		)

		XCTAssertEqual(
			_activeTracing(interval: 3600.0 * (24 * 10 + 12.5)).inDays,
			11
		)
	}

	func testLocalizedLowRiskLevelHomeScreenText() {
		XCTAssertEqual(
			_activeTracing(interval: 0).localizedDuration,
			"Risiko-Ermittlung war für 0 der letzten 14 Tage aktiv"
		)

		// 13 hours = 1 day
		XCTAssertEqual(
			_activeTracing(interval: 3_600 * 13).localizedDuration,
			"Risiko-Ermittlung war für 1 der letzten 14 Tage aktiv"
		)

		// 14 days yields different text
		XCTAssertEqual(
			_activeTracing(interval: 3_600 * 24 * 14).localizedDuration,
			"Risiko-Ermittlung dauerhaft aktiv"
		)

		// 14+ days yields different text
		XCTAssertEqual(
			_activeTracing(interval: 3_600 * 24 * 15).localizedDuration,
			"Risiko-Ermittlung dauerhaft aktiv"
		)
	}

	func testGIVEN_ActiveTracingWithNegativeInterval_THEN_InDaysIsZero() {
		// GIVEN
		let activeTracing = ActiveTracing(interval: -250)

		// THEN
		XCTAssertEqual(activeTracing.inDays, 0)
		XCTAssertEqual(activeTracing.inHours, 0)
	}
}

private func _activeTracing(interval: TimeInterval) -> ActiveTracing {
	ActiveTracing(interval: interval)
}

private extension TimeInterval {
	static let high = 0.1
}
