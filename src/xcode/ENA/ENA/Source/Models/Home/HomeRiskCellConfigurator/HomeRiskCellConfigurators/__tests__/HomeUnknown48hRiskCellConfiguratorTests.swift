//
// 🦠 Corona-Warn-App
//

import Foundation

import XCTest
@testable import ENA

class HomeUnknown48hRiskCellConfiguratorTests: XCTestCase {

	func test_unknownRiskLevelCell_shouldHaveEqualHash() {
		let date = Date()
		let configurator1 = HomeUnknown48hRiskCellConfigurator(state: .idle, lastUpdateDate: date, detectionInterval: 0, detectionMode: .manual, manualExposureDetectionState: .possible, previousRiskLevel: .low)
		let configurator2 = HomeUnknown48hRiskCellConfigurator(state: .idle, lastUpdateDate: date, detectionInterval: 0, detectionMode: .manual, manualExposureDetectionState: .possible, previousRiskLevel: .low)

		let hash1 = configurator1.hashValue
		let hash2 = configurator2.hashValue

		XCTAssertEqual(hash1, hash2)
	}

	func test_unknownRiskLevelCell_shouldHaveDifferentHash1() {

		let date = Date()

		let configurator1 = HomeUnknown48hRiskCellConfigurator(state: .idle, lastUpdateDate: date, detectionInterval: 0, detectionMode: .manual, manualExposureDetectionState: .possible, previousRiskLevel: .low)
		let configurator2 = HomeUnknown48hRiskCellConfigurator(state: .idle, lastUpdateDate: date, detectionInterval: 0, detectionMode: .automatic, manualExposureDetectionState: .possible, previousRiskLevel: .increased)

		let hash1 = configurator1.hashValue
		let hash2 = configurator2.hashValue

		XCTAssertNotEqual(hash1, hash2)
	}

	func test_unknownRiskLevelCell_shouldHaveDifferentHash2() {

		let date = Date()

		let configurator1 = HomeUnknown48hRiskCellConfigurator(state: .idle, lastUpdateDate: date, detectionInterval: 0, detectionMode: .manual, manualExposureDetectionState: .possible, previousRiskLevel: .low)
		let configurator2 = HomeUnknown48hRiskCellConfigurator(state: .idle, lastUpdateDate: date, detectionInterval: 3, detectionMode: .automatic, manualExposureDetectionState: .waiting, previousRiskLevel: .low)

		let hash1 = configurator1.hashValue
		let hash2 = configurator2.hashValue
		XCTAssertNotEqual(hash1, hash2)
	}

	func test_unknownRiskLevelCell_shouldBeEqual() {
		let date = Date()
		let configurator1 = HomeUnknown48hRiskCellConfigurator(state: .idle, lastUpdateDate: date, detectionInterval: 0, detectionMode: .manual, manualExposureDetectionState: .possible, previousRiskLevel: .increased)
		let configurator2 = HomeUnknown48hRiskCellConfigurator(state: .idle, lastUpdateDate: date, detectionInterval: 0, detectionMode: .manual, manualExposureDetectionState: .possible, previousRiskLevel: .increased)

		let isEqual = configurator1 == configurator2
		XCTAssertTrue(isEqual)
	}

	func test_unknownRiskLevelCell_shouldntBeEqual1() {
		let date = Date()
		let configurator1 = HomeUnknown48hRiskCellConfigurator(state: .idle, lastUpdateDate: date, detectionInterval: 0, detectionMode: .manual, manualExposureDetectionState: .possible, previousRiskLevel: .low)
		let configurator2 = HomeUnknown48hRiskCellConfigurator(state: .idle, lastUpdateDate: date, detectionInterval: 0, detectionMode: .automatic, manualExposureDetectionState: .possible, previousRiskLevel: .increased)

		let isEqual = configurator1 == configurator2
		XCTAssertFalse(isEqual)
	}

	func test_unknownRiskLevelCell_shouldntBeEqual2() {
		let date = Date()
		let configurator1 = HomeUnknown48hRiskCellConfigurator(state: .idle, lastUpdateDate: date, detectionInterval: 0, detectionMode: .manual, manualExposureDetectionState: .possible, previousRiskLevel: .increased)
		let configurator2 = HomeUnknown48hRiskCellConfigurator(state: .idle, lastUpdateDate: date, detectionInterval: 900, detectionMode: .manual, manualExposureDetectionState: .waiting, previousRiskLevel: .increased)

		let isEqual = configurator1 == configurator2
		XCTAssertFalse(isEqual)
	}
}
