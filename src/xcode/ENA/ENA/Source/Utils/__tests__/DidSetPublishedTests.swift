////
// 🦠 Corona-Warn-App
//

import XCTest
@testable import ENA

class DidSetPublishedTests: XCTestCase {

    func testExample() throws {
		let publishingStruct = PublishingStruct()

		let expectedValues = [false, false, true, true, false]

		let expectation = expectation(description: "Received value")
		expectation.expectedFulfillmentCount = expectedValues.count

		var receivedValues = [Bool]()
		let subscription = publishingStruct.$publishingBool
			.sink {
				// Check that the value is already set on the publishing struct and we receive it afterwards
				XCTAssertEqual($0, publishingStruct.publishingBool)
				receivedValues.append($0)

				expectation.fulfill()
			}

		publishingStruct.publishingBool = false
		publishingStruct.publishingBool = true
		publishingStruct.publishingBool = true
		publishingStruct.publishingBool = false

		waitForExpectations(timeout: .short)

		XCTAssertEqual(receivedValues, expectedValues)

		subscription.cancel()
    }

	// MARK: - Private

	private struct PublishingStruct {

		@DidSetPublished var publishingBool: Bool = false

	}

}
