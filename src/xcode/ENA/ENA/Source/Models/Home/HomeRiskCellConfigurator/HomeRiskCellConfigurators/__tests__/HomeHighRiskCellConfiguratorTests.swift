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

import Foundation

import XCTest
@testable import ENA

class HomeHighRiskCellConfiguratorTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

	func test_unknownRiskLevelCell_shouldHaveEqualHash() {
		let date = Date()

		let configurator1 = HomeHighRiskCellConfigurator(isLoading: false, numberRiskContacts: 0, daysSinceLastExposure: 0, lastUpdateDate: date, manualExposureDetectionState: .possible, detectionMode: .default, detectionInterval: 0)
		let configurator2 = HomeHighRiskCellConfigurator(isLoading: false, numberRiskContacts: 0, daysSinceLastExposure: 0, lastUpdateDate: date, manualExposureDetectionState: .possible, detectionMode: .default, detectionInterval: 0)

		let hash1 = configurator1.hashValue
		let hash2 = configurator2.hashValue

		XCTAssertEqual(hash1, hash2)
	}

	func test_unknownRiskLevelCell_shouldHaveDifferentHash1() {

		let date = Date()

		let configurator1 = HomeHighRiskCellConfigurator(isLoading: false, numberRiskContacts: 0, daysSinceLastExposure: 0, lastUpdateDate: date, manualExposureDetectionState: .possible, detectionMode: .default, detectionInterval: 0)
		let configurator2 = HomeHighRiskCellConfigurator(isLoading: false, numberRiskContacts: 4, daysSinceLastExposure: 0, lastUpdateDate: date, manualExposureDetectionState: .possible, detectionMode: .default, detectionInterval: 0)

		let hash1 = configurator1.hashValue
		let hash2 = configurator2.hashValue

		XCTAssertNotEqual(hash1, hash2)
	}

	func test_unknownRiskLevelCell_shouldHaveDifferentHash2() {

		let date = Date()

		let configurator1 = HomeHighRiskCellConfigurator(isLoading: false, numberRiskContacts: 0, daysSinceLastExposure: 0, lastUpdateDate: date, manualExposureDetectionState: .waiting, detectionMode: .default, detectionInterval: 0)
		let configurator2 = HomeHighRiskCellConfigurator(isLoading: false, numberRiskContacts: 0, daysSinceLastExposure: 0, lastUpdateDate: date, manualExposureDetectionState: .possible, detectionMode: .default, detectionInterval: 0)

		let hash1 = configurator1.hashValue
		let hash2 = configurator2.hashValue

		XCTAssertNotEqual(hash1, hash2)
	}

	func test_unknownRiskLevelCell_shouldBeEqual() {
		let date = Date()

		let configurator1 = HomeHighRiskCellConfigurator(isLoading: false, numberRiskContacts: 0, daysSinceLastExposure: 0, lastUpdateDate: date, manualExposureDetectionState: .waiting, detectionMode: .default, detectionInterval: 0)
		let configurator2 = HomeHighRiskCellConfigurator(isLoading: false, numberRiskContacts: 0, daysSinceLastExposure: 0, lastUpdateDate: date, manualExposureDetectionState: .waiting, detectionMode: .default, detectionInterval: 0)

		let isEqual = configurator1 == configurator2
		XCTAssertTrue(isEqual)
	}

	func test_unknownRiskLevelCell_shouldntBeEqual1() {
		let date = Date()

		let configurator1 = HomeHighRiskCellConfigurator(isLoading: false, numberRiskContacts: 0, daysSinceLastExposure: 0, lastUpdateDate: date, manualExposureDetectionState: .possible, detectionMode: .default, detectionInterval: 0)
		let configurator2 = HomeHighRiskCellConfigurator(isLoading: false, numberRiskContacts: 0, daysSinceLastExposure: 0, lastUpdateDate: date, manualExposureDetectionState: .possible, detectionMode: .default, detectionInterval: 99)

		let isEqual = configurator1 == configurator2

		XCTAssertFalse(isEqual)
	}

	func test_unknownRiskLevelCell_shouldntBeEqual2() {
		let date = Date()

		let configurator1 = HomeHighRiskCellConfigurator(isLoading: false, numberRiskContacts: 0, daysSinceLastExposure: 0, lastUpdateDate: date, manualExposureDetectionState: .possible, detectionMode: .default, detectionInterval: 0)
		let configurator2 = HomeHighRiskCellConfigurator(isLoading: false, numberRiskContacts: 0, daysSinceLastExposure: 0, lastUpdateDate: date.addingTimeInterval(22), manualExposureDetectionState: .possible, detectionMode: .default, detectionInterval: 0)

		let isEqual = configurator1 == configurator2

		XCTAssertFalse(isEqual)
	}
}
