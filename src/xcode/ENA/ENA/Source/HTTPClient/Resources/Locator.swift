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
		defaultHeaders: [String: String] = [:],
		cachingMode: ResourceCachingMode = .none
	) {
		self.endpoint = endpoint
		self.paths = paths
		self.method = method
		self.headers = defaultHeaders
		self.cachingMode = cachingMode
	}

	// MARK: - Internal

	let endpoint: Endpoint
	let paths: [String]
	let method: HTTP.Method
	let cachingMode: ResourceCachingMode
	var headers: [String: String]

	func urlRequest(environmentData: EnvironmentData) -> URLRequest {
		let endpointURL = endpoint.url(environmentData)
		let url = paths.reduce(endpointURL) { result, component in
			result.appendingPathComponent(component, isDirectory: false)
		}
		var urlRequest = URLRequest(url: url)
		headers.forEach { key, value in
			urlRequest.setValue(value, forHTTPHeaderField: key)
		}

		return urlRequest
	}

	func hash(into hasher: inout Hasher) {
		hasher.combine(endpoint)
		hasher.combine(paths)
		hasher.combine(method)
	}
}
