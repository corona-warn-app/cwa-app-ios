////
// 🦠 Corona-Warn-App
//

import XCTest
@testable import ENA

class StreamReaderTests: CWATestCase {

    override func setUpWithError() throws {
        continueAfterFailure = false
    }

	func testSimpleRead() throws {
		let fileURL = try testFile(ofLength: 10)

		let reader = try XCTUnwrap(StreamReader(at: fileURL))
		XCTAssertNotNil(reader.nextLine())
		XCTAssertNil(reader.nextLine())

		reader.rewind()

		XCTAssertNotNil(reader.nextLine())
	}

	func testStreamReaderInitFail() throws {
		let fileURL = FileManager.default.temporaryDirectory.appendingPathComponent("Rechnung.exe")
		XCTAssertFalse(FileManager.default.fileExists(atPath: fileURL.path))

		XCTAssertNil(StreamReader(at: fileURL))
	}

	private func testFile(ofLength length: Int) throws -> URL {

		let entry = "dummy\n"
		let data = try XCTUnwrap(
			[String](repeating: entry, count: length / entry.lengthOfBytes(using: .utf8))
				.joined()
				.data(using: .utf8)
		)
		let fileURL = FileManager.default.temporaryDirectory.appendingPathComponent("dummy-\(Int.random(in: 0...Int.max)).log")

		try data.write(to: fileURL, options: [.atomicWrite])
		return fileURL
	}
}
