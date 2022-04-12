import Foundation
import os.log

extension OSLog {

	private static var subsystem = Bundle.main.unwrappedBundleIdentifier

	/// Application lifecycle
	static let appLifecycle = OSLog(subsystem: subsystem, category: "appLifecycle")
    /// API interactions
    static let api = OSLog(subsystem: subsystem, category: "api")
    /// UI
    static let ui = OSLog(subsystem: subsystem, category: "ui")
    /// Local data & caches
    static let localData = OSLog(subsystem: subsystem, category: "localdata")
	///	Cryptography
	static let crypto = OSLog(subsystem: subsystem, category: "crypto")
	/// Risk Detection
	static let riskDetection = OSLog(subsystem: subsystem, category: "riskdetection")
	/// App Config
	static let appConfig = OSLog(subsystem: subsystem, category: "appconfig")
	/// Contact Diary
	static let contactdiary = OSLog(subsystem: subsystem, category: "contactdiary")
	/// Background - Stuff that happens in the Background.
	static let background = OSLog(subsystem: subsystem, category: "background")
	/// PPAC
	static let ppac = OSLog(subsystem: subsystem, category: "ppac")
	/// OTP
	static let otp = OSLog(subsystem: subsystem, category: "otp")
	/// Survey
	static let survey = OSLog(subsystem: subsystem, category: "survey")
	/// PP Analytics
	static let ppa = OSLog(subsystem: subsystem, category: "ppa")
	/// Error Log Submission
	static let els = OSLog(subsystem: subsystem, category: "els")
	/// Event / Location Checkin
	static let checkin = OSLog(subsystem: subsystem, category: "checkin")
	/// Event / Location Organizer
	static let traceLocation = OSLog(subsystem: subsystem, category: "traceLocation")
	/// QR Code
	static let qrCode = OSLog(subsystem: subsystem, category: "qrCode")
	/// Vaccination
	static let vaccination = OSLog(subsystem: subsystem, category: "vaccination")
	/// Local Statistics
	static let localStatistics = OSLog(subsystem: subsystem, category: "localStatistics")
	/// http client
	static let client = OSLog(subsystem: subsystem, category: "httpClient")
	/// Filescanner
	static let fileScanner = OSLog(subsystem: subsystem, category: "fileScanner")
	/// RecycleBin
	static let recycleBin = OSLog(subsystem: subsystem, category: "recyclebin")
	/// Onboarding
	static let onboarding = OSLog(subsystem: subsystem, category: "onboarding")
	/// Ticket Validation Decorator
	static let ticketValidationDecorator = OSLog(subsystem: subsystem, category: "ticketValidationDecorator")
	/// TicketValidation
	static let ticketValidation = OSLog(subsystem: subsystem, category: "ticketvalidation")
	/// TicketValidationAllowList
	static let ticketValidationAllowList = OSLog(subsystem: subsystem, category: "TicketValidationAllowList")
	/// DebugMenu
	static let debugMenu = OSLog(subsystem: subsystem, category: "DebugMenu")
}

/// Logging
///
/// Usage:
/// ```
/// Log.debug("foo")
/// Log.info("something broke", log: .api)
/// Log.warning("validation failed", log: .crypto)
/// Log.error("my hovercraft is full of eels", log: .ui)
///
/// ```
///
/// 🚨🚨🚨🚨 Usage for sensitive / private logging data (like e.g. the name of a person in the contact journal): 🚨🚨🚨🚨
/// These data are (see also TechSpec in future):
/// - PCR QR-Code (GUID, URL)
/// - PCR registration token
/// - Contact Journal Information
/// - Created Event Information
/// - Scanned Event Information
/// - Rapid Test profile information
/// - Rapid Test QR-Code (URL and JSON payload (encoded and decoded))
/// - Rapid test registration token
/// - Personal Information in Rapid test result
/// - TAN Code for submission
/// ```
/// Log.debug("some key \(private: "some sensitive values")")
/// Log.debug("some key \(private: "some sensitive values", public: "explanation what data is censored here")")
///
/// ```
enum Log {

