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

final class AppleFilesWriter {
	// MARK: Creating a Writer
	
	init(rootDir: URL, keyPackages: [SAPDownloadedPackage]) {
		self.rootDir = rootDir
		self.keyPackages = keyPackages
	}
	
	// MARK: Properties
	
	let rootDir: URL
	let keyPackages: [SAPDownloadedPackage]
	
	// MARK: Interacting with the Writer
	
	typealias WithDiagnosisKeyURLsHandler = (
		_ diagnosisKeyURLs: [URL],
		_ done: @escaping DoneHandler
	) -> Void
	
	typealias DoneHandler = () -> Void
	
	func with(handler: WithDiagnosisKeyURLsHandler) {
		var writtenURLs = [URL]()
		
		func cleanup() {
			let fileManager = FileManager()
			for writtenURL in writtenURLs {
				try? fileManager.removeItem(at: writtenURL)
			}
			return
		}
		
		var needsCleanupInDone = true
		
		for keyPackage in keyPackages {
			let filename = UUID().uuidString
			
			do {
				writtenURLs.append(
					try keyPackage.writeKeysEntry(toDirectory: rootDir, filename: filename)
				)
				writtenURLs.append(
					try keyPackage.writeSignatureEntry(toDirectory: rootDir, filename: filename)
				)
			} catch {
				cleanup()
				writtenURLs = [] // we need to set this to an empty array
				needsCleanupInDone = false
			}
		}
		
		handler(writtenURLs) {
			// This is executed when the app is finished.
			// needsCleanupInDone will be true if the writer has cleaned up already due to errors.
			guard needsCleanupInDone else {
				return
			}
			cleanup()
		}
	}
}

private extension SAPDownloadedPackage {
	func writeSignatureEntry(toDirectory directory: URL, filename: String) throws -> URL {
		let url = directory.appendingPathComponent(filename).appendingPathExtension("sig")
		try signature.write(to: url)
		return url
	}
	
	func writeKeysEntry(toDirectory directory: URL, filename: String) throws -> URL {
		let url = directory.appendingPathComponent(filename).appendingPathExtension("bin")
		try bin.write(to: url)
		return url
	}
}
