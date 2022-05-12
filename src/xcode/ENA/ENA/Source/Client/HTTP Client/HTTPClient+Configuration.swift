//
// 🦠 Corona-Warn-App
//

import Foundation

extension HTTPClient {
	struct Configuration {
		
		// MARK: Default Instances

		static func makeDefaultConfiguration(environmentProvider: EnvironmentProviding) -> Configuration {
			let endpoints = Configuration.Endpoints(
				distribution: .init(
					baseURL: environmentProvider.currentEnvironment().distributionURL,
					requiresTrailingSlash: false
				),
				verification: .init(
					baseURL: environmentProvider.currentEnvironment().verificationURL,
					requiresTrailingSlash: false
				),
				dataDonation: .init(
					baseURL: environmentProvider.currentEnvironment().dataDonationURL,
					requiresTrailingSlash: false
				),
				errorLogSubmission: .init(
					baseURL: environmentProvider.currentEnvironment().errorLogSubmissionURL,
					requiresTrailingSlash: false
				)
			)

			return Configuration(
				apiVersion: "v1",
				encryptedApiVersion: "v2",
				country: "DE",
				endpoints: endpoints
			)
		}

		// MARK: Properties

		let apiVersion: String
		let encryptedApiVersion: String
		let country: String
		let endpoints: Endpoints

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

		var configurationURL: URL {
			endpoints
				.distribution
				.appending(
					"version",
					"v2",
					"app_config_ios"
			)
		}

		var statisticsURL: URL {
			endpoints
				.distribution
				.appending(
					"version",
					apiVersion,
					"stats"
			)
		}

		func localStatisticsURL(groupID: StatisticsGroupIdentifier) -> URL {
			endpoints
				.distribution
				.appending(
					"version",
					apiVersion,
					"local_stats_\(groupID)"
			)
		}

		var otpEdusAuthorizationURL: URL {
			endpoints
				.dataDonation
				.appending(
					"version",
					apiVersion,
					"ios",
					"otp"
				)
		}

		var otpElsAuthorizationURL: URL {
			endpoints
				.dataDonation
				.appending(
					"version",
					apiVersion,
					"ios",
					"els"
			)
		}

		var ppaSubmitURL: URL {
			endpoints
				.dataDonation
				.appending(
					"version",
					apiVersion,
					"ios",
					"dat"
				)
		}

		var qrCodePosterTemplateURL: URL {
			endpoints
				.distribution
				.appending(
					"version",
					apiVersion,
					"qr_code_poster_template_ios"
			)
		}

		var logUploadURL: URL {
			endpoints
				.errorLogSubmission
				.appending(
					"api",
					"logs"
			)
		}
		
		var vaccinationValueSetsURL: URL {
			endpoints
				.distribution
				.appending(
					"version",
					apiVersion,
					"ehn-dgc",
					Locale.current.languageCodeIfSupported ?? "en",
					"value-sets"
				)
		}
		
		var DSCListURL: URL {
			endpoints
				.distribution
				.appending(
					"version",
					apiVersion,
					"ehn-dgc",
					"dscs"
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
		let verification: Endpoint
		let dataDonation: Endpoint
		let errorLogSubmission: Endpoint
	}
}