	static let fileLogger = FileLogger()

	static func debug(_ message: String, log: OSLog = .default, file: String = #fileID, line: Int = #line, function: String = #function) {
        Self.log(message: message, type: .debug, log: log, error: nil, file: file, line: line, function: function)
    }

    static func info(_ message: String, log: OSLog = .default, file: String = #fileID, line: Int = #line, function: String = #function) {
        Self.log(message: message, type: .info, log: log, error: nil, file: file, line: line, function: function)
    }

    static func warning(_ message: String, log: OSLog = .default, file: String = #fileID, line: Int = #line, function: String = #function) {
        Self.log(message: message, type: .default, log: log, error: nil, file: file, line: line, function: function)
    }

    static func error(_ message: String, log: OSLog = .default, error: Error? = nil, file: String = #fileID, line: Int = #line, function: String = #function) {
        Self.log(message: message, type: .error, log: log, error: error, file: file, line: line, function: function)
    }

	private static func log(message: String, type: OSLogType, log: OSLog, error: Error?, file: String, line: Int, function: String) {
		// Console logging
		let meta: String = "[\(file):\(line)] [\(function)]"

		if let error = error {
			// obviously we have to disable swiftlint here:
			// swiftlint:disable:next no_direct_oslog
			os_log("%{public}@ %{public}@ %{public}@ %{public}@", log: log, type: type, meta, message, error as CVarArg, error.localizedDescription)
		} else {
			// obviously we have to disable swiftlint here:
			// swiftlint:disable:next no_direct_oslog
			os_log("%{public}@ %{public}@", log: log, type: type, meta, message)
		}
		
		// Save logs to File. This is used for viewing and exporting logs from debug menu.
		fileLogger.log(message, logType: type, file: file, line: line, function: function, error: error)
	}
}

extension OSLogType {

	var title: String {
		switch self {
		case .error:
			return "Error"
		case .debug:
			return "Debug"
		case .info:
			return "Info"
		case .default:
			return "Warning"
		default:
			return "Other"
		}
	}

	var icon: String {
		switch self {
		case .error:
			return "❌"
		case .debug:
			return "🛠"
		case .info:
			return "ℹ️"
		case .default:
			return "⚠️"
		default:
			return ""
		}
	}

	var logFilePath: String {
		return "\(self.title).txt"
	}
}

struct FileLogger {

	enum Error: Swift.Error {
		case streamerInitError
	}

	// MARK: - Internal

