//
// 🦠 Corona-Warn-App
//

import Foundation
import XCTest
@testable import ENA

class ExposureDetectionViewControllerTests: XCTestCase {

	// MARK: - Setup.

	func createVC(with state: ExposureDetectionViewController.State) -> ExposureDetectionViewController? {
		ExposureDetectionViewController(state: state, store: MockTestStore(), delegate: MockExposureDetectionViewControllerDelegate())
	}

	// MARK: - Exposure detection model.

	func testHighRiskState() {
		let state = ExposureDetectionViewController.State(
			riskState: .risk(
				.init(
					level: .high,
					details: .init(
						mostRecentDateWithRiskLevel: Date(),
						numberOfDaysWithRiskLevel: 2,
						activeTracing: .init(interval: 14 * 86400),
						exposureDetectionDate: nil
					),
					riskLevelHasChanged: false
				)
			),
			detectionMode: .automatic,
			activityState: .idle,
			previousRiskLevel: nil
		)

		guard let vc = createVC(with: state) else { return }
		_ = vc.view
		XCTAssertNotNil(vc.tableView)
	}

	func testGIVEN_lowRiskWithTwoEncounter_WHEN_createDynamicCell_THEN_lastCellHasLinkToFAQ() {
		// GIVEN
		let lowRisk = Risk(
			level: .low,
			details: .init(
				mostRecentDateWithRiskLevel: Date(),
				numberOfDaysWithRiskLevel: 2,
				activeTracing: .init(interval: 14 * 86400),
				exposureDetectionDate: nil
			),
			riskLevelHasChanged: false
		)

		let state = ExposureDetectionViewController.State(
			riskState: .risk(lowRisk),
			detectionMode: .automatic,
			activityState: .idle,
			previousRiskLevel: nil
		)

		guard let vc = createVC(with: state) else { return }
		_ = vc.view
		XCTAssertNotNil(vc.tableView)

		// WHEN

		let lowRiskCellModel = vc.dynamicTableViewModel(for: state.riskLevel, riskDetectionFailed: state.riskDetectionFailed, isTracingEnabled: state.isTracingEnabled)
		let lastSection = lowRiskCellModel.numberOfSection - 1
		let lastRow = lowRiskCellModel.numberOfRows(inSection: lastSection, for: vc) - 1

		let dynamicCell = lowRiskCellModel.cell(at: IndexPath(row: lastRow, section: lastSection))
		XCTAssertNotNil(dynamicCell)

		// THEN
		switch dynamicCell.action {
		case .open(url: let url):
			XCTAssertEqual(AppStrings.ExposureDetection.explanationFAQLink, url?.absoluteString)
		default:
			XCTFail("FAQ Link cell not found")
		}
	}

	func testGIVEN_lowRiskWithNoEncounter_WHEN_createDynamicCell_THEN_lastCellHasNoLinkToFAQ() {
		// GIVEN
		let lowRisk = Risk(
			level: .low,
			details: .init(
				mostRecentDateWithRiskLevel: Date(),
				numberOfDaysWithRiskLevel: 0,
				activeTracing: .init(interval: 14 * 86400),
				exposureDetectionDate: nil
			),
			riskLevelHasChanged: false
		)

		let state = ExposureDetectionViewController.State(
			riskState: .risk(lowRisk),
			detectionMode: .automatic,
			activityState: .idle,
			previousRiskLevel: nil
		)

		guard let vc = createVC(with: state) else { return }
		_ = vc.view
		XCTAssertNotNil(vc.tableView)

		// WHEN

		let lowRiskCellModel = vc.dynamicTableViewModel(for: state.riskLevel, riskDetectionFailed: state.riskDetectionFailed, isTracingEnabled: state.isTracingEnabled)
		let lastSection = lowRiskCellModel.numberOfSection - 1
		let lastRow = lowRiskCellModel.numberOfRows(inSection: lastSection, for: vc) - 1

		let dynamicCell = lowRiskCellModel.cell(at: IndexPath(row: lastRow, section: lastSection))
		XCTAssertNotNil(dynamicCell)

		// THEN
		switch dynamicCell.action {
		case .open(url: let url):
			XCTAssertNotEqual(AppStrings.ExposureDetection.explanationFAQLink, url?.absoluteString)
		default:
			XCTAssert(true)
		}

	}


}
