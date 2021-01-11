//
// 🦠 Corona-Warn-App
//

import Foundation
import XCTest
@testable import ENA

class ExposureDetectionViewControllerTests: XCTestCase {

	// MARK: - Setup.

	func createVC() -> ExposureDetectionViewController? {
		let store = MockTestStore()

		let downloadedPackagesStore: DownloadedPackagesStore = DownloadedPackagesSQLLiteStore.inMemory()
		downloadedPackagesStore.open()

		let client = ClientMock()
		let keyPackageDownload = KeyPackageDownload(
			downloadedPackagesStore: downloadedPackagesStore,
			client: client,
			wifiClient: client,
			store: store
		)

		let homeState = HomeState(
			store: MockTestStore(),
			riskProvider: RiskProvider(
				configuration: .default,
				store: store,
				appConfigurationProvider: CachedAppConfigurationMock(),
				exposureManagerState: ExposureManagerState(authorized: true, enabled: true, status: .active),
				keyPackageDownload: keyPackageDownload,
				exposureDetectionExecutor: ExposureDetectionDelegateStub(result: .success([MutableENExposureWindow()]))
			),
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

	// MARK: - Exposure detection model.

	func testHighRiskState() {
		guard let vc = createVC() else { return }
		vc.loadViewIfNeeded()

		XCTAssertNotNil(vc.tableView)
	}

}
