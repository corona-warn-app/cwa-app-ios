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
		secureStore.enfRiskCalculationResult = riskCalculationResult

		Analytics.collect(.testResultMetadata(.registerNewTestMetadata(today, "", .pcr)))
		Analytics.collect(.testResultMetadata(.registerNewTestMetadata(today, "", .antigen)))

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

		XCTAssertNotNil(secureStore.antigenTestResultMetadata, "The testResultMetadata should be initialized")
		XCTAssertEqual(secureStore.antigenTestResultMetadata?.testRegistrationDate, today, "incorrect RegistrationDate")
		XCTAssertEqual(secureStore.antigenTestResultMetadata?.riskLevelAtTestRegistration, riskCalculationResult.riskLevel, "incorrect risk level")
		XCTAssertEqual(
			secureStore.antigenTestResultMetadata?.daysSinceMostRecentDateAtRiskLevelAtTestRegistration,
			expectedDaysSinceRecentAtRiskLevelAtTestRegistration,
			"incorrect days since recent riskLevel"
		)

		// the difference from dateOfConversionToHighRisk should be one day so 24 hours
		XCTAssertEqual(secureStore.antigenTestResultMetadata?.hoursSinceHighRiskWarningAtTestRegistration, 24, "incorrect hours")
	}

	func testRegisteringNewTestMetadata_LowRisk() {
		let secureStore = MockTestStore()
		Analytics.setupMock(store: secureStore)
		secureStore.isPrivacyPreservingAnalyticsConsentGiven = true
		
		let today = Date()
		let expectedDaysSinceRecentAtRiskLevelAtTestRegistration = 5
		let mostRecentDateLowRisk = Calendar.current.date(byAdding: .day, value: -expectedDaysSinceRecentAtRiskLevelAtTestRegistration, to: today)
		let riskCalculationResult = mockRiskCalculationResult(risk: .low, mostRecentDateLowRisk: mostRecentDateLowRisk)
		secureStore.enfRiskCalculationResult = riskCalculationResult

		Analytics.collect(.testResultMetadata(.registerNewTestMetadata(today, "", .pcr)))
		Analytics.collect(.testResultMetadata(.registerNewTestMetadata(today, "", .antigen)))

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

		XCTAssertNotNil(secureStore.antigenTestResultMetadata, "The testResultMetadata should be initialized")
		XCTAssertEqual(secureStore.antigenTestResultMetadata?.testRegistrationDate, today, "incorrect RegistrationDate")
		XCTAssertEqual(secureStore.antigenTestResultMetadata?.riskLevelAtTestRegistration, riskCalculationResult.riskLevel, "incorrect risk level")
		XCTAssertEqual(
			secureStore.antigenTestResultMetadata?.daysSinceMostRecentDateAtRiskLevelAtTestRegistration,
			expectedDaysSinceRecentAtRiskLevelAtTestRegistration,
			"incorrect days since recent riskLevel"
		)

		// the for low risk the value should always be -1
		XCTAssertEqual(secureStore.antigenTestResultMetadata?.hoursSinceHighRiskWarningAtTestRegistration, -1, "incorrect hours")
	}

	func testRegisteringNewTestMetadata_NoRecentRiskDate() {
		let secureStore = MockTestStore()
		Analytics.setupMock(store: secureStore)
		secureStore.isPrivacyPreservingAnalyticsConsentGiven = true
		
		let today = Date()
		let expectedDaysSinceRecentAtRiskLevelAtTestRegistration = -1
		let riskCalculationResult = mockRiskCalculationResult(risk: .low)
		secureStore.enfRiskCalculationResult = riskCalculationResult

		Analytics.collect(.testResultMetadata(.registerNewTestMetadata(today, "", .pcr)))
		Analytics.collect(.testResultMetadata(.registerNewTestMetadata(today, "", .antigen)))

		XCTAssertNotNil(secureStore.testResultMetadata, "The testResultMetadata should be initialized")
		XCTAssertEqual(secureStore.testResultMetadata?.testRegistrationDate, today, "incorrect RegistrationDate")
		XCTAssertEqual(secureStore.testResultMetadata?.riskLevelAtTestRegistration, riskCalculationResult.riskLevel, "incorrect risk level")
		XCTAssertEqual(
			secureStore.testResultMetadata?.daysSinceMostRecentDateAtRiskLevelAtTestRegistration,
			expectedDaysSinceRecentAtRiskLevelAtTestRegistration,
			"should be -1 if there is no recentDate for riskLevel"
		)

		// the for low risk the value should always be -1
		XCTAssertEqual(secureStore.antigenTestResultMetadata?.hoursSinceHighRiskWarningAtTestRegistration, -1, "incorrect hours")

		XCTAssertNotNil(secureStore.antigenTestResultMetadata, "The testResultMetadata should be initialized")
		XCTAssertEqual(secureStore.antigenTestResultMetadata?.testRegistrationDate, today, "incorrect RegistrationDate")
		XCTAssertEqual(secureStore.antigenTestResultMetadata?.riskLevelAtTestRegistration, riskCalculationResult.riskLevel, "incorrect risk level")
		XCTAssertEqual(
			secureStore.antigenTestResultMetadata?.daysSinceMostRecentDateAtRiskLevelAtTestRegistration,
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
		secureStore.enfRiskCalculationResult = riskCalculationResult

		guard let registrationDate = Calendar.utcCalendar.date(byAdding: .day, value: -4, to: Date()) else {
			XCTFail("registration date is nil")
			return
		}
		Analytics.collect(.testResultMetadata(.registerNewTestMetadata(registrationDate, "", .pcr)))
		Analytics.collect(.testResultMetadata(.updateTestResult(.positive, "", .pcr)))
		Analytics.collect(.testResultMetadata(.registerNewTestMetadata(registrationDate, "", .antigen)))
		Analytics.collect(.testResultMetadata(.updateTestResult(.positive, "", .antigen)))

		XCTAssertEqual(secureStore.testResultMetadata?.testResult, TestResult.positive, "incorrect testResult")
		XCTAssertEqual(secureStore.testResultMetadata?.hoursSinceTestRegistration, (24 * 4), "incorrect hoursSinceTestRegistration")

		XCTAssertEqual(secureStore.antigenTestResultMetadata?.testResult, TestResult.positive, "incorrect testResult")
		XCTAssertEqual(secureStore.antigenTestResultMetadata?.hoursSinceTestRegistration, (24 * 4), "incorrect hoursSinceTestRegistration")
	}

	func testUpdatingTestResult_ValidResult_previouslyStoredWithSameValue() {
		let secureStore = MockTestStore()
		Analytics.setupMock(store: secureStore)
		secureStore.isPrivacyPreservingAnalyticsConsentGiven = true
		let riskCalculationResult = mockRiskCalculationResult(risk: .low)
		secureStore.enfRiskCalculationResult = riskCalculationResult

		if let registrationDate = Calendar.current.date(byAdding: .day, value: -4, to: Date()) {
			Analytics.collect(.testResultMetadata(.registerNewTestMetadata(registrationDate, "Token", .pcr)))
			Analytics.collect(.testResultMetadata(.updateTestResult(.positive, "Token", .pcr)))
			Analytics.collect(.testResultMetadata(.registerNewTestMetadata(registrationDate, "Token", .antigen)))
			Analytics.collect(.testResultMetadata(.updateTestResult(.positive, "Token", .antigen)))
			secureStore.testResultMetadata?.hoursSinceTestRegistration = 0
			secureStore.antigenTestResultMetadata?.hoursSinceTestRegistration = 0
		} else {
			XCTFail("registration date is nil")
		}

		Analytics.collect(.testResultMetadata(.updateTestResult(.positive, "Token", .pcr)))
		Analytics.collect(.testResultMetadata(.updateTestResult(.positive, "Token", .antigen)))

		XCTAssertEqual(secureStore.testResultMetadata?.testResult, TestResult.positive, "incorrect testResult")
		XCTAssertEqual(secureStore.antigenTestResultMetadata?.testResult, TestResult.positive, "incorrect testResult")

		/* The date shouldn't be updated if the test result is the same as the old one
					- hoursSinceTestRegistration if updated should be (24 * 4)
					- we explicitly set it into 0 in line 81, so we can see the change
				*/
		XCTAssertNotEqual(secureStore.testResultMetadata?.hoursSinceTestRegistration, (24 * 4), "incorrect hoursSinceTestRegistration")
		XCTAssertNotEqual(secureStore.antigenTestResultMetadata?.hoursSinceTestRegistration, (24 * 4), "incorrect hoursSinceTestRegistration")
	}

	func testUpdatingTestResult_ValidResult_previouslyStoredWithDifferentValue() {
		let secureStore = MockTestStore()
		Analytics.setupMock(store: secureStore)
		secureStore.isPrivacyPreservingAnalyticsConsentGiven = true
		let riskCalculationResult = mockRiskCalculationResult(risk: .low)
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

		XCTAssertEqual(secureStore.testResultMetadata?.testResult, TestResult.positive, "incorrect testResult")
		XCTAssertEqual(secureStore.antigenTestResultMetadata?.testResult, TestResult.positive, "incorrect testResult")

		// The the date is updated if the risk results changes e.g from pending to positive
		XCTAssertEqual(secureStore.testResultMetadata?.hoursSinceTestRegistration, (24 * 4), "incorrect hoursSinceTestRegistration")
		XCTAssertEqual(secureStore.antigenTestResultMetadata?.hoursSinceTestRegistration, (24 * 4), "incorrect hoursSinceTestRegistration")
	}

	func testUpdatingTestResult_Invalid() {
		let secureStore = MockTestStore()
		Analytics.setupMock(store: secureStore)
		secureStore.isPrivacyPreservingAnalyticsConsentGiven = true
		let riskCalculationResult = mockRiskCalculationResult(risk: .low)
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
		XCTAssertNil(secureStore.testResultMetadata?.testResult, "incorrect testResult")
		XCTAssertNil(secureStore.testResultMetadata?.testResult, "incorrect testResult")

		// The if the value is invalid  hoursSinceTestRegistration shouldnt be updated and should remain the default value: 0
		XCTAssertEqual(secureStore.antigenTestResultMetadata?.hoursSinceTestRegistration, 0, "incorrect hoursSinceTestRegistration")
		XCTAssertEqual(secureStore.antigenTestResultMetadata?.hoursSinceTestRegistration, 0, "incorrect hoursSinceTestRegistration")
	}

	func testUpdatingTestResult_WithDifferentRegistrationToken_MetadataIsNotUpdated() {
		let secureStore = MockTestStore()
		Analytics.setupMock(store: secureStore)
		secureStore.isPrivacyPreservingAnalyticsConsentGiven = true
		let riskCalculationResult = mockRiskCalculationResult(risk: .low)
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
		XCTAssertEqual(secureStore.testResultMetadata?.testResult, .pending, "testResult shouldn't be updated")
		XCTAssertEqual(secureStore.antigenTestResultMetadata?.testResult, .pending, "testResult shouldn't be updated")

		// trying to update a test with the correct token should work
		Analytics.collect(.testResultMetadata(.updateTestResult(.positive, "Token", .pcr)))
		Analytics.collect(.testResultMetadata(.updateTestResult(.positive, "Token", .antigen)))

		// The if the value is valid and the token the same then the testResult should be updated
		XCTAssertEqual(secureStore.testResultMetadata?.testResult, .positive, "testResult should be updated")
		XCTAssertEqual(secureStore.antigenTestResultMetadata?.testResult, .positive, "testResult should be updated")
	}

	private func mockRiskCalculationResult(risk: RiskLevel = .high, mostRecentDateHighRisk: Date? = nil, mostRecentDateLowRisk: Date? = nil) -> ENFRiskCalculationResult {
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
}
