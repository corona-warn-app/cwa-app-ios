////
// 🦠 Corona-Warn-App
//

import Foundation

struct TestResultMetaData: Codable {
	
	//pending, positive or negative only
	var testRsult: TestResult?

	// positive or negative “First time received” = time of test result - time of test registration
	// Pending: "everytime" current timestamp - time of test registration
	// question: current time of reciveing the pending test result or time of submittion????
	var hoursSinceTestRegistration: Int? = 0
	
	// the risk level on the riskcard i.e totalRiskLevel
	var riskLevelAtTestRegistration: RiskLevel?
	
	// Number of days on the risk card
	var daysSinceMostRecentDateAtRiskLevelAtTestRegistration: Int?
	
	// if high = timestamp of when the risk card turned red -  timestamp of test registration
	// if low = -1
	var hoursSinceHighRiskWarningAtTestRegistration: Int?

	var testRegisterationDate: Date?
	
	// MARK: - Private

	enum CodingKeys: String, CodingKey {
		case testRsult
		case hoursSinceTestRegistration
		case riskLevelAtTestRegistration
		case daysSinceMostRecentDateAtRiskLevelAtTestRegistration
		case hoursSinceHighRiskWarningAtTestRegistration
	}

	init() {
		self.testRegisterationDate = Date()
	}

	init(from decoder: Decoder) throws {
		let container = try decoder.container(keyedBy: CodingKeys.self)
		
		testRsult = try container.decodeIfPresent(TestResult.self, forKey: .testRsult)
		hoursSinceTestRegistration = try container.decodeIfPresent(Int.self, forKey: .hoursSinceTestRegistration)
		riskLevelAtTestRegistration = try container.decodeIfPresent(RiskLevel.self, forKey: .riskLevelAtTestRegistration)
		daysSinceMostRecentDateAtRiskLevelAtTestRegistration = try container.decodeIfPresent(
			Int.self,
			forKey: .daysSinceMostRecentDateAtRiskLevelAtTestRegistration
		)
		hoursSinceHighRiskWarningAtTestRegistration = try container.decodeIfPresent(
			Int.self,
			forKey: .hoursSinceHighRiskWarningAtTestRegistration
		)
	}
}

class TestResultMetadataService {
	
	var testRegisterationDate: Date?
	
	private var testResultDate: Date?
	private var secureStore: Store
	
	init(store: Store) {
		secureStore = store
	}

	func saveTestRegisterationDate() {
		secureStore.testResultMetadata = TestResultMetaData()
	}
	
	func saveHoursSinceTestRegistration() {
		guard var testMetadata = secureStore.testResultMetadata,
			  let resultDate = testResultDate,
			  let registrationDate = testRegisterationDate
		else {
			return
		}
		
		switch testMetadata.testRsult {
		case .positive, .negative:
			let diffComponents = Calendar.current.dateComponents([.hour], from: registrationDate, to: resultDate)
			testMetadata.hoursSinceTestRegistration = diffComponents.hour
		case .pending:
			// double check if this works and what it means by today date
			let diffComponents = Calendar.current.dateComponents([.hour], from: registrationDate, to: Date())
			testMetadata.hoursSinceTestRegistration = diffComponents.hour
		default:
			testMetadata.hoursSinceTestRegistration = nil
		}
	}
	
	func saveTestResult(testResult: TestResult) {
		switch testResult {
		case .positive, .negative, .pending:
			secureStore.testResultMetadata?.testRsult = testResult
			testResultDate = Date()
		case .expired, .invalid:
			break
		}
	}
}
