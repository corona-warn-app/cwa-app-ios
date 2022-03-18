//
// 🦠 Corona-Warn-App
//

import Foundation

struct PackageContainer {

	enum PackageType {
		case keys
		case signature
	}

	let hash: String
	let type: PackageType
	let url: URL
}

struct WrittenPackages {

	// MARK: - Init

	init() {
		self.packages = []
	}

	// MARK: - Internal

	func cleanUp() {
		guard let directoryURL = urls.first?.deletingLastPathComponent() else {
			return
		}

		let fileManager = FileManager()
		Log.info("Removing: \(directoryURL)", log: .localData)

		do {
			// Remove the whole directory, instead of removing each file and than forget to remove the directory
			try fileManager.removeItem(at: directoryURL)
		} catch {
			Log.error("Can't remove item at \(directoryURL)", log: .localData, error: error)
		}
	}

	mutating func add(_ container: PackageContainer) {
		packages.append(container)
	}

	var urls: [URL] {
		packages.map { $0.url }
	}

	// MARK: - Internal

	private var packages: [PackageContainer]

}

final class AppleFilesWriter {

	// MARK: - Init

	init(
		rootDir: URL
	) {
		self.rootDir = rootDir
	}

	// MARK: - Internal

	private(set) var writtenPackages = WrittenPackages()

	func writePackage(_ keyPackage: SAPDownloadedPackage) -> Bool {
		do {
			let filename = UUID().uuidString
			let keyURL = try keyPackage.writeKeysEntry(toDirectory: rootDir, filename: filename)
			let signatureURL = try keyPackage.writeSignatureEntry(toDirectory: rootDir, filename: filename)
			writtenPackages.add(PackageContainer(hash: keyPackage.fingerprint, type: .keys, url: keyURL))
			writtenPackages.add(PackageContainer(hash: keyPackage.fingerprint, type: .signature, url: signatureURL))
			return true
		} catch {
			writtenPackages.cleanUp()
			return false
		}
	}

	// MARK: - Private

	private let rootDir: URL

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
