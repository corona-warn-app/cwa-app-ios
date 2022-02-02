//
// 🦠 Corona-Warn-App
//

@testable import ENA
import HealthCertificateToolkit
import XCTest
// Testpattern:
// ENF high, Checkin none
// ENF none, Checkin high
// ENF high, Checkin high
// ENF low, Checkin none
// ENF none, Checkin low
// ENF low, Checkin low
// inside these tests, we alter for testType (pcr & antigen)

// swiftlint:disable:next type_body_length
class KeySubmissionMetadataTests: CWATestCase {

	private func makeCoronaTestService(store: Store) -> CoronaTestService {
		let client = ClientMock()
		let appConfiguration = CachedAppConfigurationMock()

		return CoronaTestService(
			client: client,
			store: store,
			eventStore: MockEventStore(),
			diaryStore: MockDiaryStore(),
			appConfiguration: appConfiguration,
			healthCertificateService: HealthCertificateService(
				store: store,
				dccSignatureVerifier: DCCSignatureVerifyingStub(),
				dscListProvider: MockDSCListProvider(),
				client: client,
				appConfiguration: appConfiguration,
				cclService: FakeCCLService(),
				recycleBin: .fake()
			),
			recycleBin: .fake(),
			badgeWrapper: .fake()
		)
	}
		
	func testKeySubmissionMetadataValues_ENFHighRisk() {
		let secureStore = MockTestStore()
		let coronaTestService = makeCoronaTestService(store: secureStore)

		Analytics.setupMock(store: secureStore, coronaTestService: coronaTestService)

		secureStore.isPrivacyPreservingAnalyticsConsentGiven = true

		let riskCalculationResult = mockENFHighRiskCalculationResult()

		secureStore.dateOfConversionToENFHighRisk = Calendar.current.date(byAdding: .day, value: -1, to: Date())
		secureStore.enfRiskCalculationResult = riskCalculationResult

		coronaTestService.pcrTest = PCRTest.mock(registrationDate: Date())
		coronaTestService.antigenTest = AntigenTest.mock(registrationDate: Date())

		let keySubmissionMetadata = mockEmptyKeySubmissionMetadata()
		
		Analytics.collect(.keySubmissionMetadata(.create(keySubmissionMetadata, .pcr)))
		Analytics.collect(.keySubmissionMetadata(.setDaysSinceMostRecentDateAtENFRiskLevelAtTestRegistration(.pcr)))
		Analytics.collect(.keySubmissionMetadata(.setHoursSinceENFHighRiskWarningAtTestRegistration(.pcr)))
		Analytics.collect(.keySubmissionMetadata(.submittedAfterRapidAntigenTest(.pcr)))
		Analytics.collect(.keySubmissionMetadata(.submittedWithCheckins(false, .pcr)))
		
		Analytics.collect(.keySubmissionMetadata(.create(keySubmissionMetadata, .antigen)))
		Analytics.collect(.keySubmissionMetadata(.setDaysSinceMostRecentDateAtENFRiskLevelAtTestRegistration(.antigen)))
		Analytics.collect(.keySubmissionMetadata(.setHoursSinceENFHighRiskWarningAtTestRegistration(.antigen)))
		Analytics.collect(.keySubmissionMetadata(.submittedAfterRapidAntigenTest(.antigen)))
		Analytics.collect(.keySubmissionMetadata(.submittedWithCheckins(false, .antigen)))
		
	
		XCTAssertNotNil(secureStore.pcrKeySubmissionMetadata, "pcrKeySubmissionMetadata should be initialized with default values")
		XCTAssertEqual(secureStore.pcrKeySubmissionMetadata?.daysSinceMostRecentDateAtRiskLevelAtTestRegistration, 2, "number of days should be 2")
		XCTAssertEqual(secureStore.pcrKeySubmissionMetadata?.hoursSinceHighRiskWarningAtTestRegistration, 24, "the difference is one day so it should be 24")
		XCTAssertFalse(secureStore.pcrKeySubmissionMetadata?.submittedAfterRapidAntigenTest ?? true)
		XCTAssertEqual(secureStore.pcrKeySubmissionMetadata?.daysSinceMostRecentDateAtCheckinRiskLevelAtTestRegistration, -1, "property should not be changed from init param")
		XCTAssertEqual(secureStore.pcrKeySubmissionMetadata?.hoursSinceCheckinHighRiskWarningAtTestRegistration, -1, "property should not be changed from init param")
		XCTAssertFalse(secureStore.pcrKeySubmissionMetadata?.submittedWithCheckIns ?? true)
			
		XCTAssertNotNil(secureStore.antigenKeySubmissionMetadata, "keySubmissionMetadata should be initialized with default values")
		XCTAssertEqual(secureStore.antigenKeySubmissionMetadata?.daysSinceMostRecentDateAtRiskLevelAtTestRegistration, 2, "number of days should be 2")
		XCTAssertEqual(secureStore.antigenKeySubmissionMetadata?.hoursSinceHighRiskWarningAtTestRegistration, 24, "the difference is one day so it should be 24")
		XCTAssertTrue(secureStore.antigenKeySubmissionMetadata?.submittedAfterRapidAntigenTest ?? false)
		XCTAssertEqual(secureStore.antigenKeySubmissionMetadata?.daysSinceMostRecentDateAtCheckinRiskLevelAtTestRegistration, -1, "property should not be changed from init param")
		XCTAssertEqual(secureStore.antigenKeySubmissionMetadata?.hoursSinceCheckinHighRiskWarningAtTestRegistration, -1, "property should not be changed from init param")
		XCTAssertFalse(secureStore.antigenKeySubmissionMetadata?.submittedWithCheckIns ?? true)
		
	}
	
