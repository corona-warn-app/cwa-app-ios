//
// 🦠 Corona-Warn-App
//

@testable import ENA
import XCTest

class KeySubmissionMetadataTests: XCTestCase {
	
	func testKeySubmissionMetadataValues_HighRisk() {
		let secureStore = MockTestStore()
		Analytics.setupMock(store: secureStore)
		secureStore.isPrivacyPreservingAnalyticsConsentGiven = true
		let riskCalculationResult = mockHighRiskCalculationResult()
		let isSubmissionConsentGiven = true
		secureStore.dateOfConversionToHighRisk = Calendar.current.date(byAdding: .day, value: -1, to: Date())
		secureStore.riskCalculationResult = riskCalculationResult
		secureStore.testRegistrationDate = Date()

		let keySubmissionMetadata = KeySubmissionMetadata(
			submitted: false,
			submittedInBackground: false,
			submittedAfterCancel: false,
			submittedAfterSymptomFlow: false,
			lastSubmissionFlowScreen: .submissionFlowScreenUnknown,
			advancedConsentGiven: isSubmissionConsentGiven,
			hoursSinceTestResult: 0,
			hoursSinceTestRegistration: 0,
			daysSinceMostRecentDateAtRiskLevelAtTestRegistration: -1,
			hoursSinceHighRiskWarningAtTestRegistration: -1)
		Analytics.collect(.keySubmissionMetadata(.create(keySubmissionMetadata)))
		Analytics.collect(.keySubmissionMetadata(.setDaysSinceMostRecentDateAtRiskLevelAtTestRegistration))
		Analytics.collect(.keySubmissionMetadata(.setHoursSinceHighRiskWarningAtTestRegistration))

		XCTAssertNotNil(secureStore.keySubmissionMetadata, "keySubmissionMetadata should be initialized with default values")
		XCTAssertEqual(secureStore.keySubmissionMetadata?.daysSinceMostRecentDateAtRiskLevelAtTestRegistration, Int32(riskCalculationResult.numberOfDaysWithCurrentRiskLevel), "number of days should be same")
		XCTAssertEqual(secureStore.keySubmissionMetadata?.hoursSinceHighRiskWarningAtTestRegistration, 24, "the difference is one day so it should be 24")
	}

	func testKeySubmissionMetadataValues_HighRisk_testHours() {
		let secureStore = MockTestStore()
		Analytics.setupMock(store: secureStore)
		secureStore.isPrivacyPreservingAnalyticsConsentGiven = true
		let riskCalculationResult = mockHighRiskCalculationResult()
		let isSubmissionConsentGiven = true
		let dateSixHourAgo = Calendar.current.date(byAdding: .hour, value: -6, to: Date())
		secureStore.dateOfConversionToHighRisk = Calendar.current.date(byAdding: .day, value: -1, to: Date())
		secureStore.riskCalculationResult = riskCalculationResult
		secureStore.testRegistrationDate = Calendar.current.date(byAdding: .day, value: -1, to: Date())
		secureStore.testResultReceivedTimeStamp = Int64(dateSixHourAgo?.timeIntervalSince1970 ?? Date().timeIntervalSince1970)

		let keySubmissionMetadata = KeySubmissionMetadata(
			submitted: false,
			submittedInBackground: false,
			submittedAfterCancel: false,
			submittedAfterSymptomFlow: false,
			lastSubmissionFlowScreen: .submissionFlowScreenUnknown,
			advancedConsentGiven: isSubmissionConsentGiven,
			hoursSinceTestResult: 0,
			hoursSinceTestRegistration: 0,
			daysSinceMostRecentDateAtRiskLevelAtTestRegistration: -1,
			hoursSinceHighRiskWarningAtTestRegistration: -1)
		Analytics.collect(.keySubmissionMetadata(.create(keySubmissionMetadata)))
		Analytics.collect(.keySubmissionMetadata(.setHoursSinceTestRegistration))
		Analytics.collect(.keySubmissionMetadata(.setHoursSinceTestResult))

		XCTAssertNotNil(secureStore.keySubmissionMetadata, "keySubmissionMetadata should be initialized with default values")
		XCTAssertEqual(secureStore.keySubmissionMetadata?.hoursSinceTestResult, 6, "number of hours should be 6")
		XCTAssertEqual(secureStore.keySubmissionMetadata?.hoursSinceTestRegistration, 24, "the difference is one day so it should be 24")
	}

