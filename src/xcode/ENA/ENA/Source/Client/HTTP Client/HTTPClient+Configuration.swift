// Corona-Warn-App
//
// SAP SE and all other contributors
// copyright owners license this file to you under the Apache
// License, Version 2.0 (the "License"); you may not use this
// file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing,
// software distributed under the License is distributed on an
// "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
// KIND, either express or implied.  See the License for the
// specific language governing permissions and limitations
// under the License.

import Foundation

extension HTTPClient {
	struct Configuration {
		// MARK: Default Instances

		static let backendBaseURLs = Configuration(
			apiVersion: "v1",
			country: "DE",
			endpoints: Configuration.Endpoints(
				distribution: .init(
					baseURL: URL(staticString: Hosts.distributionURLString),
					requiresTrailingSlash: false
				),
				submission: .init(
					baseURL: URL(staticString: Hosts.submissionURLString),
					requiresTrailingSlash: false
				),
				verification: .init(
					baseURL: URL(staticString: Hosts.verificationURLString),
					requiresTrailingSlash: false
				)
			)
		)

		// MARK: Properties

		let apiVersion: String
		let country: String
		let endpoints: Endpoints

		var diagnosisKeysURL: URL {
			endpoints
				.distribution
				.appending(
					"version",
					apiVersion,
					"diagnosis-keys",
					"country",
					country
				)
		}

		var availableDaysURL: URL {
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

		func availableHoursURL(day: String) -> URL {
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

		func diagnosisKeysURL(day: String, hour: Int) -> URL {
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

		func diagnosisKeysURL(day: String) -> URL {
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
					apiVersion,
					"configuration",
					"country",
					country,
					"app_config"
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
