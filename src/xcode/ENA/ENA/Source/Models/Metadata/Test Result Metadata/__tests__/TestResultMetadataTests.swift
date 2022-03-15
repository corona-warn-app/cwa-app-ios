////
// 🦠 Corona-Warn-App
//

@testable import ENA
import XCTest

class TestResultMetadataTests: CWATestCase {
	/// Testpattern:
	/// ENF empty risk, Checkin empty risk
	/// ENF low, Checkin none
	/// ENF high, Checkin none
	/// ENF none, Checkin low
	/// ENF none, Checkin high
	/// ENF low, Checkin low
	/// ENF high, Checkin high
	/// inside these tests, we alter for testType (pcr & antigen)
	/// Afterwards follows the tests for the remaining properties
	
	func testGIVEN_RegisteringNewTestMetadata_WHEN_ENFEmptyRisk_CheckinEmptyRisk_THEN_BothDefaultValues() {
		// GIVEN
		let secureStore = MockTestStore()
		Analytics.setupMock(store: secureStore)
		secureStore.isPrivacyPreservingAnalyticsConsentGiven = true
		
		let today = Date()
		let enfRiskCalculationResult: ENFRiskCalculationResult = .fake(riskLevel: .low)
		secureStore.enfRiskCalculationResult = enfRiskCalculationResult
		let checkinRiskCalculationResult = mockCheckinRiskCalculationResult(risk: .low)
		secureStore.checkinRiskCalculationResult = checkinRiskCalculationResult
		
		// WHEN
		Analytics.collect(.testResultMetadata(.registerNewTestMetadata(today, "", .pcr)))
		Analytics.collect(.testResultMetadata(.registerNewTestMetadata(today, "", .antigen)))
		
		// THEN
		XCTAssertNotNil(secureStore.pcrTestResultMetadata, "The pcrTestResultMetadata should be initialized")
		XCTAssertEqual(secureStore.pcrTestResultMetadata?.testRegistrationDate, today, "incorrect RegistrationDate")
		
		XCTAssertEqual(secureStore.pcrTestResultMetadata?.riskLevelAtTestRegistration, enfRiskCalculationResult.riskLevel, "incorrect risk level")
		XCTAssertEqual(secureStore.pcrTestResultMetadata?.daysSinceMostRecentDateAtRiskLevelAtTestRegistration, -1, "should be -1 if there is no recentDate for riskLevel")
		XCTAssertEqual(secureStore.pcrTestResultMetadata?.hoursSinceHighRiskWarningAtTestRegistration, -1, "should be -1 if there is no recentDate for riskLevel")
		
		XCTAssertEqual(secureStore.pcrTestResultMetadata?.checkinRiskLevelAtTestRegistration, checkinRiskCalculationResult.riskLevel, "incorrect risk level")
		XCTAssertEqual(secureStore.pcrTestResultMetadata?.daysSinceMostRecentDateAtCheckinRiskLevelAtTestRegistration, -1, "should be -1 if there is no recentDate for riskLevel")
		XCTAssertEqual(secureStore.pcrTestResultMetadata?.hoursSinceCheckinHighRiskWarningAtTestRegistration, -1, "should be -1 if there is no recentDate for riskLevel")
		
		XCTAssertNotNil(secureStore.antigenTestResultMetadata, "The antigenTestResultMetadata should be initialized")
		XCTAssertEqual(secureStore.antigenTestResultMetadata?.testRegistrationDate, today, "incorrect RegistrationDate")
		
		XCTAssertEqual(secureStore.antigenTestResultMetadata?.riskLevelAtTestRegistration, enfRiskCalculationResult.riskLevel, "incorrect risk level")
		XCTAssertEqual(secureStore.antigenTestResultMetadata?.daysSinceMostRecentDateAtRiskLevelAtTestRegistration, -1, "should be -1 if there is no recentDate for riskLevel")
		XCTAssertEqual(secureStore.antigenTestResultMetadata?.hoursSinceHighRiskWarningAtTestRegistration, -1, "should be -1 if there is no recentDate for riskLevel")
		
		XCTAssertEqual(secureStore.antigenTestResultMetadata?.checkinRiskLevelAtTestRegistration, checkinRiskCalculationResult.riskLevel, "incorrect risk level")
		XCTAssertEqual(secureStore.antigenTestResultMetadata?.daysSinceMostRecentDateAtCheckinRiskLevelAtTestRegistration, -1, "should be -1 if there is no recentDate for riskLevel")
		XCTAssertEqual(secureStore.antigenTestResultMetadata?.hoursSinceCheckinHighRiskWarningAtTestRegistration, -1, "should be -1 if there is no recentDate for riskLevel")
	}
	