	func testKeySubmissionMetadataValues_CheckinHighRisk() {
		let secureStore = MockTestStore()
		let coronaTestService = makeCoronaTestService(store: secureStore)

		Analytics.setupMock(store: secureStore, coronaTestService: coronaTestService)

		secureStore.isPrivacyPreservingAnalyticsConsentGiven = true

		guard let twoDaysAgo = Calendar.current.date(byAdding: .day, value: -2, to: Date()) else {
			XCTFail("Could not create date for two days ago.")
			return
		}
		let riskCalculationResult = mockCheckinRiskCalculationResult(dateForRisk: twoDaysAgo)

		secureStore.dateOfConversionToCheckinHighRisk = Calendar.current.date(byAdding: .day, value: -1, to: Date())
		secureStore.checkinRiskCalculationResult = riskCalculationResult

		coronaTestService.pcrTest = PCRTest.mock(registrationDate: Date())

		let keySubmissionMetadata = mockEmptyKeySubmissionMetadata()
		
		Analytics.collect(.keySubmissionMetadata(.create(keySubmissionMetadata, .pcr)))
		Analytics.collect(.keySubmissionMetadata(.setDaysSinceMostRecentDateAtCheckinRiskLevelAtTestRegistration(.pcr)))
		Analytics.collect(.keySubmissionMetadata(.setHoursSinceCheckinHighRiskWarningAtTestRegistration(.pcr)))
		Analytics.collect(.keySubmissionMetadata(.submittedWithCheckins(true, .pcr)))

		XCTAssertNotNil(secureStore.pcrKeySubmissionMetadata, "keySubmissionMetadata should be initialized with default values")
		XCTAssertEqual(secureStore.pcrKeySubmissionMetadata?.daysSinceMostRecentDateAtCheckinRiskLevelAtTestRegistration, 2, "number of days should be 2")
		XCTAssertEqual(secureStore.pcrKeySubmissionMetadata?.hoursSinceCheckinHighRiskWarningAtTestRegistration, 24, "the difference is one day so it should be 24")
		XCTAssertEqual(secureStore.pcrKeySubmissionMetadata?.daysSinceMostRecentDateAtRiskLevelAtTestRegistration, -1, "property should not be changed from init param")
		XCTAssertEqual(secureStore.pcrKeySubmissionMetadata?.hoursSinceHighRiskWarningAtTestRegistration, -1, "property should not be changed from init param")
		guard let submittedWithCheckIns = secureStore.pcrKeySubmissionMetadata?.submittedWithCheckIns else {
			XCTFail("submittedWithCheckIns should not be nil.")
			return
		}
		XCTAssertTrue(submittedWithCheckIns)
		XCTAssertNil(secureStore.antigenKeySubmissionMetadata)
	}
	
