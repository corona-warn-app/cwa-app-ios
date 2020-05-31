// Corona-Warn-App
//
// SAP SE and all other contributors
// copyright owners license this file to you under the Apache
// License, Version 2.0 (the "License"); you may not use this
// file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing,
// software distributed under the License is distributed on an
// "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
// KIND, either express or implied.  See the License for the
// specific language governing permissions and limitations
// under the License.

import Foundation
import SwiftyBeaver

let appLogger = Logger()

class Logger {
	
	private let sb = SwiftyBeaver.self
	
	private let fileDest = FileDestination()
	private let consoleDest = ConsoleDestination()

	private var logDirectory: URL? {
		return try? FileManager.default.url(for: .cachesDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
			.appendingPathComponent("logs", isDirectory: true)
	}
	
	private var logFileURL: URL? {
		guard let logDir = logDirectory else {
			return nil
		}
		
		return logDir.appendingPathComponent("log.txt", isDirectory: false)
	}
	
	init() {
		setup()
	}
	
	private func setup() {
		fileDest.logFileURL = logFileURL
	}
	
	func verbose(message: String, _ file: String = #file, _ line: Int = #line, _ function: String = #function) {
		log(level: .verbose, message: message, file: file, line: line, function: function)
	}
	
	func info(message: String, _ file: String = #file, _ line: Int = #line, _ function: String = #function) {
		log(level: .info, message: message, file: file, line: line, function: function)
	}
	
	func warning(message: String, _ file: String = #file, _ line: Int = #line, _ function: String = #function) {
		log(level: .warning, message: message, file: file, line: line, function: function)
	}
	
	func error(message: String, _ file: String = #file, _ line: Int = #line, _ function: String = #function) {
		log(level: .error, message: message, file: file, line: line, function: function)
	}
	
	private func log(level: SwiftyBeaver.Level, message: String, file: String, line: Int, function: String) {
		#if DEBUG
		_ = consoleDest.send(level, msg: message, thread: Thread.current.name ?? "NA", file: file, function: function, line: line)
		#endif
		
		_ = fileDest.send(level, msg: message, thread: Thread.current.name ?? "NA", file: file, function: function, line: line)
	}

	func getLoggedData() -> Data? {
		// If this is nil the FileDestination of SwiftyBeaver will have no logFile to write to.
		// Thus there is also no recorded log data.
		guard let logFile = logFileURL else {
			appLogger.error(message: "Logfile URL is nil")
			return nil
		}
		
		do {
			return try Data(contentsOf: logFile)
		} catch {
			appLogger.error(message: "Cannot read logfile: \(error)")
			return nil
		}
	}
}