	func testGIVEN_RegisteringNewTestMetadata_WHEN_ENFLowRisk_CheckinNone_THEN_OnlyENFIsSet() {
		// GIVEN
		let secureStore = MockTestStore()
		Analytics.setupMock(store: secureStore)
		secureStore.isPrivacyPreservingAnalyticsConsentGiven = true
		
		let today = Date()
		let expectedDaysSinceRecentAtRiskLevelAtTestRegistration = 5
		guard let mostRecentDateHighRisk = Calendar.current.date(byAdding: .day, value: -expectedDaysSinceRecentAtRiskLevelAtTestRegistration, to: today) else {
			XCTFail("Could not create mostRecentDateHighRisk")
			return
		}
		let checkinRiskCalculationResult = mockCheckinRiskCalculationResult(risk: .high, dateForRisk: mostRecentDateHighRisk)
		secureStore.dateOfConversionToCheckinHighRisk = Calendar.current.date(byAdding: .day, value: -1, to: today)
		secureStore.checkinRiskCalculationResult = checkinRiskCalculationResult
		
		// WHEN
		Analytics.collect(.testResultMetadata(.registerNewTestMetadata(today, "", .pcr)))

		// THEN
		XCTAssertNotNil(secureStore.pcrTestResultMetadata, "The testResultMetadata should be initialized")
		XCTAssertEqual(secureStore.pcrTestResultMetadata?.testRegistrationDate, today, "incorrect RegistrationDate")
		XCTAssertEqual(secureStore.pcrTestResultMetadata?.checkinRiskLevelAtTestRegistration, checkinRiskCalculationResult.riskLevel, "incorrect risk level")
		XCTAssertEqual(secureStore.pcrTestResultMetadata?.daysSinceMostRecentDateAtCheckinRiskLevelAtTestRegistration, expectedDaysSinceRecentAtRiskLevelAtTestRegistration, "incorrect days since recent riskLevel")
		// the difference from dateOfConversionToENFHighRisk should be one day so 24 hours
		XCTAssertEqual(secureStore.pcrTestResultMetadata?.hoursSinceCheckinHighRiskWarningAtTestRegistration, 24, "incorrect hours")
		
		XCTAssertNil(secureStore.pcrTestResultMetadata?.riskLevelAtTestRegistration, "value should not be set")
		XCTAssertNil(secureStore.pcrTestResultMetadata?.daysSinceMostRecentDateAtRiskLevelAtTestRegistration, "value should not be set")
		XCTAssertNil(secureStore.pcrTestResultMetadata?.hoursSinceHighRiskWarningAtTestRegistration, "value should not be set")
		XCTAssertNil(secureStore.antigenTestResultMetadata)
	}
	
