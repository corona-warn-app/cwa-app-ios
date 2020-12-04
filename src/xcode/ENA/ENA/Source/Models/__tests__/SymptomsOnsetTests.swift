//
// 🦠 Corona-Warn-App
//

@testable import ENA
import Foundation
import ExposureNotification
import XCTest

final class SymptomsOnsetTests: XCTestCase {

	// MARK: - Transmission Risk Vector

	func testNoInformationTransmissionRiskVector_IsExpectedValue() {
		let vector: [Int32] = [5, 6, 7, 7, 7, 6, 4, 3, 2, 1, 1, 1, 1, 1, 1]

		XCTAssertEqual(SymptomsOnset.noInformation.transmissionRiskVector, vector)
	}

	func testNonSymptomaticTransmissionRiskVector_IsExpectedValue() {
		let vector: [Int32] = [4, 4, 3, 2, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1]

		XCTAssertEqual(SymptomsOnset.nonSymptomatic.transmissionRiskVector, vector)
	}

	func testSymptomaticWithUnknownOnsetTransmissionRiskVector_IsExpectedValue() {
		let vector: [Int32] = [5, 6, 8, 8, 8, 7, 5, 3, 2, 1, 1, 1, 1, 1, 1]

		XCTAssertEqual(SymptomsOnset.symptomaticWithUnknownOnset.transmissionRiskVector, vector)
	}

	func testLastSevenDaysTransmissionRiskVector_IsExpectedValue() {
		let vector: [Int32] = [4, 5, 6, 7, 7, 7, 6, 5, 4, 3, 2, 1, 1, 1, 1]

		XCTAssertEqual(SymptomsOnset.lastSevenDays.transmissionRiskVector, vector)
	}

	func testOneToTwoWeeksAgoTransmissionRiskVector_IsExpectedValue() {
		let vector: [Int32] = [1, 1, 1, 1, 2, 3, 4, 5, 6, 6, 7, 7, 6, 6, 4]

		XCTAssertEqual(SymptomsOnset.oneToTwoWeeksAgo.transmissionRiskVector, vector)
	}

	func testMoreThanTwoWeeksAgoTransmissionRiskVector_IsExpectedValue() {
		let vector: [Int32] = [1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 2, 3, 4, 5]

		XCTAssertEqual(SymptomsOnset.moreThanTwoWeeksAgo.transmissionRiskVector, vector)
	}

	func test0DaysSinceOnsetTransmissionRiskVector_IsExpectedValue() {
		let vector: [Int32] = [8, 8, 7, 6, 4, 2, 1, 1, 1, 1, 1, 1, 1, 1, 1]

		XCTAssertEqual(SymptomsOnset.daysSinceOnset(0).transmissionRiskVector, vector)
	}

	func test1DaySinceOnsetTransmissionRiskVector_IsExpectedValue() {
		let vector: [Int32] = [8, 8, 8, 7, 6, 4, 2, 1, 1, 1, 1, 1, 1, 1, 1]

		XCTAssertEqual(SymptomsOnset.daysSinceOnset(1).transmissionRiskVector, vector)
	}

	func test2DaysSinceOnsetTransmissionRiskVector_IsExpectedValue() {
		let vector: [Int32] = [6, 8, 8, 8, 7, 6, 4, 2, 1, 1, 1, 1, 1, 1, 1]

		XCTAssertEqual(SymptomsOnset.daysSinceOnset(2).transmissionRiskVector, vector)
	}

	func test3DaysSinceOnsetTransmissionRiskVector_IsExpectedValue() {
		let vector: [Int32] = [5, 6, 8, 8, 8, 7, 6, 4, 2, 1, 1, 1, 1, 1, 1]

		XCTAssertEqual(SymptomsOnset.daysSinceOnset(3).transmissionRiskVector, vector)
	}

	func test4DaysSinceOnsetTransmissionRiskVector_IsExpectedValue() {
		let vector: [Int32] = [3, 5, 6, 8, 8, 8, 7, 6, 4, 2, 1, 1, 1, 1, 1]

		XCTAssertEqual(SymptomsOnset.daysSinceOnset(4).transmissionRiskVector, vector)
	}

	func test5DaysSinceOnsetTransmissionRiskVector_IsExpectedValue() {
		let vector: [Int32] = [2, 3, 5, 6, 8, 8, 8, 7, 6, 4, 2, 1, 1, 1, 1]

		XCTAssertEqual(SymptomsOnset.daysSinceOnset(5).transmissionRiskVector, vector)
	}

