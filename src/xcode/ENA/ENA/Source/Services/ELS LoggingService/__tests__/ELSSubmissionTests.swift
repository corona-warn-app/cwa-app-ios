////
// 🦠 Corona-Warn-App
//

import XCTest
@testable import ENA

class ELSSubmissionTests: XCTestCase {

    func testDummyLogUpload() throws {
		let store = MockTestStore()
		let client = HTTPClient(serverEnvironmentProvider: store)

		let onUpload = expectation(description: "Data uploaded")

		let logFile = try XCTUnwrap("Dummy log".data(using: .utf8))
		client.submit(logFile: logFile, uploadToken: UUID().uuidString, isFake: false) { result in
			switch result {
			case .failure(let error):
				XCTFail(error.localizedDescription)
			case .success(let response):
				debugPrint(response.id)
				debugPrint(response.hash)
			}
			onUpload.fulfill()
		}

		waitForExpectations(timeout: .medium)
    }
}
