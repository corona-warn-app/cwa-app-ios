import Foundation

import XCTest
@testable import ENA

class HomeUnknownRiskCellConfiguratorTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

	func test_unknownRiskLevelCell_shouldHaveEqualHash() {
		let date = Date()
		let configurator1 = HomeUnknownRiskCellConfigurator(state: .idle, lastUpdateDate: date, detectionInterval: 0, detectionMode: .manual, manualExposureDetectionState: .possible)
		let configurator2 = HomeUnknownRiskCellConfigurator(state: .idle, lastUpdateDate: date, detectionInterval: 0, detectionMode: .manual, manualExposureDetectionState: .possible)

		let hash1 = configurator1.hashValue
		let hash2 = configurator2.hashValue

		XCTAssertEqual(hash1, hash2)
	}

	func test_unknownRiskLevelCell_shouldHaveDifferentHash1() {

		let date = Date()

		let configurator1 = HomeUnknownRiskCellConfigurator(state: .idle, lastUpdateDate: date, detectionInterval: 0, detectionMode: .manual, manualExposureDetectionState: .possible)
		let configurator2 = HomeUnknownRiskCellConfigurator(state: .idle, lastUpdateDate: date, detectionInterval: 0, detectionMode: .automatic, manualExposureDetectionState: .possible)

		let hash1 = configurator1.hashValue
		let hash2 = configurator2.hashValue

		XCTAssertNotEqual(hash1, hash2)
	}

	func test_unknownRiskLevelCell_shouldHaveDifferentHash2() {

		let date = Date()

		let configurator1 = HomeUnknownRiskCellConfigurator(state: .idle, lastUpdateDate: date, detectionInterval: 0, detectionMode: .manual, manualExposureDetectionState: .possible)
		let configurator2 = HomeUnknownRiskCellConfigurator(state: .idle, lastUpdateDate: date, detectionInterval: 0, detectionMode: .manual, manualExposureDetectionState: .waiting)

		let hash1 = configurator1.hashValue
		let hash2 = configurator2.hashValue
		XCTAssertNotEqual(hash1, hash2)
	}

	func test_unknownRiskLevelCell_shouldBeEqual() {
		let date = Date()
		let configurator1 = HomeUnknownRiskCellConfigurator(state: .idle, lastUpdateDate: date, detectionInterval: 0, detectionMode: .manual, manualExposureDetectionState: .possible)
		let configurator2 = HomeUnknownRiskCellConfigurator(state: .idle, lastUpdateDate: date, detectionInterval: 0, detectionMode: .manual, manualExposureDetectionState: .possible)

		let isEqual = configurator1 == configurator2
		XCTAssertTrue(isEqual)
	}

	func test_unknownRiskLevelCell_shouldntBeEqual1() {
		let date = Date()
		let configurator1 = HomeUnknownRiskCellConfigurator(state: .idle, lastUpdateDate: date, detectionInterval: 0, detectionMode: .manual, manualExposureDetectionState: .possible)
		let configurator2 = HomeUnknownRiskCellConfigurator(state: .idle, lastUpdateDate: date, detectionInterval: 0, detectionMode: .automatic, manualExposureDetectionState: .possible)

		let isEqual = configurator1 == configurator2
		XCTAssertFalse(isEqual)
	}

	func test_unknownRiskLevelCell_shouldntBeEqual2() {
		let date = Date()
		let configurator1 = HomeUnknownRiskCellConfigurator(state: .idle, lastUpdateDate: date, detectionInterval: 0, detectionMode: .manual, manualExposureDetectionState: .possible)
		let configurator2 = HomeUnknownRiskCellConfigurator(state: .idle, lastUpdateDate: date, detectionInterval: 0, detectionMode: .manual, manualExposureDetectionState: .waiting)

		let isEqual = configurator1 == configurator2
		XCTAssertFalse(isEqual)
	}
}
