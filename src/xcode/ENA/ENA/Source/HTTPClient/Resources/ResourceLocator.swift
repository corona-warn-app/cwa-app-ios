//
// 🦠 Corona-Warn-App
//

import Foundation

struct ResourceLocator {

	// MARK: - Internal

	let endpoint: Endpoint
	let paths: [String]
	let method: HTTP.Method
	let headers: [String: String]

	func urlRequest(environmentData: EnvironmentData) -> URLRequest {
		let endpointURL = endpoint.url(environmentData)
		let url = paths.reduce(endpointURL) { result, component in
			result.appendingPathComponent(component, isDirectory: false)
		}
		return URLRequest(url: url)
	}
}