	func testGIVEN_RegisteringNewTestMetadata_WHEN_ENFHighRisk_CheckinNone_THEN_OnlyENFIsSet() {
		// GIVEN
		let secureStore = MockTestStore()
		Analytics.setupMock(store: secureStore)
		secureStore.isPrivacyPreservingAnalyticsConsentGiven = true
		
		let today = Date()
		let expectedDaysSinceRecentAtRiskLevelAtTestRegistration = 5
		guard let mostRecentDateHighRisk = Calendar.current.date(byAdding: .day, value: -expectedDaysSinceRecentAtRiskLevelAtTestRegistration, to: today) else {
			XCTFail("Could not create mostRecentDateHighRisk")
			return
		}
		
		let enfRiskCalculationResult: ENFRiskCalculationResult = .fake(riskLevel: .high, mostRecentDateWithHighRisk: mostRecentDateHighRisk)
		secureStore.dateOfConversionToENFHighRisk = Calendar.current.date(byAdding: .day, value: -1, to: today)
		secureStore.enfRiskCalculationResult = enfRiskCalculationResult
		
		// WHEN
		Analytics.collect(.testResultMetadata(.registerNewTestMetadata(today, "", .antigen)))
		
		// THEN
		XCTAssertNotNil(secureStore.antigenTestResultMetadata, "The testResultMetadata should be initialized")
		XCTAssertEqual(secureStore.antigenTestResultMetadata?.testRegistrationDate, today, "incorrect RegistrationDate")
		XCTAssertEqual(secureStore.antigenTestResultMetadata?.riskLevelAtTestRegistration, enfRiskCalculationResult.riskLevel, "incorrect risk level")
		XCTAssertEqual(secureStore.antigenTestResultMetadata?.daysSinceMostRecentDateAtRiskLevelAtTestRegistration, expectedDaysSinceRecentAtRiskLevelAtTestRegistration, "incorrect days since recent riskLevel")
		// the difference from dateOfConversionToENFHighRisk should be one day so 24 hours
		XCTAssertEqual(secureStore.antigenTestResultMetadata?.hoursSinceHighRiskWarningAtTestRegistration, 24, "incorrect hours")
		
		XCTAssertNil(secureStore.antigenTestResultMetadata?.checkinRiskLevelAtTestRegistration, "value should not be set")
		XCTAssertNil(secureStore.antigenTestResultMetadata?.daysSinceMostRecentDateAtCheckinRiskLevelAtTestRegistration, "value should not be set")
		XCTAssertNil(secureStore.antigenTestResultMetadata?.hoursSinceCheckinHighRiskWarningAtTestRegistration, "value should not be set")
		XCTAssertNil(secureStore.pcrTestResultMetadata)
	}
	
	func testGIVEN_RegisteringNewTestMetadata_WHEN_CheckinLowRisk_ENFNone_THEN_OnlyCheckinIsSet() {
		// GIVEN
		let secureStore = MockTestStore()
		Analytics.setupMock(store: secureStore)
		secureStore.isPrivacyPreservingAnalyticsConsentGiven = true
		
		let today = Date()
		let expectedDaysSinceRecentAtRiskLevelAtTestRegistration = 5
		guard let mostRecentDateRisk = Calendar.current.date(byAdding: .day, value: -expectedDaysSinceRecentAtRiskLevelAtTestRegistration, to: today) else {
			XCTFail("Could not create mostRecentDateHighRisk")
			return
		}
		let checkinRiskCalculationResult = mockCheckinRiskCalculationResult(risk: .low, dateForRisk: mostRecentDateRisk)
		secureStore.dateOfConversionToCheckinHighRisk = Calendar.current.date(byAdding: .day, value: -1, to: today)
		secureStore.checkinRiskCalculationResult = checkinRiskCalculationResult
		
		// WHEN
		Analytics.collect(.testResultMetadata(.registerNewTestMetadata(today, "", .pcr)))

		// THEN
		XCTAssertNotNil(secureStore.pcrTestResultMetadata, "The testResultMetadata should be initialized")
		XCTAssertEqual(secureStore.pcrTestResultMetadata?.testRegistrationDate, today, "incorrect RegistrationDate")
		
		XCTAssertNil(secureStore.pcrTestResultMetadata?.riskLevelAtTestRegistration, "value should not be set")
		XCTAssertNil(secureStore.pcrTestResultMetadata?.daysSinceMostRecentDateAtRiskLevelAtTestRegistration, "value should not be set")
		XCTAssertNil(secureStore.pcrTestResultMetadata?.hoursSinceHighRiskWarningAtTestRegistration, "value should not be set")
		
		XCTAssertEqual(secureStore.pcrTestResultMetadata?.checkinRiskLevelAtTestRegistration, checkinRiskCalculationResult.riskLevel, "incorrect risk level")
		XCTAssertEqual(secureStore.pcrTestResultMetadata?.daysSinceMostRecentDateAtCheckinRiskLevelAtTestRegistration, expectedDaysSinceRecentAtRiskLevelAtTestRegistration, "incorrect days since recent riskLevel")
		XCTAssertEqual(secureStore.pcrTestResultMetadata?.hoursSinceCheckinHighRiskWarningAtTestRegistration, -1, "value should not be touched, so stay at default: -1")
		XCTAssertNil(secureStore.antigenTestResultMetadata)
	}
	
