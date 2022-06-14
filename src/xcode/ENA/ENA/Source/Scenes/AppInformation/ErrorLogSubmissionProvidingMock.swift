//
// 🦠 Corona-Warn-App
//

import XCTest
@testable import ENA
import OpenCombine

class ErrorLogSubmissionProvidingMock: ErrorLogSubmissionProviding {
	var logFileSizePublisherSizeReturn: Int64 = 123
	var logFileSizePublisherShouldThrowError: ELSError?
	lazy var logFileSizePublisher: AnyPublisher<Int64, ELSError> = setupFileSizePublisher()
	
	var submitCompletionGiven: ELSSubmissionResponse?
	func submit(completion: @escaping ELSSubmissionResponse) {
		submitCompletionGiven = completion
	}
	
	var startLoggingCalledExpectation: XCTestExpectation?
	func startLogging() {
		startLoggingCalledExpectation?.fulfill()
	}
	
	var fetchExistingLogReturn: LogDataItem?
	var fetchExistingLogCalledExpectation: XCTestExpectation?
	func fetchExistingLog() -> LogDataItem? {
		fetchExistingLogCalledExpectation?.fulfill()
		return fetchExistingLogReturn
	}
	
	var stopAndDeleteLogCalledExpectation: XCTestExpectation?
	func stopAndDeleteLog() throws {
		stopAndDeleteLogCalledExpectation?.fulfill()
	}
	
	private func setupFileSizePublisher() -> AnyPublisher<Int64, ELSError> {
		Timer
			.publish(every: 1.0, on: .main, in: .default)
			.autoconnect()
			.tryMap { _ in
				if let error = self.logFileSizePublisherShouldThrowError {
					throw error
				} else {
					return self.logFileSizePublisherSizeReturn
				}
			}
			.mapError({ error -> ELSError in
				return error as? ELSError ?? ELSError.couldNotReadLogfile(error.localizedDescription)
			})
			.eraseToAnyPublisher()
	}
}
