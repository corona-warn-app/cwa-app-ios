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

		let submission = Endpoint(
			baseURL: URL(staticString: "http://localhost/submit"),
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
		let dcc = Endpoint(
			baseURL: URL(staticString: "http://localhost/dcc"),
			requiresTrailingSlash: true
		)

		let endpoints = Configuration.Endpoints(
			distribution: distribution,
			submission: submission,
			verification: verification,
			dataDonation: dataDonation,
			errorLogSubmission: errorLogSubmission,
			dcc: dcc
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

		// Submission URL
		XCTAssertEqual(
			config.submissionURL.absoluteString,
			"http://localhost/submit/version/v1/diagnosis-keys/"
		)

		// Available Days URL
		XCTAssertEqual(
				config.availableDaysURL(forCountry: "IT").absoluteString,
				"http://localhost/dist/version/v1/diagnosis-keys/country/IT/date/"
		)

		// Day URL
		XCTAssertEqual(
				config.diagnosisKeysURL(day: "2020-04-20", forCountry: "IT").absoluteString,
				"http://localhost/dist/version/v1/diagnosis-keys/country/IT/date/2020-04-20/"
		)

		// Hour URL
		XCTAssertEqual(
			config.diagnosisKeysURL(day: "2020-04-20", hour: 14, forCountry: "IT").absoluteString,
			"http://localhost/dist/version/v1/diagnosis-keys/country/IT/date/2020-04-20/hour/14/"
		)

		// Available Hours for a given Day URL
		XCTAssertEqual(
			config.availableHoursURL(day: "2020-04-20", country: "IT").absoluteString,
			"http://localhost/dist/version/v1/diagnosis-keys/country/IT/date/2020-04-20/hour/"
		)

		XCTAssertEqual(
			config.encryptedTraceWarningPackageDiscoveryURL(country: "DE").absoluteString,
			"http://localhost/dist/version/v2/twp/country/DE/hour/"
		)

		XCTAssertEqual(
			config.encryptedTraceWarningPackageDownloadURL(country: "DE", packageId: 12345).absoluteString,
			"http://localhost/dist/version/v2/twp/country/DE/hour/12345/"
		)

	}
}
