////
// 🦠 Corona-Warn-App
//

@testable import ENA
import XCTest

class TestResultMetadataTests: XCTestCase {
	/// Testpattern:
	/// ENF empty risk, Checkin empty risk
	/// ENF low, Checkin none
	/// ENF high, Checkin none
	/// ENF none, Checkin low
	/// ENF none, Checkin high
	/// ENF low, Checkin low
	/// ENF high, Checkin high
	/// Afterwards foloow the tests for the remaining properties
	
	func testGIVEN_RegisteringNewTestMetadata_WHEN_ENFEmptyRisk_CheckinEmptyRisk_THEN_BothDefaultValues() {
		// GIVEN
		let secureStore = MockTestStore()
		Analytics.setupMock(store: secureStore)
		secureStore.isPrivacyPreservingAnalyticsConsentGiven = true
		
		let today = Date()
		let enfRiskCalculationResult = mockENFRiskCalculationResult(risk: .low)
		secureStore.enfRiskCalculationResult = enfRiskCalculationResult
		let checkinRiskCalculationResult = mockCheckinRiskCalculationResult(risk: .low)
		secureStore.checkinRiskCalculationResult = checkinRiskCalculationResult
		
		// WHEN
		Analytics.collect(.testResultMetadata(.registerNewTestMetadata(today, "")))
		
		// THEN
		XCTAssertNotNil(secureStore.testResultMetadata, "The testResultMetadata should be initialized")
		XCTAssertEqual(secureStore.testResultMetadata?.testRegistrationDate, today, "incorrect RegistrationDate")
		
		XCTAssertEqual(secureStore.testResultMetadata?.enfRiskLevelAtTestRegistration, enfRiskCalculationResult.riskLevel, "incorrect risk level")
		XCTAssertEqual( secureStore.testResultMetadata?.daysSinceMostRecentDateAtENFRiskLevelAtTestRegistration, -1, "should be -1 if there is no recentDate for riskLevel")
		XCTAssertEqual(secureStore.testResultMetadata?.hoursSinceENFHighRiskWarningAtTestRegistration, -1, "should be -1 if there is no recentDate for riskLevel")
		
		XCTAssertEqual(secureStore.testResultMetadata?.checkinRiskLevelAtTestRegistration, checkinRiskCalculationResult.riskLevel, "incorrect risk level")
		XCTAssertEqual( secureStore.testResultMetadata?.daysSinceMostRecentDateAtCheckinRiskLevelAtTestRegistration, -1, "should be -1 if there is no recentDate for riskLevel")
		XCTAssertEqual(secureStore.testResultMetadata?.hoursSinceCheckinHighRiskWarningAtTestRegistration, -1, "should be -1 if there is no recentDate for riskLevel")
		
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
		Analytics.collect(.testResultMetadata(.registerNewTestMetadata(today, "")))
		
		// THEN
		XCTAssertNotNil(secureStore.testResultMetadata, "The testResultMetadata should be initialized")
		XCTAssertEqual(secureStore.testResultMetadata?.testRegistrationDate, today, "incorrect RegistrationDate")
		XCTAssertEqual(secureStore.testResultMetadata?.checkinRiskLevelAtTestRegistration, checkinRiskCalculationResult.riskLevel, "incorrect risk level")
		XCTAssertEqual(secureStore.testResultMetadata?.daysSinceMostRecentDateAtCheckinRiskLevelAtTestRegistration, expectedDaysSinceRecentAtRiskLevelAtTestRegistration, "incorrect days since recent riskLevel")
		// the difference from dateOfConversionToENFHighRisk should be one day so 24 hours
		XCTAssertEqual(secureStore.testResultMetadata?.hoursSinceCheckinHighRiskWarningAtTestRegistration, 24, "incorrect hours")
		
		XCTAssertNil(secureStore.testResultMetadata?.enfRiskLevelAtTestRegistration, "value should not be set")
		XCTAssertNil(secureStore.testResultMetadata?.daysSinceMostRecentDateAtENFRiskLevelAtTestRegistration, "value should not be set")
		XCTAssertNil(secureStore.testResultMetadata?.hoursSinceENFHighRiskWarningAtTestRegistration, "value should not be set")
	}
	
