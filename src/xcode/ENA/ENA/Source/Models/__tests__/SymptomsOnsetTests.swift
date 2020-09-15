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

final class SymptomsOnsetTests: XCTestCase {

	func testNoInformationTransmissionRiskVector_IsExpectedValue() {
		let vector: [ENRiskLevel] = [5, 6, 7, 7, 7, 6, 4, 3, 2, 1, 1, 1, 1, 1, 1]

		XCTAssertEqual(SymptomsOnset.noInformation.transmissionRiskVector, vector)
	}

	func testNonSymptomaticTransmissionRiskVector_IsExpectedValue() {
		let vector: [ENRiskLevel] = [4, 4, 3, 2, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1]

		XCTAssertEqual(SymptomsOnset.nonSymptomatic.transmissionRiskVector, vector)
	}

	func testSymptomaticWithUnknownOnsetTransmissionRiskVector_IsExpectedValue() {
		let vector: [ENRiskLevel] = [5, 6, 8, 8, 8, 7, 5, 3, 2, 1, 1, 1, 1, 1, 1]

		XCTAssertEqual(SymptomsOnset.symptomaticWithUnknownOnset.transmissionRiskVector, vector)
	}

	func testLastSevenDaysTransmissionRiskVector_IsExpectedValue() {
		let vector: [ENRiskLevel] = [4, 5, 6, 7, 7, 7, 6, 5, 4, 3, 2, 1, 1, 1, 1]

		XCTAssertEqual(SymptomsOnset.lastSevenDays.transmissionRiskVector, vector)
	}

	func testOneToTwoWeeksAgoTransmissionRiskVector_IsExpectedValue() {
		let vector: [ENRiskLevel] = [1, 1, 1, 1, 2, 3, 4, 5, 6, 6, 7, 7, 6, 6, 4]

		XCTAssertEqual(SymptomsOnset.oneToTwoWeeksAgo.transmissionRiskVector, vector)
	}

	func testMoreThanTwoWeeksAgoTransmissionRiskVector_IsExpectedValue() {
		let vector: [ENRiskLevel] = [1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 2, 3, 4, 5]

		XCTAssertEqual(SymptomsOnset.moreThanTwoWeeksAgo.transmissionRiskVector, vector)
	}

	func test0DaysSinceOnsetTransmissionRiskVector_IsExpectedValue() {
		let vector: [ENRiskLevel] = [8, 8, 7, 6, 4, 2, 1, 1, 1, 1, 1, 1, 1, 1, 1]

		XCTAssertEqual(SymptomsOnset.daysSinceOnset(0).transmissionRiskVector, vector)
	}

	func test1DaySinceOnsetTransmissionRiskVector_IsExpectedValue() {
		let vector: [ENRiskLevel] = [8, 8, 8, 7, 6, 4, 2, 1, 1, 1, 1, 1, 1, 1, 1]

		XCTAssertEqual(SymptomsOnset.daysSinceOnset(1).transmissionRiskVector, vector)
	}

	func test2DaysSinceOnsetTransmissionRiskVector_IsExpectedValue() {
		let vector: [ENRiskLevel] = [6, 8, 8, 8, 7, 6, 4, 2, 1, 1, 1, 1, 1, 1, 1]

		XCTAssertEqual(SymptomsOnset.daysSinceOnset(2).transmissionRiskVector, vector)
	}

	func test3DaysSinceOnsetTransmissionRiskVector_IsExpectedValue() {
		let vector: [ENRiskLevel] = [5, 6, 8, 8, 8, 7, 6, 4, 2, 1, 1, 1, 1, 1, 1]

		XCTAssertEqual(SymptomsOnset.daysSinceOnset(3).transmissionRiskVector, vector)
	}

	func test4DaysSinceOnsetTransmissionRiskVector_IsExpectedValue() {
		let vector: [ENRiskLevel] = [3, 5, 6, 8, 8, 8, 7, 6, 4, 2, 1, 1, 1, 1, 1]

		XCTAssertEqual(SymptomsOnset.daysSinceOnset(4).transmissionRiskVector, vector)
	}

	func test5DaysSinceOnsetTransmissionRiskVector_IsExpectedValue() {
		let vector: [ENRiskLevel] = [2, 3, 5, 6, 8, 8, 8, 7, 6, 4, 2, 1, 1, 1, 1]

		XCTAssertEqual(SymptomsOnset.daysSinceOnset(5).transmissionRiskVector, vector)
	}

	func test6DaysSinceOnsetTransmissionRiskVector_IsExpectedValue() {
		let vector: [ENRiskLevel] = [2, 2, 3, 5, 6, 8, 8, 8, 7, 6, 4, 2, 1, 1, 1]

		XCTAssertEqual(SymptomsOnset.daysSinceOnset(6).transmissionRiskVector, vector)
	}

