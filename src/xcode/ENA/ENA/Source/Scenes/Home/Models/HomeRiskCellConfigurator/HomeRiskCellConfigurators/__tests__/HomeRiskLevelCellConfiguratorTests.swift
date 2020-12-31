//
// 🦠 Corona-Warn-App
//

import Foundation

import XCTest
@testable import ENA

class HomeRiskLevelCellConfiguratorTests: XCTestCase {
	
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

	func test_riskLevelCell_shouldHaveEqualHash() {
		let date = Date()
		let configurator1 = HomeRiskLevelCellConfigurator(state: .idle, isButtonEnabled: false, isButtonHidden: false, lastUpdateDate: date, detectionInterval: 0)
		let configurator2 = HomeRiskLevelCellConfigurator(state: .idle, isButtonEnabled: false, isButtonHidden: false, lastUpdateDate: date, detectionInterval: 0)

		let hash1 = configurator1.hashValue
		let hash2 = configurator2.hashValue

		XCTAssertEqual(hash1, hash2)
	}

	func test_riskLevelCell_shouldHaveDifferentHash1() {

		let date = Date()

		let configurator1 = HomeRiskLevelCellConfigurator(state: .idle, isButtonEnabled: false, isButtonHidden: false, lastUpdateDate: date, detectionInterval: 0)
		let configurator2 = HomeRiskLevelCellConfigurator(state: .downloading, isButtonEnabled: false, isButtonHidden: false, lastUpdateDate: date, detectionInterval: 0)

		let hash1 = configurator1.hashValue
		let hash2 = configurator2.hashValue

		XCTAssertNotEqual(hash1, hash2)
	}

	func test_riskLevelCell_shouldHaveDifferentHash2() {

		let date = Date()

		let configurator1 = HomeRiskLevelCellConfigurator(state: .idle, isButtonEnabled: false, isButtonHidden: false, lastUpdateDate: date, detectionInterval: 0)
		let configurator2 = HomeRiskLevelCellConfigurator(state: .detecting, isButtonEnabled: false, isButtonHidden: false, lastUpdateDate: date.addingTimeInterval(-10), detectionInterval: 0)

		let hash1 = configurator1.hashValue
		let hash2 = configurator2.hashValue
		XCTAssertNotEqual(hash1, hash2)
	}

	func test_riskLevelCell_shouldBeEqual() {
		let date = Date()
		let configurator1 = HomeRiskLevelCellConfigurator(state: .idle, isButtonEnabled: false, isButtonHidden: false, lastUpdateDate: date, detectionInterval: 0)
		let configurator2 = HomeRiskLevelCellConfigurator(state: .idle, isButtonEnabled: false, isButtonHidden: false, lastUpdateDate: date, detectionInterval: 0)

		let isEqual = configurator1 == configurator2
		XCTAssertTrue(isEqual)
	}

	func test_riskLevelCell_shouldntBeEqual1() {
		let date = Date()
		let configurator1 = HomeRiskLevelCellConfigurator(state: .idle, isButtonEnabled: false, isButtonHidden: false, lastUpdateDate: date, detectionInterval: 0)
		let configurator2 = HomeRiskLevelCellConfigurator(state: .idle, isButtonEnabled: false, isButtonHidden: false, lastUpdateDate: date.addingTimeInterval(100), detectionInterval: 0)

		let isEqual = configurator1 == configurator2
		XCTAssertFalse(isEqual)
	}
}