	func testGIVEN_RegisteringNewTestMetadata_WHEN_ENFHighRisk_CheckinNone_THEN_OnlyENFIsSet() {
		// GIVEN
		let secureStore = MockTestStore()
		Analytics.setupMock(store: secureStore)
		secureStore.isPrivacyPreservingAnalyticsConsentGiven = true
		
		let today = Date()
		let expectedDaysSinceRecentAtRiskLevelAtTestRegistration = 5
		let mostRecentDateHighRisk = Calendar.current.date(byAdding: .day, value: -expectedDaysSinceRecentAtRiskLevelAtTestRegistration, to: today)
		let enfRiskCalculationResult = mockENFRiskCalculationResult(risk: .high, mostRecentDateHighRisk: mostRecentDateHighRisk)
		secureStore.dateOfConversionToENFHighRisk = Calendar.current.date(byAdding: .day, value: -1, to: today)
		secureStore.enfRiskCalculationResult = enfRiskCalculationResult
		
		// WHEN
		Analytics.collect(.testResultMetadata(.registerNewTestMetadata(today, "")))
		
		// THEN
		XCTAssertNotNil(secureStore.testResultMetadata, "The testResultMetadata should be initialized")
		XCTAssertEqual(secureStore.testResultMetadata?.testRegistrationDate, today, "incorrect RegistrationDate")
		XCTAssertEqual(secureStore.testResultMetadata?.RiskLevelAtTestRegistration, enfRiskCalculationResult.riskLevel, "incorrect risk level")
		XCTAssertEqual(secureStore.testResultMetadata?.daysSinceMostRecentDateAtRiskLevelAtTestRegistration, expectedDaysSinceRecentAtRiskLevelAtTestRegistration, "incorrect days since recent riskLevel")
		// the difference from dateOfConversionToENFHighRisk should be one day so 24 hours
		XCTAssertEqual(secureStore.testResultMetadata?.hoursSinceHighRiskWarningAtTestRegistration, 24, "incorrect hours")
		
		XCTAssertNil(secureStore.testResultMetadata?.checkinRiskLevelAtTestRegistration, "value should not be set")
		XCTAssertNil(secureStore.testResultMetadata?.daysSinceMostRecentDateAtCheckinRiskLevelAtTestRegistration, "value should not be set")
		XCTAssertNil(secureStore.testResultMetadata?.hoursSinceCheckinHighRiskWarningAtTestRegistration, "value should not be set")
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
		Analytics.collect(.testResultMetadata(.registerNewTestMetadata(today, "")))

		// THEN
		XCTAssertNotNil(secureStore.testResultMetadata, "The testResultMetadata should be initialized")
		XCTAssertEqual(secureStore.testResultMetadata?.testRegistrationDate, today, "incorrect RegistrationDate")
		
		XCTAssertNil(secureStore.testResultMetadata?.RiskLevelAtTestRegistration, "value should not be set")
		XCTAssertNil(secureStore.testResultMetadata?.daysSinceMostRecentDateAtRiskLevelAtTestRegistration, "value should not be set")
		XCTAssertNil(secureStore.testResultMetadata?.hoursSinceHighRiskWarningAtTestRegistration, "value should not be set")
		
		XCTAssertEqual(secureStore.testResultMetadata?.checkinRiskLevelAtTestRegistration, checkinRiskCalculationResult.riskLevel, "incorrect risk level")
		XCTAssertEqual(secureStore.testResultMetadata?.daysSinceMostRecentDateAtCheckinRiskLevelAtTestRegistration, expectedDaysSinceRecentAtRiskLevelAtTestRegistration, "incorrect days since recent riskLevel")
		XCTAssertEqual(secureStore.testResultMetadata?.hoursSinceCheckinHighRiskWarningAtTestRegistration, -1, "value should not be touched, so stay at default: -1")
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
		Analytics.collect(.testResultMetadata(.registerNewTestMetadata(today, "")))

		// THEN
		XCTAssertNotNil(secureStore.testResultMetadata, "The testResultMetadata should be initialized")
		XCTAssertEqual(secureStore.testResultMetadata?.testRegistrationDate, today, "incorrect RegistrationDate")
		
		XCTAssertNil(secureStore.testResultMetadata?.enfRiskLevelAtTestRegistration, "value should not be set")
		XCTAssertNil(secureStore.testResultMetadata?.daysSinceMostRecentDateAtENFRiskLevelAtTestRegistration, "value should not be set")
		XCTAssertNil(secureStore.testResultMetadata?.hoursSinceENFHighRiskWarningAtTestRegistration, "value should not be set")
		
		XCTAssertEqual(secureStore.testResultMetadata?.checkinRiskLevelAtTestRegistration, checkinRiskCalculationResult.riskLevel, "incorrect risk level")
		XCTAssertEqual(secureStore.testResultMetadata?.daysSinceMostRecentDateAtCheckinRiskLevelAtTestRegistration, expectedDaysSinceRecentAtRiskLevelAtTestRegistration, "incorrect days since recent riskLevel")
		XCTAssertEqual(secureStore.testResultMetadata?.hoursSinceCheckinHighRiskWarningAtTestRegistration, 24, "incorrect hours")
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
		let enfRiskCalculationResult = mockENFRiskCalculationResult(risk: .low, mostRecentDateLowRisk: mostRecentDateRisk)
		secureStore.dateOfConversionToENFHighRisk = Calendar.current.date(byAdding: .day, value: -1, to: today)
		secureStore.enfRiskCalculationResult = enfRiskCalculationResult
		
		// set checkin to low
		let checkinRiskCalculationResult = mockCheckinRiskCalculationResult(risk: .low, dateForRisk: mostRecentDateRisk)
		secureStore.dateOfConversionToCheckinHighRisk = Calendar.current.date(byAdding: .day, value: -1, to: today)
		secureStore.checkinRiskCalculationResult = checkinRiskCalculationResult

		// WHEN
		Analytics.collect(.testResultMetadata(.registerNewTestMetadata(today, "")))

		// THEN
		XCTAssertNotNil(secureStore.testResultMetadata, "The testResultMetadata should be initialized")
		XCTAssertEqual(secureStore.testResultMetadata?.testRegistrationDate, today, "incorrect RegistrationDate")
		
		XCTAssertEqual(secureStore.testResultMetadata?.RiskLevelAtTestRegistration, enfRiskCalculationResult.riskLevel, "incorrect risk level")
		XCTAssertEqual(secureStore.testResultMetadata?.daysSinceMostRecentDateAtRiskLevelAtTestRegistration, expectedDaysSinceRecentAtRiskLevelAtTestRegistration, "incorrect days since recent riskLevel")
		XCTAssertEqual(secureStore.testResultMetadata?.hoursSinceHighRiskWarningAtTestRegistration, -1, "value should not be touched, so stay at default: -1")
		
		XCTAssertEqual(secureStore.testResultMetadata?.checkinRiskLevelAtTestRegistration, checkinRiskCalculationResult.riskLevel, "incorrect risk level")
		XCTAssertEqual(secureStore.testResultMetadata?.daysSinceMostRecentDateAtCheckinRiskLevelAtTestRegistration, expectedDaysSinceRecentAtRiskLevelAtTestRegistration, "incorrect days since recent riskLevel")
		XCTAssertEqual(secureStore.testResultMetadata?.hoursSinceCheckinHighRiskWarningAtTestRegistration, -1, "value should not be touched, so stay at default: -1")
		
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
		let enfRiskCalculationResult = mockENFRiskCalculationResult(risk: .high, mostRecentDateHighRisk: mostRecentDateRisk)
		secureStore.dateOfConversionToENFHighRisk = Calendar.current.date(byAdding: .day, value: -1, to: today)
		secureStore.enfRiskCalculationResult = enfRiskCalculationResult
		
		// set checkin to high
		let checkinRiskCalculationResult = mockCheckinRiskCalculationResult(risk: .high, dateForRisk: mostRecentDateRisk)
		secureStore.dateOfConversionToCheckinHighRisk = Calendar.current.date(byAdding: .day, value: -1, to: today)
		secureStore.checkinRiskCalculationResult = checkinRiskCalculationResult
		
		// WHEN
		Analytics.collect(.testResultMetadata(.registerNewTestMetadata(today, "")))
		
		// THEN
		XCTAssertNotNil(secureStore.testResultMetadata, "The testResultMetadata should be initialized")
		XCTAssertEqual(secureStore.testResultMetadata?.testRegistrationDate, today, "incorrect RegistrationDate")
		
		XCTAssertEqual(secureStore.testResultMetadata?.RiskLevelAtTestRegistration, enfRiskCalculationResult.riskLevel, "incorrect risk level")
		XCTAssertEqual(secureStore.testResultMetadata?.daysSinceMostRecentDateAtRiskLevelAtTestRegistration, expectedDaysSinceRecentAtRiskLevelAtTestRegistration, "incorrect days since recent riskLevel")
		XCTAssertEqual(secureStore.testResultMetadata?.hoursSinceHighRiskWarningAtTestRegistration, 24, "incorrect hours")
		
		XCTAssertEqual(secureStore.testResultMetadata?.checkinRiskLevelAtTestRegistration, checkinRiskCalculationResult.riskLevel, "incorrect risk level")
		XCTAssertEqual(secureStore.testResultMetadata?.daysSinceMostRecentDateAtCheckinRiskLevelAtTestRegistration, expectedDaysSinceRecentAtRiskLevelAtTestRegistration, "incorrect days since recent riskLevel")
		XCTAssertEqual(secureStore.testResultMetadata?.hoursSinceCheckinHighRiskWarningAtTestRegistration, 24, "incorrect hours")
	}
	
