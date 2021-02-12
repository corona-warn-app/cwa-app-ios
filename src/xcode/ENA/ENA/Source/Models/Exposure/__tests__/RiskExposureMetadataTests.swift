//
// 🦠 Corona-Warn-App
//

@testable import ENA
import XCTest

class RiskExposureMetadataTests: XCTestCase {

    func testHighRiskExposureMetadata() throws {
		let store = MockTestStore()
		let twoDaysBefore = Calendar.current.date(byAdding: .day, value: -2, to: Date())
		store.currentRiskExposureMetadata = RiskExposureMetadata(
			riskLevel: .high,
			riskLevelChangedComparedToPreviousSubmission: true,
			mostRecentDateAtRiskLevel: twoDaysBefore ?? Date(),
			dateChangedComparedToPreviousSubmission: true
		)
		XCTAssertEqual(store.currentRiskExposureMetadata?.riskLevel, .high)
		XCTAssertEqual(store.currentRiskExposureMetadata?.riskLevelChangedComparedToPreviousSubmission, true)
		XCTAssertEqual(store.currentRiskExposureMetadata?.mostRecentDateAtRiskLevel, twoDaysBefore)
		XCTAssertEqual(store.currentRiskExposureMetadata?.dateChangedComparedToPreviousSubmission, true)
    }

	func testLowRiskExposureMetadata() throws {
		let store = MockTestStore()
		let weekBefore = Calendar.current.date(byAdding: .day, value: -2, to: Date())
		store.currentRiskExposureMetadata = RiskExposureMetadata(
			riskLevel: .low,
			riskLevelChangedComparedToPreviousSubmission: false,
			mostRecentDateAtRiskLevel: weekBefore ?? Date(),
			dateChangedComparedToPreviousSubmission: false
		)
		XCTAssertEqual(store.currentRiskExposureMetadata?.riskLevel, .low)
		XCTAssertEqual(store.currentRiskExposureMetadata?.riskLevelChangedComparedToPreviousSubmission, false)
		XCTAssertEqual(store.currentRiskExposureMetadata?.mostRecentDateAtRiskLevel, weekBefore)
		XCTAssertEqual(store.currentRiskExposureMetadata?.dateChangedComparedToPreviousSubmission, false)
	}
}
