//
// 🦠 Corona-Warn-App
//

@testable import ENA
import Foundation

/// Helper struct to easily create a `MockUrlSession` that sends the desired HTTP status code and `URLResponse`
struct MockNetworkStack {
	var urlSession: MockUrlSession
	var packageVerifier: SAPDownloadedPackage.Verification

	init(
		mockSession: MockUrlSession,
		packageVerifier:  @escaping SAPDownloadedPackage.Verification = { _ in return true }
	) {
		self.urlSession = mockSession
		self.packageVerifier = packageVerifier
	}

	/// Convenience, creates a `MockUrlSession`, `URLResponse` under the hood
	init(
		baseURL: URL = URL(staticString: "http://example.com"),
		httpStatus: Int,
		httpVersion: String = "HTTP/2",
		headerFields: [String: String] = [:],
		responseData: Data?,
		packageVerifier: @escaping SAPDownloadedPackage.Verification = { _ in return true },
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
		self.packageVerifier = packageVerifier
	}
}

extension HTTPClient {
	/// Configure a `HTTPClient` with `.fake` configuration and mocked `URLSession`
	static func makeWith(mock stack: MockNetworkStack) -> HTTPClient {
		HTTPClient(
			serverEnvironmentProvider: MockTestStore(),
			packageVerifier: stack.packageVerifier,
			session: stack.urlSession
		)
	}
}

extension WifiOnlyHTTPClient {
	static func makeWith(mock stack: MockNetworkStack) -> WifiOnlyHTTPClient {
		WifiOnlyHTTPClient(
			serverEnvironmentProvider: MockTestStore(),
			session: stack.urlSession
		)
	}
}

enum TestError: Error {
	case error
}

struct GetTANResponse: Codable {
	let tan: String
}

struct GetTestResultResponse: Codable {
	let testResult: Int
}

struct GetRegistrationTokenResponse: Codable {
	let registrationToken: String
}
