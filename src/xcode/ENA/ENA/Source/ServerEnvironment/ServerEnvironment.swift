// Local configuation

import Foundation

// MARK: - Structs for json encoding.

struct Map: Codable {
	let serverEnvironments: [ServerEnvironmentData]

	enum CodingKeys: String, CodingKey {
		case serverEnvironments = "ServerEnvironments"
	}
}

struct ServerEnvironmentData: Codable {
	let name: String
	let distributionURL, submissionURL, verificationURL, dataDonationURL: URL
}

// MARK: - ServerEnvironment access.

struct ServerEnvironment {

	private let environments: [ServerEnvironmentData]

	init(bundle: Bundle = Bundle.main, resourceName: String = "ServerEnvironments") {
		guard let jsonURL = bundle.url(forResource: resourceName, withExtension: "json") else {
			fatalError("Missing server environment.")
		}
		do {
			let jsonData = try Data(contentsOf: jsonURL)
			let map = try JSONDecoder().decode(Map.self, from: jsonData)
			self.environments = map.serverEnvironments
		} catch {
			fatalError("Error parsing server environments: \(error)")
		}
	}

	func availableEnvironments() -> [ServerEnvironmentData] {
		return environments
	}

	func environment(_ name: String) -> ServerEnvironmentData {
		guard let environment = availableEnvironments().first(where: { $0.name == name }) else {
			fatalError("Missing server environment.")
		}

		return environment
	}

	func defaultEnvironment() -> ServerEnvironmentData {
		return environment("Default")
	}
}
