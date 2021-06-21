////
// 🦠 Corona-Warn-App
//

import Foundation
import OpenCombine

protocol ErrorLogSubmissionProviding: ErrorLogSubmitting, ErrorLogHandling {}

protocol ErrorLogSubmitting {

	typealias ELSAuthenticationResponse = (Result<String, ELSError>) -> Void
	typealias ELSSubmissionResponse = (Result<LogUploadResponse, ELSError>) -> Void
	typealias ELSToken = TimestampedToken

	/// Publisher returning the size in bytes for a given file
	var logFileSizePublisher: OpenCombine.AnyPublisher<Int64, ELSError> { get }

	func submit(completion: @escaping ELSSubmissionResponse)
}

protocol ErrorLogHandling {

	/// Enable logging
	func startLogging()

	/// Fetch logs to share with friends and family
	func fetchExistingLog() -> LogDataItem?

	/// 🔥 logs
	func stopAndDeleteLog() throws
}

struct LogUploadResponse: Codable {
	let id: String
	let hash: String
}

struct ErrorLogUploadReceipt: Codable {
	/// Assigned ID of the uploaded log
	let id: String

	/// Upload timestamp
	let timestamp: Date
}

/// Handler for the log file uploading process
final class ErrorLogSubmissionService: ErrorLogSubmissionProviding {
	
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
	
	// MARK: - Protocol ErrorLogSubmitting
	
	/// Publisher to handle changes in the size of the log file
	///
	/// - Note: The current implementation does NOT constantly observe file size changes!
	private(set) lazy var logFileSizePublisher: AnyPublisher<Int64, ELSError> = setupFileSizePublisher()
	
	func submit(completion: @escaping (Result<LogUploadResponse, ELSError>) -> Void) {
		
		// get log data from the 'all logs' file
		guard
			let data = try? Data(contentsOf: fileLogger.errorLogFileURL),
			data.isEmpty == false, // prevents some hassle with empty files
			let errorLogFiledata = LogDataItem(at: fileLogger.errorLogFileURL)?.compressedData
		else {
			Log.warning("No log data to export.", log: .els)
			completion(.failure(.emptyLogFile))
			return
		}
		Log.debug("Succesfully got a zipped error log file. Proceed with authentication for els.")

		authenticate(completion: { [weak self] result in
			switch result {
			case let .success(otpEls):
				Log.debug("Successfully authenticated ppac and OTP: \(private: otpEls, public: "--OTP Value--") for els. Proceed with uploading error log file.")
				self?.client.submit(errorLogFile: errorLogFiledata as Data, otpEls: otpEls, completion: { result in
					switch result {
					case let .success(errorFileLogResponse):
						Log.debug("Successfully uploaded error file log to server.")
						self?.store.otpElsAuthorizationDate = Date()
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
		// evaluate switch to constant observation https://developer.apple.com/documentation/foundation/nsfilepresenter
		return Timer
			.publish(every: 1.0, on: .main, in: .default) // no need to have a high refresh rate, as file sizes normally don't grow that fast
			.autoconnect()
			.tryMap { _ in
				guard let size = self.fileManager.sizeOfFile(atPath: self.fileLogger.errorLogFileURL.path) else {
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

extension ErrorLogSubmissionService: ErrorLogHandling {

	private static let errorLogEnabledKey = "elsLogActive"

	/// Flag to indicate wether the ELS logging is active or not.
	///
	/// The initial value is fetched from `UserDefaults`.
	private(set) static var errorLoggingEnabled: Bool = {
		// fetch existing case from previous runs, e.g. after the app was terminated
		return UserDefaults.standard.bool(forKey: ErrorLogSubmissionService.errorLogEnabledKey)
	}()

	func startLogging() {
		UserDefaults.standard.setValue(true, forKey: ErrorLogSubmissionService.errorLogEnabledKey)
		ErrorLogSubmissionService.errorLoggingEnabled = true
		Log.info("===== ELS logging active =====", log: .localData)
		
		#if RELEASE
		Log.info("Release Build.")
		#elseif AdHoc
		Log.info("AdHoc Build.")
		#elseif TestFlight
		Log.info("Testflight Build.")
		#elseif Community
		Log.info("Community Build.")
		#elseif DEBUG
		Log.info("Debug Build.")
		#endif
			
		Log.info("Environment: \(Environments().currentEnvironment().name)")

		let clientData = ClientMetadata(etag: nil)
		Log.info("CWA version number: \(String(describing: clientData.cwaVersion))")
		Log.info("iOS version number: \(String(describing: clientData.iosVersion))")
	}

	func fetchExistingLog() -> LogDataItem? {
		// usage see: `DMLogsViewController.exportErrorLog()`
		return Log.fetchELSLogs()
	}

	func stopAndDeleteLog() throws {
		UserDefaults.standard.setValue(false, forKey: ErrorLogSubmissionService.errorLogEnabledKey)
		Log.info("===== ELS logging finished =====", log: .localData)
		ErrorLogSubmissionService.errorLoggingEnabled = false
		try Log.deleteELSLogs()
	}
}

// MARK: - Logging + ELS handling

// Convenience functions we only need for ELS
private extension Log {

	/// Deletes the ELS logs - if present
	///
	/// Debug logs (the 'old' logs) are not affected
	static func deleteELSLogs() throws {
		if FileManager.default.fileIsEmpty(atPath: fileLogger.errorLogFileURL.path) {
			Log.info("No ELS log to delete", log: .els)
			throw ELSError.emptyLogFile
		} else {
			try FileManager.default.removeItem(atPath: fileLogger.errorLogFileURL.path)
			Log.info("Deleted ELS logs", log: .els)
		}
	}

	static func fetchELSLogs() -> LogDataItem? {
		guard !FileManager.default.fileIsEmpty(atPath: fileLogger.errorLogFileURL.path) else {
			Log.warning("No log data to export.", log: .localData)
			return nil
		}
		return LogDataItem(at: fileLogger.errorLogFileURL)
	}
}

extension FileManager {

	/// Covers cases of empty files (0 byte) being present
	/// - Parameter path: The file path to check
	/// - Returns: Returns `true` is the file is empty or in case of an invalid path given
	func fileIsEmpty(atPath path: String) -> Bool {
		let data = Data(contents(atPath: path) ?? Data())
		return data.isEmpty
	}
}