	/// The directory where all logs are stored
	let logFileBaseURL: URL = {
		let fileManager = FileManager.default
		return fileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0].appendingPathComponent("Logs")
	}()

	/// Path to a common log file for all log types combined
	let allLogsFileURL: URL = {
		let fileManager = FileManager.default
		let baseURL = fileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0].appendingPathComponent("Logs")
		#if DEBUG
		return baseURL.appendingPathComponent("AllLogTypes.txt")
		#else
		return baseURL.appendingPathComponent("AllLogTypes.log")
		#endif
	}()

	/// Path to a common log file for official submission
	let errorLogFileURL: URL = {
		let fileManager = FileManager.default
		let baseURL = fileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0].appendingPathComponent("Logs")
		// I don't want to mess with existing tester-/developer logs, so this has an extra file
		return baseURL.appendingPathComponent("application.log")
	}()

	init() {
		// Quick and dirty migration to new log location
		let fileManager = FileManager.default
		let oldURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("Logs")
		var isDir: ObjCBool = true
		if fileManager.fileExists(atPath: oldURL.path, isDirectory: &isDir) {
			// Don't `Log` anything here unless you handle file access for write + deletion properly!
			do {
				try fileManager.moveItem(atPath: oldURL.path, toPath: logFileBaseURL.path)
			} catch {
				// swiftlint:disable:next force_try
				try! fileManager.removeItem(at: oldURL) // Removal or bust! For GDPR!!!
			}
			assert(!fileManager.fileExists(atPath: oldURL.path, isDirectory: &isDir))
		}
		
		#if RELEASE
		// Delete legacy dev logs to free up disk space.
		deleteLegacyDevLogs()
		#endif
	}

	func log(_ logMessage: String, logType: OSLogType, file: String? = nil, line: Int? = nil, function: String? = nil, error: Swift.Error? = nil) {
		var meta: String = ""
		if let file = file, let line = line, let function = function {
			meta = "[\(file):\(line)] [\(function)]\n"
		}
		
		var errorLocalizedDescription: String = ""
		var errorMessage: String = ""
		if let error = error {
			errorLocalizedDescription = "\nErrorLocalizedDescription: \(error.localizedDescription)"
			errorMessage = "\nError: \(error)"
		}

		let prefixedLogMessage = "\(logType.title) \(logDateFormatter.string(from: Date()))\n\(meta)\(logMessage)\(errorLocalizedDescription)\(errorMessage)\n\n"

		writeLog(of: logType, message: prefixedLogMessage)
	}

	/// `StreamReader` for a given log type
	/// - Parameter logType: the log type to read
	/// - Throws: `FileLogger.Error.streamerInitError` if Reader initialization fails
	/// - Returns: a `StreamReader`
	func logReader(for logType: OSLogType) throws -> StreamReader {
		let fileURL = logFileBaseURL.appendingPathComponent(logType.logFilePath)
		try createLogFile(for: fileURL)
		guard let reader = StreamReader(at: fileURL) else {
			throw Error.streamerInitError
		}
		return reader
	}

	/// `StreamReader` for all log types combined
	/// - Throws: `FileLogger.Error.streamerInitError` if Reader initialization fails
	/// - Returns: a `StreamReader`
	func logReader() throws -> StreamReader {
		let url = allLogsFileURL
		try createLogFile(for: url)
		guard let reader = StreamReader(at: url) else {
			throw Error.streamerInitError
		}
		return reader
	}

	/// Removes ALL logs
	func deleteLogs() {
		do {
			try FileManager.default.removeItem(at: logFileBaseURL)
		} catch {
			Log.error("Can't remove logs at \(logFileBaseURL)", log: .localData, error: error)
		}
	}
	
	// MARK: - Private

	private let logDateFormatter = ISO8601DateFormatter()
	private let writeQueue = DispatchQueue(label: "de.rki.coronawarnapp.logging.write") // Serial by default
	
	private func writeLog(of logType: OSLogType, message: String) {
		#if !RELEASE
		let logHandle = makeWriteFileHandle(with: logType)
		let allLogsHandle = makeWriteFileHandle(with: allLogsFileURL)
		#endif
			
		let errorLogHandle = makeWriteFileHandle(with: errorLogFileURL)

		guard let logMessageData = message.data(using: .utf8) else { return }
		defer {
			#if !RELEASE
			logHandle?.closeFile()
			allLogsHandle?.closeFile()
			#endif

			errorLogHandle?.closeFile()
		}
		
		writeQueue.sync {
			
			#if !RELEASE
			logHandle?.seekToEndOfFile()
			logHandle?.write(logMessageData)

			allLogsHandle?.seekToEndOfFile()
			allLogsHandle?.write(logMessageData)
			#endif

			if ErrorLogSubmissionService.errorLoggingEnabled {
				errorLogHandle?.seekToEndOfFile()
				errorLogHandle?.write(logMessageData)
			}
		}
	}
	
	private func createLogFile(for url: URL) throws {
		let fileManager = FileManager.default
		if !fileManager.fileExists(atPath: url.path) {
			try fileManager.createDirectory(at: logFileBaseURL, withIntermediateDirectories: true)
			fileManager.createFile(atPath: url.path, contents: Data())
		}
	}

	private func makeWriteFileHandle(with logType: OSLogType) -> FileHandle? {
		#if DEBUG
		// logacy logs stay `txt` unless migrated
		let logFileURL = logFileBaseURL.appendingPathComponent("\(logType.title).txt")
		#else
		let logFileURL = logFileBaseURL.appendingPathComponent("\(logType.title).log")
		#endif
		return makeWriteFileHandle(with: logFileURL)
	}

	private func makeWriteFileHandle(with url: URL) -> FileHandle? {
		do {
			let fileManager = FileManager.default
			if !fileManager.fileExists(atPath: url.path) {
				try fileManager.createDirectory(at: logFileBaseURL, withIntermediateDirectories: true)
				fileManager.createFile(atPath: url.path, contents: nil)
			}

			let fileHandle = try? FileHandle(forWritingTo: url)
			return fileHandle
		} catch {
			// We must not use our Log here because it would produce a crash (we want to log in case we cannot create a log 🤪)
			// swiftlint:disable:next no_direct_oslog
			os_log("%{public}@", log: .default, type: .error, "Error while creating log file handler. Fallback to system logging to log this error.")
			return nil
		}
	}
	
	#if RELEASE
	private func deleteLegacyDevLogs() {
		do {
			let debugLogURLs = [
				allLogsFileURL,
				logFileBaseURL.appendingPathComponent("\(OSLogType.debug.title).log"),
				logFileBaseURL.appendingPathComponent("\(OSLogType.info.title).log"),
				logFileBaseURL.appendingPathComponent("\(OSLogType.error.title).log"),
				logFileBaseURL.appendingPathComponent("\(OSLogType.default.title).log")
			]
			
			for debugLogURL in debugLogURLs {
				if FileManager.default.fileExists(atPath: debugLogURL.path) {
					try FileManager.default.removeItem(at: debugLogURL)
				}
			}

		} catch {
			Log.error("Can't delete legacy dev logs", log: .localData, error: error)
		}
	}
	#endif
}