	func testGIVEN_RegisteringNewTestMetadata_WHEN_CheckinHighRisk_ENFNone_THEN_OnlyCheckinIsSet() {
		// GIVEN
		let secureStore = MockTestStore()
		Analytics.setupMock(store: secureStore)
		secureStore.isPrivacyPreservingAnalyticsConsentGiven = true
		
		let today = Date()
		let expectedDaysSinceRecentAtRiskLevelAtTestRegistration = 5
		guard let mostRecentDateRisk = Calendar.current.date(byAdding: .day, value: -expectedDaysSinceRecentAtRiskLevelAtTestRegistration, to: today) else {
			XCTFail("Could not create mostRecentDateHighRisk")
			return
		}
		
		// set checkin to high
		let checkinRiskCalculationResult = mockCheckinRiskCalculationResult(risk: .high, dateForRisk: mostRecentDateRisk)
		secureStore.dateOfConversionToCheckinHighRisk = Calendar.current.date(byAdding: .day, value: -1, to: today)
		secureStore.checkinRiskCalculationResult = checkinRiskCalculationResult
		
		// WHEN
		Analytics.collect(.testResultMetadata(.registerNewTestMetadata(today, "", .antigen)))

		// THEN
		XCTAssertNotNil(secureStore.antigenTestResultMetadata, "The testResultMetadata should be initialized")
		XCTAssertEqual(secureStore.antigenTestResultMetadata?.testRegistrationDate, today, "incorrect RegistrationDate")
		
		XCTAssertNil(secureStore.antigenTestResultMetadata?.riskLevelAtTestRegistration, "value should not be set")
		XCTAssertNil(secureStore.antigenTestResultMetadata?.daysSinceMostRecentDateAtRiskLevelAtTestRegistration, "value should not be set")
		XCTAssertNil(secureStore.antigenTestResultMetadata?.hoursSinceHighRiskWarningAtTestRegistration, "value should not be set")
		
		XCTAssertEqual(secureStore.antigenTestResultMetadata?.checkinRiskLevelAtTestRegistration, checkinRiskCalculationResult.riskLevel, "incorrect risk level")
		XCTAssertEqual(secureStore.antigenTestResultMetadata?.daysSinceMostRecentDateAtCheckinRiskLevelAtTestRegistration, expectedDaysSinceRecentAtRiskLevelAtTestRegistration, "incorrect days since recent riskLevel")
		XCTAssertEqual(secureStore.antigenTestResultMetadata?.hoursSinceCheckinHighRiskWarningAtTestRegistration, 24, "incorrect hours")
		XCTAssertNil(secureStore.pcrTestResultMetadata)
	}
	