	func testKeySubmissionMetadataValues_BothHighRisk() {
		let secureStore = MockTestStore()
		let coronaTestService = makeCoronaTestService(store: secureStore)

		Analytics.setupMock(store: secureStore, coronaTestService: coronaTestService)
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
		
		coronaTestService.antigenTest = AntigenTest.mock(registrationDate: Date())

		let keySubmissionMetadata = mockEmptyKeySubmissionMetadata()
		
		Analytics.collect(.keySubmissionMetadata(.create(keySubmissionMetadata, .antigen)))
		Analytics.collect(.keySubmissionMetadata(.setDaysSinceMostRecentDateAtENFRiskLevelAtTestRegistration(.antigen)))
		Analytics.collect(.keySubmissionMetadata(.setHoursSinceENFHighRiskWarningAtTestRegistration(.antigen)))
		Analytics.collect(.keySubmissionMetadata(.setDaysSinceMostRecentDateAtCheckinRiskLevelAtTestRegistration(.antigen)))
		Analytics.collect(.keySubmissionMetadata(.setHoursSinceCheckinHighRiskWarningAtTestRegistration(.antigen)))
		Analytics.collect(.keySubmissionMetadata(.submittedWithCheckins(true, .antigen)))

		XCTAssertNotNil(secureStore.antigenKeySubmissionMetadata, "keySubmissionMetadata should be initialized with default values")
		XCTAssertEqual(secureStore.antigenKeySubmissionMetadata?.daysSinceMostRecentDateAtRiskLevelAtTestRegistration, 2, "number of days should be 2")
		XCTAssertEqual(secureStore.antigenKeySubmissionMetadata?.hoursSinceHighRiskWarningAtTestRegistration, 24, "the difference is one day so it should be 24")
		XCTAssertEqual(secureStore.antigenKeySubmissionMetadata?.daysSinceMostRecentDateAtCheckinRiskLevelAtTestRegistration, 2, "number of days should be 2")
		XCTAssertEqual(secureStore.antigenKeySubmissionMetadata?.hoursSinceCheckinHighRiskWarningAtTestRegistration, 24, "the difference is one day so it should be 24")
		guard let submittedWithCheckIns = secureStore.antigenKeySubmissionMetadata?.submittedWithCheckIns else {
			XCTFail("submittedWithCheckIns should not be nil.")
			return
		}
		XCTAssertTrue(submittedWithCheckIns)
		XCTAssertNil(secureStore.pcrKeySubmissionMetadata)
	}
	
	func testKeySubmissionMetadataValues_ENFLowRisk() {
		let secureStore = MockTestStore()
		secureStore.isPrivacyPreservingAnalyticsConsentGiven = true

		let coronaTestService = makeCoronaTestService(store: secureStore)

		Analytics.setupMock(store: secureStore, coronaTestService: coronaTestService)

		let riskCalculationResult = mockENFLowRiskCalculationResult()

		secureStore.dateOfConversionToENFHighRisk = Calendar.current.date(byAdding: .day, value: -1, to: Date())
		secureStore.enfRiskCalculationResult = riskCalculationResult

		coronaTestService.pcrTest = PCRTest.mock(registrationDate: Date())

		let keySubmissionMetadata = mockEmptyKeySubmissionMetadata()
		
		Analytics.collect(.keySubmissionMetadata(.create(keySubmissionMetadata, .pcr)))
		Analytics.collect(.keySubmissionMetadata(.setDaysSinceMostRecentDateAtENFRiskLevelAtTestRegistration(.pcr)))
		Analytics.collect(.keySubmissionMetadata(.setHoursSinceENFHighRiskWarningAtTestRegistration(.pcr)))

		XCTAssertNotNil(secureStore.pcrKeySubmissionMetadata, "keySubmissionMetadata should be initialized with default values")
		XCTAssertEqual(secureStore.pcrKeySubmissionMetadata?.daysSinceMostRecentDateAtRiskLevelAtTestRegistration, 3, "number of days should be 3")
		XCTAssertEqual(secureStore.pcrKeySubmissionMetadata?.hoursSinceHighRiskWarningAtTestRegistration, -1, "the value should be default value i.e., -1 as the risk is low")
		XCTAssertEqual(secureStore.pcrKeySubmissionMetadata?.daysSinceMostRecentDateAtCheckinRiskLevelAtTestRegistration, -1, "property should not be changed from init param")
		XCTAssertEqual(secureStore.pcrKeySubmissionMetadata?.hoursSinceCheckinHighRiskWarningAtTestRegistration, -1, "property should not be changed from init param")
		XCTAssertNil(secureStore.pcrKeySubmissionMetadata?.submittedWithCheckIns)
		XCTAssertNil(secureStore.antigenKeySubmissionMetadata)
	}
	
