//
// 🦠 Corona-Warn-App
//

import Foundation

extension HTTPClient {
	struct Configuration {
		
		// MARK: Default Instances

		static func makeDefaultConfiguration(serverEnvironmentProvider: ServerEnvironmentProviding) -> Configuration {
			let endpoints = Configuration.Endpoints(
				distribution: .init(
					baseURL: serverEnvironmentProvider.selectedServerEnvironment.distributionURL,
					requiresTrailingSlash: false
				),
				submission: .init(
					baseURL: serverEnvironmentProvider.selectedServerEnvironment.submissionURL,
					requiresTrailingSlash: false
				),
				verification: .init(
					baseURL: serverEnvironmentProvider.selectedServerEnvironment.verificationURL,
					requiresTrailingSlash: false
				)
			)

			return Configuration(
				apiVersion: "v1",
				country: "DE",
				endpoints: endpoints
			)
		}

		// MARK: Properties

		let apiVersion: String
		let country: String
		let endpoints: Endpoints

		/// Generate the URL for getting all available days
		/// - Parameter country: country code
		/// - Returns: URL to get all available days that server can deliver
		func availableDaysURL(forCountry country: String) -> URL {
			endpoints
				.distribution
				.appending(
					"version",
					apiVersion,
					"diagnosis-keys",
					"country",
					country,
					"date"
			)
		}

		/// Generate the URL to get the day package with given parameters
		/// - Parameters:
		///   - day: The day format should confirms to: yyyy-MM-dd
		///   - country: The country code
		/// - Returns: The full URL point to the key package
		func diagnosisKeysURL(day: String, forCountry country: String) -> URL {
			endpoints
				.distribution
				.appending(
					"version",
					apiVersion,
					"diagnosis-keys",
					"country",
					country,
					"date",
					day
			)

		}

		func diagnosisKeysURL(day: String, hour: Int, forCountry country: String) -> URL {
			endpoints
				.distribution
				.appending(
					"version",
					apiVersion,
					"diagnosis-keys",
					"country",
					country,
					"date",
					day,
					"hour",
					String(hour)
			)
		}

		func availableHoursURL(day: String, country: String) -> URL {
			endpoints
				.distribution
				.appending(
					"version",
					apiVersion,
					"diagnosis-keys",
					"country",
					country,
					"date",
					day,
					"hour"
			)
		}

		var configurationURL: URL {
			endpoints
				.distribution
				.appending(
					"version",
					apiVersion,
					"app_config_ios"
			)
		}

		var statisticsURL: URL {
			endpoints
				.submission
				.appending(
					"version",
					apiVersion,
					"stats"
			)
		}

		var submissionURL: URL {
			endpoints
				.submission
				.appending(
					"version",
					apiVersion,
					"diagnosis-keys"
			)
		}

		var registrationURL: URL {
			endpoints
				.verification
				.appending(
					"version",
					apiVersion,
					"registrationToken"
			)
		}

		var testResultURL: URL {
			endpoints
				.verification
				.appending(
					"version",
					apiVersion,
					"testresult"
			)
		}

		var tanRetrievalURL: URL {
			endpoints
				.verification
				.appending(
					"version",
					apiVersion,
					"tan"
			)
		}
	}
}

extension HTTPClient.Configuration {
	struct Endpoint {
		// MARK: Creating an Endpoint

		init(
			baseURL: URL,
			requiresTrailingSlash: Bool,
			requiresTrailingIndex _: Bool = true
		) {
			self.baseURL = baseURL
			self.requiresTrailingSlash = requiresTrailingSlash
			requiresTrailingIndex = false
		}

		// MARK: Properties

		let baseURL: URL
		let requiresTrailingSlash: Bool
		let requiresTrailingIndex: Bool

		// MARK: Working with an Endpoint

		func appending(_ components: String...) -> URL {
			let url = components.reduce(baseURL) { result, component in
				result.appendingPathComponent(component, isDirectory: self.requiresTrailingSlash)
			}
			if requiresTrailingIndex {
				return url.appendingPathComponent("index", isDirectory: false)
			}
			return url
		}
	}
}

extension HTTPClient.Configuration {
	struct Endpoints {
		let distribution: Endpoint
		let submission: Endpoint
		let verification: Endpoint
	}
}