	func testGIVEN_RegisteringNewTestMetadata_WHEN_ENFLowRisk_CheckinLowRisk_THEN_BothLowRisk() {
		// GIVEN
		let secureStore = MockTestStore()
		Analytics.setupMock(store: secureStore)
		secureStore.isPrivacyPreservingAnalyticsConsentGiven = true
		
		let today = Date()
		let expectedDaysSinceRecentAtRiskLevelAtTestRegistration = 5
		guard let mostRecentDateRisk = Calendar.current.date(byAdding: .day, value: -expectedDaysSinceRecentAtRiskLevelAtTestRegistration, to: today) else {
			XCTFail("Could not create mostRecentDateHighRisk")
			return
		}
		
		// set ENF to low
		let enfRiskCalculationResult: ENFRiskCalculationResult = .fake(riskLevel: .low, mostRecentDateWithLowRisk: mostRecentDateRisk)
		secureStore.dateOfConversionToENFHighRisk = Calendar.current.date(byAdding: .day, value: -1, to: today)
		secureStore.enfRiskCalculationResult = enfRiskCalculationResult
		
		// set checkin to low
		let checkinRiskCalculationResult = mockCheckinRiskCalculationResult(risk: .low, dateForRisk: mostRecentDateRisk)
		secureStore.dateOfConversionToCheckinHighRisk = Calendar.current.date(byAdding: .day, value: -1, to: today)
		secureStore.checkinRiskCalculationResult = checkinRiskCalculationResult

		// WHEN
		Analytics.collect(.testResultMetadata(.registerNewTestMetadata(today, "", .pcr)))

		// THEN
		XCTAssertNotNil(secureStore.pcrTestResultMetadata, "The testResultMetadata should be initialized")
		XCTAssertEqual(secureStore.pcrTestResultMetadata?.testRegistrationDate, today, "incorrect RegistrationDate")
		
		XCTAssertEqual(secureStore.pcrTestResultMetadata?.riskLevelAtTestRegistration, enfRiskCalculationResult.riskLevel, "incorrect risk level")
		XCTAssertEqual(secureStore.pcrTestResultMetadata?.daysSinceMostRecentDateAtRiskLevelAtTestRegistration, expectedDaysSinceRecentAtRiskLevelAtTestRegistration, "incorrect days since recent riskLevel")
		XCTAssertEqual(secureStore.pcrTestResultMetadata?.hoursSinceHighRiskWarningAtTestRegistration, -1, "value should not be touched, so stay at default: -1")
		
		XCTAssertEqual(secureStore.pcrTestResultMetadata?.checkinRiskLevelAtTestRegistration, checkinRiskCalculationResult.riskLevel, "incorrect risk level")
		XCTAssertEqual(secureStore.pcrTestResultMetadata?.daysSinceMostRecentDateAtCheckinRiskLevelAtTestRegistration, expectedDaysSinceRecentAtRiskLevelAtTestRegistration, "incorrect days since recent riskLevel")
		XCTAssertEqual(secureStore.pcrTestResultMetadata?.hoursSinceCheckinHighRiskWarningAtTestRegistration, -1, "value should not be touched, so stay at default: -1")
		XCTAssertNil(secureStore.antigenTestResultMetadata)
	}
	
	func testGIVEN_RegisteringNewTestMetadata_WHEN_ENFHighRisk_CheckinHighRisk_THEN_BothHighRisk() {
		// GIVEN
		let secureStore = MockTestStore()
		Analytics.setupMock(store: secureStore)
		secureStore.isPrivacyPreservingAnalyticsConsentGiven = true
		
		let today = Date()
		let expectedDaysSinceRecentAtRiskLevelAtTestRegistration = 5
		guard let mostRecentDateRisk = Calendar.current.date(byAdding: .day, value: -expectedDaysSinceRecentAtRiskLevelAtTestRegistration, to: today) else {
			XCTFail("Could not create mostRecentDateHighRisk")
			return
		}
		
		// set ENF to low
		let enfRiskCalculationResult: ENFRiskCalculationResult = .fake(riskLevel: .high, mostRecentDateWithHighRisk: mostRecentDateRisk)
		secureStore.dateOfConversionToENFHighRisk = Calendar.current.date(byAdding: .day, value: -1, to: today)
		secureStore.enfRiskCalculationResult = enfRiskCalculationResult
		
		// set checkin to high
		let checkinRiskCalculationResult = mockCheckinRiskCalculationResult(risk: .high, dateForRisk: mostRecentDateRisk)
		secureStore.dateOfConversionToCheckinHighRisk = Calendar.current.date(byAdding: .day, value: -1, to: today)
		secureStore.checkinRiskCalculationResult = checkinRiskCalculationResult
		
		// WHEN
		Analytics.collect(.testResultMetadata(.registerNewTestMetadata(today, "", .pcr)))
		Analytics.collect(.testResultMetadata(.registerNewTestMetadata(today, "", .antigen)))
		
		// THEN
		XCTAssertNotNil(secureStore.pcrTestResultMetadata, "The pcrTestResultMetadata should be initialized")
		XCTAssertEqual(secureStore.pcrTestResultMetadata?.testRegistrationDate, today, "incorrect RegistrationDate")
		
		XCTAssertEqual(secureStore.pcrTestResultMetadata?.riskLevelAtTestRegistration, enfRiskCalculationResult.riskLevel, "incorrect risk level")
		XCTAssertEqual(secureStore.pcrTestResultMetadata?.daysSinceMostRecentDateAtRiskLevelAtTestRegistration, expectedDaysSinceRecentAtRiskLevelAtTestRegistration, "incorrect days since recent riskLevel")
		XCTAssertEqual(secureStore.pcrTestResultMetadata?.hoursSinceHighRiskWarningAtTestRegistration, 24, "incorrect hours")
		
		XCTAssertEqual(secureStore.pcrTestResultMetadata?.checkinRiskLevelAtTestRegistration, checkinRiskCalculationResult.riskLevel, "incorrect risk level")
		XCTAssertEqual(secureStore.pcrTestResultMetadata?.daysSinceMostRecentDateAtCheckinRiskLevelAtTestRegistration, expectedDaysSinceRecentAtRiskLevelAtTestRegistration, "incorrect days since recent riskLevel")
		XCTAssertEqual(secureStore.pcrTestResultMetadata?.hoursSinceCheckinHighRiskWarningAtTestRegistration, 24, "incorrect hours")
		
		XCTAssertNotNil(secureStore.antigenTestResultMetadata, "The antigenTestResultMetadata should be initialized")
		XCTAssertEqual(secureStore.antigenTestResultMetadata?.testRegistrationDate, today, "incorrect RegistrationDate")
		
		XCTAssertEqual(secureStore.antigenTestResultMetadata?.riskLevelAtTestRegistration, enfRiskCalculationResult.riskLevel, "incorrect risk level")
		XCTAssertEqual(secureStore.antigenTestResultMetadata?.daysSinceMostRecentDateAtRiskLevelAtTestRegistration, expectedDaysSinceRecentAtRiskLevelAtTestRegistration, "incorrect days since recent riskLevel")
		XCTAssertEqual(secureStore.antigenTestResultMetadata?.hoursSinceHighRiskWarningAtTestRegistration, 24, "incorrect hours")
		
		XCTAssertEqual(secureStore.antigenTestResultMetadata?.checkinRiskLevelAtTestRegistration, checkinRiskCalculationResult.riskLevel, "incorrect risk level")
		XCTAssertEqual(secureStore.antigenTestResultMetadata?.daysSinceMostRecentDateAtCheckinRiskLevelAtTestRegistration, expectedDaysSinceRecentAtRiskLevelAtTestRegistration, "incorrect days since recent riskLevel")
		XCTAssertEqual(secureStore.antigenTestResultMetadata?.hoursSinceCheckinHighRiskWarningAtTestRegistration, 24, "incorrect hours")
	}
	
