//
// 🦠 Corona-Warn-App
//

import Foundation

enum HTTP {
	enum Method: String {
		case get = "GET"
		case post = "POST"
		case put = "PUT"
		case delete = "DELETE"
		case patch = "PATCH"
	}
}

enum ResourceError: Error {
	case missingData
	case decoding
	case packageCreation
	case signatureVerification
}

/// describes a resource
///
protocol Resource {

	// Model is type of the model
	associatedtype Model

	var locator: Locator { get set }

	// this will usably be the body
	func decode(_ data: Data?) -> Result<Model, ResourceError>

	mutating func addHeaders(customHeaders: [String: String])
}

extension Resource {
	mutating func addHeaders(customHeaders: [String: String]) {
		locator.headers.merge(customHeaders) { current, _ in current }
	}

}
