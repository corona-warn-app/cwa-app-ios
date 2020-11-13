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