	func test6DaysSinceOnsetTransmissionRiskVector_IsExpectedValue() {
		let vector: [Int32] = [2, 2, 3, 5, 6, 8, 8, 8, 7, 6, 4, 2, 1, 1, 1]

		XCTAssertEqual(SymptomsOnset.daysSinceOnset(6).transmissionRiskVector, vector)
	}

	func test7DaysSinceOnsetTransmissionRiskVector_IsExpectedValue() {
		let vector: [Int32] = [1, 2, 2, 3, 5, 6, 8, 8, 8, 7, 6, 4, 2, 1, 1]

		XCTAssertEqual(SymptomsOnset.daysSinceOnset(7).transmissionRiskVector, vector)
	}

	func test8DaysSinceOnsetTransmissionRiskVector_IsExpectedValue() {
		let vector: [Int32] = [1, 1, 2, 2, 3, 5, 6, 8, 8, 8, 7, 6, 4, 2, 1]

		XCTAssertEqual(SymptomsOnset.daysSinceOnset(8).transmissionRiskVector, vector)
	}

	func test9DaysSinceOnsetTransmissionRiskVector_IsExpectedValue() {
		let vector: [Int32] = [1, 1, 1, 2, 2, 3, 5, 6, 8, 8, 8, 7, 6, 4, 2]

		XCTAssertEqual(SymptomsOnset.daysSinceOnset(9).transmissionRiskVector, vector)
	}

	func test10DaysSinceOnsetTransmissionRiskVector_IsExpectedValue() {
		let vector: [Int32] = [1, 1, 1, 1, 2, 2, 3, 5, 6, 8, 8, 8, 7, 6, 4]

		XCTAssertEqual(SymptomsOnset.daysSinceOnset(10).transmissionRiskVector, vector)
	}

	func test11DaysSinceOnsetTransmissionRiskVector_IsExpectedValue() {
		let vector: [Int32] = [1, 1, 1, 1, 1, 2, 2, 3, 5, 6, 8, 8, 8, 7, 6]

		XCTAssertEqual(SymptomsOnset.daysSinceOnset(11).transmissionRiskVector, vector)
	}

	func test12DaysSinceOnsetTransmissionRiskVector_IsExpectedValue() {
		let vector: [Int32] = [1, 1, 1, 1, 1, 1, 2, 2, 3, 5, 6, 8, 8, 8, 7]

		XCTAssertEqual(SymptomsOnset.daysSinceOnset(12).transmissionRiskVector, vector)
	}

	func test13DaysSinceOnsetTransmissionRiskVector_IsExpectedValue() {
		let vector: [Int32] = [1, 1, 1, 1, 1, 1, 1, 2, 2, 3, 5, 6, 8, 8, 8]

		XCTAssertEqual(SymptomsOnset.daysSinceOnset(13).transmissionRiskVector, vector)
	}

	func test14DaysSinceOnsetTransmissionRiskVector_IsExpectedValue() {
		let vector: [Int32] = [1, 1, 1, 1, 1, 1, 1, 1, 2, 2, 3, 5, 6, 8, 8]

		XCTAssertEqual(SymptomsOnset.daysSinceOnset(14).transmissionRiskVector, vector)
	}

	func test15DaysSinceOnsetTransmissionRiskVector_IsExpectedValue() {
		let vector: [Int32] = [1, 1, 1, 1, 1, 1, 1, 1, 1, 2, 2, 3, 5, 6, 8]

		XCTAssertEqual(SymptomsOnset.daysSinceOnset(15).transmissionRiskVector, vector)
	}

	func test16DaysSinceOnsetTransmissionRiskVector_IsExpectedValue() {
		let vector: [Int32] = [1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 2, 2, 3, 5, 6]

		XCTAssertEqual(SymptomsOnset.daysSinceOnset(16).transmissionRiskVector, vector)
	}

	func test17DaysSinceOnsetTransmissionRiskVector_IsExpectedValue() {
		let vector: [Int32] = [1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 2, 2, 3, 5]

		XCTAssertEqual(SymptomsOnset.daysSinceOnset(17).transmissionRiskVector, vector)
	}

	func test18DaysSinceOnsetTransmissionRiskVector_IsExpectedValue() {
		let vector: [Int32] = [1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 2, 2, 3]

		XCTAssertEqual(SymptomsOnset.daysSinceOnset(18).transmissionRiskVector, vector)
	}

	func test19DaysSinceOnsetTransmissionRiskVector_IsExpectedValue() {
		let vector: [Int32] = [1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 2, 2]

		XCTAssertEqual(SymptomsOnset.daysSinceOnset(19).transmissionRiskVector, vector)
	}

