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

		let fixtureUrl = bundle.url(
			forResource: "api-response-day-2020-05-16",
			withExtension: nil
		)!

		let fixtureData = try Data(contentsOf: fixtureUrl)
		let bucket = SAPDownloadedPackage(compressedData: fixtureData)
		XCTAssertNotNil(bucket)
	}
}
