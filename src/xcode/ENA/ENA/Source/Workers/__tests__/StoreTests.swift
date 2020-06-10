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

final class StoreTests: XCTestCase {
	private var store: SecureStore!

	override func setUp() {
		store = SecureStore(at: URL(staticString: ":memory:"), key: "123456")
	}

	func testResultReceivedTimeStamp_Success() {
		XCTAssertNil(store.testResultReceivedTimeStamp)
		store.testResultReceivedTimeStamp = Int64.max
		XCTAssertEqual(store.testResultReceivedTimeStamp, Int64.max)
		store.testResultReceivedTimeStamp = Int64.min
		XCTAssertEqual(store.testResultReceivedTimeStamp, Int64.min)
	}

	func lastSuccessfulSubmitDiagnosisKeyTimestamp_Success() {
		XCTAssertNil(store.lastSuccessfulSubmitDiagnosisKeyTimestamp)
		store.lastSuccessfulSubmitDiagnosisKeyTimestamp = Int64.max
		XCTAssertEqual(store.lastSuccessfulSubmitDiagnosisKeyTimestamp, Int64.max)
		store.lastSuccessfulSubmitDiagnosisKeyTimestamp = Int64.min
		XCTAssertEqual(store.lastSuccessfulSubmitDiagnosisKeyTimestamp, Int64.min)
	}

	func numberOfSuccesfulSubmissions_Success() {
		XCTAssertNil(store.numberOfSuccesfulSubmissions)
		store.numberOfSuccesfulSubmissions = Int64.max
		XCTAssertEqual(store.numberOfSuccesfulSubmissions, Int64.max)
		store.numberOfSuccesfulSubmissions = Int64.min
		XCTAssertEqual(store.numberOfSuccesfulSubmissions, Int64.min)
	}

	func initialSubmitCompleted_Success() {
		XCTAssertNil(store.initialSubmitCompleted)
		store.initialSubmitCompleted = true
		XCTAssertEqual(store.initialSubmitCompleted, true)
		store.initialSubmitCompleted = false
		XCTAssertEqual(store.initialSubmitCompleted, false)
	}

	func registrationToken_Success() {
		XCTAssertEqual(store.registrationToken, "")

		let token = UUID().description
		store.registrationToken = token
		XCTAssertEqual(store.registrationToken, token)
	}

	func tracingStatusHistory_Success() {
		XCTAssertTrue(store.tracingStatusHistory.isEmpty)
		let date1 = Date(timeIntervalSinceNow: -86400)
		let date2 = Date()
		let entry1 = TracingStatusEntry(on: true, date: date1)
		let entry2 = TracingStatusEntry(on: false, date: date2)

		store.tracingStatusHistory.append(entry1)
		store.tracingStatusHistory.append(entry2)

		XCTAssertEqual(store.tracingStatusHistory.count, 2)
		XCTAssertEqual(store.tracingStatusHistory[0].on, true)
		XCTAssertEqual(store.tracingStatusHistory[0].date, date1)
		XCTAssertEqual(store.tracingStatusHistory[1].on, false)
		XCTAssertEqual(store.tracingStatusHistory[1].date, date2)

		store.flush()
		XCTAssertTrue(store.tracingStatusHistory.isEmpty)
	}

	func SummaryMetadata_Success() {
		XCTAssertNil(store.summary)

		let date = Date()
		let summary = CodableExposureDetectionSummary(
			daysSinceLastExposure: 13,
			matchedKeyCount: UInt64.max,
			maximumRiskScore: 5,
			attenuationDurations: [0.1, 7.42, 13.0],
			maximumRiskScoreFullRange: 7
		)

		store.summary = SummaryMetadata(summary: summary, date: date)

		XCTAssertEqual(store.summary?.date, date)
		XCTAssertEqual(store.summary?.summary.daysSinceLastExposure, 13)
		XCTAssertEqual(store.summary?.summary.matchedKeyCount, UInt64.max)
		XCTAssertEqual(store.summary?.summary.maximumRiskScore, 5)
		XCTAssertEqual(store.summary?.summary.configuredAttenuationDurations.count, 3)
		XCTAssertEqual(store.summary?.summary.maximumRiskScoreFullRange, 7)
	}

	func previousRiskLevel_Success() {
		XCTAssertNil(store.previousRisk)
		let riskLevel = EitherLowOrIncreasedRiskLevel(rawValue: 7)

		store.previousRiskLevel = riskLevel
		XCTAssertEqual(store.previousRiskLevel, riskLevel)
	}
}
