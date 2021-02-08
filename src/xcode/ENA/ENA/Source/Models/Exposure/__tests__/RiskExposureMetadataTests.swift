//
// 🦠 Corona-Warn-App
//

@testable import ENA
import XCTest

class RiskExposureMetadataTests: XCTestCase {

    func testRiskExposureMetadata() throws {
		let store = MockTestStore()
		let twoDaysBefore = Calendar.current.date(byAdding: .day, value: -2, to: Date())
		store.riskExposureMetadata = RiskExposureMetadata(
			riskLevel: .high,
			riskLevelChangedComparedToPreviousSubmission: true,
			mostRecentDateAtRiskLevel: twoDaysBefore ?? Date(),
			dateChangedComparedToPreviousSubmission: false
		)
		XCTAssertEqual(store.riskExposureMetadata?.riskLevel, .high)
		XCTAssertEqual(store.riskExposureMetadata?.riskLevelChangedComparedToPreviousSubmission, true)
		XCTAssertEqual(store.riskExposureMetadata?.mostRecentDateAtRiskLevel, twoDaysBefore)
		XCTAssertNotEqual(store.riskExposureMetadata?.dateChangedComparedToPreviousSubmission, true)
    }

}
