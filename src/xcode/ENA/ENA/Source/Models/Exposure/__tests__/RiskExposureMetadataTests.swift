//
// 🦠 Corona-Warn-App
//

@testable import ENA
import XCTest

class RiskExposureMetadataTests: XCTestCase {

    func testHighRiskExposureMetadata() throws {
		let store = MockTestStore()
		let twoDaysBefore = Calendar.current.date(byAdding: .day, value: -2, to: Date())
		store.riskExposureMetadata = RiskExposureMetadata(
			riskLevel: .high,
			riskLevelChangedComparedToPreviousSubmission: true,
			mostRecentDateAtRiskLevel: twoDaysBefore ?? Date(),
			dateChangedComparedToPreviousSubmission: true
		)
		XCTAssertEqual(store.riskExposureMetadata?.riskLevel, .high)
		XCTAssertEqual(store.riskExposureMetadata?.riskLevelChangedComparedToPreviousSubmission, true)
		XCTAssertEqual(store.riskExposureMetadata?.mostRecentDateAtRiskLevel, twoDaysBefore)
		XCTAssertEqual(store.riskExposureMetadata?.dateChangedComparedToPreviousSubmission, true)
    }

	func testLowRiskExposureMetadata() throws {
		let store = MockTestStore()
		let weekBefore = Calendar.current.date(byAdding: .day, value: -2, to: Date())
		store.riskExposureMetadata = RiskExposureMetadata(
			riskLevel: .low,
			riskLevelChangedComparedToPreviousSubmission: false,
			mostRecentDateAtRiskLevel: weekBefore ?? Date(),
			dateChangedComparedToPreviousSubmission: false
		)
		XCTAssertEqual(store.riskExposureMetadata?.riskLevel, .low)
		XCTAssertEqual(store.riskExposureMetadata?.riskLevelChangedComparedToPreviousSubmission, false)
		XCTAssertEqual(store.riskExposureMetadata?.mostRecentDateAtRiskLevel, weekBefore)
		XCTAssertEqual(store.riskExposureMetadata?.dateChangedComparedToPreviousSubmission, false)
	}
}
