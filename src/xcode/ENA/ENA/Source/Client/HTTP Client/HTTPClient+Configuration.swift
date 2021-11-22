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
				submission: .init(
					baseURL: environmentProvider.currentEnvironment().submissionURL,
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
				),
				dcc: .init(
					baseURL: environmentProvider.currentEnvironment().dccURL,
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

		var submissionURL: URL {
			endpoints
				.submission
				.appending(
					"version",
					apiVersion,
					"diagnosis-keys"
			)
		}
		
		var onBehalfCheckinSubmissionURL: URL {
			endpoints
				.submission
				.appending(
					"version",
					apiVersion,
					"submission-on-behalf"
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
		
		func traceWarningPackageDiscoveryURL(country: String) -> URL {
			endpoints
				.distribution
				.appending(
					"version",
					apiVersion,
					"twp",
					"country",
					country,
					"hour"
				)
		}
		
		func traceWarningPackageDownloadURL(country: String, packageId: Int) -> URL {
			endpoints
				.distribution
				.appending(
					"version",
					apiVersion,
					"twp",
					"country",
					country,
					"hour",
					String(packageId)
				)
		}

		/// API for Encrypted Hour Package Discovery
		func encryptedTraceWarningPackageDiscoveryURL(country: String) -> URL {
			endpoints
				.distribution
				.appending(
					"version",
					encryptedApiVersion,
					"twp",
					"country",
					country,
					"hour"
				)
		}

		/// API for Encrypted Hour Package Download
		func encryptedTraceWarningPackageDownloadURL(country: String, packageId: Int) -> URL {
			endpoints
				.distribution
				.appending(
					"version",
					encryptedApiVersion,
					"twp",
					"country",
					country,
					"hour",
					String(packageId)
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

		var dccPublicKeyURL: URL {
			endpoints
				.dcc
				.appending(
					"version",
					apiVersion,
					"publicKey"
				)
		}
		
		var DCCURL: URL {
			endpoints
				.dcc
				.appending(
					"version",
					apiVersion,
					"dcc"
				)
		}
		
		var validationOnboardedCountriesURL: URL {
			endpoints
				.distribution
				.appending(
					"version",
					apiVersion,
					"ehn-dgc",
					"onboarded-countries"
				)
		}
				
		func dccRulesURL(rulePath: String) -> URL {
			endpoints
				.distribution
				.appending(
					"version",
					apiVersion,
					"ehn-dgc",
					rulePath
				)
		}
		var boosterRulesURL: URL {
			endpoints
				.distribution
				.appending(
					"version",
					apiVersion,
					"booster-notification-rules"
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
		let submission: Endpoint
		let verification: Endpoint
		let dataDonation: Endpoint
		let errorLogSubmission: Endpoint
		let dcc: Endpoint
	}
}