	func testUpdatingTestResult_ValidResult_NotPreviousTestResultStored() {
		let secureStore = MockTestStore()
		Analytics.setupMock(store: secureStore)
		secureStore.isPrivacyPreservingAnalyticsConsentGiven = true
		let riskCalculationResult = mockENFRiskCalculationResult(risk: .low)
		secureStore.enfRiskCalculationResult = riskCalculationResult

		guard let registrationDate = Calendar.utcCalendar.date(byAdding: .day, value: -4, to: Date()) else {
			XCTFail("registration date is nil")
			return
		}
		Analytics.collect(.testResultMetadata(.registerNewTestMetadata(registrationDate, "")))
		Analytics.collect(.testResultMetadata(.updateTestResult(.positive, "")))
		
		XCTAssertEqual(secureStore.testResultMetadata?.testResult, TestResult.positive, "incorrect testResult")
		
		XCTAssertEqual(secureStore.testResultMetadata?.hoursSinceTestRegistration, (24 * 4), "incorrect hoursSinceTestRegistration")
	}

	func testUpdatingTestResult_ValidResult_previouslyStoredWithSameValue() {
		let secureStore = MockTestStore()
		Analytics.setupMock(store: secureStore)
		secureStore.isPrivacyPreservingAnalyticsConsentGiven = true
		let riskCalculationResult = mockENFRiskCalculationResult(risk: .low)
		secureStore.enfRiskCalculationResult = riskCalculationResult

		if let registrationDate = Calendar.current.date(byAdding: .day, value: -4, to: Date()) {
			Analytics.collect(.testResultMetadata(.registerNewTestMetadata(registrationDate, "Token")))
			Analytics.collect(.testResultMetadata(.updateTestResult(.positive, "Token")))
			Analytics.collect(.testResultMetadata(.testResultHoursSinceTestRegistration(0)))
		} else {
			XCTFail("registration date is nil")
		}

		Analytics.collect(.testResultMetadata(.updateTestResult(.positive, "Token")))
		XCTAssertEqual(secureStore.testResultMetadata?.testResult, TestResult.positive, "incorrect testResult")

		/* The date shouldn't be updated if the test result is the same as the old one
					- hoursSinceTestRegistration if updated should be (24 * 4)
					- we explicitly set it into 0 in line 81, so we can see the change
				*/
		XCTAssertNotEqual(secureStore.testResultMetadata?.hoursSinceTestRegistration, (24 * 4), "incorrect hoursSinceTestRegistration")
	}

