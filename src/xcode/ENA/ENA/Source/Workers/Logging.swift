import Foundation
import os.log

extension OSLog {

	private static var subsystem = Bundle.main.unwrappedBundleIdentifier

    /// Logs the view cycles like viewDidLoad.
    static let viewCycle = OSLog(subsystem: subsystem, category: "viewcycle")

    /// API interactions
    static let api = OSLog(subsystem: subsystem, category: "api")
    /// Exoplanet UI
    static let ui = OSLog(subsystem: subsystem, category: "ui")
    /// Local data & caches
    static let localData = OSLog(subsystem: subsystem, category: "localdata")
}

enum Log {

    static func debug(_ message: String, log: OSLog = .default) {
        Self.log(message: message, type: .debug, log: log, error: nil)
    }

    static func info(_ message: String, log: OSLog = .default) {
        Self.log(message: message, type: .info, log: log, error: nil)
    }

    static func warning(_ message: String, log: OSLog = .default) {
        Self.log(message: message, type: .default, log: log, error: nil)
    }

    static func error(_ message: String, log: OSLog = .default, error: Error? = nil) {
        Self.log(message: message, type: .error, log: log, error: error)

		#if !RELEASE
		let errorMessages = UserDefaults.standard.dmErrorMessages
		UserDefaults.standard.dmErrorMessages = ["\(Date().description(with: .init(identifier: "en_US_POSIX"))) \(message)"] + errorMessages
		#endif
    }

	private static func log(message: String, type: OSLogType, log: OSLog, error: Error?) {
		os_log("%{private}@", log: log, type: type, message)

		// Crashlytics
		// ...

		// Sentry
		// ...
	}
}

// Usage:
// Log.debug("foo")
// Log.info("something broke", log: .api)
// Log.error("my hovercraft is full of eels", log: .ui)