	func testKeySubmissionMetadataValues_CheckinLowRisk() {
		let secureStore = MockTestStore()
		secureStore.isPrivacyPreservingAnalyticsConsentGiven = true
		let coronaTestService = makeCoronaTestService(store: secureStore)

		Analytics.setupMock(store: secureStore, coronaTestService: coronaTestService)

		guard let threeDaysAgo = Calendar.current.date(byAdding: .day, value: -3, to: Date()) else {
			XCTFail("Could not create date for two days ago.")
			return
		}
		let riskCalculationResult = mockCheckinRiskCalculationResult(risk: .low, dateForRisk: threeDaysAgo)

		secureStore.dateOfConversionToCheckinHighRisk = Calendar.current.date(byAdding: .day, value: -1, to: Date())
		secureStore.checkinRiskCalculationResult = riskCalculationResult

		coronaTestService.antigenTest = AntigenTest.mock(registrationDate: Date())

		let keySubmissionMetadata = mockEmptyKeySubmissionMetadata()
		
		Analytics.collect(.keySubmissionMetadata(.create(keySubmissionMetadata, .antigen)))
		Analytics.collect(.keySubmissionMetadata(.setDaysSinceMostRecentDateAtCheckinRiskLevelAtTestRegistration(.antigen)))
		Analytics.collect(.keySubmissionMetadata(.setHoursSinceCheckinHighRiskWarningAtTestRegistration(.antigen)))
		Analytics.collect(.keySubmissionMetadata(.submittedWithCheckins(true, .antigen)))

		XCTAssertNotNil(secureStore.antigenKeySubmissionMetadata, "keySubmissionMetadata should be initialized with default values")
		XCTAssertEqual(secureStore.antigenKeySubmissionMetadata?.daysSinceMostRecentDateAtCheckinRiskLevelAtTestRegistration, 3, "number of days should be 3")
		XCTAssertEqual(secureStore.antigenKeySubmissionMetadata?.hoursSinceCheckinHighRiskWarningAtTestRegistration, -1, "the value should be default value i.e., -1 as the risk is low")
		XCTAssertEqual(secureStore.antigenKeySubmissionMetadata?.daysSinceMostRecentDateAtRiskLevelAtTestRegistration, -1, "property should not be changed from init param")
		XCTAssertEqual(secureStore.antigenKeySubmissionMetadata?.hoursSinceHighRiskWarningAtTestRegistration, -1, "property should not be changed from init param")
		guard let submittedWithCheckIns = secureStore.antigenKeySubmissionMetadata?.submittedWithCheckIns else {
			XCTFail("submittedWithCheckIns should not be nil.")
			return
		}
		XCTAssertTrue(submittedWithCheckIns)
		XCTAssertNil(secureStore.pcrKeySubmissionMetadata)
	}
	
	func testKeySubmissionMetadataValues_BothLowRisk() {
		let secureStore = MockTestStore()
		secureStore.isPrivacyPreservingAnalyticsConsentGiven = true
		let coronaTestService = makeCoronaTestService(store: secureStore)

		Analytics.setupMock(store: secureStore, coronaTestService: coronaTestService)
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

		let keySubmissionMetadata = mockEmptyKeySubmissionMetadata()
		
		Analytics.collect(.keySubmissionMetadata(.create(keySubmissionMetadata, .pcr)))
		Analytics.collect(.keySubmissionMetadata(.setDaysSinceMostRecentDateAtENFRiskLevelAtTestRegistration(.pcr)))
		Analytics.collect(.keySubmissionMetadata(.setHoursSinceENFHighRiskWarningAtTestRegistration(.pcr)))
		Analytics.collect(.keySubmissionMetadata(.setDaysSinceMostRecentDateAtCheckinRiskLevelAtTestRegistration(.pcr)))
		Analytics.collect(.keySubmissionMetadata(.setHoursSinceCheckinHighRiskWarningAtTestRegistration(.pcr)))
		Analytics.collect(.keySubmissionMetadata(.submittedWithCheckins(true, .pcr)))

		XCTAssertNotNil(secureStore.pcrKeySubmissionMetadata, "keySubmissionMetadata should be initialized with default values")
		XCTAssertEqual(secureStore.pcrKeySubmissionMetadata?.daysSinceMostRecentDateAtRiskLevelAtTestRegistration, 3, "number of days should be 3")
		XCTAssertEqual(secureStore.pcrKeySubmissionMetadata?.hoursSinceHighRiskWarningAtTestRegistration, -1, "the value should be default value i.e., -1 as the risk is low")
		XCTAssertEqual(secureStore.pcrKeySubmissionMetadata?.daysSinceMostRecentDateAtCheckinRiskLevelAtTestRegistration, 3, "number of days should be 3")
		XCTAssertEqual(secureStore.pcrKeySubmissionMetadata?.hoursSinceCheckinHighRiskWarningAtTestRegistration, -1, "property should not be changed from init param")
		guard let submittedWithCheckIns = secureStore.pcrKeySubmissionMetadata?.submittedWithCheckIns else {
			XCTFail("submittedWithCheckIns should not be nil.")
			return
		}
		XCTAssertTrue(submittedWithCheckIns)
		XCTAssertNil(secureStore.antigenKeySubmissionMetadata)
	}

