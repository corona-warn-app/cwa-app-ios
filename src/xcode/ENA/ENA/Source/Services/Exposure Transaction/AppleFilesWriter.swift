//
// 🦠 Corona-Warn-App
//

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
