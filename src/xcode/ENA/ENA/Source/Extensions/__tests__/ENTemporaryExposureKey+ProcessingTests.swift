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

	func testTransmissionRiskDefaultVector_IsExpectedValue() {
		let vector: [ENRiskLevel] = [5, 6, 8, 8, 8, 5, 3, 1, 1, 1, 1, 1, 1, 1, 1]

		XCTAssertEqual([ENTemporaryExposureKey]().transmissionRiskDefaultVector, vector)
	}

	func testSubmissionPreprocess_VerifySort() {
		var keys: [ENTemporaryExposureKey] = [
			TemporaryExposureKeyMock(rollingStartNumber: 4),
			TemporaryExposureKeyMock(rollingStartNumber: 7),
			TemporaryExposureKeyMock(rollingStartNumber: 2)
		]
		keys.processedForSubmission()
		let rollingStartNumbers = keys.map { $0.rollingStartNumber }
		XCTAssertTrue(rollingStartNumbers.isSorted(>), "The keys were not sorted!")
	}

	func testSubmissionPreprocess_TrimKeys() {
		var keys = makeMockKeys(count: 22)
		let copy = keys.sorted { $0.rollingStartNumber > $1.rollingStartNumber }
		keys.processedForSubmission()

		XCTAssertEqual(keys.count, keys.maxKeyCount)
		XCTAssertEqual(keys, Array(copy.prefix(keys.maxKeyCount)))
	}

	func testSubmissionPreprocess_ApplyVector() {
		var keys = makeMockKeys(count: 30)
		keys.processedForSubmission()

		for (key, vectorElement) in zip(keys, keys.transmissionRiskDefaultVector.dropFirst()) {
			XCTAssertEqual(
				key.transmissionRiskLevel,
				vectorElement,
				"Transmission Risk Level vector not applied correctly! Expected \(vectorElement), got \(key.transmissionRiskLevel)"
			)
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

private extension Array where Element: Comparable {
	func isSorted(_ comparator: (Element, Element) -> Bool) -> Bool {
		var iterator = makeIterator()
		guard var previous = iterator.next() else { return true }
		while let current = iterator.next() {
			guard comparator(previous, current) else {
				return false
			}

			previous = current
		}
		return true
	}
}
