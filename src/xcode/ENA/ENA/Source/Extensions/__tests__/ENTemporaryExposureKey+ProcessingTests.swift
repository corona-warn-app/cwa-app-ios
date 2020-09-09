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
import ExposureNotification
import XCTest

final class ExposureKeysProcessingTests: XCTestCase {

	func testMaxKeyCount_IsExpectedValue() {
		XCTAssertEqual([ENTemporaryExposureKey]().maxKeyCount, 14)
	}

	func testSubmissionPreprocess_VerifySort() {
		var keys: [ENTemporaryExposureKey] = [
			TemporaryExposureKeyMock(rollingStartNumber: 4),
			TemporaryExposureKeyMock(rollingStartNumber: 7),
			TemporaryExposureKeyMock(rollingStartNumber: 2),
			TemporaryExposureKeyMock(rollingStartNumber: 7)
		]
		keys.process(for: .noInformation)
		let rollingStartNumbers = keys.map { $0.rollingStartNumber }
		XCTAssertEqual(rollingStartNumbers.count, 4)
		XCTAssertEqual(rollingStartNumbers[0], 7, "Key sorting incorrect! Got \(rollingStartNumbers[0]), expected 7")
		XCTAssertEqual(rollingStartNumbers[1], 7, "Key sorting incorrect! Got \(rollingStartNumbers[1]), expected 7")
		XCTAssertEqual(rollingStartNumbers[2], 4, "Key sorting incorrect! Got \(rollingStartNumbers[2]), expected 4")
		XCTAssertEqual(rollingStartNumbers[3], 2, "Key sorting incorrect! Got \(rollingStartNumbers[3]), expected 2")
	}

	func testSubmissionPreprocess_TrimKeys() {
		var keys = makeMockKeys(count: 22)
		let copy = keys.sorted { $0.rollingStartNumber > $1.rollingStartNumber }
		keys.process(for: .noInformation)

		XCTAssertEqual(keys.count, keys.maxKeyCount)
		XCTAssertEqual(keys, Array(copy.prefix(keys.maxKeyCount)))
	}

	func testSubmissionPreprocess_NoKeys() {
		var keys = makeMockKeys(count: 0)
		keys.process(for: .noInformation)

		XCTAssertEqual(keys.count, 0)
	}

	func testSubmissionPreprocess_FewKeys() {
		var keys = makeMockKeys(count: 2)
		let copy = keys.sorted { $0.rollingStartNumber > $1.rollingStartNumber }
		keys.process(for: .noInformation)

		XCTAssertEqual(keys.count, 2)
		XCTAssertEqual(keys, Array(copy.prefix(keys.maxKeyCount)))
	}

	func testSubmissionPreprocess_ApplyVector_FewKeys() {
		let symptomsOnset: SymptomsOnset = .noInformation
		let transmissionRiskVector = symptomsOnset.transmissionRiskVector

		var keys = makeMockKeys(count: 2)
		keys.process(for: symptomsOnset)

		XCTAssertEqual(keys.count, 2)
		XCTAssertEqual(keys[0].transmissionRiskLevel, transmissionRiskVector[1])
		XCTAssertEqual(keys[1].transmissionRiskLevel, transmissionRiskVector[2])
	}

	func testSubmissionPreprocess_ApplyNoInformationVector() {
		let symptomsOnset: SymptomsOnset = .noInformation
		let transmissionRiskVector = symptomsOnset.transmissionRiskVector

		var keys = makeMockKeys(count: 30)
		keys.process(for: symptomsOnset)

		for (key, vectorElement) in zip(keys, transmissionRiskVector.dropFirst()) {
			XCTAssertEqual(
				key.transmissionRiskLevel,
				vectorElement,
				"Transmission Risk Level vector not applied correctly! Expected \(vectorElement), got \(key.transmissionRiskLevel)"
			)
		}
	}

	func testSubmissionPreprocess_ApplyNonSymptomaticVector() {
		let symptomsOnset: SymptomsOnset = .nonSymptomatic
		let transmissionRiskVector = symptomsOnset.transmissionRiskVector

		var keys = makeMockKeys(count: 30)
		keys.process(for: symptomsOnset)

		for (key, vectorElement) in zip(keys, transmissionRiskVector.dropFirst()) {
			XCTAssertEqual(
				key.transmissionRiskLevel,
				vectorElement,
				"Transmission Risk Level vector not applied correctly! Expected \(vectorElement), got \(key.transmissionRiskLevel)"
			)
		}
	}

