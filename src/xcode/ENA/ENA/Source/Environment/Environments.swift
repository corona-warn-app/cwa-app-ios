// Local configuration

import Foundation

// MARK: - Structs for json encoding.

struct Map: Codable {
	let environments: [EnvironmentData]
}

struct EnvironmentData: Codable {
	/// Environment name
	let name: String

	// Hosts
	let distributionURL, submissionURL, verificationURL, dataDonationURL, errorLogSubmissionURL, dccURL, dccRecertifyURL: URL

	/// String representation of the package validation (public) key.
	///
	/// Note that the values are taken from the regular public key in PEM format but without the first 36 characters,
	/// which denote PEM header information. These 36 characters are typically:
	/// `MFkwEwYHKoZIzj0CAQYIKoZIzj0DAQcDQgAE`
	let validationKeyString: String

	/// Used for certificate pinning
	let pinningKeyHash: String
}

// MARK: - ServerEnvironment access.

protocol EnvironmentProviding {
	var environments: [EnvironmentData] { get }

	/// The default (i.e. first) environment
	func defaultEnvironment() -> EnvironmentData

	/// The currently selected set of environment parameters
	///
	/// Always returns the production-set on non-DEBUG builds
	func currentEnvironment() -> EnvironmentData

	func environment(_ name: EnvironmentDescriptor) -> EnvironmentData
}

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

struct Environments: EnvironmentProviding {

	static let selectedEnvironmentKey = "env"

	let environments: [EnvironmentData]

	init(bundle: Bundle = Bundle.main, resourceName: String = "Environments") {
		guard let jsonURL = bundle.url(forResource: resourceName, withExtension: "json") else {
			fatalError("Missing server environment.")
		}
		do {
			let jsonData = try Data(contentsOf: jsonURL)
			let map = try JSONDecoder().decode(Map.self, from: jsonData)
			self.environments = map.environments
		} catch {
			fatalError("Error parsing server environments: \(error)")
		}
	}
	#if DEBUG
	/// Initializer to provide custom environments in tests
	init(environments: [EnvironmentData]) {
		self.environments = environments
	}
	#endif

	func environment(_ name: EnvironmentDescriptor) -> EnvironmentData {
		guard let environment = environments.first(where: { $0.name == name.string }) else {
			fatalError("Missing server environment \(name.string).")
		}

		return environment
	}

	func currentEnvironment() -> EnvironmentData {
		#if !RELEASE
		if let env = UserDefaults.standard.string(forKey: Environments.selectedEnvironmentKey) {
			return environment(.custom(env))
		} else {
			return defaultEnvironment()
		}
		#else
		return environment(.production)
		#endif
	}

	func defaultEnvironment() -> EnvironmentData {
		#if !RELEASE
		return environments[0]
		#else
		return environment(.production)
		#endif
	}
}