	func testKeySubmissionMetadataValues_HighRisk_testHours() {
		let secureStore = MockTestStore()
		secureStore.isPrivacyPreservingAnalyticsConsentGiven = true
		let coronaTestService = makeCoronaTestService(store: secureStore)

		Analytics.setupMock(store: secureStore, coronaTestService: coronaTestService)
		
		let riskCalculationResult = mockENFHighRiskCalculationResult()
		let dateSixHourAgo = Calendar.current.date(byAdding: .hour, value: -6, to: Date())
		secureStore.dateOfConversionToENFHighRisk = Calendar.current.date(byAdding: .day, value: -1, to: Date())
		secureStore.enfRiskCalculationResult = riskCalculationResult

		coronaTestService.pcrTest = PCRTest.mock(
			registrationDate: Calendar.current.date(byAdding: .day, value: -1, to: Date()) ?? Date(),
			finalTestResultReceivedDate: dateSixHourAgo ?? Date()
		)
		coronaTestService.antigenTest = AntigenTest.mock(
			registrationDate: Calendar.current.date(byAdding: .day, value: -1, to: Date()) ?? Date(),
			finalTestResultReceivedDate: dateSixHourAgo ?? Date()
		)

		let keySubmissionMetadata = mockEmptyKeySubmissionMetadata()
		
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
		let coronaTestService = makeCoronaTestService(store: secureStore)

		Analytics.setupMock(
			store: secureStore,
			coronaTestService: coronaTestService
		)
		secureStore.isPrivacyPreservingAnalyticsConsentGiven = true
		let riskCalculationResult = mockENFHighRiskCalculationResult()
		secureStore.dateOfConversionToENFHighRisk = Calendar.current.date(byAdding: .day, value: -1, to: Date())
		secureStore.enfRiskCalculationResult = riskCalculationResult

		let keySubmissionMetadata = mockEmptyKeySubmissionMetadata()
		
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
		let coronaTestService = makeCoronaTestService(store: secureStore)

		Analytics.setupMock(
			store: secureStore,
			coronaTestService: coronaTestService
		)
		secureStore.isPrivacyPreservingAnalyticsConsentGiven = true
		let riskCalculationResult = mockENFHighRiskCalculationResult()
		secureStore.dateOfConversionToENFHighRisk = Calendar.current.date(byAdding: .day, value: -1, to: Date())
		secureStore.enfRiskCalculationResult = riskCalculationResult
		Analytics.collect(.keySubmissionMetadata(.submittedWithTeletan(false, .pcr)))

		let keySubmissionMetadata = mockEmptyKeySubmissionMetadata()
			
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
	
	private func mockEmptyKeySubmissionMetadata(isSubmissionConsentGiven: Bool = true) -> KeySubmissionMetadata {
		return KeySubmissionMetadata(
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
			submittedWithTeleTAN: false,
			submittedAfterRapidAntigenTest: false,
			daysSinceMostRecentDateAtCheckinRiskLevelAtTestRegistration: -1,
			hoursSinceCheckinHighRiskWarningAtTestRegistration: -1,
			submittedWithCheckIns: nil
		)
	}
}
