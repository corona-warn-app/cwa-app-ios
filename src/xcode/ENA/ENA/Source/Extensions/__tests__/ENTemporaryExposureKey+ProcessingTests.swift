//
// 🦠 Corona-Warn-App
//

@testable import ENA
import Foundation
import ExposureNotification
import XCTest

final class ExposureKeysProcessingTests: XCTestCase {
	
	func testSubmissionPreprocess_ApplyNoInformationVectors() {
		let symptomsOnset: SymptomsOnset = .noInformation
		
		let days = Array(0...14)
		let keys = days.map { makeMockKey(daysUntilToday: $0) }
		let processedKeys = keys.processedForSubmission(with: symptomsOnset, today: Date(timeIntervalSinceReferenceDate: 0))

		assertCorrectProcessing(on: processedKeys, for: days, with: symptomsOnset)
	}
	
	func testSubmissionPreprocess_ApplyNonSymptomaticVectors() {
		let symptomsOnset: SymptomsOnset = .nonSymptomatic
		
		let days = Array(0...14)
		let keys = days.map { makeMockKey(daysUntilToday: $0) }
		let processedKeys = keys.processedForSubmission(with: symptomsOnset, today: Date(timeIntervalSinceReferenceDate: 0))

		assertCorrectProcessing(on: processedKeys, for: days, with: symptomsOnset)
	}
	
	func testSubmissionPreprocess_ApplySymptomaticWithUnknownOnsetDaysVectors() {
		let symptomsOnset: SymptomsOnset = .symptomaticWithUnknownOnset
		
		let days = Array(0...14)
		let keys = days.map { makeMockKey(daysUntilToday: $0) }
		let processedKeys = keys.processedForSubmission(with: symptomsOnset, today: Date(timeIntervalSinceReferenceDate: 0))

		assertCorrectProcessing(on: processedKeys, for: days, with: symptomsOnset)
	}
	
	func testSubmissionPreprocess_ApplyLastSevenDaysVectors() {
		let symptomsOnset: SymptomsOnset = .lastSevenDays
		
		let days = Array(0...14)
		let keys = days.map { makeMockKey(daysUntilToday: $0) }
		let processedKeys = keys.processedForSubmission(with: symptomsOnset, today: Date(timeIntervalSinceReferenceDate: 0))

		assertCorrectProcessing(on: processedKeys, for: days, with: symptomsOnset)
	}
	
	func testSubmissionPreprocess_ApplyOneToTwoWeeksAgoVectors() {
		let symptomsOnset: SymptomsOnset = .oneToTwoWeeksAgo
		
		let days = Array(0...14)
		let keys = days.map { makeMockKey(daysUntilToday: $0) }
		let processedKeys = keys.processedForSubmission(with: symptomsOnset, today: Date(timeIntervalSinceReferenceDate: 0))

		assertCorrectProcessing(on: processedKeys, for: days, with: symptomsOnset)
	}
	
	func testSubmissionPreprocess_ApplyMoreThanTwoWeeksAgoVectors() {
		let symptomsOnset: SymptomsOnset = .moreThanTwoWeeksAgo
		
		let days = Array(0...14)
		let keys = days.map { makeMockKey(daysUntilToday: $0) }
		let processedKeys = keys.processedForSubmission(with: symptomsOnset, today: Date(timeIntervalSinceReferenceDate: 0))

		assertCorrectProcessing(on: processedKeys, for: days, with: symptomsOnset)
	}
	
	func testSubmissionPreprocess_ApplyDaysSinceOnsetVectors() {
		for daysSinceOnset in 0..<22 {
			let symptomsOnset: SymptomsOnset = .daysSinceOnset(daysSinceOnset)
			
			let days = Array(0...14)
			let keys = days.map { makeMockKey(daysUntilToday: $0) }
			let processedKeys = keys.processedForSubmission(with: symptomsOnset, today: Date(timeIntervalSinceReferenceDate: 0))

			assertCorrectProcessing(on: processedKeys, for: days, with: symptomsOnset)
		}
	}
	
	func testSubmissionPreprocess_NoKeys() {
		let keys = [SAP_External_Exposurenotification_TemporaryExposureKey]()
		let processedKeys = keys.processedForSubmission(with: .noInformation)
		
		XCTAssertEqual(processedKeys.count, 0)
	}
	
	func testSubmissionPreprocess_TodaysKeyMissing() {
		let symptomsOnset: SymptomsOnset = .daysSinceOnset(7)
		
		let days = Array(1...14)
		let keys = days.map { makeMockKey(daysUntilToday: $0) }
		let processedKeys = keys.processedForSubmission(with: symptomsOnset, today: Date(timeIntervalSinceReferenceDate: 0))

		assertCorrectProcessing(on: processedKeys, for: days, with: symptomsOnset)
	}
	
	func testSubmissionPreprocess_14DaysAgoKeyMissing() {
		let symptomsOnset: SymptomsOnset = .daysSinceOnset(7)
		
		let days = Array(1...13)
		let keys = days.map { makeMockKey(daysUntilToday: $0) }
		let processedKeys = keys.processedForSubmission(with: symptomsOnset, today: Date(timeIntervalSinceReferenceDate: 0))

		assertCorrectProcessing(on: processedKeys, for: days, with: symptomsOnset)
	}
	
