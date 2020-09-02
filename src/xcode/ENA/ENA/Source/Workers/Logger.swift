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

func log(
	message: String,
	level: LogLevel = .info,
	file: String = #file,
	line: UInt = #line,
	function: String = #function
) {
	#if !RELEASE
	print("\(level.rawValue.uppercased()): [\((file as NSString).lastPathComponent):\(line) - \(function)]\n \(message)")
	#endif
}

func logError(
	message: String,
	level: LogLevel = .error,
	file: String = #file,
	line: UInt = #line,
	function: String = #function
) {
	#if !RELEASE
	log(
		message: message,
		level: .error,
		file: file,
		line: line,
		function: function
	)
	let errorMessages = UserDefaults.standard.dmErrorMessages
	UserDefaults.standard.dmErrorMessages = ["\(Date().description(with: .init(identifier: "en_US_POSIX"))) \(message)"] + errorMessages
	#endif
}

enum LogLevel: String {
	case info
	case warning
	case error
}