	func testUpdatingTestResult_ValidResult_previouslyStoredWithDifferentValue() {
		let secureStore = MockTestStore()
		Analytics.setupMock(store: secureStore)
		secureStore.isPrivacyPreservingAnalyticsConsentGiven = true
		let riskCalculationResult = mockENFRiskCalculationResult(risk: .low)
		secureStore.enfRiskCalculationResult = riskCalculationResult
		Analytics.collect(.testResultMetadata(.updateTestResult(.pending, "")))
		
		guard let registrationDate = Calendar.utcCalendar.date(byAdding: .day, value: -4, to: Date()) else {
			XCTFail("registration date is nil")
			return
		}
		Analytics.collect(.testResultMetadata(.registerNewTestMetadata(registrationDate, "")))
		Analytics.collect(.testResultMetadata(.updateTestResult(.positive, "")))
		XCTAssertEqual(secureStore.testResultMetadata?.testResult, TestResult.positive, "incorrect testResult")
		
		// The the date is updated if the risk results changes e.g from pending to positive
		XCTAssertEqual(secureStore.testResultMetadata?.hoursSinceTestRegistration, (24 * 4), "incorrect hoursSinceTestRegistration")
	}

	func testUpdatingTestResult_Invalid() {
		let secureStore = MockTestStore()
		Analytics.setupMock(store: secureStore)
		secureStore.isPrivacyPreservingAnalyticsConsentGiven = true
		let riskCalculationResult = mockENFRiskCalculationResult(risk: .low)
		secureStore.enfRiskCalculationResult = riskCalculationResult
		Analytics.collect(.testResultMetadata(.updateTestResult(.pending, "")))

		if let registrationDate = Calendar.current.date(byAdding: .day, value: -4, to: Date()) {
			Analytics.collect(.testResultMetadata(.registerNewTestMetadata(registrationDate, "")))
		} else {
			XCTFail("registration date is nil")
		}

		Analytics.collect(.testResultMetadata(.updateTestResult(.invalid, "")))

		// The if the value is invalid  testResult shouldn't be updated
		XCTAssertNil(secureStore.testResultMetadata?.testResult, "incorrect testResult")

		// The if the value is invalid  hoursSinceTestRegistration shouldnt be updated and should remain the default value: 0
		XCTAssertEqual(secureStore.testResultMetadata?.hoursSinceTestRegistration, 0, "incorrect hoursSinceTestRegistration")
	}

