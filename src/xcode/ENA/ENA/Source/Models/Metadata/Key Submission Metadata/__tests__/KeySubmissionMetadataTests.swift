//
// 🦠 Corona-Warn-App
//

@testable import ENA
import XCTest

// swiftlint:disable:next type_body_length
class KeySubmissionMetadataTests: XCTestCase {
		
	func testKeySubmissionMetadataValues_ENFHighRisk() {
		let secureStore = MockTestStore()
		let coronaTestService = CoronaTestService(
			client: ClientMock(),
			store: secureStore,
			appConfiguration: CachedAppConfigurationMock()
		)

		Analytics.setupMock(store: secureStore, coronaTestService: coronaTestService)

		secureStore.isPrivacyPreservingAnalyticsConsentGiven = true

		let riskCalculationResult = mockENFHighRiskCalculationResult()
		let isSubmissionConsentGiven = true

		secureStore.dateOfConversionToENFHighRisk = Calendar.current.date(byAdding: .day, value: -1, to: Date())
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
			hoursSinceHighRiskWarningAtTestRegistration: -1,
			daysSinceMostRecentDateAtCheckinRiskLevelAtTestRegistration: -1,
			hoursSinceCheckinHighRiskWarningAtTestRegistration: -1,
			submittedWithCheckIns: nil
		)
		Analytics.collect(.keySubmissionMetadata(.create(keySubmissionMetadata)))
		Analytics.collect(.keySubmissionMetadata(.setDaysSinceMostRecentDateAtENFRiskLevelAtTestRegistration))
		Analytics.collect(.keySubmissionMetadata(.setHoursSinceENFHighRiskWarningAtTestRegistration))
		Analytics.collect(.keySubmissionMetadata(.submittedWithCheckins(false)))

