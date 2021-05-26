//
// 🦠 Corona-Warn-App
//

@testable import ENA
import XCTest

class KeySubmissionMetadataTests: XCTestCase {
	
	func testKeySubmissionMetadataValues_HighRisk() {
		let secureStore = MockTestStore()
		let coronaTestService = CoronaTestService(
			client: ClientMock(),
			store: secureStore,
			appConfiguration: CachedAppConfigurationMock()
		)

		Analytics.setupMock(store: secureStore, coronaTestService: coronaTestService)

		secureStore.isPrivacyPreservingAnalyticsConsentGiven = true

		let riskCalculationResult = mockHighRiskCalculationResult()
		let isSubmissionConsentGiven = true

		secureStore.dateOfConversionToHighRisk = Calendar.current.date(byAdding: .day, value: -1, to: Date())
		secureStore.enfRiskCalculationResult = riskCalculationResult

		coronaTestService.pcrTest = PCRTest.mock(registrationDate: Date())

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
			submittedWithTeleTAN: false,
			hoursSinceHighRiskWarningAtTestRegistration: -1,
			submittedAfterRapidAntigenTest: false
		)
		Analytics.collect(.keySubmissionMetadata(.create(keySubmissionMetadata, .pcr)))
		Analytics.collect(.keySubmissionMetadata(.setDaysSinceMostRecentDateAtRiskLevelAtTestRegistration(.pcr)))
		Analytics.collect(.keySubmissionMetadata(.setHoursSinceHighRiskWarningAtTestRegistration(.pcr)))

