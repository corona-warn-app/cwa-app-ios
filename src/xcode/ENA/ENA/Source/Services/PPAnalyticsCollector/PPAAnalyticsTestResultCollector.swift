////
// 🦠 Corona-Warn-App
//

import Foundation

final class PPAAnalyticsTestResultCollector {

	init(store: Store) {
		// We put the PPAnalyticsData protocol and its implementation in a seperate file because this protocol is only used by the collector. And only the collector should use it!
		// This way we avoid the direct asscess of analytics data at other places over the store.
		guard let store = store as? (Store & PPAnalyticsData) else {
			Log.error("I will never submit any analytics data. Could not cast to correct store protocol", log: .ppa)
			fatalError("I will never submit any analytics data. Could not cast to correct store protocol")
		}

		self.store = store
	}

	// MARK: - Internal

	func logTestResultMetadata(_ testResultMetadata: PPATestResultMetadata) {
		switch testResultMetadata {
		case let .updateTestResult(testResult, token, type):
			updateTestResult(testResult, token, type)
		case let .registerNewTestMetadata(date, token, type):
			registerNewTestMetadata(date, token, type)
		}
	}

	// MARK: - Private

	private var store: PPAnalyticsData & StoreProtocol

	private func createTestResultMetadata(_ metaData: TestResultMetadata) {
		switch metaData.testType {
		case .pcr:
			store.testResultMetadata = metaData
		case .antigen:
			store.antigenTestResultMetadata = metaData
		}
	}

	private func persistTestResult(testResult: TestResult, testType: TestResultMetadata.TestType) {
		switch testType {
		case .pcr:
			store.testResultMetadata?.testResult = testResult
		case .antigen:
			store.antigenTestResultMetadata?.testResult = testResult
		}
	}

	private func updateTestResultHoursSinceTestRegistration(_ hours: Int?, testType: TestResultMetadata.TestType) {
		switch testType {
		case .pcr:
			store.testResultMetadata?.hoursSinceTestRegistration = hours
		case .antigen:
			store.antigenTestResultMetadata?.hoursSinceTestRegistration = hours
		}
	}

	private func registerNewTestMetadata(_ date: Date = Date(), _ token: String, _ type: TestResultMetadata.TestType) {
		guard let riskCalculationResult = store.enfRiskCalculationResult else {
			Log.warning("Could not register new test meta data due to riskCalculationResult is nil", log: .ppa)
			return
		}
		var testResultMetadata = TestResultMetadata(registrationToken: token, testType: type)
		testResultMetadata.testRegistrationDate = date
		testResultMetadata.riskLevelAtTestRegistration = riskCalculationResult.riskLevel

		if let mostRecentRiskCalculationDate = riskCalculationResult.mostRecentDateWithCurrentRiskLevel {
			let daysSinceMostRecentDateAtRiskLevelAtTestRegistration = Calendar.current.dateComponents([.day], from: mostRecentRiskCalculationDate, to: date).day
			testResultMetadata.daysSinceMostRecentDateAtRiskLevelAtTestRegistration = daysSinceMostRecentDateAtRiskLevelAtTestRegistration
			Log.debug("daysSinceMostRecentDateAtRiskLevelAtTestRegistration: \(String(describing: daysSinceMostRecentDateAtRiskLevelAtTestRegistration))", log: .ppa)
		} else {
			testResultMetadata.daysSinceMostRecentDateAtRiskLevelAtTestRegistration = -1
			Log.warning("daysSinceMostRecentDateAtRiskLevelAtTestRegistration: -1", log: .ppa)
		}

		createTestResultMetadata(testResultMetadata)

		switch riskCalculationResult.riskLevel {
		case .high:
			guard let timeOfRiskChangeToHigh = store.dateOfConversionToHighRisk else {
				Log.warning("Could not log risk calculation result due to timeOfRiskChangeToHigh is nil", log: .ppa)
				return
			}
			let differenceInHours = Calendar.current.dateComponents([.hour], from: timeOfRiskChangeToHigh, to: date)
			updateHoursSinceHighRiskWarningAtTestRegistration(hours: differenceInHours.hour, testType: type)
		case .low:
			updateHoursSinceHighRiskWarningAtTestRegistration(hours: -1, testType: type)
		}
	}

	private func updateHoursSinceHighRiskWarningAtTestRegistration(hours: Int?, testType: TestResultMetadata.TestType) {
		switch testType {
		case .pcr:
			store.testResultMetadata?.hoursSinceHighRiskWarningAtTestRegistration = hours
		case .antigen:
			store.antigenTestResultMetadata?.hoursSinceHighRiskWarningAtTestRegistration = hours
		}
	}

	private func updateTestResult(_ testResult: TestResult, _ token: String, _ type: TestResultMetadata.TestType) {
		// we only save metadata for tests submitted on QR code,and there is the only place in the app where we set the registration date
		guard shouldUpdateTestResult(token: token, type: type),
			  let registrationDate = testRegistrationDate(for: type) else {
			Log.warning("Could not update test meta data result of type: \(type), due to testRegistrationDate is nil.", log: .ppa)
			return
		}


		let storedTestResultMetaData = storedTestResultMetadata(for: type)
		let storedTestResult = storedTestResultMetaData?.testResult
		// if storedTestResult != newTestResult ---> update persisted testResult and the hoursSinceTestRegistration
		// if storedTestResult == nil ---> update persisted testResult and the hoursSinceTestRegistration
		// if storedTestResult == newTestResult ---> do nothing

		if storedTestResult == nil || storedTestResult != testResult {
			switch testResult {
			case .positive, .negative, .pending:
				Log.info("update TestResultMetadata of type: \(type), with testResult: \(testResult.stringValue)", log: .ppa)

				persistTestResult(testResult: testResult, testType: type)

				let diffComponents = Calendar.current.dateComponents([.hour], from: registrationDate, to: Date())

				updateTestResultHoursSinceTestRegistration(diffComponents.hour, testType: type)

				Log.info("update TestResultMetadataof type: \(type), with HoursSinceTestRegistration: \(String(describing: diffComponents.hour))", log: .ppa)

			case .expired, .invalid:
				break
			}
		} else {
			Log.warning("will not update same TestResultMetadata, oldResult: \(storedTestResult?.stringValue ?? "") newResult: \(testResult.stringValue) of type: \(type)", log: .ppa)
		}
	}

	private func shouldUpdateTestResult(token: String, type: TestResultMetadata.TestType) -> Bool {
		switch type {
		case .pcr:
			return store.testResultMetadata?.testRegistrationToken == token
		case .antigen:
			return store.antigenTestResultMetadata?.testRegistrationToken == token
		}
	}

	private func testRegistrationDate(for type: TestResultMetadata.TestType) -> Date? {
		switch type {
		case .pcr:
			return store.testResultMetadata?.testRegistrationDate
		case .antigen:
			return store.antigenTestResultMetadata?.testRegistrationDate
		}
	}

	private func storedTestResultMetadata(for type: TestResultMetadata.TestType) -> TestResultMetadata? {
		switch type {
		case .pcr:
			return store.testResultMetadata
		case .antigen:
			return store.antigenTestResultMetadata
		}
	}
}