		XCTAssertNotNil(secureStore.keySubmissionMetadata, "keySubmissionMetadata should be initialized with default values")
		XCTAssertEqual(secureStore.keySubmissionMetadata?.daysSinceMostRecentDateAtRiskLevelAtTestRegistration, 2, "number of days should be 2")
		XCTAssertEqual(secureStore.keySubmissionMetadata?.hoursSinceHighRiskWarningAtTestRegistration, 24, "the difference is one day so it should be 24")
		XCTAssertEqual(secureStore.keySubmissionMetadata?.daysSinceMostRecentDateAtCheckinRiskLevelAtTestRegistration, -1, "property should not be changed from init param")
		XCTAssertEqual(secureStore.keySubmissionMetadata?.hoursSinceCheckinHighRiskWarningAtTestRegistration, -1, "property should not be changed from init param")
		guard let submittedWithCheckIns = secureStore.keySubmissionMetadata?.submittedWithCheckIns else {
			XCTFail("submittedWithCheckIns should not be nil.")
			return
		}
		XCTAssertFalse(submittedWithCheckIns)
	}
	
	func testKeySubmissionMetadataValues_CheckinHighRisk() {
		let secureStore = MockTestStore()
		let coronaTestService = CoronaTestService(
			client: ClientMock(),
			store: secureStore,
			appConfiguration: CachedAppConfigurationMock()
		)

		Analytics.setupMock(store: secureStore, coronaTestService: coronaTestService)

		secureStore.isPrivacyPreservingAnalyticsConsentGiven = true

		guard let twoDaysAgo = Calendar.current.date(byAdding: .day, value: -2, to: Date()) else {
			XCTFail("Could not create date for two days ago.")
			return
		}
		let riskCalculationResult = mockCheckinRiskCalculationResult(dateForRisk: twoDaysAgo)
		let isSubmissionConsentGiven = true

		secureStore.dateOfConversionToCheckinHighRisk = Calendar.current.date(byAdding: .day, value: -1, to: Date())
		secureStore.checkinRiskCalculationResult = riskCalculationResult

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
			hoursSinceHighRiskWarningAtTestRegistration: -1,
			daysSinceMostRecentDateAtCheckinRiskLevelAtTestRegistration: -1,
			hoursSinceCheckinHighRiskWarningAtTestRegistration: -1,
			submittedWithCheckIns: nil
		)
		Analytics.collect(.keySubmissionMetadata(.create(keySubmissionMetadata)))
		Analytics.collect(.keySubmissionMetadata(.setDaysSinceMostRecentDateAtCheckinRiskLevelAtTestRegistration))
		Analytics.collect(.keySubmissionMetadata(.setHoursSinceCheckinHighRiskWarningAtTestRegistration))
		Analytics.collect(.keySubmissionMetadata(.submittedWithCheckins(true)))

		XCTAssertNotNil(secureStore.keySubmissionMetadata, "keySubmissionMetadata should be initialized with default values")
		XCTAssertEqual(secureStore.keySubmissionMetadata?.daysSinceMostRecentDateAtCheckinRiskLevelAtTestRegistration, 2, "number of days should be 2")
		XCTAssertEqual(secureStore.keySubmissionMetadata?.hoursSinceCheckinHighRiskWarningAtTestRegistration, 24, "the difference is one day so it should be 24")
		XCTAssertEqual(secureStore.keySubmissionMetadata?.daysSinceMostRecentDateAtRiskLevelAtTestRegistration, -1, "property should not be changed from init param")
		XCTAssertEqual(secureStore.keySubmissionMetadata?.hoursSinceHighRiskWarningAtTestRegistration, -1, "property should not be changed from init param")
		guard let submittedWithCheckIns = secureStore.keySubmissionMetadata?.submittedWithCheckIns else {
			XCTFail("submittedWithCheckIns should not be nil.")
			return
		}
		XCTAssertTrue(submittedWithCheckIns)
	}
	
	func testKeySubmissionMetadataValues_BothHighRisk() {
		let secureStore = MockTestStore()
		let coronaTestService = CoronaTestService(
			client: ClientMock(),
			store: secureStore,
			appConfiguration: CachedAppConfigurationMock()
		)

		Analytics.setupMock(store: secureStore, coronaTestService: coronaTestService)
		let isSubmissionConsentGiven = true
		let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: Date())
		
		secureStore.isPrivacyPreservingAnalyticsConsentGiven = true
		
		let enfRiskCalculationResult = mockENFHighRiskCalculationResult()
		secureStore.dateOfConversionToENFHighRisk = yesterday
		secureStore.enfRiskCalculationResult = enfRiskCalculationResult
		
		guard let twoDaysAgo = Calendar.current.date(byAdding: .day, value: -2, to: Date()) else {
			XCTFail("Could not create date for two days ago.")
			return
		}
		let checkinRiskCalculationResult = mockCheckinRiskCalculationResult(dateForRisk: twoDaysAgo)
		secureStore.dateOfConversionToCheckinHighRisk = yesterday
		secureStore.checkinRiskCalculationResult = checkinRiskCalculationResult
		
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
			hoursSinceHighRiskWarningAtTestRegistration: -1,
			daysSinceMostRecentDateAtCheckinRiskLevelAtTestRegistration: -1,
			hoursSinceCheckinHighRiskWarningAtTestRegistration: -1,
			submittedWithCheckIns: nil
		)
		Analytics.collect(.keySubmissionMetadata(.create(keySubmissionMetadata)))
		Analytics.collect(.keySubmissionMetadata(.setDaysSinceMostRecentDateAtENFRiskLevelAtTestRegistration))
		Analytics.collect(.keySubmissionMetadata(.setHoursSinceENFHighRiskWarningAtTestRegistration))
		Analytics.collect(.keySubmissionMetadata(.setDaysSinceMostRecentDateAtCheckinRiskLevelAtTestRegistration))
		Analytics.collect(.keySubmissionMetadata(.setHoursSinceCheckinHighRiskWarningAtTestRegistration))
		Analytics.collect(.keySubmissionMetadata(.submittedWithCheckins(true)))

		XCTAssertNotNil(secureStore.keySubmissionMetadata, "keySubmissionMetadata should be initialized with default values")
		XCTAssertEqual(secureStore.keySubmissionMetadata?.daysSinceMostRecentDateAtRiskLevelAtTestRegistration, 2, "number of days should be 2")
		XCTAssertEqual(secureStore.keySubmissionMetadata?.hoursSinceHighRiskWarningAtTestRegistration, 24, "the difference is one day so it should be 24")
		XCTAssertEqual(secureStore.keySubmissionMetadata?.daysSinceMostRecentDateAtCheckinRiskLevelAtTestRegistration, 2, "number of days should be 2")
		XCTAssertEqual(secureStore.keySubmissionMetadata?.hoursSinceCheckinHighRiskWarningAtTestRegistration, 24, "the difference is one day so it should be 24")
		guard let submittedWithCheckIns = secureStore.keySubmissionMetadata?.submittedWithCheckIns else {
			XCTFail("submittedWithCheckIns should not be nil.")
			return
		}
		XCTAssertTrue(submittedWithCheckIns)
	}
	
	func testKeySubmissionMetadataValues_ENFLowRisk() {
		let secureStore = MockTestStore()
		secureStore.isPrivacyPreservingAnalyticsConsentGiven = true

		let coronaTestService = CoronaTestService(
			client: ClientMock(),
			store: secureStore,
			appConfiguration: CachedAppConfigurationMock()
		)

		Analytics.setupMock(store: secureStore, coronaTestService: coronaTestService)

		let riskCalculationResult = mockENFLowRiskCalculationResult()
		let isSubmissionConsentGiven = true

		secureStore.dateOfConversionToENFHighRisk = Calendar.current.date(byAdding: .day, value: -1, to: Date())
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
			hoursSinceHighRiskWarningAtTestRegistration: -1,
			daysSinceMostRecentDateAtCheckinRiskLevelAtTestRegistration: -1,
			hoursSinceCheckinHighRiskWarningAtTestRegistration: -1,
			submittedWithCheckIns: nil
		)
		Analytics.collect(.keySubmissionMetadata(.create(keySubmissionMetadata)))
		Analytics.collect(.keySubmissionMetadata(.setDaysSinceMostRecentDateAtENFRiskLevelAtTestRegistration))
		Analytics.collect(.keySubmissionMetadata(.setHoursSinceENFHighRiskWarningAtTestRegistration))

		XCTAssertNotNil(secureStore.keySubmissionMetadata, "keySubmissionMetadata should be initialized with default values")
		XCTAssertEqual(secureStore.keySubmissionMetadata?.daysSinceMostRecentDateAtRiskLevelAtTestRegistration, 3, "number of days should be 3")
		XCTAssertEqual(secureStore.keySubmissionMetadata?.hoursSinceHighRiskWarningAtTestRegistration, -1, "the value should be default value i.e., -1 as the risk is low")
		XCTAssertEqual(secureStore.keySubmissionMetadata?.daysSinceMostRecentDateAtCheckinRiskLevelAtTestRegistration, -1, "property should not be changed from init param")
		XCTAssertEqual(secureStore.keySubmissionMetadata?.hoursSinceCheckinHighRiskWarningAtTestRegistration, -1, "property should not be changed from init param")
		XCTAssertNil(secureStore.keySubmissionMetadata?.submittedWithCheckIns)
	}
	
	func testKeySubmissionMetadataValues_CheckinLowRisk() {
		let secureStore = MockTestStore()
		secureStore.isPrivacyPreservingAnalyticsConsentGiven = true

		let coronaTestService = CoronaTestService(
			client: ClientMock(),
			store: secureStore,
			appConfiguration: CachedAppConfigurationMock()
		)

		Analytics.setupMock(store: secureStore, coronaTestService: coronaTestService)

		guard let threeDaysAgo = Calendar.current.date(byAdding: .day, value: -3, to: Date()) else {
			XCTFail("Could not create date for two days ago.")
			return
		}
		let riskCalculationResult = mockCheckinRiskCalculationResult(risk: .low, dateForRisk: threeDaysAgo)
		let isSubmissionConsentGiven = true

		secureStore.dateOfConversionToCheckinHighRisk = Calendar.current.date(byAdding: .day, value: -1, to: Date())
		secureStore.checkinRiskCalculationResult = riskCalculationResult

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
			hoursSinceHighRiskWarningAtTestRegistration: -1,
			daysSinceMostRecentDateAtCheckinRiskLevelAtTestRegistration: -1,
			hoursSinceCheckinHighRiskWarningAtTestRegistration: -1,
			submittedWithCheckIns: nil
		)
		Analytics.collect(.keySubmissionMetadata(.create(keySubmissionMetadata)))
		Analytics.collect(.keySubmissionMetadata(.setDaysSinceMostRecentDateAtCheckinRiskLevelAtTestRegistration))
		Analytics.collect(.keySubmissionMetadata(.setHoursSinceCheckinHighRiskWarningAtTestRegistration))
		Analytics.collect(.keySubmissionMetadata(.submittedWithCheckins(true)))

		XCTAssertNotNil(secureStore.keySubmissionMetadata, "keySubmissionMetadata should be initialized with default values")
		XCTAssertEqual(secureStore.keySubmissionMetadata?.daysSinceMostRecentDateAtCheckinRiskLevelAtTestRegistration, 3, "number of days should be 3")
		XCTAssertEqual(secureStore.keySubmissionMetadata?.hoursSinceCheckinHighRiskWarningAtTestRegistration, -1, "the value should be default value i.e., -1 as the risk is low")
		XCTAssertEqual(secureStore.keySubmissionMetadata?.daysSinceMostRecentDateAtRiskLevelAtTestRegistration, -1, "property should not be changed from init param")
		XCTAssertEqual(secureStore.keySubmissionMetadata?.hoursSinceHighRiskWarningAtTestRegistration, -1, "property should not be changed from init param")
		guard let submittedWithCheckIns = secureStore.keySubmissionMetadata?.submittedWithCheckIns else {
			XCTFail("submittedWithCheckIns should not be nil.")
			return
		}
		XCTAssertTrue(submittedWithCheckIns)
	}
	
	func testKeySubmissionMetadataValues_BothLowRisk() {
		let secureStore = MockTestStore()
		secureStore.isPrivacyPreservingAnalyticsConsentGiven = true

		let coronaTestService = CoronaTestService(
			client: ClientMock(),
			store: secureStore,
			appConfiguration: CachedAppConfigurationMock()
		)

		Analytics.setupMock(store: secureStore, coronaTestService: coronaTestService)
		let isSubmissionConsentGiven = true
		let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: Date())
		
		let enfRiskCalculationResult = mockENFLowRiskCalculationResult()
		secureStore.dateOfConversionToENFHighRisk = yesterday
		secureStore.enfRiskCalculationResult = enfRiskCalculationResult
		
		guard let threeDaysAgo = Calendar.current.date(byAdding: .day, value: -3, to: Date()) else {
			XCTFail("Could not create date for two days ago.")
			return
		}
		let checkinRiskCalculationResult = mockCheckinRiskCalculationResult(risk: .low, dateForRisk: threeDaysAgo)
		secureStore.dateOfConversionToCheckinHighRisk = yesterday
		secureStore.checkinRiskCalculationResult = checkinRiskCalculationResult
		
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
			hoursSinceHighRiskWarningAtTestRegistration: -1,
			daysSinceMostRecentDateAtCheckinRiskLevelAtTestRegistration: -1,
			hoursSinceCheckinHighRiskWarningAtTestRegistration: -1,
			submittedWithCheckIns: nil
		)
		Analytics.collect(.keySubmissionMetadata(.create(keySubmissionMetadata)))
		Analytics.collect(.keySubmissionMetadata(.setDaysSinceMostRecentDateAtENFRiskLevelAtTestRegistration))
		Analytics.collect(.keySubmissionMetadata(.setHoursSinceENFHighRiskWarningAtTestRegistration))
		Analytics.collect(.keySubmissionMetadata(.setDaysSinceMostRecentDateAtCheckinRiskLevelAtTestRegistration))
		Analytics.collect(.keySubmissionMetadata(.setHoursSinceCheckinHighRiskWarningAtTestRegistration))
		Analytics.collect(.keySubmissionMetadata(.submittedWithCheckins(true)))

		XCTAssertNotNil(secureStore.keySubmissionMetadata, "keySubmissionMetadata should be initialized with default values")
		XCTAssertEqual(secureStore.keySubmissionMetadata?.daysSinceMostRecentDateAtRiskLevelAtTestRegistration, 3, "number of days should be 3")
		XCTAssertEqual(secureStore.keySubmissionMetadata?.hoursSinceHighRiskWarningAtTestRegistration, -1, "the value should be default value i.e., -1 as the risk is low")
		XCTAssertEqual(secureStore.keySubmissionMetadata?.daysSinceMostRecentDateAtCheckinRiskLevelAtTestRegistration, 3, "number of days should be 3")
		XCTAssertEqual(secureStore.keySubmissionMetadata?.hoursSinceCheckinHighRiskWarningAtTestRegistration, -1, "property should not be changed from init param")
		guard let submittedWithCheckIns = secureStore.keySubmissionMetadata?.submittedWithCheckIns else {
			XCTFail("submittedWithCheckIns should not be nil.")
			return
		}
		XCTAssertTrue(submittedWithCheckIns)
	}

	func testKeySubmissionMetadataValues_HighRisk_testHours() {
		let secureStore = MockTestStore()
		secureStore.isPrivacyPreservingAnalyticsConsentGiven = true
		let coronaTestService = CoronaTestService(
			client: ClientMock(),
			store: secureStore,
			appConfiguration: CachedAppConfigurationMock()
		)

		Analytics.setupMock(store: secureStore, coronaTestService: coronaTestService)
		
		let riskCalculationResult = mockENFHighRiskCalculationResult()
		let isSubmissionConsentGiven = true
		let dateSixHourAgo = Calendar.current.date(byAdding: .hour, value: -6, to: Date())
		secureStore.dateOfConversionToENFHighRisk = Calendar.current.date(byAdding: .day, value: -1, to: Date())
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
			hoursSinceHighRiskWarningAtTestRegistration: -1,
			daysSinceMostRecentDateAtCheckinRiskLevelAtTestRegistration: -1,
			hoursSinceCheckinHighRiskWarningAtTestRegistration: -1,
			submittedWithCheckIns: nil
		)
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
		let riskCalculationResult = mockENFHighRiskCalculationResult()
		let isSubmissionConsentGiven = true
		secureStore.dateOfConversionToENFHighRisk = Calendar.current.date(byAdding: .day, value: -1, to: Date())
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
			hoursSinceHighRiskWarningAtTestRegistration: -1,
			daysSinceMostRecentDateAtCheckinRiskLevelAtTestRegistration: -1,
			hoursSinceCheckinHighRiskWarningAtTestRegistration: -1,
			submittedWithCheckIns: nil
		)
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
		let riskCalculationResult = mockENFHighRiskCalculationResult()
		let isSubmissionConsentGiven = true
		secureStore.dateOfConversionToENFHighRisk = Calendar.current.date(byAdding: .day, value: -1, to: Date())
		secureStore.enfRiskCalculationResult = riskCalculationResult
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
			hoursSinceHighRiskWarningAtTestRegistration: -1,
			daysSinceMostRecentDateAtCheckinRiskLevelAtTestRegistration: -1,
			hoursSinceCheckinHighRiskWarningAtTestRegistration: -1,
			submittedWithCheckIns: nil
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

	private func mockENFHighRiskCalculationResult(risk: RiskLevel = .high) -> ENFRiskCalculationResult {
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
	private func mockENFLowRiskCalculationResult(risk: RiskLevel = .low) -> ENFRiskCalculationResult {
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
	
	private func mockCheckinRiskCalculationResult(risk: RiskLevel = .high, dateForRisk: Date = Date()) -> CheckinRiskCalculationResult {
		let checkinIdWithRisk = CheckinIdWithRisk(
			checkinId: 007,
			riskLevel: risk
		)
		
		return CheckinRiskCalculationResult(
			calculationDate: Date(),
			checkinIdsWithRiskPerDate: [dateForRisk: [checkinIdWithRisk]],
			riskLevelPerDate: [dateForRisk: risk]
		)
	}
}
