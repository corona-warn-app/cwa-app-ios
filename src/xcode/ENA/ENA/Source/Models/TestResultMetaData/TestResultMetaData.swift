////
// 🦠 Corona-Warn-App
//

import Foundation

struct TestResultMetaData: Codable {
	
	//pending, positive or negative only
	var testRsult: TestResult? 

	// positive or negative “First time received” = time of test result - time of test registration
	// Pending: "everytime" current timestamp - time of test registration
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

	init() {}
	
	enum CodingKeys: String, CodingKey {
		case testRsult
		case hoursSinceTestRegistration
		case riskLevelAtTestRegistration
		case daysSinceMostRecentDateAtRiskLevelAtTestRegistration
		case hoursSinceHighRiskWarningAtTestRegistration
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
		
	private var testResultDate: Int64?
	private var secureStore: Store
	
	// MARK: - Init.

	init(store: Store) {
		secureStore = store
	}
	
	// MARK: - Private Helpers.

	func registerNewTestMetadata(date: Date = Date()) {
		guard let riskLevel = secureStore.riskCalculationResult?.riskLevel  else {
			return
		}
		secureStore.testResultMetadata = TestResultMetaData()
		secureStore.testResultMetadata?.testRegisterationDate = date
		secureStore.testResultMetadata?.riskLevelAtTestRegistration = riskLevel
		secureStore.testResultMetadata?.daysSinceMostRecentDateAtRiskLevelAtTestRegistration = secureStore.riskCalculationResult?.numberOfDaysWithCurrentRiskLevel
		
		switch riskLevel {
		case .high:
			guard let timeOfRiskChangeToHigh = secureStore.dateOfConversionToHighRisk,
				  let registrationTime = secureStore.testResultMetadata?.testRegisterationDate else {
				Log.debug("Time Risk Change was not stored Correctly.")
				return
			}
			let differenceInHours = Calendar.current.dateComponents([.hour], from: timeOfRiskChangeToHigh, to: registrationTime)
			secureStore.testResultMetadata?.hoursSinceHighRiskWarningAtTestRegistration = differenceInHours.hour
		case .low:
			secureStore.testResultMetadata?.hoursSinceHighRiskWarningAtTestRegistration = -1
		}
	}

	func updateResult(testResult: TestResult) {
		// we only save metadata for tests submitted on QR code,and there is the only place in the app where we set the registration date
		guard secureStore.testResultMetadata?.testRegisterationDate != nil else {
			return
		}
		
		let storedTestResult = secureStore.testResultMetadata?.testRsult
		// if storedTestResult != newTestResult ---> update persisted testResult and the hoursSinceTestRegistration
		// if storedTestResult == nil ---> update persisted testResult and the hoursSinceTestRegistration
		// if storedTestResult == newTestResult ---> do nothing

		if storedTestResult == nil || storedTestResult != testResult {
			switch testResult {
			case .positive, .negative, .pending:
				secureStore.testResultMetadata?.testRsult = testResult
				saveHoursSinceTestRegistration()
				
			case .expired, .invalid:
				break
			}
		}
	}
	
	// MARK: - Private Helpers.
	
	private func saveHoursSinceTestRegistration() {
		guard var testMetadata = secureStore.testResultMetadata,
			  let registrationDate = secureStore.testResultMetadata?.testRegisterationDate
		else {
			return
		}
		
		switch testMetadata.testRsult {
		case .positive, .negative, .pending:
			let diffComponents = Calendar.current.dateComponents([.hour], from: registrationDate, to: Date())
			testMetadata.hoursSinceTestRegistration = diffComponents.hour
		default:
			testMetadata.hoursSinceTestRegistration = nil
		}
	}
}