	func testSubmissionPreprocess_InBetweenKeyMissing() {
		let symptomsOnset: SymptomsOnset = .daysSinceOnset(7)
		
		let days = [0, 1, 2, 3, 4, 5, 7, 8, 9, 10, 11, 12, 13, 14]
		let keys = days.map { makeMockKey(daysUntilToday: $0) }
		let processedKeys = keys.processedForSubmission(with: symptomsOnset, today: Date(timeIntervalSinceReferenceDate: 0))

		assertCorrectProcessing(on: processedKeys, for: days, with: symptomsOnset)
	}
	
	func testSubmissionPreprocess_MultipleKeysMissing() {
		let symptomsOnset: SymptomsOnset = .daysSinceOnset(7)
		
		let days = [1, 2, 3, 4, 5, 8, 9, 10, 11, 13, 14]
		let keys = days.map { makeMockKey(daysUntilToday: $0) }
		let processedKeys = keys.processedForSubmission(with: symptomsOnset, today: Date(timeIntervalSinceReferenceDate: 0))

		assertCorrectProcessing(on: processedKeys, for: days, with: symptomsOnset)
	}
	
	func testSubmissionPreprocess_MultipleKeysForOneDay() {
		let symptomsOnset: SymptomsOnset = .daysSinceOnset(7)
		
		let days = [0, 0, 0, 1, 2, 3, 4, 5, 6, 6, 7, 7, 7, 8, 9, 10, 11, 12, 12, 13, 14, 14]
		let keys = days.map { makeMockKey(daysUntilToday: $0) }
		let processedKeys = keys.processedForSubmission(with: symptomsOnset, today: Date(timeIntervalSinceReferenceDate: 0))

		assertCorrectProcessing(on: processedKeys, for: days, with: symptomsOnset)
	}
	
	func testSubmissionPreprocess_KeysFromTheFutureAreIgnored() {
		let symptomsOnset: SymptomsOnset = .daysSinceOnset(7)
		
		let days = [-6, -1, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14]
		let keys = days.map { makeMockKey(daysUntilToday: $0) }
		let processedKeys = keys.processedForSubmission(with: symptomsOnset, today: Date(timeIntervalSinceReferenceDate: 0))

		assertCorrectProcessing(on: processedKeys, for: days, with: symptomsOnset)
	}
	
	func testSubmissionPreprocess_KeysOlderThan14DaysAreIgnored() {
		let symptomsOnset: SymptomsOnset = .daysSinceOnset(7)
		
		let days = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 32, 167]
		let keys = days.map { makeMockKey(daysUntilToday: $0) }
		let processedKeys = keys.processedForSubmission(with: symptomsOnset, today: Date(timeIntervalSinceReferenceDate: 0))

		assertCorrectProcessing(on: processedKeys, for: days, with: symptomsOnset)
	}
	
	func testSubmissionPreprocess_ManyEdgeCases() {
		let symptomsOnset: SymptomsOnset = .daysSinceOnset(7)
		
		let days = [-54, -3, 1, 2, 3, 4, 6, 6, 6, 6, 6, 6, 7, 8, 9, 10, 11, 15, 16, 32, 167]
		let keys = days.map { makeMockKey(daysUntilToday: $0) }
		let processedKeys = keys.processedForSubmission(with: symptomsOnset, today: Date(timeIntervalSinceReferenceDate: 0))
		
		assertCorrectProcessing(on: processedKeys, for: days, with: symptomsOnset)
	}
	
}

// MARK: - Helpers

extension ExposureKeysProcessingTests {
	
	private func makeMockKey(daysUntilToday: Int, today: Date = Date(timeIntervalSinceReferenceDate: 0)) -> SAP_External_Exposurenotification_TemporaryExposureKey {
		var calendar = Calendar(identifier: .gregorian)
		// swiftlint:disable:next force_unwrapping
		calendar.timeZone = TimeZone(secondsFromGMT: 0)!
		
		guard let date = calendar.date(byAdding: .day, value: -daysUntilToday, to: today) else { fatalError("Could not create date") }

		var key = SAP_External_Exposurenotification_TemporaryExposureKey()
		key.rollingStartIntervalNumber = Int32(date.timeIntervalSince1970 / 600)
		
		return key
	}

	private func assertCorrectProcessing(on processedKeys: [SAP_External_Exposurenotification_TemporaryExposureKey], for days: [Int], with symptomsOnset: SymptomsOnset) {
		let transmissionRiskVector = symptomsOnset.transmissionRiskVector
		let daysSinceOnsetOfSymptomsVector = symptomsOnset.daysSinceOnsetOfSymptomsVector

		let sortedKeys = processedKeys.sorted { $0.rollingStartIntervalNumber > $1.rollingStartIntervalNumber }

		let filteredDays = days.filter { (0...14).contains($0) }
		for (key, day) in zip(sortedKeys, filteredDays) {
			XCTAssertEqual(
				key.transmissionRiskLevel,
				transmissionRiskVector[day],
				"Transmission Risk Level vector not applied correctly! Expected \(transmissionRiskVector[day]), got \(key.transmissionRiskLevel)"
			)

			XCTAssertEqual(
				key.daysSinceOnsetOfSymptoms,
				daysSinceOnsetOfSymptomsVector[day],
				"Days Since Onset Of Symptoms vector not applied correctly! Expected \(daysSinceOnsetOfSymptomsVector[day]), got \(key.daysSinceOnsetOfSymptoms)"
			)
		}
	}

}
