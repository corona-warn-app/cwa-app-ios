////
// 🦠 Corona-Warn-App
//

@testable import ENA
import XCTest

class TestResultMetadataTests: XCTestCase {

	func testRegisteringNewTestMetadata_HighRisk() {
		let secureStore = MockTestStore()
		Analytics.setupMock(store: secureStore)
		secureStore.isPrivacyPreservingAnalyticsConsentGiven = true
		
		let today = Date()
		let expectedDaysSinceRecentAtRiskLevelAtTestRegistration = 5
		let mostRecentDateHighRisk = Calendar.current.date(byAdding: .day, value: -expectedDaysSinceRecentAtRiskLevelAtTestRegistration, to: today)
		let riskCalculationResult = mockRiskCalculationResult(risk: .high, mostRecentDateHighRisk: mostRecentDateHighRisk)
		secureStore.dateOfConversionToHighRisk = Calendar.current.date(byAdding: .day, value: -1, to: today)
		secureStore.riskCalculationResult = riskCalculationResult

		Analytics.collect(.testResultMetadata(.registerNewTestMetadata(today, "")))

		XCTAssertNotNil(secureStore.testResultMetadata, "The testResultMetadata should be initialized")
		XCTAssertEqual(secureStore.testResultMetadata?.testRegistrationDate, today, "incorrect RegistrationDate")
		XCTAssertEqual(secureStore.testResultMetadata?.riskLevelAtTestRegistration, riskCalculationResult.riskLevel, "incorrect risk level")
		XCTAssertEqual(
			secureStore.testResultMetadata?.daysSinceMostRecentDateAtRiskLevelAtTestRegistration,
			expectedDaysSinceRecentAtRiskLevelAtTestRegistration,
			"incorrect days since recent riskLevel"
		)

		// the difference from dateOfConversionToHighRisk should be one day so 24 hours
		XCTAssertEqual(secureStore.testResultMetadata?.hoursSinceHighRiskWarningAtTestRegistration, 24, "incorrect hours")
	}

	func testRegisteringNewTestMetadata_LowRisk() {
		let secureStore = MockTestStore()
		Analytics.setupMock(store: secureStore)
		secureStore.isPrivacyPreservingAnalyticsConsentGiven = true
		
		let today = Date()
		let expectedDaysSinceRecentAtRiskLevelAtTestRegistration = 5
		let mostRecentDateLowRisk = Calendar.current.date(byAdding: .day, value: -expectedDaysSinceRecentAtRiskLevelAtTestRegistration, to: today)
		let riskCalculationResult = mockRiskCalculationResult(risk: .low, mostRecentDateLowRisk: mostRecentDateLowRisk)
		secureStore.riskCalculationResult = riskCalculationResult

		Analytics.collect(.testResultMetadata(.registerNewTestMetadata(today, "")))

		XCTAssertNotNil(secureStore.testResultMetadata, "The testResultMetadata should be initialized")
		XCTAssertEqual(secureStore.testResultMetadata?.testRegistrationDate, today, "incorrect RegistrationDate")
		XCTAssertEqual(secureStore.testResultMetadata?.riskLevelAtTestRegistration, riskCalculationResult.riskLevel, "incorrect risk level")
		XCTAssertEqual(
			secureStore.testResultMetadata?.daysSinceMostRecentDateAtRiskLevelAtTestRegistration,
			expectedDaysSinceRecentAtRiskLevelAtTestRegistration,
			"incorrect days since recent riskLevel"
		)

		// the for low risk the value should always be -1
		XCTAssertEqual(secureStore.testResultMetadata?.hoursSinceHighRiskWarningAtTestRegistration, -1, "incorrect hours")
	}

	func testRegisteringNewTestMetadata_NoRecentRiskDate() {
		let secureStore = MockTestStore()
		Analytics.setupMock(store: secureStore)
		secureStore.isPrivacyPreservingAnalyticsConsentGiven = true
		
		let today = Date()
		let expectedDaysSinceRecentAtRiskLevelAtTestRegistration = -1
		let riskCalculationResult = mockRiskCalculationResult(risk: .low)
		secureStore.riskCalculationResult = riskCalculationResult

		Analytics.collect(.testResultMetadata(.registerNewTestMetadata(today, "")))

		XCTAssertNotNil(secureStore.testResultMetadata, "The testResultMetadata should be initialized")
		XCTAssertEqual(secureStore.testResultMetadata?.testRegistrationDate, today, "incorrect RegistrationDate")
		XCTAssertEqual(secureStore.testResultMetadata?.riskLevelAtTestRegistration, riskCalculationResult.riskLevel, "incorrect risk level")
		XCTAssertEqual(
			secureStore.testResultMetadata?.daysSinceMostRecentDateAtRiskLevelAtTestRegistration,
			expectedDaysSinceRecentAtRiskLevelAtTestRegistration,
			"should be -1 if there is no recentDate for riskLevel"
		)

		// the for low risk the value should always be -1
		XCTAssertEqual(secureStore.testResultMetadata?.hoursSinceHighRiskWarningAtTestRegistration, -1, "incorrect hours")
	}
	
	func testUpdatingTestResult_ValidResult_NotPreviousTestResultStored() {
		let secureStore = MockTestStore()
		Analytics.setupMock(store: secureStore)
		secureStore.isPrivacyPreservingAnalyticsConsentGiven = true
		let riskCalculationResult = mockRiskCalculationResult(risk: .low)
		secureStore.riskCalculationResult = riskCalculationResult

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
		let riskCalculationResult = mockRiskCalculationResult(risk: .low)
		secureStore.riskCalculationResult = riskCalculationResult

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
		let riskCalculationResult = mockRiskCalculationResult(risk: .low)
		secureStore.riskCalculationResult = riskCalculationResult
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
		let riskCalculationResult = mockRiskCalculationResult(risk: .low)
		secureStore.riskCalculationResult = riskCalculationResult
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
		let riskCalculationResult = mockRiskCalculationResult(risk: .low)
		secureStore.riskCalculationResult = riskCalculationResult

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

	private func mockRiskCalculationResult(risk: RiskLevel = .high, mostRecentDateHighRisk: Date? = nil, mostRecentDateLowRisk: Date? = nil) -> RiskCalculationResult {
		RiskCalculationResult(
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
}
