////
// 🦠 Corona-Warn-App
//

import Foundation
import OpenCombine

protocol ErrorLogSubmitting {

	typealias ELSAuthenticationResponse = (Result<String, ELSError>) -> Void
	typealias ELSSubmissionResponse = (Result<LogUploadResponse, ELSError>) -> Void
	typealias ELSToken = TimestampedToken

	/// Publisher returning the size in bytes for a given file
	var logFileSizePublisher: OpenCombine.AnyPublisher<Int64, ELSError> { get }

	func submit(log: Data, completion: @escaping ELSSubmissionResponse)
}

protocol ErrorLogHandling {
	// Enable logging

	// disable logging

	// delete existing log
}

struct LogUploadResponse: Codable {
	let id: String
	let hash: String
}

/// Handler for the log file uploading process
final class ErrorLogSubmissionService: ErrorLogSubmitting {
	
	// MARK: - Init
	
	init(
		client: Client,
		store: ErrorLogProviding,
		ppacService: PrivacyPreservingAccessControl,
		otpService: OTPServiceProviding
	) {
		self.client = client
		self.store = store
		self.ppacService = ppacService
		self.otpService = otpService
	}
	
	// MARK: - Overrides
	
	// MARK: - Protocol ErrorLogSubmitting
	
	/// Publisher to handle changes in the size of the log file
	///
	/// - Note: The current implementation does NOT constantly observe file size changes!
	private(set) lazy var logFileSizePublisher: AnyPublisher<Int64, ELSError> = setupFileSizePublisher()
	
	func submit(log: Data, completion: @escaping (Result<LogUploadResponse, ELSError>) -> Void) {
		
		// get log data from the 'all logs' file
		guard let errorLogFiledata = LogDataItem(at: fileLogger.allLogsFileURL)?.compressedData else {
			Log.warning("No log data to export.", log: .els)
			completion(.failure(.emptyLogFile))
			return
		}
		Log.debug("Succesfully got a zipped error log file. Proceed with authentication for els.")

		authenticate(completion: { [weak self] result in
			switch result {
			case let .success(otpEls):
				Log.debug("Successfully authenticated ppac and otp for els. Proceed with uploading error log file.")
				self?.client.submit(errorLogFile: errorLogFiledata as Data, otpEls: otpEls, completion: { result in
					switch result {
					case let .success(errorFileLogResponse):
						Log.debug("Successfully uploaded error file log to server.")
						completion(.success(errorFileLogResponse))
					case let .failure(error):
						Log.error("Uploading error file log failed.", log: .els, error: error)
						completion(.failure(error))
					}
				})
			case let .failure(error):
				Log.error("Authentication for els otp failed. Abord upload process.", log: .els, error: error)
				completion(.failure(error))
			}
		})
	}
	
	// MARK: - Public
	
	// MARK: - Internal
	
	// MARK: - Private

	private let client: Client
	private let store: ErrorLogProviding
	private let ppacService: PrivacyPreservingAccessControl
	private let otpService: OTPServiceProviding
	
	private lazy var fileLogger = FileLogger()
	private lazy var fileManager = FileManager.default
	
	private func authenticate(completion: @escaping ELSAuthenticationResponse) {
		// first get ppac token for els (without devide time check)
		ppacService.getPPACTokenELS({ [weak self] result in
			switch result {
			case let .success(ppacToken):
				Log.debug("Successfully retrieved for els a ppac token. Proceed for otp.")
				// then get otp token for els (without restrictions for api token)
				self?.otpService.getOTPEls(ppacToken: ppacToken, completion: { result in
					switch result {
					case let .success(otpEls):
						Log.debug("Successfully retrieved for els an otp.")
						// now we can submit our log with valid otp.
						completion(.success(otpEls))
					case let .failure(otpError):
						Log.error("Could not obtain otp for els.", log: .els, error: otpError)
						completion(.failure(.otpError(otpError)))
					}
				})
			case let .failure(ppacError):
				Log.error("Could not obtain ppac token for els.", log: .els, error: ppacError)
				completion(.failure(.ppacError(ppacError)))
			}
		})
	}

	private func setupFileSizePublisher() -> AnyPublisher<Int64, ELSError> {
		// TODO: evaluate switch to constant observation https://developer.apple.com/documentation/foundation/nsfilepresenter
		return Timer
			.publish(every: 1.0, on: .main, in: .default)
			.autoconnect()
			.tryMap { _ in
				guard let size = self.fileManager.sizeOfFile(atPath: self.fileLogger.allLogsFileURL.path) else {
					throw ELSError.couldNotReadLogfile()
				}
				return size
			}
			.mapError({ error -> ELSError in
				return error as? ELSError ?? ELSError.couldNotReadLogfile(error.localizedDescription)
			})
			.eraseToAnyPublisher()
	}
}