	func testKeySubmissionMetadataValues_HighRisk_submittedInBackground() {
		let secureStore = MockTestStore()
		Analytics.setupMock(store: secureStore)
		secureStore.isPrivacyPreservingAnalyticsConsentGiven = true
		let riskCalculationResult = mockHighRiskCalculationResult()
		let isSubmissionConsentGiven = true
		secureStore.dateOfConversionToHighRisk = Calendar.current.date(byAdding: .day, value: -1, to: Date())
		secureStore.riskCalculationResult = riskCalculationResult

		let keySubmissionMetadata = KeySubmissionMetadata(
			submitted: false,
			submittedInBackground: false,
			submittedAfterCancel: false,
			submittedAfterSymptomFlow: false,
			lastSubmissionFlowScreen: .submissionFlowScreenUnknown,
			advancedConsentGiven: isSubmissionConsentGiven,
			hoursSinceTestResult: 0,
			hoursSinceTestRegistration: 0,
			daysSinceMostRecentDateAtRiskLevelAtTestRegistration: -1,
			hoursSinceHighRiskWarningAtTestRegistration: -1)
		Analytics.collect(.keySubmissionMetadata(.create(keySubmissionMetadata)))
		Analytics.collect(.keySubmissionMetadata(.submitted(true)))
		Analytics.collect(.keySubmissionMetadata(.submittedInBackground(true)))

		XCTAssertNotNil(secureStore.keySubmissionMetadata, "keySubmissionMetadata should be initialized with default values")
		XCTAssertTrue(((secureStore.keySubmissionMetadata?.submitted) != false))
		XCTAssertTrue(((secureStore.keySubmissionMetadata?.submittedInBackground) != false))
	}

	func testKeySubmissionMetadataValues_HighRisk_testSubmitted() {
		let secureStore = MockTestStore()
		Analytics.setupMock(store: secureStore)
		secureStore.isPrivacyPreservingAnalyticsConsentGiven = true
		let riskCalculationResult = mockHighRiskCalculationResult()
		let isSubmissionConsentGiven = true
		secureStore.dateOfConversionToHighRisk = Calendar.current.date(byAdding: .day, value: -1, to: Date())
		secureStore.riskCalculationResult = riskCalculationResult
		Analytics.collect(.keySubmissionMetadata(.submittedWithTeletan(false)))

		let keySubmissionMetadata = KeySubmissionMetadata(
			submitted: false,
			submittedInBackground: false,
			submittedAfterCancel: false,
			submittedAfterSymptomFlow: false,
			lastSubmissionFlowScreen: .submissionFlowScreenUnknown,
			advancedConsentGiven: isSubmissionConsentGiven,
			hoursSinceTestResult: 0,
			hoursSinceTestRegistration: 0,
			daysSinceMostRecentDateAtRiskLevelAtTestRegistration: -1,
			hoursSinceHighRiskWarningAtTestRegistration: -1
		)
		Analytics.collect(.keySubmissionMetadata(.create(keySubmissionMetadata)))
		
		Analytics.collect(.keySubmissionMetadata(.submitted(true)))
		Analytics.collect(.keySubmissionMetadata(.submittedInBackground(false)))
		Analytics.collect(.keySubmissionMetadata(.submittedAfterCancel(true)))
		Analytics.collect(.keySubmissionMetadata(.submittedAfterSymptomFlow(true)))
		Analytics.collect(.keySubmissionMetadata(.lastSubmissionFlowScreen(.submissionFlowScreenSymptoms)))

		XCTAssertNotNil(secureStore.keySubmissionMetadata, "keySubmissionMetadata should be initialized with default values")
		XCTAssertTrue(((secureStore.keySubmissionMetadata?.submitted) != false))
		XCTAssertTrue(((secureStore.keySubmissionMetadata?.submittedInBackground) != true))
		XCTAssertTrue(((secureStore.keySubmissionMetadata?.submittedAfterCancel) != false))
		XCTAssertTrue(((secureStore.keySubmissionMetadata?.submittedAfterSymptomFlow) != false))
		XCTAssertEqual(secureStore.keySubmissionMetadata?.lastSubmissionFlowScreen, .submissionFlowScreenSymptoms)
		XCTAssertTrue(((secureStore.submittedWithQR) != false))
	}

