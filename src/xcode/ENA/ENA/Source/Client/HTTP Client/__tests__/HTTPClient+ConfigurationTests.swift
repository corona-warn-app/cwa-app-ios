//
// 🦠 Corona-Warn-App
//

@testable import ENA
import Foundation
import XCTest

final class BackendConfigurationTests: CWATestCase {
	private typealias Configuration = HTTPClient.Configuration
	private typealias Endpoint = HTTPClient.Configuration.Endpoint

	func testConfiguration() {
		let distribution = Endpoint(
			baseURL: URL(staticString: "http://localhost/dist"),
			requiresTrailingSlash: true
		)
		let verification = Endpoint(
			baseURL: URL(staticString: "http://localhost/verification"),
			requiresTrailingSlash: true
		)
		let dataDonation = Endpoint(
			baseURL: URL(staticString: "http://localhost/dataDonation"),
			requiresTrailingSlash: true
		)
		let errorLogSubmission = Endpoint(
			baseURL: URL(staticString: "http://localhost/errorLogSubmission"),
			requiresTrailingSlash: true
		)

		let endpoints = Configuration.Endpoints(
			distribution: distribution,
			verification: verification,
			dataDonation: dataDonation,
			errorLogSubmission: errorLogSubmission
		)

		let config = Configuration(
			apiVersion: "v1",
			encryptedApiVersion: "v2",
			country: "DE",
			endpoints: endpoints
		)

		// Check Configuration URL
		XCTAssertEqual(
			config.configurationURL.absoluteString,
			"http://localhost/dist/version/v2/app_config_ios/"
		)

		// Day URL
		XCTAssertEqual(
				config.diagnosisKeysURL(day: "2020-04-20", forCountry: "IT").absoluteString,
				"http://localhost/dist/version/v1/diagnosis-keys/country/IT/date/2020-04-20/"
		)

	}
}