	func testUpdatingTestResult_ValidResult_NotPreviousTestResultStored() {
		let secureStore = MockTestStore()
		Analytics.setupMock(store: secureStore)
		secureStore.isPrivacyPreservingAnalyticsConsentGiven = true
		let riskCalculationResult: ENFRiskCalculationResult = .fake(riskLevel: .low)
		secureStore.enfRiskCalculationResult = riskCalculationResult

		guard let registrationDate = Calendar.utcCalendar.date(byAdding: .day, value: -4, to: Date()) else {
			XCTFail("registration date is nil")
			return
		}
		Analytics.collect(.testResultMetadata(.registerNewTestMetadata(registrationDate, "", .pcr)))
		Analytics.collect(.testResultMetadata(.updateTestResult(.positive, "", .pcr)))
		Analytics.collect(.testResultMetadata(.registerNewTestMetadata(registrationDate, "", .antigen)))
		Analytics.collect(.testResultMetadata(.updateTestResult(.positive, "", .antigen)))

		XCTAssertEqual(secureStore.pcrTestResultMetadata?.testResult, TestResult.positive, "incorrect testResult")
		XCTAssertEqual(secureStore.pcrTestResultMetadata?.hoursSinceTestRegistration, (24 * 4), "incorrect hoursSinceTestRegistration")

		XCTAssertEqual(secureStore.antigenTestResultMetadata?.testResult, TestResult.positive, "incorrect testResult")
		XCTAssertEqual(secureStore.antigenTestResultMetadata?.hoursSinceTestRegistration, (24 * 4), "incorrect hoursSinceTestRegistration")
	}