	func test7DaysSinceOnsetTransmissionRiskVector_IsExpectedValue() {
		let vector: [ENRiskLevel] = [1, 2, 2, 3, 5, 6, 8, 8, 8, 7, 6, 4, 2, 1, 1]

		XCTAssertEqual(SymptomsOnset.daysSinceOnset(7).transmissionRiskVector, vector)
	}

	func test8DaysSinceOnsetTransmissionRiskVector_IsExpectedValue() {
		let vector: [ENRiskLevel] = [1, 1, 2, 2, 3, 5, 6, 8, 8, 8, 7, 6, 4, 2, 1]

		XCTAssertEqual(SymptomsOnset.daysSinceOnset(8).transmissionRiskVector, vector)
	}

	func test9DaysSinceOnsetTransmissionRiskVector_IsExpectedValue() {
		let vector: [ENRiskLevel] = [1, 1, 1, 2, 2, 3, 5, 6, 8, 8, 8, 7, 6, 4, 2]

		XCTAssertEqual(SymptomsOnset.daysSinceOnset(9).transmissionRiskVector, vector)
	}

	func test10DaysSinceOnsetTransmissionRiskVector_IsExpectedValue() {
		let vector: [ENRiskLevel] = [1, 1, 1, 1, 2, 2, 3, 5, 6, 8, 8, 8, 7, 6, 4]

		XCTAssertEqual(SymptomsOnset.daysSinceOnset(10).transmissionRiskVector, vector)
	}

	func test11DaysSinceOnsetTransmissionRiskVector_IsExpectedValue() {
		let vector: [ENRiskLevel] = [1, 1, 1, 1, 1, 2, 2, 3, 5, 6, 8, 8, 8, 7, 6]

		XCTAssertEqual(SymptomsOnset.daysSinceOnset(11).transmissionRiskVector, vector)
	}

	func test12DaysSinceOnsetTransmissionRiskVector_IsExpectedValue() {
		let vector: [ENRiskLevel] = [1, 1, 1, 1, 1, 1, 2, 2, 3, 5, 6, 8, 8, 8, 7]

		XCTAssertEqual(SymptomsOnset.daysSinceOnset(12).transmissionRiskVector, vector)
	}

	func test13DaysSinceOnsetTransmissionRiskVector_IsExpectedValue() {
		let vector: [ENRiskLevel] = [1, 1, 1, 1, 1, 1, 1, 2, 2, 3, 5, 6, 8, 8, 8]

		XCTAssertEqual(SymptomsOnset.daysSinceOnset(13).transmissionRiskVector, vector)
	}

	func test14DaysSinceOnsetTransmissionRiskVector_IsExpectedValue() {
		let vector: [ENRiskLevel] = [1, 1, 1, 1, 1, 1, 1, 1, 2, 2, 3, 5, 6, 8, 8]

		XCTAssertEqual(SymptomsOnset.daysSinceOnset(14).transmissionRiskVector, vector)
	}

	func test15DaysSinceOnsetTransmissionRiskVector_IsExpectedValue() {
		let vector: [ENRiskLevel] = [1, 1, 1, 1, 1, 1, 1, 1, 1, 2, 2, 3, 5, 6, 8]

		XCTAssertEqual(SymptomsOnset.daysSinceOnset(15).transmissionRiskVector, vector)
	}

	func test16DaysSinceOnsetTransmissionRiskVector_IsExpectedValue() {
		let vector: [ENRiskLevel] = [1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 2, 2, 3, 5, 6]

		XCTAssertEqual(SymptomsOnset.daysSinceOnset(16).transmissionRiskVector, vector)
	}

	func test17DaysSinceOnsetTransmissionRiskVector_IsExpectedValue() {
		let vector: [ENRiskLevel] = [1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 2, 2, 3, 5]

		XCTAssertEqual(SymptomsOnset.daysSinceOnset(17).transmissionRiskVector, vector)
	}

	func test18DaysSinceOnsetTransmissionRiskVector_IsExpectedValue() {
		let vector: [ENRiskLevel] = [1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 2, 2, 3]

		XCTAssertEqual(SymptomsOnset.daysSinceOnset(18).transmissionRiskVector, vector)
	}

	func test19DaysSinceOnsetTransmissionRiskVector_IsExpectedValue() {
		let vector: [ENRiskLevel] = [1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 2, 2]

		XCTAssertEqual(SymptomsOnset.daysSinceOnset(19).transmissionRiskVector, vector)
	}

	func test20DaysSinceOnsetTransmissionRiskVector_IsExpectedValue() {
		let vector: [ENRiskLevel] = [1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 2]

		XCTAssertEqual(SymptomsOnset.daysSinceOnset(20).transmissionRiskVector, vector)
	}

	func test21DaysSinceOnsetTransmissionRiskVector_IsExpectedValue() {
		let vector: [ENRiskLevel] = [1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1]

		XCTAssertEqual(SymptomsOnset.daysSinceOnset(21).transmissionRiskVector, vector)
	}

}
