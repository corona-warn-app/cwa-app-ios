////
// 🦠 Corona-Warn-App
//

@testable import ENA
import XCTest

class TestResultMetadataServiceTests: XCTestCase {

	func testRegisteringNewTestMetadata_HighRisk() {
		let secureStore = MockTestStore()
		let riskCalculationResult = mockRiskCalculationResult()
		let date = Date()
		secureStore.dateOfConversionToHighRisk = Calendar.current.date(byAdding: .day, value: -1, to: date)
		secureStore.riskCalculationResult = riskCalculationResult

		Analytics.log(.TestResultMetadata(.registerNewTestMetadata(date)))

		XCTAssertNotNil(secureStore.TestResultMetadata, "The TestResultMetadata should be initialized")
		XCTAssertEqual(secureStore.TestResultMetadata?.testRegistrationDate, date, "incorrect RegistrationDate")
		XCTAssertEqual(secureStore.TestResultMetadata?.riskLevelAtTestRegistration, riskCalculationResult.riskLevel, "incorrect risk level")
		XCTAssertEqual(
			secureStore.TestResultMetadata?.daysSinceMostRecentDateAtRiskLevelAtTestRegistration,
			riskCalculationResult.numberOfDaysWithCurrentRiskLevel,
			"incorrect days since recent riskLEvel"
		)

		// the difference from dateOfConversionToHighRisk should be one day so 24 hours
		XCTAssertEqual(secureStore.TestResultMetadata?.hoursSinceHighRiskWarningAtTestRegistration, 24, "incorrect hours")
	}

	func testRegisteringNewTestMetadata_LowRisk() {
		let secureStore = MockTestStore()
		let riskCalculationResult = mockRiskCalculationResult(risk: .low)
		let date = Date()
		secureStore.riskCalculationResult = riskCalculationResult

		Analytics.log(.TestResultMetadata(.registerNewTestMetadata(date)))

		XCTAssertNotNil(secureStore.TestResultMetadata, "The TestResultMetadata should be initialized")
		XCTAssertEqual(secureStore.TestResultMetadata?.testRegistrationDate, date, "incorrect RegistrationDate")
		XCTAssertEqual(secureStore.TestResultMetadata?.riskLevelAtTestRegistration, riskCalculationResult.riskLevel, "incorrect risk level")
		XCTAssertEqual(
			secureStore.TestResultMetadata?.daysSinceMostRecentDateAtRiskLevelAtTestRegistration,
			riskCalculationResult.numberOfDaysWithCurrentRiskLevel,
			"incorrect days since recent riskLEvel"
		)

		// the for low risk the value should always be -1
		XCTAssertEqual(secureStore.TestResultMetadata?.hoursSinceHighRiskWarningAtTestRegistration, -1, "incorrect hours")
	}

	func testUpdatingTestResult_ValidResult_NotPreviousTestResultStored() {
		let secureStore = MockTestStore()
		let riskCalculationResult = mockRiskCalculationResult(risk: .low)
		secureStore.riskCalculationResult = riskCalculationResult

		if let registrationDate = Calendar.current.date(byAdding: .day, value: -4, to: Date()) {
			Analytics.log(.TestResultMetadata(.registerNewTestMetadata(registrationDate)))
		} else {
			XCTFail("registration date is nil")
		}

		Analytics.log(.TestResultMetadata(.updateTestResult(.positive)))
		XCTAssertEqual(secureStore.TestResultMetadata?.testResult, TestResult.positive, "incorrect testResult")
		XCTAssertEqual(secureStore.TestResultMetadata?.hoursSinceTestRegistration, (24 * 4), "incorrect hoursSinceTestRegistration")
	}

	func testUpdatingTestResult_ValidResult_previouslyStoredWithSameValue() {
		let secureStore = MockTestStore()
		let riskCalculationResult = mockRiskCalculationResult(risk: .low)
		secureStore.riskCalculationResult = riskCalculationResult
		Analytics.log(.TestResultMetadata(.updateTestResult(.positive)))

		if let registrationDate = Calendar.current.date(byAdding: .day, value: -4, to: Date()) {
			Analytics.log(.TestResultMetadata(.registerNewTestMetadata(registrationDate)))
		} else {
			XCTFail("registration date is nil")
		}

		Analytics.log(.TestResultMetadata(.updateTestResult(.positive)))
		XCTAssertEqual(secureStore.TestResultMetadata?.testResult, TestResult.positive, "incorrect testResult")

		// The date shouldn't be updated if the test result is the same as the old one
		XCTAssertEqual(secureStore.TestResultMetadata?.hoursSinceTestRegistration, (24 * 4), "incorrect hoursSinceTestRegistration")
	}

	func testUpdatingTestResult_ValidResult_previouslyStoredWithDifferentValue() {
		let secureStore = MockTestStore()
		let riskCalculationResult = mockRiskCalculationResult(risk: .low)
		secureStore.riskCalculationResult = riskCalculationResult
		Analytics.log(.TestResultMetadata(.updateTestResult(.pending)))

		if let registrationDate = Calendar.current.date(byAdding: .day, value: -4, to: Date()) {
			Analytics.log(.TestResultMetadata(.registerNewTestMetadata(registrationDate)))
		} else {
			XCTFail("registration date is nil")
		}

		Analytics.log(.TestResultMetadata(.updateTestResult(.positive)))
		XCTAssertEqual(secureStore.TestResultMetadata?.testResult, TestResult.positive, "incorrect testResult")

		// The the date is updated if the risk results changes e.g from pendong to positive
		XCTAssertEqual(secureStore.TestResultMetadata?.hoursSinceTestRegistration, (24 * 4), "incorrect hoursSinceTestRegistration")
	}

	func testUpdatingTestResult_Invalid() {
		let secureStore = MockTestStore()
		let riskCalculationResult = mockRiskCalculationResult(risk: .low)
		secureStore.riskCalculationResult = riskCalculationResult
		Analytics.log(.TestResultMetadata(.updateTestResult(.pending)))

		if let registrationDate = Calendar.current.date(byAdding: .day, value: -4, to: Date()) {
			Analytics.log(.TestResultMetadata(.registerNewTestMetadata(registrationDate)))
		} else {
			XCTFail("registration date is nil")
		}

		Analytics.log(.TestResultMetadata(.updateTestResult(.invalid)))

		// The if the value is invalid  testResult shouldn't be updated
		XCTAssertNil(secureStore.TestResultMetadata?.testResult, "incorrect testResult")

		// The if the value is invalid  hoursSinceTestRegistration shouldnt be updated and should remain the default value: 0
		XCTAssertEqual(secureStore.TestResultMetadata?.hoursSinceTestRegistration, 0, "incorrect hoursSinceTestRegistration")

	}

	private func mockRiskCalculationResult(risk: RiskLevel = .high) -> RiskCalculationResult {
		RiskCalculationResult(
			riskLevel: risk,
			minimumDistinctEncountersWithLowRisk: 0,
			minimumDistinctEncountersWithHighRisk: 0,
			mostRecentDateWithLowRisk: Date(),
			mostRecentDateWithHighRisk: Date(),
			numberOfDaysWithLowRisk: 0,
			numberOfDaysWithHighRisk: 2,
			calculationDate: Date(),
			riskLevelPerDate: [:]
		)
	}
}
