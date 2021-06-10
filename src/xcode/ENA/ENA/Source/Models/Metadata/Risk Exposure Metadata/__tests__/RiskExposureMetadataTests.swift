//
// 🦠 Corona-Warn-App
//

@testable import ENA
import XCTest

class RiskExposureMetadataTests: CWATestCase {
	
    func testGIVEN_RiskExposureMetadata_WHEN_ENF_Current_HighRisk_IsSaved_THEN_OnlyENFCurrentRiskExposureMetadataIsSaved() throws {
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
		XCTAssertNil(store.currentCheckinRiskExposureMetadata)
    }

	func testGIVEN_RiskExposureMetadata_WHEN_ENF_Current_LowRisk_IsSaved_THEN_OnlyENFCurrentRiskExposureMetadataIsSaved() throws {
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
		XCTAssertNil(store.currentCheckinRiskExposureMetadata)
	}
	
	func testGIVEN_RiskExposureMetadata_WHEN_Checkin_Current_HighRisk_IsSaved_THEN_OnlyCheckinCurrentRiskExposureMetadataIsSaved() throws {
		let store = MockTestStore()
		let twoDaysBefore = Calendar.current.date(byAdding: .day, value: -2, to: Date())
		store.currentCheckinRiskExposureMetadata = RiskExposureMetadata(
			riskLevel: .high,
			riskLevelChangedComparedToPreviousSubmission: true,
			mostRecentDateAtRiskLevel: twoDaysBefore ?? Date(),
			dateChangedComparedToPreviousSubmission: true
		)
		XCTAssertEqual(store.currentCheckinRiskExposureMetadata?.riskLevel, .high)
		XCTAssertEqual(store.currentCheckinRiskExposureMetadata?.riskLevelChangedComparedToPreviousSubmission, true)
		XCTAssertEqual(store.currentCheckinRiskExposureMetadata?.mostRecentDateAtRiskLevel, twoDaysBefore)
		XCTAssertEqual(store.currentCheckinRiskExposureMetadata?.dateChangedComparedToPreviousSubmission, true)
		XCTAssertNil(store.currentENFRiskExposureMetadata)
	}

	func testGIVEN_RiskExposureMetadata_WHEN_Checkin_Current_LowRisk_IsSaved_THEN_OnlyCheckinCurrentRiskExposureMetadataIsSaved() throws {
		let store = MockTestStore()
		let weekBefore = Calendar.current.date(byAdding: .day, value: -2, to: Date())
		store.currentCheckinRiskExposureMetadata = RiskExposureMetadata(
			riskLevel: .low,
			riskLevelChangedComparedToPreviousSubmission: false,
			mostRecentDateAtRiskLevel: weekBefore ?? Date(),
			dateChangedComparedToPreviousSubmission: false
		)
		XCTAssertEqual(store.currentCheckinRiskExposureMetadata?.riskLevel, .low)
		XCTAssertEqual(store.currentCheckinRiskExposureMetadata?.riskLevelChangedComparedToPreviousSubmission, false)
		XCTAssertEqual(store.currentCheckinRiskExposureMetadata?.mostRecentDateAtRiskLevel, weekBefore)
		XCTAssertEqual(store.currentCheckinRiskExposureMetadata?.dateChangedComparedToPreviousSubmission, false)
		XCTAssertNil(store.currentENFRiskExposureMetadata)
	}
}
