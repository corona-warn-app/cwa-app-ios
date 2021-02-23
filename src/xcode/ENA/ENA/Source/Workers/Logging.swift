import Foundation
import os.log

extension OSLog {

	private static var subsystem = Bundle.main.unwrappedBundleIdentifier

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
}

/// Logging
///
/// Usage:
/// ```
/// Log.debug("foo")
/// Log.info("something broke", log: .api)
/// Log.warning("validation failed", log: .crypto)
/// Log.error("my hovercraft is full of eels", log: .ui)
/// ```
enum Log {

	#if !RELEASE

	private static let fileLogger = FileLogger()

	#endif

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
		#if !RELEASE
		// Console logging
		let meta: String = "[\(file):\(line)] [\(function)]"
		os_log("%{private}@ %{private}@", log: log, type: type, meta, message)

		// Save logs to File. This is used for viewing and exporting logs from debug menu.
		fileLogger.log(message, logType: type, file: file, line: line, function: function)
		#endif
	}
}

#if !RELEASE

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
}

struct FileLogger {

	// MARK: - Internal

	func log(_ logMessage: String, logType: OSLogType, file: String? = nil, line: Int? = nil, function: String? = nil) {
		var meta: String = ""
		if let file = file, let line = line, let function = function {
			meta = "[\(file):\(line)] [\(function)]\n"
		}
		let prefixedLogMessage = "\(logType.icon) \(logDateFormatter.string(from: Date()))\n\(meta)\(logMessage)\n\n"

		guard let fileHandle = makeWriteFileHandle(with: logType),
			  let logMessageData = prefixedLogMessage.data(using: encoding) else {
			return
		}
		defer {
			fileHandle.closeFile()
		}

		fileHandle.seekToEndOfFile()
		fileHandle.write(logMessageData)

		guard let allLogsFileHandle = makeWriteFileHandle(with: allLogsFileURL) else {
			return
		}
		allLogsFileHandle.seekToEndOfFile()
		allLogsFileHandle.write(logMessageData)
	}

	func read(logType: OSLogType) -> String {
		guard let fileHandle = makeReadFileHandle(with: logType),
			  let logString = String(data: fileHandle.readDataToEndOfFile(), encoding: encoding) else {
			return ""
		}
		return logString
	}

	func readAllLogs() -> String {
		guard let fileHandle = makeReadFileHandle(with: allLogsFileURL),
			  let logString = String(data: fileHandle.readDataToEndOfFile(), encoding: encoding) else {
			return ""
		}
		return logString
	}

	func deleteLogs() {
		do {
			try FileManager.default.removeItem(at: logFileBaseURL)
		} catch {
			Log.error("Can't remove logs at \(logFileBaseURL)", log: .localData, error: error)
		}
	}

	// MARK: - Private

	private let encoding: String.Encoding = .utf8
	private let logFileBaseURL: URL = {
		let fileManager = FileManager.default
		return fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("Logs")
	}()
	private let allLogsFileURL: URL = {
		let fileManager = FileManager.default
		let baseURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("Logs")
		return baseURL.appendingPathComponent("AllLogTypes.txt")
	}()
	private let logDateFormatter = ISO8601DateFormatter()

	private func makeWriteFileHandle(with logType: OSLogType) -> FileHandle? {
		let logFileURL = logFileBaseURL.appendingPathComponent("\(logType.title).txt")
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
			Log.error("File handle error", log: .localData, error: error)
			return nil
		}
	}

	private func makeReadFileHandle(with logType: OSLogType) -> FileHandle? {
		let logFileURL = logFileBaseURL.appendingPathComponent("\(logType.title).txt")
		return makeReadFileHandle(with: logFileURL)
	}

	private func makeReadFileHandle(with url: URL) -> FileHandle? {
		do {
			return try FileHandle(forReadingFrom: url)
		} catch {
			Log.error("File handle error", log: .localData, error: error)
			return nil
		}
	}
}

#endif
