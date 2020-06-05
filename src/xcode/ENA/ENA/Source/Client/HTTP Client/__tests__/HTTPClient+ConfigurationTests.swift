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

@testable import ENA
import Foundation
import XCTest

final class BackendConfigurationTests: XCTestCase {
	private typealias Configuration = HTTPClient.Configuration
	private typealias Endpoint = HTTPClient.Configuration.Endpoint

	func testConfiguration() {
		let distribution = Endpoint(
			baseURL: URL(staticString: "http://localhost/dist"),
			requiresTrailingSlash: true
		)

		let submission = Endpoint(
			baseURL: URL(staticString: "http://localhost/submit"),
			requiresTrailingSlash: true
		)
		let verification = Endpoint(
			baseURL: URL(staticString: "http://localhost/verification"),
			requiresTrailingSlash: true
		)

		let endpoints = Configuration.Endpoints(
			distribution: distribution,
			submission: submission,
			verification: verification
		)

		let config = Configuration(
			apiVersion: "v1",
			country: "DE",
			endpoints: endpoints
		)

		// Diagnosis Keys URL
		XCTAssertEqual(
			config.diagnosisKeysURL.absoluteString,
			"http://localhost/dist/version/v1/diagnosis-keys/country/DE/"
		)

		// Check Configuration URL
		XCTAssertEqual(
			config.configurationURL.absoluteString,
			"http://localhost/dist/version/v1/configuration/country/DE/app_config/"
		)

		// Submission URL
		XCTAssertEqual(
			config.submissionURL.absoluteString,
			"http://localhost/submit/version/v1/diagnosis-keys/"
		)

		// Hour URL
		XCTAssertEqual(
			config.diagnosisKeysURL(day: "2020-04-20", hour: 14).absoluteString,
			"http://localhost/dist/version/v1/diagnosis-keys/country/DE/date/2020-04-20/hour/14/"
		)

		// Day URL
		XCTAssertEqual(
			config.diagnosisKeysURL(day: "2020-04-20").absoluteString,
			"http://localhost/dist/version/v1/diagnosis-keys/country/DE/date/2020-04-20/"
		)

		// Available Days URL
		XCTAssertEqual(
			config.availableDaysURL.absoluteString,
			"http://localhost/dist/version/v1/diagnosis-keys/country/DE/date/"
		)

		// Available Hours for a given Day URL
		XCTAssertEqual(
			config.availableHoursURL(day: "2020-04-20").absoluteString,
			"http://localhost/dist/version/v1/diagnosis-keys/country/DE/date/2020-04-20/hour/"
		)
	}
}
