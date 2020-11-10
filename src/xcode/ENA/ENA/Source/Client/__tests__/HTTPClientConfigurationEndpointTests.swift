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

@testable import ENA
import XCTest

final class HTTPClientConfigurationEndpointTests: XCTestCase {
	private typealias Endpoint = HTTPClient.Configuration.Endpoint

	func testEndpointThatRequiresTrailingSlash() {
		let baseURL = URL(staticString: "http://localhost:8080")
		let endpoint = Endpoint(baseURL: baseURL, requiresTrailingSlash: true)

		XCTAssertEqual(
			endpoint.appending("hello"),
			URL(staticString: "http://localhost:8080/hello/")
		)

		XCTAssertEqual(
			endpoint.appending("hello", "world"),
			URL(staticString: "http://localhost:8080/hello/world/")
		)
	}

	func testEndpointThatRequiresNoTrailingSlash() {
		let baseURL = URL(staticString: "http://localhost:8080")
		let endpoint = Endpoint(baseURL: baseURL, requiresTrailingSlash: false)

		XCTAssertEqual(
			endpoint.appending("hello"),
			URL(staticString: "http://localhost:8080/hello")
		)

		XCTAssertEqual(
			endpoint.appending("hello", "world"),
			URL(staticString: "http://localhost:8080/hello/world")
		)
	}
}
