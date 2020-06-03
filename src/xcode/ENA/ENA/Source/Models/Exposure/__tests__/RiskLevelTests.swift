//
// Corona-Warn-App
//
// SAP SE and all other contributors /
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

/// Tests comparing of the `RiskLevel` enum
final class RiskLevelTests: XCTestCase {

	/*
	RiskLevels are ordered according to these rules:
	1. .low is least
	2. .inactive is highest
	3. .increased overrides .unknownOutdated
	4. .unknownOutdated overrides .low AND .increased
	5. .unknownInitial overrides .low AND .unknownOutdated
	*/

	func testRiskLevelCompare_ExceptionCase() {
		XCTAssert(RiskLevel.unknownOutdated < RiskLevel.increased)
	}

	func testRiskLevelCompare_BaseCases() {
		// Unfortunately we cannot simply shuffle and sort all cases, as our exception case will make it fail.
		// Let's test our rules individually
		RiskLevel.allCases.dropFirst().forEach {
			XCTAssert(RiskLevel.low < $0)
		}

		RiskLevel.allCases.dropLast().forEach {
			XCTAssert(RiskLevel.inactive > $0)
		}

		XCTAssert(RiskLevel.increased > RiskLevel.unknownOutdated)
		XCTAssert(RiskLevel.unknownOutdated > RiskLevel.increased)
		XCTAssert(RiskLevel.unknownInitial > RiskLevel.unknownOutdated)
	}
}
