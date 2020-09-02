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

class HomeUnknown48hRiskCellConfiguratorTests: XCTestCase {

	func test_unknownRiskLevelCell_shouldHaveEqualHash() {
		let date = Date()
		let configurator1 = HomeUnknown48hRiskCellConfigurator(isLoading: false, lastUpdateDate: date, detectionInterval: 0, detectionMode: .manual, manualExposureDetectionState: .possible, previousRiskLevel: .low)
		let configurator2 = HomeUnknown48hRiskCellConfigurator(isLoading: false, lastUpdateDate: date, detectionInterval: 0, detectionMode: .manual, manualExposureDetectionState: .possible, previousRiskLevel: .low)

		let hash1 = configurator1.hashValue
		let hash2 = configurator2.hashValue

		XCTAssertEqual(hash1, hash2)
	}

	func test_unknownRiskLevelCell_shouldHaveDifferentHash1() {

		let date = Date()

		let configurator1 = HomeUnknown48hRiskCellConfigurator(isLoading: false, lastUpdateDate: date, detectionInterval: 0, detectionMode: .manual, manualExposureDetectionState: .possible, previousRiskLevel: .low)
		let configurator2 = HomeUnknown48hRiskCellConfigurator(isLoading: false, lastUpdateDate: date, detectionInterval: 0, detectionMode: .automatic, manualExposureDetectionState: .possible, previousRiskLevel: .increased)

		let hash1 = configurator1.hashValue
		let hash2 = configurator2.hashValue

		XCTAssertNotEqual(hash1, hash2)
	}

	func test_unknownRiskLevelCell_shouldHaveDifferentHash2() {

		let date = Date()

		let configurator1 = HomeUnknown48hRiskCellConfigurator(isLoading: false, lastUpdateDate: date, detectionInterval: 0, detectionMode: .manual, manualExposureDetectionState: .possible, previousRiskLevel: .low)
		let configurator2 = HomeUnknown48hRiskCellConfigurator(isLoading: false, lastUpdateDate: date, detectionInterval: 3, detectionMode: .automatic, manualExposureDetectionState: .waiting, previousRiskLevel: .low)

		let hash1 = configurator1.hashValue
		let hash2 = configurator2.hashValue
		XCTAssertNotEqual(hash1, hash2)
	}

	func test_unknownRiskLevelCell_shouldBeEqual() {
		let date = Date()
		let configurator1 = HomeUnknown48hRiskCellConfigurator(isLoading: false, lastUpdateDate: date, detectionInterval: 0, detectionMode: .manual, manualExposureDetectionState: .possible, previousRiskLevel: .increased)
		let configurator2 = HomeUnknown48hRiskCellConfigurator(isLoading: false, lastUpdateDate: date, detectionInterval: 0, detectionMode: .manual, manualExposureDetectionState: .possible, previousRiskLevel: .increased)

		let isEqual = configurator1 == configurator2
		XCTAssertTrue(isEqual)
	}

	func test_unknownRiskLevelCell_shouldntBeEqual1() {
		let date = Date()
		let configurator1 = HomeUnknown48hRiskCellConfigurator(isLoading: false, lastUpdateDate: date, detectionInterval: 0, detectionMode: .manual, manualExposureDetectionState: .possible, previousRiskLevel: .low)
		let configurator2 = HomeUnknown48hRiskCellConfigurator(isLoading: false, lastUpdateDate: date, detectionInterval: 0, detectionMode: .automatic, manualExposureDetectionState: .possible, previousRiskLevel: .increased)

		let isEqual = configurator1 == configurator2
		XCTAssertFalse(isEqual)
	}

	func test_unknownRiskLevelCell_shouldntBeEqual2() {
		let date = Date()
		let configurator1 = HomeUnknown48hRiskCellConfigurator(isLoading: false, lastUpdateDate: date, detectionInterval: 0, detectionMode: .manual, manualExposureDetectionState: .possible, previousRiskLevel: .increased)
		let configurator2 = HomeUnknown48hRiskCellConfigurator(isLoading: false, lastUpdateDate: date, detectionInterval: 900, detectionMode: .manual, manualExposureDetectionState: .waiting, previousRiskLevel: .increased)

		let isEqual = configurator1 == configurator2
		XCTAssertFalse(isEqual)
	}
}