	func test20DaysSinceOnsetTransmissionRiskVector_IsExpectedValue() {
		let vector: [Int32] = [1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 2]

		XCTAssertEqual(SymptomsOnset.daysSinceOnset(20).transmissionRiskVector, vector)
	}

	func test21DaysSinceOnsetTransmissionRiskVector_IsExpectedValue() {
		let vector: [Int32] = [1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1]

		XCTAssertEqual(SymptomsOnset.daysSinceOnset(21).transmissionRiskVector, vector)
	}

	func testMoreThan21DaysSinceOnsetTransmissionRiskVector_Equals21DaysSinceOnsetTransmissionRiskVector() {
		let twentyOneDaysVector: [Int32] = SymptomsOnset.daysSinceOnset(21).transmissionRiskVector

		for daysSinceOnset in 22..<28 {
			XCTAssertEqual(SymptomsOnset.daysSinceOnset(daysSinceOnset).transmissionRiskVector, twentyOneDaysVector)
		}
	}

	// MARK: - Days Since Onset Of Symptoms Vector

	func testNoInformationDaysSinceOnsetOfSymptomsVector_IsExpectedValue() {
		let vector: [Int32] = [4000, 3999, 3998, 3997, 3996, 3995, 3994, 3993, 3992, 3991, 3990, 3989, 3988, 3987, 3986]

		XCTAssertEqual(SymptomsOnset.noInformation.daysSinceOnsetOfSymptomsVector, vector)
	}

	func testNonSymptomaticDaysSinceOnsetOfSymptomsVector_IsExpectedValue() {
		let vector: [Int32] = [3000, 2999, 2998, 2997, 2996, 2995, 2994, 2993, 2992, 2991, 2990, 2989, 2988, 2987, 2986]

		XCTAssertEqual(SymptomsOnset.nonSymptomatic.daysSinceOnsetOfSymptomsVector, vector)
	}

	func testSymptomaticWithUnknownOnsetDaysSinceOnsetOfSymptomsVector_IsExpectedValue() {
		let vector: [Int32] = [2000, 1999, 1998, 1997, 1996, 1995, 1994, 1993, 1992, 1991, 1990, 1989, 1988, 1987, 1986]

		XCTAssertEqual(SymptomsOnset.symptomaticWithUnknownOnset.daysSinceOnsetOfSymptomsVector, vector)
	}

	func testLastSevenDaysDaysSinceOnsetOfSymptomsVector_IsExpectedValue() {
		let vector: [Int32] = [701, 700, 699, 698, 697, 696, 695, 694, 693, 692, 691, 690, 689, 688, 687]

		XCTAssertEqual(SymptomsOnset.lastSevenDays.daysSinceOnsetOfSymptomsVector, vector)
	}

	func testOneToTwoWeeksAgoDaysSinceOnsetOfSymptomsVector_IsExpectedValue() {
		let vector: [Int32] = [708, 707, 706, 705, 704, 703, 702, 701, 700, 699, 698, 697, 696, 695, 694]

		XCTAssertEqual(SymptomsOnset.oneToTwoWeeksAgo.daysSinceOnsetOfSymptomsVector, vector)
	}

	func testMoreThanTwoWeeksAgoDaysSinceOnsetOfSymptomsVector_IsExpectedValue() {
		let vector: [Int32] = [715, 714, 713, 712, 711, 710, 709, 708, 707, 706, 705, 704, 703, 702, 701]

		XCTAssertEqual(SymptomsOnset.moreThanTwoWeeksAgo.daysSinceOnsetOfSymptomsVector, vector)
	}

	func test0DaysSinceOnsetDaysSinceOnsetOfSymptomsVector_IsExpectedValue() {
		let vector: [Int32] = [0, -1, -2, -3, -4, -5, -6, -7, -8, -9, -10, -11, -12, -13, -14]

		XCTAssertEqual(SymptomsOnset.daysSinceOnset(0).daysSinceOnsetOfSymptomsVector, vector)
	}

	func test1DaySinceOnsetDaysSinceOnsetOfSymptomsVector_IsExpectedValue() {
		let vector: [Int32] = [1, 0, -1, -2, -3, -4, -5, -6, -7, -8, -9, -10, -11, -12, -13]

		XCTAssertEqual(SymptomsOnset.daysSinceOnset(1).daysSinceOnsetOfSymptomsVector, vector)
	}

	func test2DaysSinceOnsetDaysSinceOnsetOfSymptomsVector_IsExpectedValue() {
		let vector: [Int32] = [2, 1, 0, -1, -2, -3, -4, -5, -6, -7, -8, -9, -10, -11, -12]

		XCTAssertEqual(SymptomsOnset.daysSinceOnset(2).daysSinceOnsetOfSymptomsVector, vector)
	}

