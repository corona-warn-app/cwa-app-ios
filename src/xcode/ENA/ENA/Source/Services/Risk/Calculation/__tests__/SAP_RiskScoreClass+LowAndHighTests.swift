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
@testable import ENA

final class SAP_RiskScoreClass_LowAndHighTests: XCTestCase {
    func testWithOnlyHighAndLow() {
		let sut: [SAP_RiskScoreClass] = [
			SAP_RiskScoreClass.with {
				$0.label = "LOW"
			},
			SAP_RiskScoreClass.with {
				$0.label = "HIGH"
			}
		]

		XCTAssertEqual(sut.low?.label, "LOW")
		XCTAssertEqual(sut.high?.label, "HIGH")
	}

	func testEmpty() {
		let sut: [SAP_RiskScoreClass] = []
		XCTAssertNil(sut.low)
		XCTAssertNil(sut.high)
	}

	func testIgnoresEmojis() {
		let high = SAP_RiskScoreClass.with { $0.label = "🚬" }
		let sut: [SAP_RiskScoreClass] = [high]
		XCTAssertNil(sut.high)
	}
}
