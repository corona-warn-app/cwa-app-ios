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

let appLogger = Logger()

func log(message: String, level _: LogLevel = .info, file _: String = #file, line _: UInt = #line, function _: String = #function) {
	NSLog("%@", message)
}

func logError(message: String, level _: LogLevel = .error, file _: String = #file, line _: UInt = #line, function _: String = #function) {
	NSLog("%@", message)
}

class Logger {
	func log(message _: String, level _: LogLevel = .info, file _: String, line _: UInt, function _: String) {}

	func getLoggedData() -> Data? {
		Data()
	}
}

enum LogLevel {
	case info
	case warning
	case error
}
