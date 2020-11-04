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
			forResource: "de-config-int-2020-09-25",
			withExtension: nil
		))

		let fixtureData = try Data(contentsOf: fixtureUrl)
		let bucket = try XCTUnwrap(SAPDownloadedPackage(compressedData: fixtureData))
		let config = try SAP_Internal_ApplicationConfiguration(serializedData: bucket.bin)
		XCTAssertEqual(config.supportedCountries, ["DE"])
	}
}
