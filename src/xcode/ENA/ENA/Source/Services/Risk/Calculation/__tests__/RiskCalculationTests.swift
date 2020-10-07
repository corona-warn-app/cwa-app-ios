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
import ExposureNotification
import XCTest

class RiskCalculationTests: XCTestCase {

	private let store = MockTestStore()

	// MARK: - Tests for calculating raw risk score

	func testCalculateRawRiskScore_Zero() throws {
		let summaryZeroMaxRisk = makeExposureSummaryContainer(maxRiskScoreFullRange: 0, ad_low: 10, ad_mid: 10, ad_high: 10)
		XCTAssertEqual(RiskCalculation.calculateRawRisk(summary: summaryZeroMaxRisk, configuration: appConfig), 0.0, accuracy: 0.01)
	}

	func testCalculateRawRiskScore_Low() throws {
		XCTAssertEqual(RiskCalculation.calculateRawRisk(summary: summaryLow, configuration: appConfig), 1.07, accuracy: 0.01)
	}

	func testCalculateRawRiskScore_Med() throws {
		XCTAssertEqual(RiskCalculation.calculateRawRisk(summary: summaryMed, configuration: appConfig), 2.56, accuracy: 0.01)
	}

	func testCalculateRawRiskScore_High() throws {
		XCTAssertEqual(RiskCalculation.calculateRawRisk(summary: summaryHigh, configuration: appConfig), 10.2, accuracy: 0.01)
	}

}
