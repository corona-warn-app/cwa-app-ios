//
// 🦠 Corona-Warn-App
//

import XCTest
@testable import ENA

final class AppleFilesWriterTests: XCTestCase {

	private class func createRootDir() throws -> URL {
		let fm = FileManager()

		return try fm.createKeyPackageDirectory()
	}

	private var rootDir: URL!

	override func setUpWithError() throws {
		try super.setUpWithError()
		if rootDir != nil {
			try FileManager().removeItem(at: rootDir)
		}
		rootDir = try type(of: self).createRootDir()
	}

	func testWriterWithoutPackagesDoesNothing() throws {
		let writer = AppleFilesWriter(rootDir: rootDir)
		let writtenPackages = writer.writtenPackages
		XCTAssertNotNil(writtenPackages)
		XCTAssertTrue(writtenPackages.urls.isEmpty)
	}

	func testWriterWithPackagesWritesEverything() throws {
		let packages: [SAPDownloadedPackage] = [
			.init(
				keysBin: Data(bytes: [0x0] as [UInt8], count: 1),
				signature: Data(bytes: [0x1] as [UInt8], count: 1)
			)
		]
		let writer = AppleFilesWriter(rootDir: rootDir)

		for package in packages {
			let success = writer.writePackage(package)
			XCTAssertTrue(success)
		}

		XCTAssertEqual(writer.writtenPackages.urls.count, 2)
		let urls = writer.writtenPackages.urls

		let url0 = urls[0]
		let url1 = urls[1]
		let hasSig = url0.pathExtension == "sig" || url1.pathExtension == "sig"
		XCTAssertTrue(hasSig)
		let hasBin = url0.pathExtension == "bin" || url1.pathExtension == "bin"
		XCTAssertTrue(hasBin)

		let writtenFiles = try FileManager().contentsOfDirectory(
			at: rootDir,
			includingPropertiesForKeys: nil,
			options: .skipsHiddenFiles
		)

		XCTAssertEqual(writtenFiles.count, 2)

		writer.writtenPackages.cleanUp()
	
		XCTAssertFalse(FileManager().fileExists(atPath: rootDir.path))
	}
}
