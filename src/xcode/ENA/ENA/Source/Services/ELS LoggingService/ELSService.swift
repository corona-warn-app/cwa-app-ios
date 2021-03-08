////
// 🦠 Corona-Warn-App
//

import Foundation
import OpenCombine

protocol ErrorLogSubmitting {

	typealias ELSSubmissionCompletionHandler = (Result<LogUploadResponse, PPASError>) -> Void
	typealias ELSToken = String

	var logFileSizePublisher: OpenCombine.AnyPublisher<Int64, Error> { get }

	func submit(log: Data, uploadToken: ELSToken, completion: @escaping ELSSubmissionCompletionHandler)
}

struct LogUploadResponse {
	let id: String
	let hash: String
}


/// Handler for the log file uploading process
final class ErrorLogSubmissionService: ErrorLogSubmitting {

	private let client: Client
	private let store: ErrorLogProviding
	private lazy var fileLogger = FileLogger()
	private lazy var fileManager = FileManager.default

	/// Publisher to handle changes in the size of the log file
	///
	/// - Note: The current implementation does NOT constantly observe file size changes!
	private(set) lazy var logFileSizePublisher: AnyPublisher<Int64, Error> = setupFileSizePublisher()

	init(client: Client, store: ErrorLogProviding) {
		self.client = client
		self.store = store
	}

	// MARK: - ErrorLogSubmitting

	func submit(log: Data, uploadToken: ErrorLogSubmitting.ELSToken, completion: @escaping (Result<LogUploadResponse, PPASError>) -> Void) {
		// get log data from the 'all logs' file
		guard let item = LogDataItem(at: fileLogger.allLogsFileURL) else {
			Log.warning("No log data to export.", log: .localData)
			return
		}

		client.submit(logFile: item.compressedData as Data, uploadToken: uploadToken, isFake: false, completion: completion)
	}

	private func setupFileSizePublisher() -> AnyPublisher<Int64, Error> {
		// TO DO: evaluate switch to constant observation https://developer.apple.com/documentation/foundation/nsfilepresenter
		let fileSize = fileManager.sizeOfFile(atPath: fileLogger.allLogsFileURL.absoluteString) ?? -1
		return Just(fileSize)
			.setFailureType(to: Error.self)
			.eraseToAnyPublisher()
	}
}