	func testUpdatingTestResult_ValidResult_previouslyStoredWithSameValue() {
		let secureStore = MockTestStore()
		Analytics.setupMock(store: secureStore)
		secureStore.isPrivacyPreservingAnalyticsConsentGiven = true
		let riskCalculationResult: ENFRiskCalculationResult = .fake(riskLevel: .low)
		secureStore.enfRiskCalculationResult = riskCalculationResult

		if let registrationDate = Calendar.current.date(byAdding: .day, value: -4, to: Date()) {
			Analytics.collect(.testResultMetadata(.registerNewTestMetadata(registrationDate, "Token", .pcr)))
			Analytics.collect(.testResultMetadata(.updateTestResult(.positive, "Token", .pcr)))
			Analytics.collect(.testResultMetadata(.registerNewTestMetadata(registrationDate, "Token", .antigen)))
			Analytics.collect(.testResultMetadata(.updateTestResult(.positive, "Token", .antigen)))
			secureStore.pcrTestResultMetadata?.hoursSinceTestRegistration = 0
			secureStore.antigenTestResultMetadata?.hoursSinceTestRegistration = 0
		} else {
			XCTFail("registration date is nil")
		}

		Analytics.collect(.testResultMetadata(.updateTestResult(.positive, "Token", .pcr)))
		Analytics.collect(.testResultMetadata(.updateTestResult(.positive, "Token", .antigen)))

		XCTAssertEqual(secureStore.pcrTestResultMetadata?.testResult, TestResult.positive, "incorrect testResult")
		XCTAssertEqual(secureStore.antigenTestResultMetadata?.testResult, TestResult.positive, "incorrect testResult")

		/* The date shouldn't be updated if the test result is the same as the old one
					- hoursSinceTestRegistration if updated should be (24 * 4)
					- we explicitly set it into 0 in line 81, so we can see the change
				*/
		XCTAssertNotEqual(secureStore.pcrTestResultMetadata?.hoursSinceTestRegistration, (24 * 4), "incorrect hoursSinceTestRegistration")
		XCTAssertNotEqual(secureStore.antigenTestResultMetadata?.hoursSinceTestRegistration, (24 * 4), "incorrect hoursSinceTestRegistration")
	}

	func testUpdatingTestResult_ValidResult_previouslyStoredWithDifferentValue() {
		let secureStore = MockTestStore()
		Analytics.setupMock(store: secureStore)
		secureStore.isPrivacyPreservingAnalyticsConsentGiven = true
		let riskCalculationResult: ENFRiskCalculationResult = .fake(riskLevel: .low)
		secureStore.enfRiskCalculationResult = riskCalculationResult
		Analytics.collect(.testResultMetadata(.updateTestResult(.pending, "", .pcr)))
		Analytics.collect(.testResultMetadata(.updateTestResult(.pending, "", .antigen)))

		guard let registrationDate = Calendar.utcCalendar.date(byAdding: .day, value: -4, to: Date()) else {
			XCTFail("registration date is nil")
			return
		}
		Analytics.collect(.testResultMetadata(.registerNewTestMetadata(registrationDate, "", .pcr)))
		Analytics.collect(.testResultMetadata(.registerNewTestMetadata(registrationDate, "", .antigen)))
		Analytics.collect(.testResultMetadata(.updateTestResult(.positive, "", .pcr)))
		Analytics.collect(.testResultMetadata(.updateTestResult(.positive, "", .antigen)))

		XCTAssertEqual(secureStore.pcrTestResultMetadata?.testResult, TestResult.positive, "incorrect testResult")
		XCTAssertEqual(secureStore.antigenTestResultMetadata?.testResult, TestResult.positive, "incorrect testResult")

		// The the date is updated if the risk results changes e.g from pending to positive
		XCTAssertEqual(secureStore.pcrTestResultMetadata?.hoursSinceTestRegistration, (24 * 4), "incorrect hoursSinceTestRegistration")
		XCTAssertEqual(secureStore.antigenTestResultMetadata?.hoursSinceTestRegistration, (24 * 4), "incorrect hoursSinceTestRegistration")
	}

