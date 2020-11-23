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
	}

	// MARK: - Internal

	let exposureSubmissionService: ExposureSubmissionService
	let appConfigurationProvider: AppConfigurationProviding

	var supportedCountries: [Country] = []

	var shouldShowSymptomsOnsetScreen = false

	var exposureSubmissionServiceHasRegistrationToken: Bool {
		exposureSubmissionService.hasRegistrationToken()
	}

	func checkStateAndLoadCountries(
		isLoading: @escaping (Bool) -> Void,
		onSuccess: @escaping () -> Void,
		onError: @escaping (ExposureSubmissionError) -> Void
	) {
		if isExposureSubmissionServiceStateGood {
			loadSupportedCountries(isLoading: isLoading, onSuccess: onSuccess, onError: onError)
		} else {
			onError(.enNotEnabled)
		}
	}

	func symptomsOptionSelected(
		_ selectedSymptomsOption: ExposureSubmissionSymptomsViewController.SymptomsOption
	) {
		switch selectedSymptomsOption {
		case .yes:
			shouldShowSymptomsOnsetScreen = true
		case .no:
			symptomsOnset = .nonSymptomatic
			shouldShowSymptomsOnsetScreen = false
		case .preferNotToSay:
			symptomsOnset = .noInformation
			shouldShowSymptomsOnsetScreen = false
		}
	}

	func symptomsOnsetOptionSelected(
		_ selectedSymptomsOnsetOption: ExposureSubmissionSymptomsOnsetViewController.SymptomsOnsetOption
	) {
		switch selectedSymptomsOnsetOption {
		case .exactDate(let date):
			guard let daysSinceOnset = Calendar.gregorian().dateComponents([.day], from: date, to: Date()).day else { fatalError("Getting days since onset from date failed") }
			symptomsOnset = .daysSinceOnset(daysSinceOnset)
		case .lastSevenDays:
			symptomsOnset = .lastSevenDays
		case .oneToTwoWeeksAgo:
			symptomsOnset = .oneToTwoWeeksAgo
		case .moreThanTwoWeeksAgo:
			symptomsOnset = .moreThanTwoWeeksAgo
		case .preferNotToSay:
			symptomsOnset = .symptomaticWithUnknownOnset
		}
	}

	func warnOthersConsentGiven(
		isLoading: @escaping (Bool) -> Void,
		onSuccess: @escaping () -> Void,
		onError: @escaping (ExposureSubmissionError) -> Void
	) {
		startSubmitProcess(
			isLoading: isLoading,
			onSuccess: onSuccess,
			onError: onError
		)
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

	// MARK: - Private

	private var symptomsOnset: SymptomsOnset = .noInformation
	private var subscriptions = [AnyCancellable]()

	private var isExposureSubmissionServiceStateGood: Bool {
		exposureSubmissionService.preconditions().isGood
	}

	private func loadSupportedCountries(
		isLoading: @escaping (Bool) -> Void,
		onSuccess: @escaping () -> Void,
		onError: @escaping (ExposureSubmissionError) -> Void
	) {
		isLoading(true)
		appConfigurationProvider.appConfiguration().sink { [weak self] config in
			isLoading(false)
			let countries = config.supportedCountries.compactMap({ Country(countryCode: $0) })
			if countries.isEmpty {
				self?.supportedCountries = [.defaultCountry()]
			} else {
				self?.supportedCountries = countries
			}
			onSuccess()
			
		}.store(in: &subscriptions)
	}

	private func startSubmitProcess(
		isLoading: @escaping (Bool) -> Void,
		onSuccess: @escaping () -> Void,
		onError: @escaping (ExposureSubmissionError) -> Void
	) {
		isLoading(true)

		exposureSubmissionService.submitExposure(
			symptomsOnset: symptomsOnset,
			visitedCountries: supportedCountries,
			completionHandler: { error in
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
		)
	}

}
