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

	func testLastSuccessfulSubmitDiagnosisKeyTimestamp_Success() {
		XCTAssertNil(store.lastSuccessfulSubmitDiagnosisKeyTimestamp)
		store.lastSuccessfulSubmitDiagnosisKeyTimestamp = Int64.max
		XCTAssertEqual(store.lastSuccessfulSubmitDiagnosisKeyTimestamp, Int64.max)
		store.lastSuccessfulSubmitDiagnosisKeyTimestamp = Int64.min
		XCTAssertEqual(store.lastSuccessfulSubmitDiagnosisKeyTimestamp, Int64.min)
	}

	func testNumberOfSuccesfulSubmissions_Success() {
		XCTAssertEqual(store.numberOfSuccesfulSubmissions, 0)
		store.numberOfSuccesfulSubmissions = Int64.max
		XCTAssertEqual(store.numberOfSuccesfulSubmissions, Int64.max)
		store.numberOfSuccesfulSubmissions = Int64.min
		XCTAssertEqual(store.numberOfSuccesfulSubmissions, Int64.min)
	}

	func testInitialSubmitCompleted_Success() {
		XCTAssertEqual(store.initialSubmitCompleted, false)
		store.initialSubmitCompleted = true
		XCTAssertEqual(store.initialSubmitCompleted, true)
		store.initialSubmitCompleted = false
		XCTAssertEqual(store.initialSubmitCompleted, false)
	}

	func testRegistrationToken_Success() {
		XCTAssertNil(store.registrationToken)

		let token = UUID().description
		store.registrationToken = token
		XCTAssertEqual(store.registrationToken, token)
	}

	func testTracingStatusHistory_Success() {
		XCTAssertTrue(store.tracingStatusHistory.isEmpty)
		let date1 = Date(timeIntervalSinceNow: -86400)
		let date2 = Date()
		let entry1 = TracingStatusEntry(on: true, date: date1)
		let entry2 = TracingStatusEntry(on: false, date: date2)

		store.tracingStatusHistory.append(entry1)
		store.tracingStatusHistory.append(entry2)

		XCTAssertEqual(store.tracingStatusHistory.count, 2)
		XCTAssertEqual(store.tracingStatusHistory[0].on, true)
		XCTAssertEqual(store.tracingStatusHistory[0].date.description, date1.description)
		XCTAssertEqual(store.tracingStatusHistory[1].on, false)
		XCTAssertEqual(store.tracingStatusHistory[1].date.description, date2.description)

		store.flush()
		XCTAssertTrue(store.tracingStatusHistory.isEmpty)
	}

	func testSummary_Success() {
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

	func testPreviousRiskLevel_Success() {
		XCTAssertNil(store.previousRiskLevel)

		store.previousRiskLevel = .low
		XCTAssertEqual(store.previousRiskLevel, .low)
	}

	func testPrepareContainer() {
		let fileManager = FileManager.default
		// swiftlint:disable:next force_try
		let directoryURL = try! fileManager
			.url(for: .applicationSupportDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
			.appendingPathComponent("tempDatabase")
		print(directoryURL)
		let tmpStore = SecureStore(at: directoryURL, key: "12345678")

		// Prepare data
		let testTimeStamp: Int64 = 1466467200
		let testDate1 = Date(timeIntervalSince1970: Double(testTimeStamp))  // 21.06.2016
		let testDate2 = Date(timeIntervalSince1970: Double(testTimeStamp) - 86400)

		let testSummary = CodableExposureDetectionSummary(
			daysSinceLastExposure: 13,
			matchedKeyCount: UInt64.max,
			maximumRiskScore: 5,
			attenuationDurations: [0.1, 7.42, 13.0],
			maximumRiskScoreFullRange: 7
		)

		let entry1 = TracingStatusEntry(on: true, date: testDate1)
		let entry2 = TracingStatusEntry(on: false, date: testDate2)
		tmpStore.tracingStatusHistory.append(entry1)
		tmpStore.tracingStatusHistory.append(entry2)

		tmpStore.isOnboarded = true
		tmpStore.dateOfAcceptedPrivacyNotice = testDate1
		tmpStore.teleTan = "97RR2D5644"
		tmpStore.hourlyFetchingEnabled = false
		tmpStore.tan = "97RR2D5644"
		tmpStore.testGUID = "00000000-0000-4000-8000-000000000000"
		tmpStore.devicePairingConsentAccept = true
		tmpStore.devicePairingConsentAcceptTimestamp = testTimeStamp
		tmpStore.devicePairingSuccessfulTimestamp = testTimeStamp
		tmpStore.isAllowedToSubmitDiagnosisKeys = true
		tmpStore.allowRiskChangesNotification = true
		tmpStore.allowTestsStatusNotification = true
		tmpStore.summary = SummaryMetadata(summary: testSummary, date: testDate1)
		tmpStore.registrationToken = ""
		tmpStore.hasSeenSubmissionExposureTutorial = true
		tmpStore.testResultReceivedTimeStamp = testTimeStamp
		tmpStore.lastSuccessfulSubmitDiagnosisKeyTimestamp = testTimeStamp
		tmpStore.numberOfSuccesfulSubmissions = 1
		tmpStore.initialSubmitCompleted = true
		tmpStore.exposureActivationConsentAcceptTimestamp = testTimeStamp
		tmpStore.exposureActivationConsentAccept = true
		tmpStore.previousRiskLevel = .increased

	}
}
