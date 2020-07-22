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

@testable import ENA
import XCTest

class HomeRiskCellConfiguratorTests: XCTestCase {

    func testLowRiskCell_configureManualButton() throws {

		// Intialize.
		let detectionInterval = 24
        let configurator = HomeLowRiskCellConfigurator(
			isLoading: false,
			numberRiskContacts: 0,
			lastUpdateDate: Date().addingTimeInterval(-8 * 60 * 60),
			isButtonHidden: false,
			detectionMode: .manual,
			manualExposureDetectionState: .waiting,
			detectionInterval: detectionInterval,
			activeTracing: ActiveTracing(interval: .init(hours: 42))
		)

		guard let cell = loadCell(ofType: RiskLevelCollectionViewCell.self) else {
			return XCTFail("Could not load RiskLevelCollectionViewCell.")
		}

		configurator.configure(cell: cell)

		// Test if button is disabled.
		configurator.configureButton(for: cell)
		XCTAssertFalse(cell.updateButton.isEnabled)
		XCTAssertEqual(cell.updateButton.currentTitle, String(format: AppStrings.Home.riskCardIntervalDisabledButtonTitle, "\(detectionInterval)"))

		// Test if button shows refresh date.
		let nextRefreshDate = "00:11:22"
		configurator.timeUntilUpdate = nextRefreshDate
		configurator.configureButton(for: cell)
		XCTAssertFalse(cell.updateButton.isEnabled)
		XCTAssertEqual(cell.updateButton.currentTitle, String(format: AppStrings.ExposureDetection.refreshIn, nextRefreshDate))

		// Test if button shows correct text when enabled.
		configurator.isButtonEnabled = true
		configurator.configureButton(for: cell)
		XCTAssert(cell.updateButton.isEnabled)
		XCTAssertEqual(cell.updateButton.currentTitle, AppStrings.Home.riskCardUpdateButton)

		// Test if button is clickable and triggers action.
		let expectation = self.expectation(description: "Expect button to trigger action")
		configurator.buttonAction = {
			expectation.fulfill()
		}

		configurator.configureButton(for: cell)
		cell.updateButton.sendActions(for: .touchUpInside)
		waitForExpectations(timeout: .short)
    }

	func testHighRiskCell_configureManualButton() {

		// Intialize.
		let detectionInterval = 24
		let configurator = HomeHighRiskCellConfigurator(
			isLoading: false,
			numberRiskContacts: 10,
			daysSinceLastExposure: 1,
			lastUpdateDate: Date().addingTimeInterval(-3 * 60 * 60),
			manualExposureDetectionState: .waiting,
			detectionMode: .manual,
			detectionInterval: detectionInterval
		)

		guard let cell = loadCell(ofType: RiskLevelCollectionViewCell.self) else {
			return XCTFail("Could not load RiskLevelCollectionViewCell.")
		}

		configurator.configure(cell: cell)

		// Test if button is disabled.
		configurator.configureButton(for: cell)
		XCTAssertFalse(cell.updateButton.isEnabled)
		XCTAssertEqual(cell.updateButton.currentTitle, String(format: AppStrings.Home.riskCardIntervalDisabledButtonTitle, "\(detectionInterval)"))

		// Test if button shows refresh date.
		let nextRefreshDate = "00:11:22"
		configurator.timeUntilUpdate = nextRefreshDate
		configurator.configureButton(for: cell)
		XCTAssertFalse(cell.updateButton.isEnabled)
		XCTAssertEqual(cell.updateButton.currentTitle, String(format: AppStrings.ExposureDetection.refreshIn, nextRefreshDate))

		// Test if button shows correct text when enabled.
		configurator.isButtonEnabled = true
		configurator.configureButton(for: cell)
		XCTAssert(cell.updateButton.isEnabled)
		XCTAssertEqual(cell.updateButton.currentTitle, AppStrings.Home.riskCardUpdateButton)

		// Test if button is clickable and triggers action.
		let expectation = self.expectation(description: "Expect button to trigger action")
		configurator.buttonAction = {
			expectation.fulfill()
		}

		configurator.configureButton(for: cell)
		cell.updateButton.sendActions(for: .touchUpInside)
		waitForExpectations(timeout: .short)
	}
}

private extension HomeRiskCellConfiguratorTests {
	func loadCell<Cell: UICollectionViewCell>(ofType: Cell.Type) -> Cell? {
		guard let cell = Bundle(for: Cell.self).loadNibNamed("\(Cell.self)", owner: nil)?.first as? Cell else {
			return nil
		}

		return cell
	}
}
