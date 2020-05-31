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

var appLogger = Logger()

struct Logger {
	
	enum Level: String {
		case verbose = "VERBOSE"
		case info = "INFO"
		case warning = "WARNING"
		case error = "ERROR"
	}
	
	private var fileLogger = FileLogger()
	
	mutating func verbose(message: String, _ file: String = #file, _ line: Int = #line, _ function: String = #function) {
		log(level: .verbose, message: message, file: file, line: line, function: function)
	}
	
	mutating func info(message: String, _ file: String = #file, _ line: Int = #line, _ function: String = #function) {
		log(level: .info, message: message, file: file, line: line, function: function)
	}
	
	mutating func warning(message: String, _ file: String = #file, _ line: Int = #line, _ function: String = #function) {
		log(level: .warning, message: message, file: file, line: line, function: function)
	}
	
	mutating func error(message: String, _ file: String = #file, _ line: Int = #line, _ function: String = #function) {
		log(level: .error, message: message, file: file, line: line, function: function)
	}
	
	private mutating func log(level: Level, message: String, file: String, line: Int, function: String) {
		let formattedString = formatLogString(level: level, message: message, file: file, line: line, function: function)
		
		#if !APP_STORE
		print(formattedString)
		#endif
		
		logToFile(formattedString: formattedString)
	}
	
	private func formatLogString(level: Level, message: String, file: String, line: Int, function: String) -> String {
		let levelIndicator: String
		
		switch level {
		case .verbose:
			levelIndicator = "💬"
		case .info:
			levelIndicator = "ℹ️"
		case .warning:
			levelIndicator = "⚠️"
		case .error:
			levelIndicator = "💥"
		}
		
		let fileName = URL(fileURLWithPath: file).lastPathComponent
		
		return "\(levelIndicator) \(level.rawValue) \(fileName):\(line)(\(function)): \(message)"
	}
	
	private mutating func logToFile(formattedString: String) {
		fileLogger.write(formattedString)
	}

	func getLoggedData() -> Data? {
		return fileLogger.getLoggedData()
	}
	
}
