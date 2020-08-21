//
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
//

@testable import ENA
import Foundation
import XCTest
import ZIPFoundation

final class HTTPClientExposureConfigTests: XCTestCase {

	private let expectationsTimeout: TimeInterval = 2

	func testInvalidEmptyExposureConfigurationResponseData() {
		let stack = MockNetworkStack(
			httpStatus: 200,
			responseData: nil
		)

		let expectation = self.expectation(description: "HTTPClient should have failed.")

		HTTPClient.makeWith(mock: stack).exposureConfiguration { config in
			XCTAssertNil(config, "configuration should be nil when data is invalid")
			expectation.fulfill()
		}
		waitForExpectations(timeout: expectationsTimeout)
	}

	func testResponseDataHasNoExposureConfig() throws {
		// Test the case where we get a SAP_ApplicationConfiguration, but it's hasExposureConfig == nil

		// We need to build the SAP_ApplicationConfiguration manually
		// 1 Create in - memory archive
		guard let archive = Archive(accessMode: .create) else {
			XCTFail("Could not create in-memory ZIP archive!")
			return
		}
		// 2 Init default SAP_ApplicationConfiguration - it will have hasExposureConfig defaulted to nil
		let appConfig = try SAP_ApplicationConfiguration().serializedData()
		// 3 Make ZIP
		try archive.addEntry(with: "export.bin", type: .file, uncompressedSize: UInt32(appConfig.count), bufferSize: 4, provider: { position, size -> Data in
			return appConfig.subdata(in: position..<position + size)
		})

		let randomData = Data("Hello!".utf8)
		try archive.addEntry(with: "export.sig", type: .file, uncompressedSize: UInt32(randomData.count), bufferSize: 4, provider: { position, size -> Data in
			return randomData.subdata(in: position..<position + size)
		})
		let archiveData = archive.data ?? Data()
		// 3 Mock URLSession setup to return mock ZIP
		let stack = MockNetworkStack(
			httpStatus: 200,
			responseData: archiveData
		)

		let expectation = self.expectation(description: "HTTPClient should have failed.")
		// 4 Test that the exposureConfiguration fetch fails
		HTTPClient.makeWith(mock: stack).exposureConfiguration { config in
			XCTAssertNil(config, "configuration should be nil when data is invalid")
			expectation.fulfill()
		}
		waitForExpectations(timeout: expectationsTimeout)
	}

	func testValidExposureConfigurationResponseData() throws {
		// swiftlint:disable:next force_unwrapping
		let url = Bundle(for: type(of: self)).url(forResource: "de-config", withExtension: nil)!
		let stack = MockNetworkStack(
			httpStatus: 200,
			responseData: try Data(contentsOf: url)
		)

		let expectation = self.expectation(description: "HTTPClient should have succeeded.")

		HTTPClient.makeWith(mock: stack).exposureConfiguration { config in
			XCTAssertNotNil(config, "configuration should not be nil for valid responses")
			expectation.fulfill()
		}
		waitForExpectations(timeout: expectationsTimeout)
	}

	func testValidExposureConfigurationDataBut404Response() throws {
		// swiftlint:disable:next force_unwrapping
		let url = Bundle(for: type(of: self)).url(forResource: "de-config", withExtension: nil)!
		let stack = MockNetworkStack(
			httpStatus: 404,
			responseData: try Data(contentsOf: url)
		)

		let expectation = self.expectation(description: "HTTPClient should have failed.")

		HTTPClient.makeWith(mock: stack).exposureConfiguration { configuration in
			XCTAssertNil(
				configuration, "a 404 configuration response should yield an error - not a success"
			)
			expectation.fulfill()
		}
		waitForExpectations(timeout: expectationsTimeout)
	}
}
