////
// 🦠 Corona-Warn-App
//

import Foundation

final class PPAAnalyticsTestResultCollector {

	init(store: Store) {
		// We put the PPAnalyticsData protocol and its implementation in a separate file because this protocol is only used by the collector. And only the collector should use it!
		// This way we avoid the direct access of analytics data at other places over the store.
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
		case let .setDateOfConversionToENFHighRisk(date):
			store.dateOfConversionToENFHighRisk = date
		case let .setDateOfConversionToCheckinHighRisk(date):
			store.dateOfConversionToCheckinHighRisk = date
		case let .collectCurrentExposureWindows(exposureWindows):
			collectCurrentExposureWindows(exposureWindows)
		}
	}

	// MARK: - Private

	private var store: PPAnalyticsData & StoreProtocol

	private func createTestResultMetadata(_ metaData: TestResultMetadata) {
		switch metaData.testType {
		case .pcr:
			store.pcrTestResultMetadata = metaData
		case .antigen:
			store.antigenTestResultMetadata = metaData
		}
	}

	private func persistTestResult(testResult: TestResult, testType: CoronaTestType) {
		switch testType {
		case .pcr:
			store.pcrTestResultMetadata?.testResult = testResult
		case .antigen:
			store.antigenTestResultMetadata?.testResult = testResult
		}
	}

	private func updateTestResultHoursSinceTestRegistration(_ hours: Int?, testType: CoronaTestType) {
		switch testType {
		case .pcr:
			store.pcrTestResultMetadata?.hoursSinceTestRegistration = hours
		case .antigen:
			store.antigenTestResultMetadata?.hoursSinceTestRegistration = hours
		}
	}
	
	private func updateExposureWindowsUntilTestResult(_ exposureWindows: [SubmissionExposureWindow], testType: CoronaTestType) {
		var currentExposureWindows = exposureWindows
		
		switch testType {
		case .pcr:
			if let exposureWindowsAtTestRegistration = store.pcrTestResultMetadata?.exposureWindowsAtTestRegistration {
				// removing all the exposureWindowsAtTestRegistration from current exposure windows
				currentExposureWindows.removeAll(where: { window -> Bool in
					return exposureWindowsAtTestRegistration.contains(where: { $0.hash == window.hash })
				})
				store.pcrTestResultMetadata?.exposureWindowsUntilTestResult = currentExposureWindows
			}
		case .antigen:
			if let exposureWindowsAtTestRegistration = store.antigenTestResultMetadata?.exposureWindowsAtTestRegistration {
				// removing all the exposureWindowsAtTestRegistration from current exposure windows
				currentExposureWindows.removeAll(where: { window -> Bool in
					return exposureWindowsAtTestRegistration.contains(where: { $0.hash == window.hash })
				})
				store.antigenTestResultMetadata?.exposureWindowsUntilTestResult = currentExposureWindows
			}
		}
	}
	
	// swiftlint:disable:next cyclomatic_complexity
	private func registerNewTestMetadata(_ date: Date = Date(), _ token: String, _ type: CoronaTestType) {
		guard store.enfRiskCalculationResult != nil || store.checkinRiskCalculationResult != nil else {
			Log.warning("Could not register new test meta data due to enfRiskCalculationResult and checkinRiskCalculationResult are both nil", log: .ppa)
			return
		}
		
		var testResultMetadata = TestResultMetadata(registrationToken: token, testType: type)
		testResultMetadata.testRegistrationDate = date
		
		if let enfRiskCalculationResult = store.enfRiskCalculationResult {
			testResultMetadata.riskLevelAtTestRegistration = enfRiskCalculationResult.riskLevel

			if let mostRecentRiskCalculationDate = enfRiskCalculationResult.mostRecentDateWithCurrentRiskLevel {
				let daysSinceMostRecentDateAtRiskLevelAtTestRegistration = Calendar.current.dateComponents([.day], from: mostRecentRiskCalculationDate, to: date).day
				testResultMetadata.daysSinceMostRecentDateAtRiskLevelAtTestRegistration = daysSinceMostRecentDateAtRiskLevelAtTestRegistration
				Log.debug("daysSinceMostRecentDateAtRiskLevelAtTestRegistration: \(String(describing: daysSinceMostRecentDateAtRiskLevelAtTestRegistration))", log: .ppa)
			} else {
				testResultMetadata.daysSinceMostRecentDateAtRiskLevelAtTestRegistration = -1
				Log.warning("daysSinceMostRecentDateAtRiskLevelAtTestRegistration: -1", log: .ppa)
			}

			switch enfRiskCalculationResult.riskLevel {
			case .high:
				if let timeOfRiskChangeToHigh = store.dateOfConversionToENFHighRisk {
					let differenceInHours = Calendar.current.dateComponents([.hour], from: timeOfRiskChangeToHigh, to: date)
					testResultMetadata.hoursSinceHighRiskWarningAtTestRegistration = differenceInHours.hour
				} else {
					Log.warning("Could not log risk calculation result due to timeOfRiskChangeToHigh is nil", log: .ppa)
				}
			case .low:
				testResultMetadata.hoursSinceHighRiskWarningAtTestRegistration = -1
			}
		}
		
		if let checkinRiskCalculationResult = store.checkinRiskCalculationResult {
			testResultMetadata.checkinRiskLevelAtTestRegistration = checkinRiskCalculationResult.riskLevel
			
			if let mostRecentRiskCalculationDate = checkinRiskCalculationResult.mostRecentDateWithCurrentRiskLevel {
				let daysSinceMostRecentDateAtRiskLevelAtTestRegistration = Calendar.current.dateComponents([.day], from: mostRecentRiskCalculationDate, to: date).day
				testResultMetadata.daysSinceMostRecentDateAtCheckinRiskLevelAtTestRegistration = daysSinceMostRecentDateAtRiskLevelAtTestRegistration
				Log.debug("daysSinceMostRecentDateAtCheckinRiskLevelAtTestRegistration: \(String(describing: daysSinceMostRecentDateAtRiskLevelAtTestRegistration))", log: .ppa)
			} else {
				testResultMetadata.daysSinceMostRecentDateAtCheckinRiskLevelAtTestRegistration = -1
				Log.warning("daysSinceMostRecentDateAtCheckinRiskLevelAtTestRegistration: -1", log: .ppa)
			}
			
			switch checkinRiskCalculationResult.riskLevel {
			case .high:
				if let timeOfRiskChangeToHigh = store.dateOfConversionToCheckinHighRisk {
					let differenceInHours = Calendar.current.dateComponents([.hour], from: timeOfRiskChangeToHigh, to: date)
					testResultMetadata.hoursSinceCheckinHighRiskWarningAtTestRegistration = differenceInHours.hour
				} else {
					Log.warning("Could not log checkin risk calculation result due to timeOfRiskChangeToHigh is nil", log: .ppa)
				}
			case .low:
				testResultMetadata.hoursSinceCheckinHighRiskWarningAtTestRegistration = -1
			}
		}
		
		if let currentExposureWindows = store.currentExposureWindows {
			testResultMetadata.exposureWindowsAtTestRegistration = currentExposureWindows
		}

		createTestResultMetadata(testResultMetadata)
	}

	private func updateHoursSinceENFHighRiskWarningAtTestRegistration(hours: Int?, testType: CoronaTestType) {
		switch testType {
		case .pcr:
			store.pcrTestResultMetadata?.hoursSinceHighRiskWarningAtTestRegistration = hours
		case .antigen:
			store.antigenTestResultMetadata?.hoursSinceHighRiskWarningAtTestRegistration = hours
		}
	}
	
	private func updateHoursSinceCheckinHighRiskWarningAtTestRegistration(hours: Int?, testType: CoronaTestType) {
		switch testType {
		case .pcr:
			store.pcrTestResultMetadata?.hoursSinceCheckinHighRiskWarningAtTestRegistration = hours
		case .antigen:
			store.antigenTestResultMetadata?.hoursSinceCheckinHighRiskWarningAtTestRegistration = hours
		}
	}

	private func updateTestResult(_ testResult: TestResult, _ token: String, _ type: CoronaTestType) {
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
				if testResult != .pending, let currentExposureWindows = store.currentExposureWindows {
					updateExposureWindowsUntilTestResult(currentExposureWindows, testType: type)
				}

				let diffComponents = Calendar.current.dateComponents([.hour], from: registrationDate, to: Date())

				updateTestResultHoursSinceTestRegistration(diffComponents.hour, testType: type)

				Log.info("update TestResultMetadata of type: \(type), with HoursSinceTestRegistration: \(String(describing: diffComponents.hour))", log: .ppa)
			case .expired, .invalid:
				break
			}
		} else {
			Log.warning("will not update same TestResultMetadata, oldResult: \(storedTestResult?.stringValue ?? "") newResult: \(testResult.stringValue) of type: \(type)", log: .ppa)
		}
	}

	private func collectCurrentExposureWindows(_ riskCalculationWindows: [RiskCalculationExposureWindow]) {
		let mappedSubmissionExposureWindows: [SubmissionExposureWindow] = riskCalculationWindows.map {
			SubmissionExposureWindow(
				exposureWindow: $0.exposureWindow,
				transmissionRiskLevel: $0.transmissionRiskLevel,
				normalizedTime: $0.normalizedTime,
				hash: Analytics.generateSHA256($0.exposureWindow),
				date: $0.date
			)
		}

		store.currentExposureWindows = mappedSubmissionExposureWindows
		Log.info("Number of current exposure windows: \(String(describing: store.currentExposureWindows?.count)) windows", log: .ppa)
	}
	
	private func shouldUpdateTestResult(token: String, type: CoronaTestType) -> Bool {
		switch type {
		case .pcr:
			return store.pcrTestResultMetadata?.testRegistrationToken == token
		case .antigen:
			return store.antigenTestResultMetadata?.testRegistrationToken == token
		}
	}

	private func testRegistrationDate(for type: CoronaTestType) -> Date? {
		switch type {
		case .pcr:
			return store.pcrTestResultMetadata?.testRegistrationDate
		case .antigen:
			return store.antigenTestResultMetadata?.testRegistrationDate
		}
	}

	private func storedTestResultMetadata(for type: CoronaTestType) -> TestResultMetadata? {
		switch type {
		case .pcr:
			return store.pcrTestResultMetadata
		case .antigen:
			return store.antigenTestResultMetadata
		}
	}
}