	func testUpdatingTestResult_Invalid() {
		let secureStore = MockTestStore()
		Analytics.setupMock(store: secureStore)
		secureStore.isPrivacyPreservingAnalyticsConsentGiven = true
		let riskCalculationResult: ENFRiskCalculationResult = .fake(riskLevel: .low)
		secureStore.enfRiskCalculationResult = riskCalculationResult
		Analytics.collect(.testResultMetadata(.updateTestResult(.pending, "", .pcr)))

		if let registrationDate = Calendar.current.date(byAdding: .day, value: -4, to: Date()) {
			Analytics.collect(.testResultMetadata(.registerNewTestMetadata(registrationDate, "", .pcr)))
			Analytics.collect(.testResultMetadata(.registerNewTestMetadata(registrationDate, "", .antigen)))
		} else {
			XCTFail("registration date is nil")
		}

		Analytics.collect(.testResultMetadata(.updateTestResult(.invalid, "", .pcr)))
		Analytics.collect(.testResultMetadata(.updateTestResult(.invalid, "", .antigen)))

		// The if the value is invalid  testResult shouldn't be updated
		XCTAssertNil(secureStore.pcrTestResultMetadata?.testResult, "incorrect testResult")
		XCTAssertNil(secureStore.pcrTestResultMetadata?.testResult, "incorrect testResult")

		// The if the value is invalid  hoursSinceTestRegistration shouldn't be updated and should remain the default value: 0
		XCTAssertEqual(secureStore.antigenTestResultMetadata?.hoursSinceTestRegistration, 0, "incorrect hoursSinceTestRegistration")
		XCTAssertEqual(secureStore.antigenTestResultMetadata?.hoursSinceTestRegistration, 0, "incorrect hoursSinceTestRegistration")
	}

	func testUpdatingTestResult_WithDifferentRegistrationToken_MetadataIsNotUpdated() {
		let secureStore = MockTestStore()
		Analytics.setupMock(store: secureStore)
		secureStore.isPrivacyPreservingAnalyticsConsentGiven = true
		let riskCalculationResult: ENFRiskCalculationResult = .fake(riskLevel: .low)
		secureStore.enfRiskCalculationResult = riskCalculationResult

		if let registrationDate = Calendar.current.date(byAdding: .day, value: -4, to: Date()) {
			Analytics.collect(.testResultMetadata(.registerNewTestMetadata(registrationDate, "Token", .pcr)))
			Analytics.collect(.testResultMetadata(.updateTestResult(.pending, "Token", .pcr)))
			Analytics.collect(.testResultMetadata(.registerNewTestMetadata(registrationDate, "Token", .antigen)))
			Analytics.collect(.testResultMetadata(.updateTestResult(.pending, "Token", .antigen)))
		} else {
			XCTFail("registration date is nil")
		}

		// trying to update a test with a different token shouldn't work
		Analytics.collect(.testResultMetadata(.updateTestResult(.positive, "Different Token", .pcr)))
		Analytics.collect(.testResultMetadata(.updateTestResult(.positive, "Different Token", .antigen)))

		// The if the value is valid but the token is different then the testResult shouldn't be updated
		XCTAssertEqual(secureStore.pcrTestResultMetadata?.testResult, .pending, "testResult shouldn't be updated")
		XCTAssertEqual(secureStore.antigenTestResultMetadata?.testResult, .pending, "testResult shouldn't be updated")

		// trying to update a test with the correct token should work
		Analytics.collect(.testResultMetadata(.updateTestResult(.positive, "Token", .pcr)))
		Analytics.collect(.testResultMetadata(.updateTestResult(.positive, "Token", .antigen)))

		// The if the value is valid and the token the same then the testResult should be updated
		XCTAssertEqual(secureStore.pcrTestResultMetadata?.testResult, .positive, "testResult should be updated")
		XCTAssertEqual(secureStore.antigenTestResultMetadata?.testResult, .positive, "testResult should be updated")
	}
	
	private func mockCheckinRiskCalculationResult(risk: RiskLevel = .high, dateForRisk: Date? = nil) -> CheckinRiskCalculationResult {
		let checkinIdWithRisk = CheckinIdWithRisk(
			checkinId: 007,
			riskLevel: risk
		)
		
		if let dateForRisk = dateForRisk {
			return CheckinRiskCalculationResult(
				calculationDate: Date(),
				checkinIdsWithRiskPerDate: [dateForRisk: [checkinIdWithRisk]],
				riskLevelPerDate: [dateForRisk: risk]
			)
		} else {
			return CheckinRiskCalculationResult(
				calculationDate: Date(),
				checkinIdsWithRiskPerDate: [:],
				riskLevelPerDate: [:]
			)
		}
	}
}