	func test3DaysSinceOnsetDaysSinceOnsetOfSymptomsVector_IsExpectedValue() {
		let vector: [Int32] = [3, 2, 1, 0, -1, -2, -3, -4, -5, -6, -7, -8, -9, -10, -11]

		XCTAssertEqual(SymptomsOnset.daysSinceOnset(3).daysSinceOnsetOfSymptomsVector, vector)
	}

	func test4DaysSinceOnsetDaysSinceOnsetOfSymptomsVector_IsExpectedValue() {
		let vector: [Int32] = [4, 3, 2, 1, 0, -1, -2, -3, -4, -5, -6, -7, -8, -9, -10]

		XCTAssertEqual(SymptomsOnset.daysSinceOnset(4).daysSinceOnsetOfSymptomsVector, vector)
	}

	func test5DaysSinceOnsetDaysSinceOnsetOfSymptomsVector_IsExpectedValue() {
		let vector: [Int32] = [5, 4, 3, 2, 1, 0, -1, -2, -3, -4, -5, -6, -7, -8, -9]

		XCTAssertEqual(SymptomsOnset.daysSinceOnset(5).daysSinceOnsetOfSymptomsVector, vector)
	}

	func test6DaysSinceOnsetDaysSinceOnsetOfSymptomsVector_IsExpectedValue() {
		let vector: [Int32] = [6, 5, 4, 3, 2, 1, 0, -1, -2, -3, -4, -5, -6, -7, -8]

		XCTAssertEqual(SymptomsOnset.daysSinceOnset(6).daysSinceOnsetOfSymptomsVector, vector)
	}

	func test7DaysSinceOnsetDaysSinceOnsetOfSymptomsVector_IsExpectedValue() {
		let vector: [Int32] = [7, 6, 5, 4, 3, 2, 1, 0, -1, -2, -3, -4, -5, -6, -7]

		XCTAssertEqual(SymptomsOnset.daysSinceOnset(7).daysSinceOnsetOfSymptomsVector, vector)
	}

	func test8DaysSinceOnsetDaysSinceOnsetOfSymptomsVector_IsExpectedValue() {
		let vector: [Int32] = [8, 7, 6, 5, 4, 3, 2, 1, 0, -1, -2, -3, -4, -5, -6]

		XCTAssertEqual(SymptomsOnset.daysSinceOnset(8).daysSinceOnsetOfSymptomsVector, vector)
	}

	func test9DaysSinceOnsetDaysSinceOnsetOfSymptomsVector_IsExpectedValue() {
		let vector: [Int32] = [9, 8, 7, 6, 5, 4, 3, 2, 1, 0, -1, -2, -3, -4, -5]

		XCTAssertEqual(SymptomsOnset.daysSinceOnset(9).daysSinceOnsetOfSymptomsVector, vector)
	}

	func test10DaysSinceOnsetDaysSinceOnsetOfSymptomsVector_IsExpectedValue() {
		let vector: [Int32] = [10, 9, 8, 7, 6, 5, 4, 3, 2, 1, 0, -1, -2, -3, -4]

		XCTAssertEqual(SymptomsOnset.daysSinceOnset(10).daysSinceOnsetOfSymptomsVector, vector)
	}

	func test11DaysSinceOnsetDaysSinceOnsetOfSymptomsVector_IsExpectedValue() {
		let vector: [Int32] = [11, 10, 9, 8, 7, 6, 5, 4, 3, 2, 1, 0, -1, -2, -3]

		XCTAssertEqual(SymptomsOnset.daysSinceOnset(11).daysSinceOnsetOfSymptomsVector, vector)
	}

	func test12DaysSinceOnsetDaysSinceOnsetOfSymptomsVector_IsExpectedValue() {
		let vector: [Int32] = [12, 11, 10, 9, 8, 7, 6, 5, 4, 3, 2, 1, 0, -1, -2]

		XCTAssertEqual(SymptomsOnset.daysSinceOnset(12).daysSinceOnsetOfSymptomsVector, vector)
	}

	func test13DaysSinceOnsetDaysSinceOnsetOfSymptomsVector_IsExpectedValue() {
		let vector: [Int32] = [13, 12, 11, 10, 9, 8, 7, 6, 5, 4, 3, 2, 1, 0, -1]

		XCTAssertEqual(SymptomsOnset.daysSinceOnset(13).daysSinceOnsetOfSymptomsVector, vector)
	}

