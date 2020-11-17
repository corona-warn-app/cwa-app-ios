//
// 🦠 Corona-Warn-App
//

@testable import ENA
import Foundation
import XCTest

final class SapFileBucketTests: XCTestCase {
	func testDataFromBackend() throws {
		let bundle = Bundle(for: SapFileBucketTests.self)

		let fixtureUrl = try XCTUnwrap(bundle.url(
			forResource: "api-response-day-2020-05-16",
			withExtension: nil
		))

		let fixtureData = try Data(contentsOf: fixtureUrl)
		_ = try XCTUnwrap(SAPDownloadedPackage(compressedData: fixtureData))
	}

	func testStaticAppConfiguration() throws {
		let bundle = Bundle(for: SapFileBucketTests.self)

		let fixtureUrl = try XCTUnwrap(bundle.url(
			forResource: "config-wru-2020-11-13",
			withExtension: nil
		))

		let fixtureData = try Data(contentsOf: fixtureUrl)
		let bucket = try XCTUnwrap(SAPDownloadedPackage(compressedData: fixtureData))
		let config = try SAP_Internal_V2_ApplicationConfigurationIOS(serializedData: bucket.bin)
		XCTAssertEqual(config.supportedCountries, ["DE", "DK", "IE", "IT", "ES", "LV", "CZ", "HR"])
	}
}