		XCTAssertNotNil(secureStore.keySubmissionMetadata, "keySubmissionMetadata should be initialized with default values")
		XCTAssertEqual(secureStore.keySubmissionMetadata?.daysSinceMostRecentDateAtRiskLevelAtTestRegistration, 2, "number of days should be 2")
		XCTAssertEqual(secureStore.keySubmissionMetadata?.hoursSinceHighRiskWarningAtTestRegistration, 24, "the difference is one day so it should be 24")
	}

	func testKeySubmissionMetadataValues_HighRisk_testHours() {
		let secureStore = MockTestStore()
		let coronaTestService = CoronaTestService(
			client: ClientMock(),
			store: secureStore,
			appConfiguration: CachedAppConfigurationMock()
		)

		Analytics.setupMock(store: secureStore, coronaTestService: coronaTestService)

		secureStore.isPrivacyPreservingAnalyticsConsentGiven = true
		let riskCalculationResult = mockHighRiskCalculationResult()
		let isSubmissionConsentGiven = true
		let dateSixHourAgo = Calendar.current.date(byAdding: .hour, value: -6, to: Date())
		secureStore.dateOfConversionToHighRisk = Calendar.current.date(byAdding: .day, value: -1, to: Date())
		secureStore.enfRiskCalculationResult = riskCalculationResult

		coronaTestService.pcrTest = PCRTest.mock(
			registrationDate: Calendar.current.date(byAdding: .day, value: -1, to: Date()) ?? Date(),
			finalTestResultReceivedDate: dateSixHourAgo ?? Date()
		)

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
			submittedWithTeleTAN: false,
			hoursSinceHighRiskWarningAtTestRegistration: -1,
			submittedAfterRapidAntigenTest: false
		)
		Analytics.collect(.keySubmissionMetadata(.create(keySubmissionMetadata, .pcr)))
		Analytics.collect(.keySubmissionMetadata(.setHoursSinceTestRegistration(.pcr)))
		Analytics.collect(.keySubmissionMetadata(.setHoursSinceTestResult(.pcr)))

		XCTAssertNotNil(secureStore.keySubmissionMetadata, "keySubmissionMetadata should be initialized with default values")
		XCTAssertEqual(secureStore.keySubmissionMetadata?.hoursSinceTestResult, 6, "number of hours should be 6")
		XCTAssertEqual(secureStore.keySubmissionMetadata?.hoursSinceTestRegistration, 24, "the difference is one day so it should be 24")
	}

	func testKeySubmissionMetadataValues_HighRisk_submittedInBackground() {
		let secureStore = MockTestStore()
		let coronaTestService = CoronaTestService(
			client: ClientMock(),
			store: secureStore,
			appConfiguration: CachedAppConfigurationMock()
		)
		Analytics.setupMock(
			store: secureStore,
			coronaTestService: coronaTestService
		)
		secureStore.isPrivacyPreservingAnalyticsConsentGiven = true
		let riskCalculationResult = mockHighRiskCalculationResult()
		let isSubmissionConsentGiven = true
		secureStore.dateOfConversionToHighRisk = Calendar.current.date(byAdding: .day, value: -1, to: Date())
		secureStore.enfRiskCalculationResult = riskCalculationResult

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
			submittedWithTeleTAN: false,
			hoursSinceHighRiskWarningAtTestRegistration: -1,
			submittedAfterRapidAntigenTest: false
		)
		Analytics.collect(.keySubmissionMetadata(.create(keySubmissionMetadata, .pcr)))
		Analytics.collect(.keySubmissionMetadata(.submitted(true, .pcr)))
		Analytics.collect(.keySubmissionMetadata(.submittedInBackground(true, .pcr)))

		XCTAssertNotNil(secureStore.keySubmissionMetadata, "keySubmissionMetadata should be initialized with default values")
		XCTAssertTrue(((secureStore.keySubmissionMetadata?.submitted) != false))
		XCTAssertTrue(((secureStore.keySubmissionMetadata?.submittedInBackground) != false))
	}

	func testKeySubmissionMetadataValues_HighRisk_testSubmitted() {
		let secureStore = MockTestStore()
		let coronaTestService = CoronaTestService(
			client: ClientMock(),
			store: secureStore,
			appConfiguration: CachedAppConfigurationMock()
		)
		Analytics.setupMock(
			store: secureStore,
			coronaTestService: coronaTestService
		)
		secureStore.isPrivacyPreservingAnalyticsConsentGiven = true
		let riskCalculationResult = mockHighRiskCalculationResult()
		let isSubmissionConsentGiven = true
		secureStore.dateOfConversionToHighRisk = Calendar.current.date(byAdding: .day, value: -1, to: Date())
		secureStore.enfRiskCalculationResult = riskCalculationResult
		Analytics.collect(.keySubmissionMetadata(.submittedWithTeletan(false, .pcr)))

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
			submittedWithTeleTAN: false,
			hoursSinceHighRiskWarningAtTestRegistration: -1,
			submittedAfterRapidAntigenTest: false
		)
		Analytics.collect(.keySubmissionMetadata(.create(keySubmissionMetadata, .pcr)))
		
		Analytics.collect(.keySubmissionMetadata(.submitted(true, .pcr)))
		Analytics.collect(.keySubmissionMetadata(.submittedInBackground(false, .pcr)))
		Analytics.collect(.keySubmissionMetadata(.submittedAfterCancel(true, .pcr)))
		Analytics.collect(.keySubmissionMetadata(.submittedAfterSymptomFlow(true, .pcr)))
		Analytics.collect(.keySubmissionMetadata(.lastSubmissionFlowScreen(.submissionFlowScreenSymptoms, .pcr)))

		XCTAssertNotNil(secureStore.keySubmissionMetadata, "keySubmissionMetadata should be initialized with default values")
		XCTAssertTrue((secureStore.keySubmissionMetadata?.submitted) != false)
		XCTAssertTrue((secureStore.keySubmissionMetadata?.submittedInBackground) != true)
		XCTAssertTrue(((secureStore.keySubmissionMetadata?.submittedAfterCancel) != false))
		XCTAssertTrue(((secureStore.keySubmissionMetadata?.submittedAfterSymptomFlow) != false))
		XCTAssertEqual(secureStore.keySubmissionMetadata?.lastSubmissionFlowScreen, .submissionFlowScreenSymptoms)
		XCTAssertTrue(((secureStore.keySubmissionMetadata?.submittedWithTeleTAN) == false))
	}

	func testKeySubmissionMetadataValues_LowRisk() {
		let secureStore = MockTestStore()
		secureStore.isPrivacyPreservingAnalyticsConsentGiven = true

		let coronaTestService = CoronaTestService(
			client: ClientMock(),
			store: secureStore,
			appConfiguration: CachedAppConfigurationMock()
		)

		Analytics.setupMock(store: secureStore, coronaTestService: coronaTestService)

		let riskCalculationResult = mockLowRiskCalculationResult()
		let isSubmissionConsentGiven = true

		secureStore.dateOfConversionToHighRisk = Calendar.current.date(byAdding: .day, value: -1, to: Date())
		secureStore.enfRiskCalculationResult = riskCalculationResult

		coronaTestService.pcrTest = PCRTest.mock(registrationDate: Date())

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
			submittedWithTeleTAN: false,
			hoursSinceHighRiskWarningAtTestRegistration: -1,
			submittedAfterRapidAntigenTest: false
		)
		Analytics.collect(.keySubmissionMetadata(.create(keySubmissionMetadata, .pcr)))
		Analytics.collect(.keySubmissionMetadata(.setDaysSinceMostRecentDateAtRiskLevelAtTestRegistration(.pcr)))
		Analytics.collect(.keySubmissionMetadata(.setHoursSinceHighRiskWarningAtTestRegistration(.pcr)))

		XCTAssertNotNil(secureStore.keySubmissionMetadata, "keySubmissionMetadata should be initialized with default values")
		XCTAssertEqual(secureStore.keySubmissionMetadata?.daysSinceMostRecentDateAtRiskLevelAtTestRegistration, 3, "number of days should be 3")
		XCTAssertEqual(secureStore.keySubmissionMetadata?.hoursSinceHighRiskWarningAtTestRegistration, -1, "the value should be default value i.e., -1 as the risk is low")
	}

	private func mockHighRiskCalculationResult(risk: RiskLevel = .high) -> ENFRiskCalculationResult {
		ENFRiskCalculationResult(
			riskLevel: risk,
			minimumDistinctEncountersWithLowRisk: 0,
			minimumDistinctEncountersWithHighRisk: 0,
			mostRecentDateWithLowRisk: Date(),
			mostRecentDateWithHighRisk: Calendar.utcCalendar.date(byAdding: .day, value: -2, to: Date()),
			numberOfDaysWithLowRisk: 0,
			numberOfDaysWithHighRisk: 2,
			calculationDate: Date(),
			riskLevelPerDate: [:],
			minimumDistinctEncountersWithHighRiskPerDate: [:]
		)
	}
	private func mockLowRiskCalculationResult(risk: RiskLevel = .low) -> ENFRiskCalculationResult {
		ENFRiskCalculationResult(
			riskLevel: risk,
			minimumDistinctEncountersWithLowRisk: 0,
			minimumDistinctEncountersWithHighRisk: 0,
			mostRecentDateWithLowRisk: Calendar.utcCalendar.date(byAdding: .day, value: -3, to: Date()),
			mostRecentDateWithHighRisk: Date(),
			numberOfDaysWithLowRisk: 3,
			numberOfDaysWithHighRisk: 0,
			calculationDate: Date(),
			riskLevelPerDate: [:],
			minimumDistinctEncountersWithHighRiskPerDate: [:]
		)
	}
}