	func testUpdatingTestResult_WithDifferentRegistrationToken_MetadataIsNotUpdated() {
		let secureStore = MockTestStore()
		Analytics.setupMock(store: secureStore)
		secureStore.isPrivacyPreservingAnalyticsConsentGiven = true
		let riskCalculationResult = mockENFRiskCalculationResult(risk: .low)
		secureStore.enfRiskCalculationResult = riskCalculationResult

		if let registrationDate = Calendar.current.date(byAdding: .day, value: -4, to: Date()) {
			Analytics.collect(.testResultMetadata(.registerNewTestMetadata(registrationDate, "Token")))
			Analytics.collect(.testResultMetadata(.updateTestResult(.pending, "Token")))
		} else {
			XCTFail("registration date is nil")
		}

		// trying to update a test with a different token shouldn't work
		Analytics.collect(.testResultMetadata(.updateTestResult(.positive, "Different Token")))
		// The if the value is valid but the token is different then the testResult shouldn't be updated
		XCTAssertEqual(secureStore.testResultMetadata?.testResult, .pending, "testResult shouldn't be updated")

		// trying to update a test with the correct token should work
		Analytics.collect(.testResultMetadata(.updateTestResult(.positive, "Token")))
		// The if the value is valid and the token the same then the testResult should be updated
		XCTAssertEqual(secureStore.testResultMetadata?.testResult, .positive, "testResult should be updated")
	}

	private func mockENFRiskCalculationResult(risk: RiskLevel = .high, mostRecentDateHighRisk: Date? = nil, mostRecentDateLowRisk: Date? = nil) -> ENFRiskCalculationResult {
		ENFRiskCalculationResult(
			riskLevel: risk,
			minimumDistinctEncountersWithLowRisk: 0,
			minimumDistinctEncountersWithHighRisk: 0,
			mostRecentDateWithLowRisk: mostRecentDateLowRisk,
			mostRecentDateWithHighRisk: mostRecentDateHighRisk,
			numberOfDaysWithLowRisk: 0,
			numberOfDaysWithHighRisk: 2,
			calculationDate: Date(),
			riskLevelPerDate: [:],
			minimumDistinctEncountersWithHighRiskPerDate: [:]
		)
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
