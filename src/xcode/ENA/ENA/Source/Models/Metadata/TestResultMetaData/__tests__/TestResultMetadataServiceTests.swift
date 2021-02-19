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
		
		let sut = TestResultMetadataService(store: secureStore)
		sut.registerNewTestMetadata(date: date, token: "Token")

		XCTAssertNotNil(secureStore.testResultMetadata, "The testResultMetadata should be initialized")
		XCTAssertEqual(secureStore.testResultMetadata?.testRegistrationDate, date, "incorrect RegistrationDate")
		XCTAssertEqual(secureStore.testResultMetadata?.riskLevelAtTestRegistration, riskCalculationResult.riskLevel, "incorrect risk level")
		XCTAssertEqual(
			secureStore.testResultMetadata?.daysSinceMostRecentDateAtRiskLevelAtTestRegistration,
			riskCalculationResult.numberOfDaysWithCurrentRiskLevel,
			"incorrect days since recent riskLEvel"
		)
		
		// the difference from dateOfConversionToHighRisk should be one day so 24 hours
		XCTAssertEqual(secureStore.testResultMetadata?.hoursSinceHighRiskWarningAtTestRegistration, 24, "incorrect hours")
	}
	
	func testRegisteringNewTestMetadata_LowRisk() {
		let secureStore = MockTestStore()
		let riskCalculationResult = mockRiskCalculationResult(risk: .low)
		let date = Date()
		secureStore.riskCalculationResult = riskCalculationResult
		
		let sut = TestResultMetadataService(store: secureStore)
		sut.registerNewTestMetadata(date: date, token: "Token")

		XCTAssertNotNil(secureStore.testResultMetadata, "The testResultMetadata should be initialized")
		XCTAssertEqual(secureStore.testResultMetadata?.testRegistrationDate, date, "incorrect RegistrationDate")
		XCTAssertEqual(secureStore.testResultMetadata?.riskLevelAtTestRegistration, riskCalculationResult.riskLevel, "incorrect risk level")
		XCTAssertEqual(
			secureStore.testResultMetadata?.daysSinceMostRecentDateAtRiskLevelAtTestRegistration,
			riskCalculationResult.numberOfDaysWithCurrentRiskLevel,
			"incorrect days since recent riskLEvel"
		)
		
		// the for low risk the value should always be -1
		XCTAssertEqual(secureStore.testResultMetadata?.hoursSinceHighRiskWarningAtTestRegistration, -1, "incorrect hours")
	}
	
	func testUpdatingTestResult_ValidResult_NotPreviousTestResultStored() {
		let secureStore = MockTestStore()
		let riskCalculationResult = mockRiskCalculationResult(risk: .low)
		secureStore.riskCalculationResult = riskCalculationResult
		let sut = TestResultMetadataService(store: secureStore)

		if let registrationDate = Calendar.current.date(byAdding: .day, value: -4, to: Date()) {
			sut.registerNewTestMetadata(date: registrationDate, token: "Token")
		} else {
			XCTFail("registration date is nil")
		}

		sut.updateResult(testResult: .positive, token: "Token")
		XCTAssertEqual(secureStore.testResultMetadata?.testResult, TestResult.positive, "incorrect testResult")
		XCTAssertEqual(secureStore.testResultMetadata?.hoursSinceTestRegistration, (24 * 4), "incorrect hoursSinceTestRegistration")
	}
	
	func testUpdatingTestResult_ValidResult_previouslyStoredWithSameValue() {
		let secureStore = MockTestStore()
		let riskCalculationResult = mockRiskCalculationResult(risk: .low)
		secureStore.riskCalculationResult = riskCalculationResult
		let sut = TestResultMetadataService(store: secureStore)

		if let registrationDate = Calendar.current.date(byAdding: .day, value: -4, to: Date()) {
			sut.registerNewTestMetadata(date: registrationDate, token: "Token")
			sut.updateResult(testResult: .positive, token: "Token")
			secureStore.testResultMetadata?.hoursSinceTestRegistration = 0

		} else {
			XCTFail("registration date is nil")
		}

		sut.updateResult(testResult: .positive, token: "Token")
		XCTAssertEqual(secureStore.testResultMetadata?.testResult, TestResult.positive, "incorrect testResult")
		
		/* The date shouldn't be updated if the test result is the same as the old one
			- hoursSinceTestRegistration if updated should be (24 * 4)
			- we explicitly set it into 0 in line 81, so we can see the change
		*/
		XCTAssertNotEqual(secureStore.testResultMetadata?.hoursSinceTestRegistration, (24 * 4), "incorrect hoursSinceTestRegistration")
	}

	func testUpdatingTestResult_ValidResult_previouslyStoredWithDifferentValue() {
		let secureStore = MockTestStore()
		let riskCalculationResult = mockRiskCalculationResult(risk: .low)
		secureStore.riskCalculationResult = riskCalculationResult
		let sut = TestResultMetadataService(store: secureStore)

		if let registrationDate = Calendar.current.date(byAdding: .day, value: -4, to: Date()) {
			sut.registerNewTestMetadata(date: registrationDate, token: "Token")
			secureStore.testResultMetadata?.testResult = .pending
		} else {
			XCTFail("registration date is nil")
		}

		sut.updateResult(testResult: .positive, token: "Token")
		XCTAssertEqual(secureStore.testResultMetadata?.testResult, TestResult.positive, "incorrect testResult")
		
		// The the date is updated if the risk results changes e.g from pendong to positive
		XCTAssertEqual(secureStore.testResultMetadata?.hoursSinceTestRegistration, (24 * 4), "incorrect hoursSinceTestRegistration")
	}

	func testUpdatingTestResult_Invalid() {
		let secureStore = MockTestStore()
		let riskCalculationResult = mockRiskCalculationResult(risk: .low)
		secureStore.riskCalculationResult = riskCalculationResult
		let sut = TestResultMetadataService(store: secureStore)

		if let registrationDate = Calendar.current.date(byAdding: .day, value: -4, to: Date()) {
			sut.registerNewTestMetadata(date: registrationDate, token: "Token")
			secureStore.testResultMetadata?.testResult = .pending
		} else {
			XCTFail("registration date is nil")
		}

		sut.updateResult(testResult: .invalid, token: "Token")
		
		// The if the value is invalid  testResult shouldn't be updated
		XCTAssertEqual(secureStore.testResultMetadata?.testResult, .pending, "testResult shouldn't be updated")
		
		// The if the value is invalid  hoursSinceTestRegistration shouldnt be updated and should remain the default value: 0
		XCTAssertEqual(secureStore.testResultMetadata?.hoursSinceTestRegistration, 0, "incorrect hoursSinceTestRegistration")

	}
	
	func testUpdatingTestResult_WithDifferentRegistrationToken_MetadataIsNotUpdated() {
		let secureStore = MockTestStore()
		let riskCalculationResult = mockRiskCalculationResult(risk: .low)
		secureStore.riskCalculationResult = riskCalculationResult
		let sut = TestResultMetadataService(store: secureStore)

		if let registrationDate = Calendar.current.date(byAdding: .day, value: -4, to: Date()) {
			sut.registerNewTestMetadata(date: registrationDate, token: "Token")
			secureStore.testResultMetadata?.testResult = .pending
		} else {
			XCTFail("registration date is nil")
		}
		
		// trying to update a test with a different token shouldn't work
		sut.updateResult(testResult: .positive, token: "Different Token")
		// The if the value is valid but the token is different then the testResult shouldn't be updated
		XCTAssertEqual(secureStore.testResultMetadata?.testResult, .pending, "testResult shouldn't be updated")

		// trying to update a test with the correct token should work
		sut.updateResult(testResult: .positive, token: "Token")
		// The if the value is valid and the token the same then the testResult should be updated
		XCTAssertEqual(secureStore.testResultMetadata?.testResult, .positive, "testResult should be updated")
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
