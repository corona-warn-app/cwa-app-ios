//
// 🦠 Corona-Warn-App
//

import Foundation

struct Locator {

	// MARK: - Internal

	let endpoint: Endpoint
	let paths: [String]
	let method: HTTP.Method
	var headers: [String: String]

	func urlRequest(environmentData: EnvironmentData) -> URLRequest {
		let endpointURL = endpoint.url(environmentData)
		let url = paths.reduce(endpointURL) { result, component in
			result.appendingPathComponent(component, isDirectory: false)
		}
		return URLRequest(url: url)
	}
}
