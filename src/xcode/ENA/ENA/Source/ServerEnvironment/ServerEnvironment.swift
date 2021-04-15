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
	/// Environemnt name
	let name: String

	// Hosts
	let distributionURL, submissionURL, verificationURL, dataDonationURL, errorLogSubmission: URL

	/// String representation of the servers public key. Used for signature validation.
	let publicKeyString: String
}

// MARK: - ServerEnvironment access.

enum EnvironmentDescriptor {
	case production
	case custom(_ name: String)

	var string: String {
		switch self {
		case .production:
			return "prod"
		case .custom(let name):
			return name
		}
	}
}

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

	func environment(_ name: EnvironmentDescriptor) -> ServerEnvironmentData {
		guard let environment = availableEnvironments().first(where: { $0.name == name.string }) else {
			fatalError("Missing server environment.")
		}

		return environment
	}

	func defaultEnvironment() -> ServerEnvironmentData {
		return environment(.production)
	}
}
