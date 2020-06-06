//
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
//

import XCTest
@testable import ENA

final class CachedAppConfigurationTests: XCTestCase {
	func testXX() {
		let client = ClientMock(submissionError: nil)

		let expectation = self.expectation(description: "onAppConfiguration called")
		expectation.expectedFulfillmentCount = 1
		expectation.assertForOverFulfill = true

		let expectedConfig = SAP_ApplicationConfiguration()
		client.onAppConfiguration = { completeWith in
			completeWith(expectedConfig)
			expectation.fulfill()
		}

		let sut = CachedAppConfiguration(client: client)

		sut.appConfiguration { config in
			XCTAssertEqual(config, expectedConfig)
		}

		// Should not trigger another call to the actual client
		sut.appConfiguration { config in
			XCTAssertEqual(config, expectedConfig)
		}

		waitForExpectations(timeout: 0.5)
	}
}
