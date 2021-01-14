//
// 🦠 Corona-Warn-App
//

import Foundation
import XCTest
@testable import ENA

class ExposureDetectionViewControllerTests: XCTestCase {

	func testHighRiskState() {
		let vc = createVC()
		vc.loadViewIfNeeded()

		XCTAssertNotNil(vc.tableView)
	}

	// MARK: - Private

	private func createVC() -> ExposureDetectionViewController {
		let store = MockTestStore()

		let homeState = HomeState(
			store: store,
			riskProvider: MockRiskProvider(),
			exposureManagerState: ExposureManagerState(authorized: true, enabled: true, status: .active),
			enState: .enabled,
			exposureSubmissionService: MockExposureSubmissionService()
		)

		return ExposureDetectionViewController(
			viewModel: ExposureDetectionViewModel(
				homeState: homeState,
				onInactiveButtonTap: { _ in }
			),
			store: store
		)
	}

}
