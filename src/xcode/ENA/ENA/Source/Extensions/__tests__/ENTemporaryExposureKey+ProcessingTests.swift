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

	func testSubmissionPreprocess_NoKeys() {
		var keys = makeMockKeys(count: 0)
		keys = keys.processedForSubmission(with: .noInformation)

		XCTAssertEqual(keys.count, 0)
	}

	func testSubmissionPreprocess_FewKeys() {
		var keys = makeMockKeys(count: 2)
		keys = keys.processedForSubmission(with: .noInformation)

		XCTAssertEqual(keys.count, 2)
	}

	func testSubmissionPreprocess_ApplyNoInformationVector() {
		let symptomsOnset: SymptomsOnset = .noInformation
		let transmissionRiskVector = symptomsOnset.transmissionRiskVector

		var keys = [
			makeMockKey(daysUntilToday: 0),
			makeMockKey(daysUntilToday: 1),
			makeMockKey(daysUntilToday: 2),
			makeMockKey(daysUntilToday: 3),
			makeMockKey(daysUntilToday: 4),
			makeMockKey(daysUntilToday: 5),
			makeMockKey(daysUntilToday: 6),
			makeMockKey(daysUntilToday: 7),
			makeMockKey(daysUntilToday: 8),
			makeMockKey(daysUntilToday: 9),
			makeMockKey(daysUntilToday: 10),
			makeMockKey(daysUntilToday: 11),
			makeMockKey(daysUntilToday: 12),
			makeMockKey(daysUntilToday: 13),
			makeMockKey(daysUntilToday: 14)
		]
		keys = keys.processedForSubmission(with: symptomsOnset, today: Date(timeIntervalSinceReferenceDate: 0))

		keys.sort { $0.rollingStartNumber > $1.rollingStartNumber }

		for (key, vectorElement) in zip(keys, transmissionRiskVector) {
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

		var keys = [
			makeMockKey(daysUntilToday: 0),
			makeMockKey(daysUntilToday: 1),
			makeMockKey(daysUntilToday: 2),
			makeMockKey(daysUntilToday: 3),
			makeMockKey(daysUntilToday: 4),
			makeMockKey(daysUntilToday: 5),
			makeMockKey(daysUntilToday: 6),
			makeMockKey(daysUntilToday: 7),
			makeMockKey(daysUntilToday: 8),
			makeMockKey(daysUntilToday: 9),
			makeMockKey(daysUntilToday: 10),
			makeMockKey(daysUntilToday: 11),
			makeMockKey(daysUntilToday: 12),
			makeMockKey(daysUntilToday: 13),
			makeMockKey(daysUntilToday: 14)
		]
		keys = keys.processedForSubmission(with: symptomsOnset, today: Date(timeIntervalSinceReferenceDate: 0))

		keys.sort { $0.rollingStartNumber > $1.rollingStartNumber }

		for (key, vectorElement) in zip(keys, transmissionRiskVector) {
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

		var keys = [
			makeMockKey(daysUntilToday: 0),
			makeMockKey(daysUntilToday: 1),
			makeMockKey(daysUntilToday: 2),
			makeMockKey(daysUntilToday: 3),
			makeMockKey(daysUntilToday: 4),
			makeMockKey(daysUntilToday: 5),
			makeMockKey(daysUntilToday: 6),
			makeMockKey(daysUntilToday: 7),
			makeMockKey(daysUntilToday: 8),
			makeMockKey(daysUntilToday: 9),
			makeMockKey(daysUntilToday: 10),
			makeMockKey(daysUntilToday: 11),
			makeMockKey(daysUntilToday: 12),
			makeMockKey(daysUntilToday: 13),
			makeMockKey(daysUntilToday: 14)
		]
		keys = keys.processedForSubmission(with: symptomsOnset, today: Date(timeIntervalSinceReferenceDate: 0))

		keys.sort { $0.rollingStartNumber > $1.rollingStartNumber }

		for (key, vectorElement) in zip(keys, transmissionRiskVector) {
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

		var keys = [
			makeMockKey(daysUntilToday: 0),
			makeMockKey(daysUntilToday: 1),
			makeMockKey(daysUntilToday: 2),
			makeMockKey(daysUntilToday: 3),
			makeMockKey(daysUntilToday: 4),
			makeMockKey(daysUntilToday: 5),
			makeMockKey(daysUntilToday: 6),
			makeMockKey(daysUntilToday: 7),
			makeMockKey(daysUntilToday: 8),
			makeMockKey(daysUntilToday: 9),
			makeMockKey(daysUntilToday: 10),
			makeMockKey(daysUntilToday: 11),
			makeMockKey(daysUntilToday: 12),
			makeMockKey(daysUntilToday: 13),
			makeMockKey(daysUntilToday: 14)
		]
		keys = keys.processedForSubmission(with: symptomsOnset, today: Date(timeIntervalSinceReferenceDate: 0))

		keys.sort { $0.rollingStartNumber > $1.rollingStartNumber }

		for (key, vectorElement) in zip(keys, transmissionRiskVector) {
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

		var keys = [
			makeMockKey(daysUntilToday: 0),
			makeMockKey(daysUntilToday: 1),
			makeMockKey(daysUntilToday: 2),
			makeMockKey(daysUntilToday: 3),
			makeMockKey(daysUntilToday: 4),
			makeMockKey(daysUntilToday: 5),
			makeMockKey(daysUntilToday: 6),
			makeMockKey(daysUntilToday: 7),
			makeMockKey(daysUntilToday: 8),
			makeMockKey(daysUntilToday: 9),
			makeMockKey(daysUntilToday: 10),
			makeMockKey(daysUntilToday: 11),
			makeMockKey(daysUntilToday: 12),
			makeMockKey(daysUntilToday: 13),
			makeMockKey(daysUntilToday: 14)
		]
		keys = keys.processedForSubmission(with: symptomsOnset, today: Date(timeIntervalSinceReferenceDate: 0))

		keys.sort { $0.rollingStartNumber > $1.rollingStartNumber }

		for (key, vectorElement) in zip(keys, transmissionRiskVector) {
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

		var keys = [
			makeMockKey(daysUntilToday: 0),
			makeMockKey(daysUntilToday: 1),
			makeMockKey(daysUntilToday: 2),
			makeMockKey(daysUntilToday: 3),
			makeMockKey(daysUntilToday: 4),
			makeMockKey(daysUntilToday: 5),
			makeMockKey(daysUntilToday: 6),
			makeMockKey(daysUntilToday: 7),
			makeMockKey(daysUntilToday: 8),
			makeMockKey(daysUntilToday: 9),
			makeMockKey(daysUntilToday: 10),
			makeMockKey(daysUntilToday: 11),
			makeMockKey(daysUntilToday: 12),
			makeMockKey(daysUntilToday: 13),
			makeMockKey(daysUntilToday: 14)
		]
		keys = keys.processedForSubmission(with: symptomsOnset, today: Date(timeIntervalSinceReferenceDate: 0))

		keys.sort { $0.rollingStartNumber > $1.rollingStartNumber }

		for (key, vectorElement) in zip(keys, transmissionRiskVector) {
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

			var keys = [
				makeMockKey(daysUntilToday: 0),
				makeMockKey(daysUntilToday: 1),
				makeMockKey(daysUntilToday: 2),
				makeMockKey(daysUntilToday: 3),
				makeMockKey(daysUntilToday: 4),
				makeMockKey(daysUntilToday: 5),
				makeMockKey(daysUntilToday: 6),
				makeMockKey(daysUntilToday: 7),
				makeMockKey(daysUntilToday: 8),
				makeMockKey(daysUntilToday: 9),
				makeMockKey(daysUntilToday: 10),
				makeMockKey(daysUntilToday: 11),
				makeMockKey(daysUntilToday: 12),
				makeMockKey(daysUntilToday: 13),
				makeMockKey(daysUntilToday: 14)
			]
			keys = keys.processedForSubmission(with: symptomsOnset, today: Date(timeIntervalSinceReferenceDate: 0))

			keys.sort { $0.rollingStartNumber > $1.rollingStartNumber }

			for (key, vectorElement) in zip(keys, transmissionRiskVector) {
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
		(0..<count).map {
			TemporaryExposureKeyMock(rollingStartNumber: ENIntervalNumber($0 * 144))
		}
	}

	private func makeMockKey(daysUntilToday: Int, today: Date = Date(timeIntervalSinceReferenceDate: 0)) -> ENTemporaryExposureKey {
		var calendar = Calendar(identifier: .gregorian)
		// swiftlint:disable:next force_unwrapping
		calendar.timeZone = TimeZone(secondsFromGMT: 0)!

		guard let date = calendar.date(byAdding: .day, value: -daysUntilToday, to: today) else { fatalError("Could not create date") }

		return TemporaryExposureKeyMock(rollingStartNumber: ENIntervalNumber(date.timeIntervalSince1970 / 600))
	}
}

private extension ENIntervalNumber {
	static func random() -> ENIntervalNumber {
		ENIntervalNumber.random(in: ENIntervalNumber.min...ENIntervalNumber.max)
	}
}
