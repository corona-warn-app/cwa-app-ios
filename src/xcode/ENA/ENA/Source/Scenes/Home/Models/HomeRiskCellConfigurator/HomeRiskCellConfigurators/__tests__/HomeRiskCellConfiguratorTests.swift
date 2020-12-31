//
// 🦠 Corona-Warn-App
//

@testable import ENA
import XCTest

class HomeRiskCellConfiguratorTests: XCTestCase {

    func testLowRiskCell_configureManualButton() throws {

		// Intialize.
		let detectionInterval = 24
        let configurator = HomeLowRiskCellConfigurator(
			state: .idle,
			numberOfDaysWithLowRisk: 0,
			lastUpdateDate: Date().addingTimeInterval(-8 * 60 * 60),
			isButtonHidden: false,
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
			state: .idle,
			numberOfDaysWithHighRisk: 10,
			mostRecentDateWithHighRisk: Date(),
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
