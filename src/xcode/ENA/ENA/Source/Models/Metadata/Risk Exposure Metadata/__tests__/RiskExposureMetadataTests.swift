//
// 🦠 Corona-Warn-App
//

@testable import ENA
import XCTest

class RiskExposureMetadataTests: XCTestCase {

    func testHighRiskExposureMetadata() throws {
		let store = MockTestStore()
		let twoDaysBefore = Calendar.current.date(byAdding: .day, value: -2, to: Date())
		store.currentENFRiskExposureMetadata = RiskExposureMetadata(
			riskLevel: .high,
			riskLevelChangedComparedToPreviousSubmission: true,
			mostRecentDateAtRiskLevel: twoDaysBefore ?? Date(),
			dateChangedComparedToPreviousSubmission: true
		)
		XCTAssertEqual(store.currentENFRiskExposureMetadata?.riskLevel, .high)
		XCTAssertEqual(store.currentENFRiskExposureMetadata?.riskLevelChangedComparedToPreviousSubmission, true)
		XCTAssertEqual(store.currentENFRiskExposureMetadata?.mostRecentDateAtRiskLevel, twoDaysBefore)
		XCTAssertEqual(store.currentENFRiskExposureMetadata?.dateChangedComparedToPreviousSubmission, true)
    }

	func testLowRiskExposureMetadata() throws {
		let store = MockTestStore()
		let weekBefore = Calendar.current.date(byAdding: .day, value: -2, to: Date())
		store.currentENFRiskExposureMetadata = RiskExposureMetadata(
			riskLevel: .low,
			riskLevelChangedComparedToPreviousSubmission: false,
			mostRecentDateAtRiskLevel: weekBefore ?? Date(),
			dateChangedComparedToPreviousSubmission: false
		)
		XCTAssertEqual(store.currentENFRiskExposureMetadata?.riskLevel, .low)
		XCTAssertEqual(store.currentENFRiskExposureMetadata?.riskLevelChangedComparedToPreviousSubmission, false)
		XCTAssertEqual(store.currentENFRiskExposureMetadata?.mostRecentDateAtRiskLevel, weekBefore)
		XCTAssertEqual(store.currentENFRiskExposureMetadata?.dateChangedComparedToPreviousSubmission, false)
	}
}
