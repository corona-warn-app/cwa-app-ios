////
// 🦠 Corona-Warn-App
//

import XCTest
@testable import ENA

class ExposureWindowsMetadataServiceTests: XCTestCase {

	// MARK: - Internal

	func testWindowsCollectionFirstTime_whenNotInitialized() {
		
		guard let riskCalculation = riskCalculationMock().first else {
			XCTFail("riskCalculationMock is nil")
			return
		}
		let store = MockTestStore()
		XCTAssertNil(store.exposureWindowsMetadata, "Windows metadata should not be initialized")

		Analytics.log(.exposureWindowsMetadata(.collectExposureWindows(riskCalculation)))
		guard let metadata = store.exposureWindowsMetadata else {
			XCTFail("Windows metadata should be initialized")
			return
		}
		
		XCTAssertFalse(metadata.newExposureWindowsQueue.isEmpty, "newExposureWindowsQueue should be populated")
		XCTAssertFalse(metadata.reportedExposureWindowsQueue.isEmpty, "reportedExposureWindowsQueue should be populated")

	}

	func testWindowsCollection_AlreadyInitialized_alreadyExistingHashsAreNotAppended() {
		
		guard let firstRiskCalculation = riskCalculationMock().first else {
			XCTFail("riskCalculationMock is nil")
			return
		}
		
		let store = MockTestStore()
		XCTAssertNil(store.exposureWindowsMetadata, "Windows metadata should not be initialized")

		// initialize
		Analytics.log(.exposureWindowsMetadata(.collectExposureWindows(firstRiskCalculation)))

		guard let oldMetadata = store.exposureWindowsMetadata else {
			XCTFail("oldMetadata should be initialized")
			return
		}
		// try to add the same windows again
		Analytics.log(.exposureWindowsMetadata(.collectExposureWindows(firstRiskCalculation)))

		guard let newMetadata = store.exposureWindowsMetadata else {
			XCTFail("newMetadata should be initialized")
			return
		}

		XCTAssertEqual(newMetadata.newExposureWindowsQueue.count, oldMetadata.newExposureWindowsQueue.count, "The count should be the same because no new hashs are added")
		XCTAssertEqual(newMetadata.reportedExposureWindowsQueue.count, oldMetadata.reportedExposureWindowsQueue.count, "The count should be the same because no new hashs are added")
	}
	
	func testWindowsCollection_AlreadyInitialized_newHashsAreAppended() {
		
		guard let firstRiskCalculation = riskCalculationMock().first,
			  let lastRiskCalculation = riskCalculationMock().last else {
			XCTFail("riskCalculationMock is nil")
			return
		}
		
		let store = MockTestStore()
		XCTAssertNil(store.exposureWindowsMetadata, "Windows metadata should not be initialized")

		// initialize
		Analytics.log(.exposureWindowsMetadata(.collectExposureWindows(firstRiskCalculation)))

		guard let oldMetadata = store.exposureWindowsMetadata else {
			XCTFail("oldMetadata should be initialized")
			return
		}
		// add new windows
		Analytics.log(.exposureWindowsMetadata(.collectExposureWindows(lastRiskCalculation)))

		guard let newMetadata = store.exposureWindowsMetadata else {
			XCTFail("newMetadata should be initialized")
			return
		}

		XCTAssertNotEqual(newMetadata.newExposureWindowsQueue.count, oldMetadata.newExposureWindowsQueue.count, "The count should not be the same because new hashs are added")
		XCTAssertNotEqual(newMetadata.reportedExposureWindowsQueue.count, oldMetadata.reportedExposureWindowsQueue.count, "The count should not be the same because new hashs are added")
	}
	
	func testWindowsCollection_AlreadyInitialized_ReportedEntriesOlderThan15DaysAreDeleted() {
		
		guard let firstRiskCalculation = riskCalculationMock().first,
			  let lastRiskCalculation = riskCalculationMock().last else {
			XCTFail("riskCalculationMock is nil")
			return
		}
		
		let store = MockTestStore()
		XCTAssertNil(store.exposureWindowsMetadata, "Windows metadata should not be initialized")

		// initialize
		Analytics.log(.exposureWindowsMetadata(.collectExposureWindows(firstRiskCalculation)))

		guard let dateLastMonth = Calendar.current.date(byAdding: .month, value: -1, to: Date()) else {
			XCTFail("date from last month is nil")
			return
		}
		
		let submissionExposureWindow = generateMockSubmissionExposureWindow(date: dateLastMonth)
		store.exposureWindowsMetadata?.reportedExposureWindowsQueue.append(submissionExposureWindow)

		XCTAssertEqual(store.exposureWindowsMetadata?.reportedExposureWindowsQueue.count, 2, "The expected coundshould be 2")
		Analytics.log(.exposureWindowsMetadata(.collectExposureWindows(lastRiskCalculation)))
		XCTAssertEqual(store.exposureWindowsMetadata?.reportedExposureWindowsQueue.count, 2, "The expected coundshould still be 2 as  the entry older than 15 days is removed")
	}
	
	// MARK: - Private
	
	private func generateMockSubmissionExposureWindow(date: Date = Date()) -> SubmissionExposureWindow {
		let exposureWindow = ExposureWindow(
			calibrationConfidence: .high,
			date: date,
			reportType: .confirmedTest,
			infectiousness: .high,
			scanInstances: []
		)
		return SubmissionExposureWindow(
			exposureWindow: exposureWindow,
			transmissionRiskLevel: 1,
			normalizedTime: 0.0,
			hash: "hash",
			date: date
		)
	}
	
	private func riskCalculationMock() -> [RiskCalculation] {
		
		let testCases = testCasesWithConfiguration.testCases
		var riskCalculations = [RiskCalculation]()
		
		for testCase in testCases {
			do {
				let riskCalculation = RiskCalculation()
				_ = try riskCalculation.calculateRisk(
					exposureWindows: testCase.exposureWindows,
					configuration: testCasesWithConfiguration.defaultRiskCalculationConfiguration
				)
				riskCalculations.append(riskCalculation)
			} catch {
				XCTFail("Caught error decoding the riskCalculations, Error: \(error.localizedDescription)")
			}
		}
		return riskCalculations
	}
	
	private lazy var testCasesWithConfiguration: TestCasesWithConfiguration = {
		let testBundle = Bundle(for: RiskCalculationTest.self)
		guard let urlJsonFile = testBundle.url(forResource: "exposure-windows-risk-calculation", withExtension: "json"),
			  let data = try? Data(contentsOf: urlJsonFile) else {
			XCTFail("Failed init json file for tests")
			fatalError("Failed init json file for tests - stop hete")
		}

		do {
			return try JSONDecoder().decode(TestCasesWithConfiguration.self, from: data)
		} catch let DecodingError.keyNotFound(jsonKey, context) {
			fatalError("missing key: \(jsonKey)\nDebug Description: \(context.debugDescription)")
		} catch let DecodingError.valueNotFound(type, context) {
			fatalError("Type not found \(type)\nDebug Description: \(context.debugDescription)")
		} catch let DecodingError.typeMismatch(type, context) {
			fatalError("Type mismatch found \(type)\nDebug Description: \(context.debugDescription)")
		} catch DecodingError.dataCorrupted(let context) {
			fatalError("Debug Description: \(context.debugDescription)")
		} catch {
			fatalError("Failed to parse JSON answer")
		}
	}()
}
