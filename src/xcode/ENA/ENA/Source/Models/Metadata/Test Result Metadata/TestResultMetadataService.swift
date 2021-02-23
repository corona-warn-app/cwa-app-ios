////
// 🦠 Corona-Warn-App
//

import Foundation

class TestResultMetadataService {
			
	// MARK: - Init
	
	init(store: Store) {
		secureStore = store
	}
	
	// MARK: - Internal

	func registerNewTestMetadata(date: Date = Date(), token: String) {
		guard let riskLevel = secureStore.riskCalculationResult?.riskLevel  else {
			return
		}
		secureStore.testResultMetadata = TestResultMetadata(registrationToken: token)
		secureStore.testResultMetadata?.testRegistrationDate = date
		secureStore.testResultMetadata?.riskLevelAtTestRegistration = riskLevel
		secureStore.testResultMetadata?.daysSinceMostRecentDateAtRiskLevelAtTestRegistration = secureStore.riskCalculationResult?.numberOfDaysWithCurrentRiskLevel
		
		switch riskLevel {
		case .high:
			guard let timeOfRiskChangeToHigh = secureStore.dateOfConversionToHighRisk,
				  let registrationTime = secureStore.testResultMetadata?.testRegistrationDate else {
				Log.debug("Time Risk Change was not stored Correctly.")
				return
			}
			let differenceInHours = Calendar.current.dateComponents([.hour], from: timeOfRiskChangeToHigh, to: registrationTime)
			secureStore.testResultMetadata?.hoursSinceHighRiskWarningAtTestRegistration = differenceInHours.hour
		case .low:
			secureStore.testResultMetadata?.hoursSinceHighRiskWarningAtTestRegistration = -1
		}
	}

	func updateResult(testResult: TestResult, token: String) {
		// we only save metadata for tests submitted on QR code,and there is the only place in the app where we set the registration date
		guard secureStore.testResultMetadata?.testRegistrationToken == token,
			secureStore.testResultMetadata?.testRegistrationDate != nil else {
			return
		}
		
		let storedTestResult = secureStore.testResultMetadata?.testResult
		// if storedTestResult != newTestResult ---> update persisted testResult and the hoursSinceTestRegistration
		// if storedTestResult == nil ---> update persisted testResult and the hoursSinceTestRegistration
		// if storedTestResult == newTestResult ---> do nothing

		if storedTestResult == nil || storedTestResult != testResult {
			switch testResult {
			case .positive, .negative, .pending:
				secureStore.testResultMetadata?.testResult = testResult
				saveHoursSinceTestRegistration()
				
			case .expired, .invalid:
				break
			}
		}
	}
	
	// MARK: - Private

	private func saveHoursSinceTestRegistration() {
		guard let registrationDate = secureStore.testResultMetadata?.testRegistrationDate else {
			return
		}
		
		switch secureStore.testResultMetadata?.testResult {
		case .positive, .negative, .pending:
			let diffComponents = Calendar.current.dateComponents([.hour], from: registrationDate, to: Date())
			secureStore.testResultMetadata?.hoursSinceTestRegistration = diffComponents.hour
		default:
			secureStore.testResultMetadata?.hoursSinceTestRegistration = nil
		}
	}
	
	private var secureStore: Store
}
