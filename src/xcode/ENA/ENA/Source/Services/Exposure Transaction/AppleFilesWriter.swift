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

struct WrittenPackages {
	init(urls: [URL]) {
		self.urls = urls
	}

	var urls: [URL]
	func cleanUp() {
		let fileManager = FileManager()
		for url in urls {
			try? fileManager.removeItem(at: url)
		}
	}

	mutating func add(_ url: URL) {
		urls.append(url)
	}
}

final class AppleFilesWriter {

	// MARK: Creating a Writer

	init(rootDir: URL) {
		self.rootDir = rootDir
	}

	// MARK: Properties

	private(set) var writtenPackages = WrittenPackages(urls: [])
	let rootDir: URL

	// MARK: Interacting with the Writer

	func writePackage(_ keyPackage: SAPDownloadedPackage) -> Bool {
		do {
			let filename = UUID().uuidString
			let keyURL = try keyPackage.writeKeysEntry(toDirectory: rootDir, filename: filename)
			let signatureURL = try keyPackage.writeSignatureEntry(toDirectory: rootDir, filename: filename)
			writtenPackages.add(keyURL)
			writtenPackages.add(signatureURL)
			return true
		} catch {
			writtenPackages.cleanUp()
			return false
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
