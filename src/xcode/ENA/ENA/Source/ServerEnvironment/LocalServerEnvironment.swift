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

	private let bundle: Bundle

	init(_ bundle: Bundle = Bundle.main) {
		self.bundle = bundle
	}

	struct Hosts {
		let distributionURL: URL
		let submissionURL: URL
		let verificationURL: URL
	}

	func defaultEnvironment() -> ServerEnvironment {
		return loadServerEnvironment("Default")
	}

	func loadServerEnvironment(_ name: String) -> ServerEnvironment {
		guard let environment = availableEnvironments().first(where: { $0.name == name }) else {
			fatalError("Missing server environment.")
		}

		return environment
	}

	func availableEnvironments() -> [ServerEnvironment] {
		guard
			let jsonURL = bundle.url(forResource: "ServerEnvironments", withExtension: "json"),
			let jsonData = try? Data(contentsOf: jsonURL),
			let map = try? JSONDecoder().decode(Map.self, from: jsonData) else {

			fatalError("Missing server environment.")
		}

		return map.serverEnvironments
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
