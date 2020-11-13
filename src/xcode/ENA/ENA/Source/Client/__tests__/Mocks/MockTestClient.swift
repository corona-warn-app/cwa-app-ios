//
// 🦠 Corona-Warn-App
//

@testable import ENA
import ExposureNotification

final class ClientMock {
	// MARK: Creating a Mock Client
	init(submissionError: SubmissionError?) {
		self.submissionError = submissionError
	}

	// MARK: Properties
	let submissionError: SubmissionError?
	var onAppConfiguration: (AppConfigurationCompletion) -> Void = { $0(nil) }
}

extension ClientMock: Client {
	func appConfiguration(completion: @escaping AppConfigurationCompletion) {
		onAppConfiguration(completion)
	}

	func availableDays(completion: @escaping AvailableDaysCompletionHandler) {
		completion(.success([]))
	}

	func availableHours(day: String, completion: @escaping AvailableHoursCompletionHandler) {
		completion(.success([]))
	}

	func fetchDay(_: String, completion: @escaping DayCompletionHandler) {}

	func fetchHour(_: Int, day: String, completion: @escaping HourCompletionHandler) {}

	func exposureConfiguration(completion: @escaping ExposureConfigurationCompletionHandler) {
		completion(ENExposureConfiguration())
	}

	func submit(keys _: [ENTemporaryExposureKey], tan: String, completion: @escaping SubmitKeysCompletionHandler) {
		completion(submissionError)
	}

	func getRegistrationToken(forKey _: String, withType: String, completion completeWith: @escaping RegistrationHandler) {
		completeWith(.success("dummyRegistrationToken"))
	}

	func getTestResult(forDevice device: String, completion completeWith: @escaping TestResultHandler) {
		completeWith(.success(2))
	}

	func getTANForExposureSubmit(forDevice device: String, completion completeWith: @escaping TANHandler) {
		completeWith(.success("dummyTan"))
	}

	func appConfiguration(completion: @escaping AppConfigurationCompletion) {
		completion(SAP_ApplicationConfiguration())
	}
}
