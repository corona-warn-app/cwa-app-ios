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

struct LogUploadResponse: Decodable {
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
		
	
		authenticate(completion: { [weak self] otpEls in
			
			
			
		})
		
		// get log data from the 'all logs' file
//		guard let item = LogDataItem(at: fileLogger.allLogsFileURL) else {
//			Log.warning("No log data to export.", log: .els)
//			completion(.failure(PPASError.generalError))
//			return
//		}
//
//		#warning("TODO!!!!!")
//		// if needed, generate els token on the fly
//		let token = store.elsApiToken ?? {
//			let token = UUID().uuidString
//			Log.info("Creating new ELS upload token", log: .els)
//			store.elsUploadToken = token
//			return token
//		}()
//		client.submitErrorLog(logFile: item.compressedData as Data, uploadToken: token, isFake: false, completion: completion)
		
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
				// then get otp token for els (without restrictions for api token)
				self?.otpService.getOTPEls(ppacToken: ppacToken, completion: { result in
					switch result {
					case let .success(otpEls):
						// now we can submit our log with valid otp.
						completion(.success(otpEls))
					case let .failure(otpError):
						completion(.failure(.otpError(otpError)))
					}
				})
			case let .failure(ppacError):
				completion(.failure(.ppacError(ppacError)))
			}
		})
	}

	private func setupFileSizePublisher() -> AnyPublisher<Int64, ELSError> {
		// TO DO: evaluate switch to constant observation https://developer.apple.com/documentation/foundation/nsfilepresenter
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
