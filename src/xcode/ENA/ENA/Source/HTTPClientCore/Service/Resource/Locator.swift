//
// 🦠 Corona-Warn-App
//

import SWCompression

protocol UniqueHash {
	var uniqueIdentifier: String { get }
}

/**
 The locator describes where (endpoint and path) a resource should be send or received. I can also add some headers, like the fake request header.
 */
struct Locator: UniqueHash {

	// MARK: - Init

	init(
		endpoint: Endpoint,
		paths: [String],
		method: HTTP.Method,
		defaultHeaders: [String: String] = [:]
	) {
		self.endpoint = endpoint
		self.paths = paths
		self.method = method
		self.headers = defaultHeaders

		// we need a unique identifier to persist data inside the cache
		guard let uniqueData = [
			endpoint.description,
			paths.joined(separator: "/"),
			method.rawValue
		]
				.joined(separator: "/")
				.data(using: .utf8) else {
					Log.error("Failed to create locator \(endpoint) \(paths) \(method)")
					fatalError()
				}
		self.uniqueIdentifier = uniqueData.sha256String()
	}

	// MARK: - Protocol UniqueHash

	let uniqueIdentifier: String

	// MARK: - Internal

	let endpoint: Endpoint
	let paths: [String]
	let method: HTTP.Method
	let headers: [String: String]

	var isFake: Bool {
		guard let isFakeValue = headers["cwa-fake"] else {
			return false
		}
		return isFakeValue == "1"
	}

#if DEBUG

	static func fake(
		endpoint: Endpoint = .distribution,
		paths: [String] = [String](),
		method: HTTP.Method = .get,
		defaultHeaders: [String: String] = [:]
	) -> Locator {
		return Locator(
			endpoint: endpoint,
			paths: paths,
			method: method,
			defaultHeaders: defaultHeaders
		)
	}

#endif
}