protocol Logging {
	func debug(_ message: String, log: OSLog, file: String, line: Int, function: String)
	func info(_ message: String, log: OSLog, file: String, line: Int, function: String)
	func warning(_ message: String, log: OSLog, file: String, line: Int, function: String)
	func error(_ message: String, log: OSLog, error: Error?, file: String, line: Int, function: String)
}

extension Log {
	static func debug(_ message: String, log: OSLog = .default, file: String = #fileID, line: Int = #line, function: String = #function, logger: Logging?) {
		#if DEBUG
		if let logger = logger {
			logger.debug(message, log: log, file: file, line: line, function: function)
		}
		#endif
		debug(message, log: log, file: file, line: line, function: function)
	}

	static func info(_ message: String, log: OSLog = .default, file: String = #fileID, line: Int = #line, function: String = #function, logger: Logging?) {
		#if DEBUG
		if let logger = logger {
			logger.info(message, log: log, file: file, line: line, function: function)
		}
		#endif
		info(message, log: log, file: file, line: line, function: function)
	}

	static func warning(_ message: String, log: OSLog = .default, file: String = #fileID, line: Int = #line, function: String = #function, logger: Logging?) {
		#if DEBUG
		if let logger = logger {
			logger.warning(message, log: log, file: file, line: line, function: function)
		}
		#endif
		warning(message, log: log, file: file, line: line, function: function)
	}

	static func error(_ message: String, log: OSLog = .default, error err: Error? = nil, file: String = #fileID, line: Int = #line, function: String = #function, logger: Logging?) {
		#if DEBUG
		if let logger = logger {
			logger.error(message, log: log, error: err, file: file, line: line, function: function)
		}
		#endif
		error(message, log: log, error: err, file: file, line: line, function: function)
	}
}
