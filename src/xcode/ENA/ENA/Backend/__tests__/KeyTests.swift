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
import XCTest

class KeyTests: XCTestCase {
	// This is a very basic sanity test just to make sure that encoding and decoding of keys
	// works. Currently this is needed by the developer menu in order to transfer keys from
	// device to device.
	func testKeyEncodeDecode() throws {
		var kIn = Apple_TemporaryExposureKey()
		kIn.keyData = Data(bytes: [1, 2, 3], count: 3)
		kIn.rollingPeriod = 1337
		kIn.rollingStartIntervalNumber = 42
		kIn.transmissionRiskLevel = 8

		let dataIn = try kIn.serializedData()
		let kOut = try Apple_TemporaryExposureKey(serializedData: dataIn)
		XCTAssertEqual(kOut.keyData, Data(bytes: [1, 2, 3], count: 3))
		XCTAssertEqual(kOut.rollingPeriod, 1337)
		XCTAssertEqual(kOut.rollingStartIntervalNumber, 42)
		XCTAssertEqual(kOut.transmissionRiskLevel, 8)
	}
}