	func testSubmissionPreprocess_ApplySymptomaticWithUnknownOnsetDaysVector() {
		let symptomsOnset: SymptomsOnset = .symptomaticWithUnknownOnset
		let transmissionRiskVector = symptomsOnset.transmissionRiskVector

		var keys = makeMockKeys(count: 30)
		keys.process(for: symptomsOnset)

		for (key, vectorElement) in zip(keys, transmissionRiskVector.dropFirst()) {
			XCTAssertEqual(
				key.transmissionRiskLevel,
				vectorElement,
				"Transmission Risk Level vector not applied correctly! Expected \(vectorElement), got \(key.transmissionRiskLevel)"
			)
		}
	}

	func testSubmissionPreprocess_ApplyLastSevenDaysVector() {
		let symptomsOnset: SymptomsOnset = .lastSevenDays
		let transmissionRiskVector = symptomsOnset.transmissionRiskVector

		var keys = makeMockKeys(count: 30)
		keys.process(for: symptomsOnset)

		for (key, vectorElement) in zip(keys, transmissionRiskVector.dropFirst()) {
			XCTAssertEqual(
				key.transmissionRiskLevel,
				vectorElement,
				"Transmission Risk Level vector not applied correctly! Expected \(vectorElement), got \(key.transmissionRiskLevel)"
			)
		}
	}

	func testSubmissionPreprocess_ApplyOneToTwoWeeksAgoVector() {
		let symptomsOnset: SymptomsOnset = .oneToTwoWeeksAgo
		let transmissionRiskVector = symptomsOnset.transmissionRiskVector

		var keys = makeMockKeys(count: 30)
		keys.process(for: symptomsOnset)

		for (key, vectorElement) in zip(keys, transmissionRiskVector.dropFirst()) {
			XCTAssertEqual(
				key.transmissionRiskLevel,
				vectorElement,
				"Transmission Risk Level vector not applied correctly! Expected \(vectorElement), got \(key.transmissionRiskLevel)"
			)
		}
	}

	func testSubmissionPreprocess_ApplyMoreThanTwoWeeksAgoVector() {
		let symptomsOnset: SymptomsOnset = .moreThanTwoWeeksAgo
		let transmissionRiskVector = symptomsOnset.transmissionRiskVector

		var keys = makeMockKeys(count: 30)
		keys.process(for: symptomsOnset)

		for (key, vectorElement) in zip(keys, transmissionRiskVector.dropFirst()) {
			XCTAssertEqual(
				key.transmissionRiskLevel,
				vectorElement,
				"Transmission Risk Level vector not applied correctly! Expected \(vectorElement), got \(key.transmissionRiskLevel)"
			)
		}
	}

	func testSubmissionPreprocess_ApplyDaysSinceOnsetVector() {
		for daysSinceOnset in 0..<22 {
			let symptomsOnset: SymptomsOnset = .daysSinceOnset(daysSinceOnset)
			let transmissionRiskVector = symptomsOnset.transmissionRiskVector

			var keys = makeMockKeys(count: 30)
			keys.process(for: symptomsOnset)

			for (key, vectorElement) in zip(keys, transmissionRiskVector.dropFirst()) {
				XCTAssertEqual(
					key.transmissionRiskLevel,
					vectorElement,
					"Transmission Risk Level vector not applied correctly! Expected \(vectorElement), got \(key.transmissionRiskLevel)"
				)
			}
		}
	}

}

// MARK: - Helpers

extension ExposureKeysProcessingTests {
	/// Make an ENTemporaryExposureKey with random values
	private func makeMockKeys(count: Int) -> [ENTemporaryExposureKey] {
		(0..<count).map { _ in
			TemporaryExposureKeyMock(rollingStartNumber: ENIntervalNumber.random())
		}
	}
}

private extension ENIntervalNumber {
	static func random() -> ENIntervalNumber {
		ENIntervalNumber.random(in: ENIntervalNumber.min...ENIntervalNumber.max)
	}
}
