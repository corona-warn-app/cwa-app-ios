import XCTest
@testable import ENA

final class SAP_Internal_RiskScoreClass_LowAndHighTests: XCTestCase {
    func testWithOnlyHighAndLow() {
		let sut: [SAP_Internal_RiskScoreClass] = [
			SAP_Internal_RiskScoreClass.with {
				$0.label = "LOW"
			},
			SAP_Internal_RiskScoreClass.with {
				$0.label = "HIGH"
			}
		]

		XCTAssertEqual(sut.low?.label, "LOW")
		XCTAssertEqual(sut.high?.label, "HIGH")
	}

	func testEmpty() {
		let sut: [SAP_Internal_RiskScoreClass] = []
		XCTAssertNil(sut.low)
		XCTAssertNil(sut.high)
	}

	func testIgnoresEmojis() {
		let high = SAP_Internal_RiskScoreClass.with { $0.label = "🚬" }
		let sut: [SAP_Internal_RiskScoreClass] = [high]
		XCTAssertNil(sut.high)
	}
}
