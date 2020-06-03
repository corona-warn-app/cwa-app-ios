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
	init(rootDir: URL, keyPackages: [SAPDownloadedPackage]) {
		self.rootDir = rootDir
		self.keyPackages = keyPackages
	}

	// MARK: Properties
	let rootDir: URL
	let keyPackages: [SAPDownloadedPackage]

	// MARK: Interacting with the Writer
	func writeAllPackages() -> WrittenPackages? {
		var writtenPackages = WrittenPackages(urls: [])
		do {
			for keyPackage in keyPackages {
				let filename = UUID().uuidString
				writtenPackages.add(try keyPackage.writeKeysEntry(toDirectory: rootDir, filename: filename))
				writtenPackages.add(try keyPackage.writeSignatureEntry(toDirectory: rootDir, filename: filename))
			}
		} catch {
			writtenPackages.cleanUp()
			return nil
		}
		return writtenPackages
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
