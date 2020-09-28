// Local configuation

import Foundation

// MARK: - Map
struct Map: Codable {
	let serverEnvironments: [ServerEnvironment]

	enum CodingKeys: String, CodingKey {
		case serverEnvironments = "ServerEnvironments"
	}
}

// MARK: - ServerEnvironment
struct ServerEnvironment: Codable {
	let name: String
	let distributionURL, submissionURL, verificationURL: URL
}

struct LocalServerEnvironment {

	struct Hosts {
		let distributionURL: URL
		let submissionURL: URL
		let verificationURL: URL
	}

	private let environments: [ServerEnvironment]

	init(bundle: Bundle = Bundle.main, resourceName: String = "ServerEnvironments") {
		guard
			let jsonURL = bundle.url(forResource: resourceName, withExtension: "json"),
			let jsonData = try? Data(contentsOf: jsonURL),
			let map = try? JSONDecoder().decode(Map.self, from: jsonData) else {

			fatalError("Missing server environment.")
		}

		self.environments = map.serverEnvironments
	}

	func availableEnvironments() -> [ServerEnvironment] {
		return environments
	}

	func loadServerEnvironment(_ name: String) -> ServerEnvironment {
		guard let environment = availableEnvironments().first(where: { $0.name == name }) else {
			fatalError("Missing server environment.")
		}

		return environment
	}

	func defaultEnvironment() -> ServerEnvironment {
		return loadServerEnvironment("Default")
	}

	func getHosts(for environment: String) -> Hosts {
		let environment = loadServerEnvironment(environment)
		return Hosts(
			distributionURL: environment.distributionURL,
			submissionURL: environment.submissionURL,
			verificationURL: environment.verificationURL
		)
	}
}
