////
// 🦠 Corona-Warn-App
//

import XCTest
@testable import ENA

class ExposureWindowsMetadataTests: XCTestCase {

	// MARK: - Internal

	func testWindowsCollectionFirstTime_whenNotInitialized() {
		
		let store = MockTestStore()
		Analytics.setupMock(store: store)
		store.isPrivacyPreservingAnalyticsConsentGiven = true
		XCTAssertNil(store.exposureWindowsMetadata, "Windows metadata should not be initialized")
		
		Analytics.collect(.exposureWindowsMetadata(.collectExposureWindows(mappedExposureWindowsMock())))
		guard let metadata = store.exposureWindowsMetadata else {
			XCTFail("Windows metadata should be initialized")
			return
		}
		
		XCTAssertFalse(metadata.newExposureWindowsQueue.isEmpty, "newExposureWindowsQueue should be populated")
		XCTAssertFalse(metadata.reportedExposureWindowsQueue.isEmpty, "reportedExposureWindowsQueue should be populated")

	}

	func testWindowsCollection_AlreadyInitialized_alreadyExistingHashsAreNotAppended() {
		
		let store = MockTestStore()
		Analytics.setupMock(store: store)
		store.isPrivacyPreservingAnalyticsConsentGiven = true
		XCTAssertNil(store.exposureWindowsMetadata, "Windows metadata should not be initialized")

		// initialize
		Analytics.collect(.exposureWindowsMetadata(.collectExposureWindows(mappedExposureWindowsMock())))

		guard let oldMetadata = store.exposureWindowsMetadata else {
			XCTFail("oldMetadata should be initialized")
			return
		}
		// try to add the same windows again
		Analytics.collect(.exposureWindowsMetadata(.collectExposureWindows(mappedExposureWindowsMock())))

		guard let newMetadata = store.exposureWindowsMetadata else {
			XCTFail("newMetadata should be initialized")
			return
		}

		XCTAssertEqual(newMetadata.newExposureWindowsQueue.count, oldMetadata.newExposureWindowsQueue.count, "The count should be the same because no new hashs are added")
		XCTAssertEqual(newMetadata.reportedExposureWindowsQueue.count, oldMetadata.reportedExposureWindowsQueue.count, "The count should be the same because no new hashs are added")
	}
	
	func testWindowsCollection_AlreadyInitialized_newHashsAreAppended() {
		
		guard let firstRiskCalculation = mappedExposureWindowsMock().first,
			  let lastRiskCalculation = mappedExposureWindowsMock().last else {
			XCTFail("riskCalculationMock is nil")
			return
		}
		
		let store = MockTestStore()
		Analytics.setupMock(store: store)
		store.isPrivacyPreservingAnalyticsConsentGiven = true
		XCTAssertNil(store.exposureWindowsMetadata, "Windows metadata should not be initialized")

		// initialize
		Analytics.collect(.exposureWindowsMetadata(.collectExposureWindows([firstRiskCalculation])))

		guard let oldMetadata = store.exposureWindowsMetadata else {
			XCTFail("oldMetadata should be initialized")
			return
		}
		// add new windows
		Analytics.collect(.exposureWindowsMetadata(.collectExposureWindows([lastRiskCalculation])))

		guard let newMetadata = store.exposureWindowsMetadata else {
			XCTFail("newMetadata should be initialized")
			return
		}

		XCTAssertNotEqual(newMetadata.newExposureWindowsQueue.count, oldMetadata.newExposureWindowsQueue.count, "The count should not be the same because new hashs are added")
		XCTAssertNotEqual(newMetadata.reportedExposureWindowsQueue.count, oldMetadata.reportedExposureWindowsQueue.count, "The count should not be the same because new hashs are added")
	}
	
	func testWindowsCollection_AlreadyInitialized_ReportedEntriesOlderThan15DaysAreDeleted() {
		
		guard let firstRiskCalculation = mappedExposureWindowsMock().first,
			  let lastRiskCalculation = mappedExposureWindowsMock().last else {
			XCTFail("riskCalculationMock is nil")
			return
		}
		
		let store = MockTestStore()
		Analytics.setupMock(store: store)
		store.isPrivacyPreservingAnalyticsConsentGiven = true
		XCTAssertNil(store.exposureWindowsMetadata, "Windows metadata should not be initialized")

		// initialize
		Analytics.collect(.exposureWindowsMetadata(.collectExposureWindows([firstRiskCalculation])))

		guard let dateLastMonth = Calendar.current.date(byAdding: .month, value: -1, to: Date()) else {
			XCTFail("date from last month is nil")
			return
		}
		
		let submissionExposureWindow = generateMockSubmissionExposureWindow(date: dateLastMonth)
		store.exposureWindowsMetadata?.reportedExposureWindowsQueue.append(submissionExposureWindow)

		XCTAssertEqual(store.exposureWindowsMetadata?.reportedExposureWindowsQueue.count, 2, "The expected coundshould be 2")
		Analytics.collect(.exposureWindowsMetadata(.collectExposureWindows([lastRiskCalculation])))
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
	
	private func mappedExposureWindowsMock() -> [RiskCalculationExposureWindow] {
		var mappedWindows = [RiskCalculationExposureWindow]()
		for testCase in testCasesWithConfiguration.testCases {
			let windows = testCase.exposureWindows.map {
				RiskCalculationExposureWindow(
					exposureWindow: $0,
					configuration: testCasesWithConfiguration.defaultRiskCalculationConfiguration
				)
			}
			mappedWindows.append(contentsOf: windows)
		}
		return mappedWindows
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
