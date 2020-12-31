//
// 🦠 Corona-Warn-App
//

import Foundation

import XCTest
@testable import ENA

class HomeLowRiskCellConfiguratorTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

	func test_unknownRiskLevelCell_shouldHaveEqualHash() {
		let date = Date()
		let configurator1 = HomeLowRiskCellConfigurator(state: .idle, numberOfDaysWithLowRisk: 0, lastUpdateDate: date, isButtonHidden: false, manualExposureDetectionState: .possible, detectionInterval: 0, activeTracing: ActiveTracing(interval: .init(days: 0)))
		let configurator2 = HomeLowRiskCellConfigurator(state: .idle, numberOfDaysWithLowRisk: 0, lastUpdateDate: date, isButtonHidden: false, manualExposureDetectionState: .possible, detectionInterval: 0, activeTracing: ActiveTracing(interval: .init(days: 0)))

		let hash1 = configurator1.hashValue
		let hash2 = configurator2.hashValue

		XCTAssertEqual(hash1, hash2)
	}

	func test_unknownRiskLevelCell_shouldHaveDifferentHash1() {

		let date = Date()

		let configurator1 = HomeLowRiskCellConfigurator(state: .idle, numberOfDaysWithLowRisk: 0, lastUpdateDate: date, isButtonHidden: false, manualExposureDetectionState: .possible, detectionInterval: 0, activeTracing: ActiveTracing(interval: .init(days: 0)))
		let configurator2 = HomeLowRiskCellConfigurator(state: .idle, numberOfDaysWithLowRisk: 0, lastUpdateDate: date, isButtonHidden: false, manualExposureDetectionState: .possible, detectionInterval: 0, activeTracing: ActiveTracing(interval: .init(days: 5)))

		let hash1 = configurator1.hashValue
		let hash2 = configurator2.hashValue

		XCTAssertNotEqual(hash1, hash2)
	}

	func test_unknownRiskLevelCell_shouldBeEqual() {
		let date = Date()
		let configurator1 = HomeLowRiskCellConfigurator(state: .idle, numberOfDaysWithLowRisk: 0, lastUpdateDate: date, isButtonHidden: false, manualExposureDetectionState: .possible, detectionInterval: 0, activeTracing: ActiveTracing(interval: .init(days: 0)))
		let configurator2 = HomeLowRiskCellConfigurator(state: .idle, numberOfDaysWithLowRisk: 0, lastUpdateDate: date, isButtonHidden: false, manualExposureDetectionState: .possible, detectionInterval: 0, activeTracing: ActiveTracing(interval: .init(days: 0)))

		let isEqual = configurator1 == configurator2
		XCTAssertTrue(isEqual)
	}

	func test_unknownRiskLevelCell_shouldntBeEqual1() {
		let date = Date()
		let configurator1 = HomeLowRiskCellConfigurator(state: .idle, numberOfDaysWithLowRisk: 0, lastUpdateDate: date, isButtonHidden: false, manualExposureDetectionState: .possible, detectionInterval: 0, activeTracing: ActiveTracing(interval: .init(days: 0)))
		let configurator2 = HomeLowRiskCellConfigurator(state: .idle, numberOfDaysWithLowRisk: 3, lastUpdateDate: date, isButtonHidden: false, manualExposureDetectionState: .possible, detectionInterval: 0, activeTracing: ActiveTracing(interval: .init(days: 0)))

		let isEqual = configurator1 == configurator2

		XCTAssertFalse(isEqual)
	}

	func test_unknownRiskLevelCell_shouldntBeEqual2() {
		let date = Date()
		let configurator1 = HomeLowRiskCellConfigurator(state: .idle, numberOfDaysWithLowRisk: 0, lastUpdateDate: date, isButtonHidden: false, manualExposureDetectionState: .possible, detectionInterval: 0, activeTracing: ActiveTracing(interval: .init(days: 0)))
		let configurator2 = HomeLowRiskCellConfigurator(state: .idle, numberOfDaysWithLowRisk: 0, lastUpdateDate: date, isButtonHidden: false, manualExposureDetectionState: .possible, detectionInterval: 0, activeTracing: ActiveTracing(interval: .init(days: 4)))

		let isEqual = configurator1 == configurator2

		XCTAssertFalse(isEqual)
	}
}
