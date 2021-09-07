//
// 🦠 Corona-Warn-App
//

import Foundation

struct Locator: Hashable {

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
	}

	// MARK: - Internal

	let endpoint: Endpoint
	let paths: [String]
	let method: HTTP.Method
	let headers: [String: String]

	func hash(into hasher: inout Hasher) {
		hasher.combine(endpoint)
		hasher.combine(paths)
		hasher.combine(method)
	}
}
