//
// 🦠 Corona-Warn-App
//

@testable import ENA
import Foundation
import XCTest

final class RiskTests: XCTestCase {
	func testGetNumberOfDaysActiveTracing_LessThanOneDay() {
		let details = mockDetails(activeTracing: .init(interval: .init(hours: 11)))
		XCTAssertEqual(details.numberOfDaysWithActiveTracing, 0)
	}

	func testGetNumberOfDaysActiveTracing_ZeroHours() {
		let details = mockDetails(activeTracing: .init(interval: .init(hours: 0)))
		XCTAssertEqual(details.numberOfDaysWithActiveTracing, 0)
	}

	func testGetNumberOfDaysActiveTracing_OneDayRoundedDown() {
		let details = mockDetails(activeTracing: .init(interval: .init(hours: 25)))
		XCTAssertEqual(details.numberOfDaysWithActiveTracing, 1)
	}

	func testGetNumberOfDaysActiveTracing_OneDayExact() {
		let details = mockDetails(activeTracing: .init(interval: .init(hours: 25)))
		XCTAssertEqual(details.numberOfDaysWithActiveTracing, 1)
	}

	func testGetNumberOfDaysActiveTracing_FourteenDaysExact() {
		let details = mockDetails(activeTracing: .init(interval: .init(hours: 14 * 24)))
		XCTAssertEqual(details.numberOfDaysWithActiveTracing, 14)
	}
}

extension RiskTests {
	func mockDetails(activeTracing: ActiveTracing) -> Risk.Details {
		Risk.Details(
			numberOfDaysWithRiskLevel: 0,
			activeTracing: activeTracing,
			exposureDetectionDate: Date()
		)
	}
}
