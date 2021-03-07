////
// 🦠 Corona-Warn-App
//

import Foundation

protocol ErrorLogSubmitting {

	typealias ELSSubmissionCompletionHandler = (Result<LogUploadResponse, PPASError>) -> Void
	typealias ELSToken = String
	
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

	init(client: Client, store: ErrorLogProviding) {
		self.client = client
		self.store = store
	}

	// MARK: - ErrorLogSubmitting

	func submit(log: Data, uploadToken: ErrorLogSubmitting.ELSToken, completion: @escaping (Result<LogUploadResponse, PPASError>) -> Void) {
		// get log data from the 'all logs' file
		let fileLogger = FileLogger()
		guard let item = LogDataItem(at: fileLogger.allLogsFileURL) else {
			Log.warning("No log data to export.", log: .localData)
			return
		}

		client.submit(logFile: item.compressedData as Data, uploadToken: uploadToken, isFake: false, completion: completion)
	}
}
