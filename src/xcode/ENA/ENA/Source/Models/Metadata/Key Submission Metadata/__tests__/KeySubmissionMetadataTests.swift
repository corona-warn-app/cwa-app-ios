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
		coronaTestService.antigenTest = AntigenTest.mock(registrationDate: Date())

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
		Analytics.collect(.keySubmissionMetadata(.submittedAfterRapidAntigenTest(.pcr)))
		Analytics.collect(.keySubmissionMetadata(.create(keySubmissionMetadata, .antigen)))
		Analytics.collect(.keySubmissionMetadata(.setDaysSinceMostRecentDateAtRiskLevelAtTestRegistration(.antigen)))
		Analytics.collect(.keySubmissionMetadata(.setHoursSinceHighRiskWarningAtTestRegistration(.antigen)))
		Analytics.collect(.keySubmissionMetadata(.submittedAfterRapidAntigenTest(.antigen)))

		XCTAssertNotNil(secureStore.pcrKeySubmissionMetadata, "pcrKeySubmissionMetadata should be initialized with default values")
		XCTAssertEqual(secureStore.pcrKeySubmissionMetadata?.daysSinceMostRecentDateAtRiskLevelAtTestRegistration, 2, "number of days should be 2")
		XCTAssertEqual(secureStore.pcrKeySubmissionMetadata?.hoursSinceHighRiskWarningAtTestRegistration, 24, "the difference is one day so it should be 24")
		XCTAssertFalse(secureStore.pcrKeySubmissionMetadata?.submittedAfterRapidAntigenTest ?? true)

		XCTAssertNotNil(secureStore.antigenKeySubmissionMetadata, "keySubmissionMetadata should be initialized with default values")
		XCTAssertEqual(secureStore.antigenKeySubmissionMetadata?.daysSinceMostRecentDateAtRiskLevelAtTestRegistration, 2, "number of days should be 2")
		XCTAssertEqual(secureStore.antigenKeySubmissionMetadata?.hoursSinceHighRiskWarningAtTestRegistration, 24, "the difference is one day so it should be 24")
		XCTAssertTrue(secureStore.antigenKeySubmissionMetadata?.submittedAfterRapidAntigenTest ?? false)
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
		coronaTestService.antigenTest = AntigenTest.mock(
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
		Analytics.collect(.keySubmissionMetadata(.create(keySubmissionMetadata, .antigen)))
		Analytics.collect(.keySubmissionMetadata(.setHoursSinceTestRegistration(.antigen)))
		Analytics.collect(.keySubmissionMetadata(.setHoursSinceTestResult(.antigen)))

		XCTAssertNotNil(secureStore.pcrKeySubmissionMetadata, "pcrKeySubmissionMetadata should be initialized with default values")
		XCTAssertEqual(secureStore.pcrKeySubmissionMetadata?.hoursSinceTestResult, 6, "number of hours should be 6")
		XCTAssertEqual(secureStore.pcrKeySubmissionMetadata?.hoursSinceTestRegistration, 24, "the difference is one day so it should be 24")
		XCTAssertNotNil(secureStore.antigenKeySubmissionMetadata, "keySubmissionMetadata should be initialized with default values")
		XCTAssertEqual(secureStore.antigenKeySubmissionMetadata?.hoursSinceTestResult, 6, "number of hours should be 6")
		XCTAssertEqual(secureStore.antigenKeySubmissionMetadata?.hoursSinceTestRegistration, 24, "the difference is one day so it should be 24")
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
		Analytics.collect(.keySubmissionMetadata(.advancedConsentGiven(true, .pcr)))
		Analytics.collect(.keySubmissionMetadata(.create(keySubmissionMetadata, .antigen)))
		Analytics.collect(.keySubmissionMetadata(.submitted(true, .antigen)))
		Analytics.collect(.keySubmissionMetadata(.submittedInBackground(true, .antigen)))
		Analytics.collect(.keySubmissionMetadata(.advancedConsentGiven(true, .antigen)))

		XCTAssertNotNil(secureStore.pcrKeySubmissionMetadata, "pcrKeySubmissionMetadata should be initialized with default values")
		XCTAssertTrue(((secureStore.pcrKeySubmissionMetadata?.submitted) != false))
		XCTAssertTrue(((secureStore.pcrKeySubmissionMetadata?.submittedInBackground) != false))
		XCTAssertTrue(secureStore.pcrKeySubmissionMetadata?.advancedConsentGiven ?? false)
		XCTAssertNotNil(secureStore.antigenKeySubmissionMetadata, "keySubmissionMetadata should be initialized with default values")
		XCTAssertTrue(((secureStore.antigenKeySubmissionMetadata?.submitted) != false))
		XCTAssertTrue(((secureStore.antigenKeySubmissionMetadata?.submittedInBackground) != false))
		XCTAssertTrue(secureStore.antigenKeySubmissionMetadata?.advancedConsentGiven ?? false)
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

		Analytics.collect(.keySubmissionMetadata(.create(keySubmissionMetadata, .antigen)))
		Analytics.collect(.keySubmissionMetadata(.submitted(true, .antigen)))
		Analytics.collect(.keySubmissionMetadata(.submittedInBackground(false, .antigen)))
		Analytics.collect(.keySubmissionMetadata(.submittedAfterCancel(true, .antigen)))
		Analytics.collect(.keySubmissionMetadata(.submittedAfterSymptomFlow(true, .antigen)))
		Analytics.collect(.keySubmissionMetadata(.lastSubmissionFlowScreen(.submissionFlowScreenSymptoms, .antigen)))

		XCTAssertNotNil(secureStore.pcrKeySubmissionMetadata, "pcrKeySubmissionMetadata should be initialized with default values")
		XCTAssertTrue(secureStore.pcrKeySubmissionMetadata?.submitted != false)
		XCTAssertTrue(secureStore.pcrKeySubmissionMetadata?.submittedInBackground != true)
		XCTAssertTrue(secureStore.pcrKeySubmissionMetadata?.submittedAfterCancel != false)
		XCTAssertTrue(secureStore.pcrKeySubmissionMetadata?.submittedAfterSymptomFlow != false)
		XCTAssertEqual(secureStore.pcrKeySubmissionMetadata?.lastSubmissionFlowScreen, .submissionFlowScreenSymptoms)
		XCTAssertTrue(secureStore.pcrKeySubmissionMetadata?.submittedWithTeleTAN == false)

		XCTAssertNotNil(secureStore.antigenKeySubmissionMetadata, "keySubmissionMetadata should be initialized with default values")
		XCTAssertTrue(secureStore.antigenKeySubmissionMetadata?.submitted != false)
		XCTAssertTrue(secureStore.antigenKeySubmissionMetadata?.submittedInBackground != true)
		XCTAssertTrue(secureStore.antigenKeySubmissionMetadata?.submittedAfterCancel != false)
		XCTAssertTrue(secureStore.antigenKeySubmissionMetadata?.submittedAfterSymptomFlow != false)
		XCTAssertEqual(secureStore.antigenKeySubmissionMetadata?.lastSubmissionFlowScreen, .submissionFlowScreenSymptoms)
		XCTAssertTrue(secureStore.antigenKeySubmissionMetadata?.submittedWithTeleTAN == false)
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
		coronaTestService.antigenTest = AntigenTest.mock(registrationDate: Date())

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
		Analytics.collect(.keySubmissionMetadata(.create(keySubmissionMetadata, .antigen)))
		Analytics.collect(.keySubmissionMetadata(.setDaysSinceMostRecentDateAtRiskLevelAtTestRegistration(.antigen)))
		Analytics.collect(.keySubmissionMetadata(.setHoursSinceHighRiskWarningAtTestRegistration(.antigen)))

		XCTAssertNotNil(secureStore.pcrKeySubmissionMetadata, "pcrKeySubmissionMetadata should be initialized with default values")
		XCTAssertEqual(secureStore.pcrKeySubmissionMetadata?.daysSinceMostRecentDateAtRiskLevelAtTestRegistration, 3, "number of days should be 3")
		XCTAssertEqual(secureStore.pcrKeySubmissionMetadata?.hoursSinceHighRiskWarningAtTestRegistration, -1, "the value should be default value i.e., -1 as the risk is low")

		XCTAssertNotNil(secureStore.antigenKeySubmissionMetadata, "keySubmissionMetadata should be initialized with default values")
		XCTAssertEqual(secureStore.antigenKeySubmissionMetadata?.daysSinceMostRecentDateAtRiskLevelAtTestRegistration, 3, "number of days should be 3")
		XCTAssertEqual(secureStore.antigenKeySubmissionMetadata?.hoursSinceHighRiskWarningAtTestRegistration, -1, "the value should be default value i.e., -1 as the risk is low")
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
