////
// 🦠 Corona-Warn-App
//

import XCTest
@testable import ENA

class OnBehalfScanQRCodeCellModelTests: CWATestCase {

	func testGIVEN_CellModel_THEN_InitialStateIsAsExpected() {
		// GIVEN
		let cellViewModel = OnBehalfScanQRCodeCellModel()

		// THEN
		XCTAssertEqual(
			cellViewModel.text,
			AppStrings.OnBehalfCheckinSubmission.TraceLocationSelection.scanButtonTitle
		)
		XCTAssertEqual(
			cellViewModel.textColorPublisher.value,
			UIColor.enaColor(for: .textPrimary1)
		)
		XCTAssertEqual(
			cellViewModel.iconImagePublisher.value,
			UIImage(named: "Icons_qrScan")
		)
		XCTAssertEqual(
			cellViewModel.accessibilityTraitsPublisher.value,
			[.button]
		)
	}

	func testGIVEN_CellModel_WHEN_SetEnabled_THEN_TextColorAndButtonStateChange() {
		// GIVEN
		let cellViewModel = OnBehalfScanQRCodeCellModel()

		// WHEN
		cellViewModel.setEnabled(false)

		// THEN
		XCTAssertEqual(
			cellViewModel.text,
			AppStrings.OnBehalfCheckinSubmission.TraceLocationSelection.scanButtonTitle
		)
		XCTAssertEqual(
			cellViewModel.textColorPublisher.value,
			UIColor.enaColor(for: .textPrimary2)
		)
		XCTAssertEqual(
			cellViewModel.iconImagePublisher.value,
			UIImage(named: "Icons_qrScan_Grey")
		)
		XCTAssertEqual(
			cellViewModel.accessibilityTraitsPublisher.value,
			[.button, .notEnabled]
		)
	}

}
