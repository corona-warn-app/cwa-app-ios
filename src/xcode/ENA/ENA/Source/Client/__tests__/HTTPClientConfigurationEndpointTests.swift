//
// 🦠 Corona-Warn-App
//

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