	func testKeySubmissionMetadataValues_LowRisk() {
		let secureStore = MockTestStore()
		Analytics.setupMock(store: secureStore)
		secureStore.isPrivacyPreservingAnalyticsConsentGiven = true
		let riskCalculationResult = mockLowRiskCalculationResult()
		let isSubmissionConsentGiven = true
		secureStore.dateOfConversionToHighRisk = Calendar.current.date(byAdding: .day, value: -1, to: Date())
		secureStore.riskCalculationResult = riskCalculationResult
		secureStore.testRegistrationDate = Date()

		let keySubmissionMetadata = KeySubmissionMetadata(
			submitted: false,
			submittedInBackground: false,
			submittedAfterCancel: false,
			submittedAfterSymptomFlow: false,
			lastSubmissionFlowScreen: .submissionFlowScreenUnknown,
			advancedConsentGiven: isSubmissionConsentGiven,
			hoursSinceTestResult: 0,
			hoursSinceTestRegistration: 0,
			daysSinceMostRecentDateAtRiskLevelAtTestRegistration: -1,
			hoursSinceHighRiskWarningAtTestRegistration: -1)
		Analytics.collect(.keySubmissionMetadata(.create(keySubmissionMetadata)))
		Analytics.collect(.keySubmissionMetadata(.setDaysSinceMostRecentDateAtRiskLevelAtTestRegistration))
		Analytics.collect(.keySubmissionMetadata(.setHoursSinceHighRiskWarningAtTestRegistration))

		XCTAssertNotNil(secureStore.keySubmissionMetadata, "keySubmissionMetadata should be initialized with default values")
		XCTAssertEqual(secureStore.keySubmissionMetadata?.daysSinceMostRecentDateAtRiskLevelAtTestRegistration, Int32(riskCalculationResult.numberOfDaysWithCurrentRiskLevel), "number of days should be same")
		XCTAssertEqual(secureStore.keySubmissionMetadata?.hoursSinceHighRiskWarningAtTestRegistration, -1, "the value should be default value i.e., -1 as the risk is low")
	}

	private func mockHighRiskCalculationResult(risk: RiskLevel = .high) -> RiskCalculationResult {
		RiskCalculationResult(
			riskLevel: risk,
			minimumDistinctEncountersWithLowRisk: 0,
			minimumDistinctEncountersWithHighRisk: 0,
			mostRecentDateWithLowRisk: Date(),
			mostRecentDateWithHighRisk: Date(),
			numberOfDaysWithLowRisk: 0,
			numberOfDaysWithHighRisk: 2,
			calculationDate: Date(),
			riskLevelPerDate: [:],
			minimumDistinctEncountersWithHighRiskPerDate: [:]
		)
	}
	private func mockLowRiskCalculationResult(risk: RiskLevel = .low) -> RiskCalculationResult {
		RiskCalculationResult(
			riskLevel: risk,
			minimumDistinctEncountersWithLowRisk: 0,
			minimumDistinctEncountersWithHighRisk: 0,
			mostRecentDateWithLowRisk: Date(),
			mostRecentDateWithHighRisk: Date(),
			numberOfDaysWithLowRisk: 3,
			numberOfDaysWithHighRisk: 0,
			calculationDate: Date(),
			riskLevelPerDate: [:],
			minimumDistinctEncountersWithHighRiskPerDate: [:]
		)
	}
}
