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
		type: ResourceType = .default
	) {
		self.endpoint = endpoint
		self.paths = paths
		self.method = method
		self.headers = defaultHeaders
		self.type = type
	}

	// MARK: - Internal

	let endpoint: Endpoint
	let paths: [String]
	let method: HTTP.Method
	let type: ResourceType
	let headers: [String: String]

	func urlRequest(environmentData: EnvironmentData, eTag: String? = nil) -> URLRequest {
		let endpointURL = endpoint.url(environmentData)
		let url = paths.reduce(endpointURL) { result, component in
			result.appendingPathComponent(component, isDirectory: false)
		}
		var urlRequest = URLRequest(url: url)
		headers.forEach { key, value in
			urlRequest.setValue(value, forHTTPHeaderField: key)
		}

		if let eTag = eTag {
			urlRequest.setValue(eTag, forHTTPHeaderField: "If-None-Match")
		}

		return urlRequest
	}

	func hash(into hasher: inout Hasher) {
		hasher.combine(endpoint)
		hasher.combine(paths)
		hasher.combine(method)
	}
}
