////
// 🦠 Corona-Warn-App
//

import Foundation

class TestResultMetadataService {
			
	// MARK: - Init
	
	init(store: Store) {
		self.store = store
	}
	
	// MARK: - Internal

	func registerNewTestMetadata(date: Date = Date()) {
		guard let riskCalculationResult = store.riskCalculationResult else {
			return
		}
		var testResultMetadata = TestResultMetaData()
		testResultMetadata.testRegistrationDate = date
		testResultMetadata.riskLevelAtTestRegistration = riskCalculationResult.riskLevel
		testResultMetadata.daysSinceMostRecentDateAtRiskLevelAtTestRegistration = riskCalculationResult.numberOfDaysWithCurrentRiskLevel
		
		switch riskCalculationResult.riskLevel {
		case .high:
			guard let timeOfRiskChangeToHigh = store.dateOfConversionToHighRisk else {
				Log.debug("Time Risk Change was not stored Correctly.")
				return
			}
			let differenceInHours = Calendar.current.dateComponents([.hour], from: timeOfRiskChangeToHigh, to: date)
			testResultMetadata.hoursSinceHighRiskWarningAtTestRegistration = differenceInHours.hour
		case .low:
			testResultMetadata.hoursSinceHighRiskWarningAtTestRegistration = -1
		}

		Analytics.log(.testResultMetadata(testResultMetadata))
	}

	func updateResult(testResult: TestResult) {
		// we only save metadata for tests submitted on QR code,and there is the only place in the app where we set the registration date
		guard Analytics.testRegistrationDate != nil else {
			return
		}
		
		let storedTestResult = Analytics.testResult
		// if storedTestResult != newTestResult ---> update persisted testResult and the hoursSinceTestRegistration
		// if storedTestResult == nil ---> update persisted testResult and the hoursSinceTestRegistration
		// if storedTestResult == newTestResult ---> do nothing

		if storedTestResult == nil || storedTestResult != testResult {
			switch testResult {
			case .positive, .negative, .pending:

				Analytics.logPartial(.testResult(testResult))
				saveHoursSinceTestRegistration()
				
			case .expired, .invalid:
				break
			}
		}
	}
	
	// MARK: - Private

	private let store: Store

	private func saveHoursSinceTestRegistration() {
		guard let registrationDate = Analytics.testRegistrationDate else {
			return
		}
		
		switch Analytics.testResult {
		case .positive, .negative, .pending:
			let diffComponents = Calendar.current.dateComponents([.hour], from: registrationDate, to: Date())
			Analytics.logPartial(.hoursSinceTestRegistration(diffComponents.hour))
		default:
			Analytics.logPartial(.hoursSinceTestRegistration(nil))
		}
	}

}
