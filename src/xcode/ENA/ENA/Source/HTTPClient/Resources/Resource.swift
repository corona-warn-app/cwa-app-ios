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
	case decodeError
}

/// describes a resource
///
protocol HTTPResource {

	// universal resource locator
	var url: URL { get }

	// protocol
	var method: HTTP.Method { get }

	// this will usably be the body
	func decode<M>(_ data: Data?) -> M? where M: Decodable

}

struct JSONResource: HTTPResource {

	// MARK: - Init

	// MARK: - Overrides

	// MARK: - Protocol HTTPResource

	let url: URL
	let method: HTTP.Method

	func decode<M>(_ data: Data?) -> M? where M: Decodable {
		guard let data = data else {
			return nil
		}
		do {
			return try decoder.decode(M.self, from: data)
		} catch let DecodingError.keyNotFound(key, context) {
			Log.debug("missing key: \(key.stringValue)", log: .client)
			Log.debug("Debug Description: \(context.debugDescription)", log: .client)
		} catch let DecodingError.valueNotFound(type, context) {
			Log.debug("Type not found \(type)", log: .client)
			Log.debug("Debug Description: \(context.debugDescription)", log: .client)
		} catch let DecodingError.typeMismatch(type, context) {
			Log.debug("Type mismatch found \(type)", log: .client)
			Log.debug("Debug Description: \(context.debugDescription)", log: .client)
		} catch let DecodingError.dataCorrupted(context) {
			Log.debug("Debug Description: \(context.debugDescription)", log: .client)
		} catch {
			Log.debug("Failed to parse JSON answer - unhandled error", log: .client)
		}
		return nil
	}

	// MARK: - Public

	// MARK: - Internal

	// MARK: - Private

	private let decoder = JSONDecoder()

}