	func test14DaysSinceOnsetDaysSinceOnsetOfSymptomsVector_IsExpectedValue() {
		let vector: [Int32] = [14, 13, 12, 11, 10, 9, 8, 7, 6, 5, 4, 3, 2, 1, 0]

		XCTAssertEqual(SymptomsOnset.daysSinceOnset(14).daysSinceOnsetOfSymptomsVector, vector)
	}

	func test15DaysSinceOnsetDaysSinceOnsetOfSymptomsVector_IsExpectedValue() {
		let vector: [Int32] = [15, 14, 13, 12, 11, 10, 9, 8, 7, 6, 5, 4, 3, 2, 1]

		XCTAssertEqual(SymptomsOnset.daysSinceOnset(15).daysSinceOnsetOfSymptomsVector, vector)
	}

	func test16DaysSinceOnsetDaysSinceOnsetOfSymptomsVector_IsExpectedValue() {
		let vector: [Int32] = [16, 15, 14, 13, 12, 11, 10, 9, 8, 7, 6, 5, 4, 3, 2]

		XCTAssertEqual(SymptomsOnset.daysSinceOnset(16).daysSinceOnsetOfSymptomsVector, vector)
	}

	func test17DaysSinceOnsetDaysSinceOnsetOfSymptomsVector_IsExpectedValue() {
		let vector: [Int32] = [17, 16, 15, 14, 13, 12, 11, 10, 9, 8, 7, 6, 5, 4, 3]

		XCTAssertEqual(SymptomsOnset.daysSinceOnset(17).daysSinceOnsetOfSymptomsVector, vector)
	}

	func test18DaysSinceOnsetDaysSinceOnsetOfSymptomsVector_IsExpectedValue() {
		let vector: [Int32] = [18, 17, 16, 15, 14, 13, 12, 11, 10, 9, 8, 7, 6, 5, 4]

		XCTAssertEqual(SymptomsOnset.daysSinceOnset(18).daysSinceOnsetOfSymptomsVector, vector)
	}

	func test19DaysSinceOnsetDaysSinceOnsetOfSymptomsVector_IsExpectedValue() {
		let vector: [Int32] = [19, 18, 17, 16, 15, 14, 13, 12, 11, 10, 9, 8, 7, 6, 5]

		XCTAssertEqual(SymptomsOnset.daysSinceOnset(19).daysSinceOnsetOfSymptomsVector, vector)
	}

	func test20DaysSinceOnsetDaysSinceOnsetOfSymptomsVector_IsExpectedValue() {
		let vector: [Int32] = [20, 19, 18, 17, 16, 15, 14, 13, 12, 11, 10, 9, 8, 7, 6]

		XCTAssertEqual(SymptomsOnset.daysSinceOnset(20).daysSinceOnsetOfSymptomsVector, vector)
	}

	func test21DaysSinceOnsetDaysSinceOnsetOfSymptomsVector_IsExpectedValue() {
		let vector: [Int32] = [21, 20, 19, 18, 17, 16, 15, 14, 13, 12, 11, 10, 9, 8, 7]

		XCTAssertEqual(SymptomsOnset.daysSinceOnset(21).daysSinceOnsetOfSymptomsVector, vector)
	}

	func testMoreThan21DaysSinceOnsetOfSymptomsVector_Equals21DaysSinceOnsetOfSymptomsVector() {
		let twentyOneDaysVector: [Int32] = SymptomsOnset.daysSinceOnset(21).daysSinceOnsetOfSymptomsVector

		for daysSinceOnset in 22..<28 {
			XCTAssertEqual(SymptomsOnset.daysSinceOnset(daysSinceOnset).daysSinceOnsetOfSymptomsVector, twentyOneDaysVector)
		}
	}

	// MARK: - Codable

	func testEncodingAndDecodingNoInformation() throws {
		let symptomsOnsets: [SymptomsOnset] = [.noInformation, .nonSymptomatic, .symptomaticWithUnknownOnset, .lastSevenDays, .oneToTwoWeeksAgo, .moreThanTwoWeeksAgo, .daysSinceOnset(-1), .daysSinceOnset(0), .daysSinceOnset(17), .daysSinceOnset(Int.max)]

		let encoder = JSONEncoder()
		let decoder = JSONDecoder()

		for symptomsOnset in symptomsOnsets {
			let encodedSymptomsOnset = try encoder.encode(symptomsOnset)
			let decodedSymptomsOnset = try decoder.decode(SymptomsOnset.self, from: encodedSymptomsOnset)

			XCTAssertEqual(decodedSymptomsOnset, symptomsOnset)
		}
	}

}
