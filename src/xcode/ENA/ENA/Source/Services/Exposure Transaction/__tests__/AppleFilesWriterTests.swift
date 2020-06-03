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

import XCTest
@testable import ENA

final class AppleFilesWriterTests: XCTestCase {

	private class func createRootDir() throws -> URL {
		let fm = FileManager()
		let tempDir = fm.temporaryDirectory.appendingPathComponent(UUID().uuidString, isDirectory: true)

		try fm.createDirectory(
			atPath: tempDir.path,
			withIntermediateDirectories: true,
			attributes: nil
		)
		return tempDir
	}

	private var rootDir: URL!

	override func setUpWithError() throws {
		try super.setUpWithError()
		if rootDir != nil {
			try FileManager().removeItem(at: rootDir)
		}
		rootDir = try type(of: self).createRootDir()
	}

	override func tearDownWithError() throws {
		try FileManager().removeItem(at: rootDir)
	}

	func testWriterWithoutPackagesDoesNothing() throws {
		let writer = AppleFilesWriter(rootDir: rootDir, keyPackages: [])
		let writtenPackages = writer.writeAllPackages()
		XCTAssertNotNil(writtenPackages)
		XCTAssertTrue(writtenPackages?.urls.isEmpty == true)
	}

	func testWriterWithPackagesWritesEverything() throws {
		let packages: [SAPDownloadedPackage] = [
			.init(
				keysBin: Data(bytes: [0x0], count: 1),
				signature: Data(bytes: [0x1], count: 1)
			)
		]
		let writer = AppleFilesWriter(rootDir: rootDir, keyPackages: packages)
		let writtenPackages = writer.writeAllPackages()
		XCTAssertNotNil(writtenPackages)
		XCTAssertEqual(writtenPackages?.urls.count, 2)
		let urls = writtenPackages?.urls ?? []

		let url0 = urls[0]
		let url1 = urls[1]
		let hasSig = url0.pathExtension == "sig" || url1.pathExtension == "sig"
		XCTAssertTrue(hasSig)
		let hasBin = url0.pathExtension == "bin" || url1.pathExtension == "bin"
		XCTAssertTrue(hasBin)

		let writtenFiles = try? FileManager().contentsOfDirectory(
			at: rootDir,
			includingPropertiesForKeys: nil,
			options: .skipsHiddenFiles
		)

		XCTAssertEqual(writtenFiles?.count, 2)

		writtenPackages?.cleanUp()
		
		let contentsOfRootDir = try? FileManager().contentsOfDirectory(
			at: rootDir,
			includingPropertiesForKeys: nil,
			options: .skipsHiddenFiles
		)

		XCTAssertTrue(contentsOfRootDir?.isEmpty == true)
	}
}
