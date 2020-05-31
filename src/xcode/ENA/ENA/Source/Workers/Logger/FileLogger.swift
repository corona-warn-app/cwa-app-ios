//
// Corona-Warn-App
//
// SAP SE and all other contributors /
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
//

import Foundation

// This struct handles the writing of log data to the log file
// Please keep in mind that using the appLogger within the writing functions is unsafe
// because in an error case this can lead to the same error happening again within the new logging
// statement which results in an endless loop.
struct FileLogger: TextOutputStream {
	
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
	
	// Manages the writing to the log file
	mutating func write(_ string: String) {
		guard let logDirURL = logDirectory else {
			print("Log directory URL is nil.")
			return
		}
		
		guard let logFileURL = logFileURL else {
			print("Log file URL is nil.")
			return
		}
		
		guard let stringData = "\(string)\n".data(using: .utf8) else {
			print("Cannot get data from logged string")
			return
		}
		
		guard FileManager.default.fileExists(atPath: logFileURL.path) else {
			// Log file does not exist (yet), create it and write the given string into it
			do {
				// Create the log directory, this won't do anything in case the directory is already present
				try FileManager.default.createDirectory(at: logDirURL, withIntermediateDirectories: true, attributes: nil)
				try stringData.write(to: logFileURL)
			} catch {
				print("Error while creating log file: \(error)")
			}
			
			return
		}
		
		// At this point the log file already exists, now we need to write the given string into it
		// To be safe here, these writing operations are coordinated by a NSFileCoordinator
		
		var error: NSError?
		
		let coordinator = NSFileCoordinator()
		
		coordinator.coordinate(writingItemAt: logFileURL, error: &error) { url in
			do {
				let fileHandle = try FileHandle(forWritingTo: url)
				fileHandle.seekToEndOfFile()
				fileHandle.write(stringData)
				fileHandle.synchronizeFile()
				fileHandle.closeFile()
			} catch {
				// If this fails, the next write operation will probably fail as well.
				// At least a dev can see this error message then in the console
				print("Cannot log to file with url \(logFileURL)")
				return
			}
		}
		
		if let error = error {
			print("Error while coordinating log file write operations: \(error)")
		}
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
