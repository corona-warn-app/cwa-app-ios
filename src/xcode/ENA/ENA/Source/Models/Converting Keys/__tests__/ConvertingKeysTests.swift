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

import XCTest
import ExposureNotification
@testable import ENA

final class ConvertingKeysTests: XCTestCase {
	func testToSapKeyConversion() {
		let key = TemporaryExposureKeyMock(
			keyData: Data("hello".utf8),
			rollingPeriod: 123,
			rollingStartNumber: 456,
			transmissionRiskLevel: 88
		).sapKey
		XCTAssertEqual(key.keyData, Data("hello".utf8))
		XCTAssertEqual(key.rollingPeriod, 123)
		XCTAssertEqual(key.rollingStartIntervalNumber, 456)
		XCTAssertEqual(key.transmissionRiskLevel, 88)
	}
}
