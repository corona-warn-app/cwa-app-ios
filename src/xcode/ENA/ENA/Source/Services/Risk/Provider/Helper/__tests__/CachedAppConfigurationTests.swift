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
	func testCachedRequests() {
		let client = CachingClientMock()

		let expectation = self.expectation(description: "app configuration fetched")
		// we trigger a config fetch twice but expect only one http request (plus one cached result)
		expectation.expectedFulfillmentCount = 1
		expectation.assertForOverFulfill = true

		let expectedConfig = SAP_ApplicationConfiguration()
		client.onFetchAppConfiguration = { _, completeWith in
			completeWith(.success(expectedConfig))
			expectation.fulfill()
		}

		let cache = CachedAppConfiguration(client: client, store: MockTestStore())
		cache.appConfiguration { response in
			switch response {
			case .success(let config):
				XCTAssertEqual(config, expectedConfig)
			case .failure(let error):
				XCTFail(error.localizedDescription)
			}
		}

		// Should not trigger another call (expectation) to the actual client
		// Remember: `expectedFulfillmentCount = 1`
		cache.appConfiguration { response in
			switch response {
			case .success(let config):
				XCTAssertEqual(config, expectedConfig)
			case .failure(let error):
				XCTFail(error.localizedDescription)
			}
		}

		waitForExpectations(timeout: 0.5)
	}
}
