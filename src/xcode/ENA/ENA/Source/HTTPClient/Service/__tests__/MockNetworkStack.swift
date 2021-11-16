//
// 🦠 Corona-Warn-App
//

@testable import ENA
import Foundation

/// Helper struct to easily create a `MockUrlSession` that sends the desired HTTP status code and `URLResponse`
struct MockNetworkStack {
	var urlSession: MockUrlSession

	init(
		mockSession: MockUrlSession
	) {
		self.urlSession = mockSession
	}

	/// Convenience, creates a `MockUrlSession`, `URLResponse` under the hood
	init(
		baseURL: URL = URL(staticString: "http://example.com"),
		httpStatus: Int,
		httpVersion: String = "HTTP/2",
		headerFields: [String: String] = [:],
		responseData: Data?,
		requestObserver: MockUrlSession.URLRequestObserver? = nil
	) {
		let mockResponse = HTTPURLResponse(
			url: baseURL,
			statusCode: httpStatus,
			httpVersion: httpVersion,
			headerFields: headerFields
		)!	// swiftlint:disable:this force_unwrapping
		urlSession = MockUrlSession(
			data: responseData,
			nextResponse: mockResponse,
			error: nil,
			urlRequestObserver: requestObserver
		)
	}
}

// @available(*, deprecated)
extension HTTPClient {
	/// Configure a `HTTPClient` with `.fake` configuration and mocked `URLSession`
	static func makeWith(mock stack: MockNetworkStack) -> HTTPClient {
		HTTPClient(session: stack.urlSession)
	}
}

// @available(*, deprecated)
extension WifiOnlyHTTPClient {
	static func makeWith(mock stack: MockNetworkStack) -> WifiOnlyHTTPClient {
		WifiOnlyHTTPClient(session: stack.urlSession)
	}
}

// @available(*, deprecated)
enum TestError: Error {
	case error
}

// @available(*, deprecated)
struct GetTANResponse: Codable {
	let tan: String
}

// @available(*, deprecated)
struct GetTestResultResponse: Codable {
	let testResult: Int
}

// @available(*, deprecated)
struct GetRegistrationTokenResponse: Codable {
	let registrationToken: String
}
