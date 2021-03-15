////
// 🦠 Corona-Warn-App
//

import Foundation
import OpenCombine

protocol ErrorLogSubmitting {

	typealias ELSAuthenticationResponse = (Result<ELSToken, OTPError>) -> Void
	typealias ELSSubmissionResponse = (Result<LogUploadResponse, PPASError>) -> Void // TODO: PPAC or PPAS?
	typealias ELSToken = TimestampedToken

	/// Publisher returning the size in bytes for a given file
	var logFileSizePublisher: OpenCombine.AnyPublisher<Int64, LogError> { get }

	func authenticate(completion: @escaping ELSAuthenticationResponse)
	func submit(log: Data, completion: @escaping ELSSubmissionResponse)
}

protocol ErrorLogHandling {
	// Enable logging

	// disable logging

	// delete existing log
}

struct LogUploadResponse: Decodable {
	let id: String
	let hash: String
}


/// Handler for the log file uploading process
final class ErrorLogSubmissionService: ErrorLogSubmitting {

	private let client: Client
	private var store: ErrorLogProviding
	private lazy var fileLogger = FileLogger()
	private lazy var fileManager = FileManager.default

	/// Publisher to handle changes in the size of the log file
	///
	/// - Note: The current implementation does NOT constantly observe file size changes!
	private(set) lazy var logFileSizePublisher: AnyPublisher<Int64, LogError> = setupFileSizePublisher()

	init(client: Client, store: ErrorLogProviding) {
		self.client = client
		self.store = store
	}

	// MARK: - ErrorLogSubmitting

	func authenticate(completion: @escaping ELSAuthenticationResponse) {
		if let token = store.elsApiToken, token.timestamp > Date() {
			completion(.success(token))
		} else {
			let token = UUID().uuidString
			PPACDeviceCheck().deviceToken(token) { result in
				switch result {
				case .success(let deviceToken):
					self.client.authorizeELS(elsToken: token, ppacToken: deviceToken, isFake: false, forceApiTokenHeader: false) { result in
						switch result {
						case .success(let validUntil):
							let elsToken = TimestampedToken(token: token, timestamp: validUntil)
							self.store.elsApiToken = elsToken
							completion(.success(elsToken))
						case .failure(let error):
							completion(.failure(error))
						}
					}
				case .failure(let error):
					completion(.failure(OTPError.generalError))
				}
			}
		}
	}

	func submit(log: Data, completion: @escaping (Result<LogUploadResponse, PPASError>) -> Void) {
		// get log data from the 'all logs' file
		guard let item = LogDataItem(at: fileLogger.allLogsFileURL) else {
			Log.warning("No log data to export.", log: .els)
			completion(.failure(PPASError.generalError))
			return
		}

		#warning("TODO!!!!!")
//		// if needed, generate els token on the fly
//		let token = store.elsApiToken ?? {
//			let token = UUID().uuidString
//			Log.info("Creating new ELS upload token", log: .els)
//			store.elsUploadToken = token
//			return token
//		}()
//		client.submit(logFile: item.compressedData as Data, uploadToken: token, isFake: false, completion: completion)
	}

	// MARK: - Helpers

	private func setupFileSizePublisher() -> AnyPublisher<Int64, LogError> {
		// TO DO: evaluate switch to constant observation https://developer.apple.com/documentation/foundation/nsfilepresenter
		return Timer
			.publish(every: 1.0, on: .main, in: .default)
			.autoconnect()
			.tryMap { _ in
				guard let size = self.fileManager.sizeOfFile(atPath: self.fileLogger.allLogsFileURL.path) else {
					throw LogError.couldNotReadLogfile()
				}
				return size
			}
			.mapError({ error -> LogError in
				return error as? LogError ?? LogError.couldNotReadLogfile(error.localizedDescription)
			})
			.eraseToAnyPublisher()
	}
}
