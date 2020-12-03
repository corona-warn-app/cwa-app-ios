//
// 🦠 Corona-Warn-App
//

import Foundation
import Combine
import UIKit

class ExposureSubmissionCoordinatorModel {

	// MARK: - Init

	init(exposureSubmissionService: ExposureSubmissionService, appConfigurationProvider: AppConfigurationProviding) {
		self.exposureSubmissionService = exposureSubmissionService
		self.appConfigurationProvider = appConfigurationProvider

		// Initial loading of country list
		// This is an intermediate solution until further refactoring has been done
		exposureSubmissionService.loadSupportedCountries { _ in
			// no op
		} onSuccess: {
			Log.debug("[Coordinator] initial country list loaded", log: .riskDetection)
		} onError: { error in
			Log.error("[Coordinator] Error during initial country load", log: .riskDetection, error: error)
		}

	}

	// MARK: - Internal

	let exposureSubmissionService: ExposureSubmissionService
	let appConfigurationProvider: AppConfigurationProviding

	var shouldShowSymptomsOnsetScreen = false

	func symptomsOptionSelected(
		_ selectedSymptomsOption: ExposureSubmissionSymptomsViewController.SymptomsOption
	) {
		switch selectedSymptomsOption {
		case .yes:
			shouldShowSymptomsOnsetScreen = true
		case .no:
			exposureSubmissionService.symptomsOnset = .nonSymptomatic
			shouldShowSymptomsOnsetScreen = false
		case .preferNotToSay:
			exposureSubmissionService.symptomsOnset = .noInformation
			shouldShowSymptomsOnsetScreen = false
		}
	}

	func symptomsOnsetOptionSelected(
		_ selectedSymptomsOnsetOption: ExposureSubmissionSymptomsOnsetViewController.SymptomsOnsetOption
	) {
		switch selectedSymptomsOnsetOption {
		case .exactDate(let date):
			guard let daysSinceOnset = Calendar.gregorian().dateComponents([.day], from: date, to: Date()).day else { fatalError("Getting days since onset from date failed") }
			exposureSubmissionService.symptomsOnset = .daysSinceOnset(daysSinceOnset)
		case .lastSevenDays:
			exposureSubmissionService.symptomsOnset = .lastSevenDays
		case .oneToTwoWeeksAgo:
			exposureSubmissionService.symptomsOnset = .oneToTwoWeeksAgo
		case .moreThanTwoWeeksAgo:
			exposureSubmissionService.symptomsOnset = .moreThanTwoWeeksAgo
		case .preferNotToSay:
			exposureSubmissionService.symptomsOnset = .symptomaticWithUnknownOnset
		}
	}

	func submitExposure(
		isLoading: @escaping (Bool) -> Void,
		onSuccess: @escaping () -> Void,
		onError: @escaping (ExposureSubmissionError) -> Void
	) {
		isLoading(true)

		exposureSubmissionService.submitExposure { error in
			isLoading(false)

			switch error {
			// If the user doesn`t allow the TEKs to be shared with the app, we stay on the screen (https://jira.itc.sap.com/browse/EXPOSUREAPP-2293)
			case .notAuthorized:
				return

			// We continue the regular flow even if there are no keys collected.
			case .none, .noKeys:
				onSuccess()

			case .some(let error):
				Log.error("error: \(error.localizedDescription)", log: .api)
				onError(error)
			}
		}
	}

	func getTestResults(
		for key: DeviceRegistrationKey,
		isLoading: @escaping (Bool) -> Void,
		onSuccess: @escaping (TestResult) -> Void,
		onError: @escaping (ExposureSubmissionError) -> Void
	) {
		isLoading(true)

		exposureSubmissionService.getTestResult(forKey: key, useStoredRegistration: false, completion: { result in
			isLoading(false)

			switch result {
			case let .failure(error):
				onError(error)
			case let .success(testResult):
				onSuccess(testResult)
			}
		})
	}

}
