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
import Foundation
import XCTest

class ExposureSubmissionCoordinatorTests: XCTestCase {

	// MARK: - Attributes.

	private var parentNavigationController: UINavigationController!
	private var exposureSubmissionService: MockExposureSubmissionService!
	// swiftlint:disable:next weak_delegate
	private var delegate: MockExposureSubmissionCoordinatorDelegate!

	// MARK: - Setup and teardown methods.

	override func setUp() {
		parentNavigationController = UINavigationController()
		exposureSubmissionService = MockExposureSubmissionService()
		delegate = MockExposureSubmissionCoordinatorDelegate()
	}

	// MARK: - Helper methods.

	private func createCoordinator(
		parentNavigationController: UINavigationController,
		exposureSubmissionService: ExposureSubmissionService,
		delegate: ExposureSubmissionCoordinatorDelegate) -> ExposureSubmissionCoordinating {

		return ExposureSubmissionCoordinator(
			parentNavigationController: parentNavigationController,
			exposureSubmissionService: exposureSubmissionService,
			delegate: delegate
		)
	}

	private func getNavigationController(from coordinator: ExposureSubmissionCoordinating) -> UINavigationController? {
		guard let navigationController = (coordinator as? ExposureSubmissionCoordinator)?.navigationController else {
			XCTFail("Could not load navigation controller from coordinator.")
			return nil
		}

		return navigationController
	}

	// MARK: - Navigation tests.

	func testStart_default() {
		let coordinator = createCoordinator(
			parentNavigationController: parentNavigationController,
			exposureSubmissionService: exposureSubmissionService,
			delegate: delegate
		)

		coordinator.start(with: nil)

		// Get navigation controller and make sure to load view.
		let navigationController = getNavigationController(from: coordinator)
		_ = navigationController?.view

		XCTAssertNotNil(navigationController)
		XCTAssertNotNil(navigationController?.topViewController)
		guard let vc = navigationController?.topViewController as? ExposureSubmissionIntroViewController else {
			XCTFail("Could not load presented view controller.")
			return
		}

		XCTAssertNotNil(vc.coordinator)
	}

	func testStart_withResult() {
		let result = TestResult.negative
		exposureSubmissionService.hasRegistrationTokenCallback = { true }
		let coordinator = createCoordinator(
			parentNavigationController: parentNavigationController,
			exposureSubmissionService: exposureSubmissionService,
			delegate: delegate
		)

		coordinator.start(with: result)

		// Get navigation controller and make sure to load view.
		let navigationController = getNavigationController(from: coordinator)
		_ = navigationController?.view

		XCTAssertNotNil(navigationController)
		XCTAssertNotNil(navigationController?.topViewController)
		guard let vc = navigationController?.topViewController as? ExposureSubmissionTestResultViewController else {
			XCTFail("Could not load presented view controller.")
			return
		}

		XCTAssertNotNil(vc.coordinator)
		XCTAssertNotNil(vc.exposureSubmissionService)
		XCTAssertEqual(vc.testResult, result)
	}

	func testDismiss() {
		let window = UIWindow(frame: UIScreen.main.bounds)
		window.rootViewController = parentNavigationController
		window.makeKeyAndVisible()

		let coordinator = createCoordinator(
			parentNavigationController: parentNavigationController,
			exposureSubmissionService: exposureSubmissionService,
			delegate: delegate
		)

		let expectation = self.expectation(description: "Expect delegate to be called on disappear.")
		delegate.onExposureSubmissionCoordinatorWillDisappear = { _ in expectation.fulfill() }

		XCTAssertNil(parentNavigationController.presentedViewController)
		coordinator.start(with: nil)
		XCTAssertNotNil(parentNavigationController.presentedViewController)

		coordinator.dismiss()
		waitForExpectations(timeout: 1.0)
	}

	func testShowOverview() {
		let coordinator = createCoordinator(
			parentNavigationController: parentNavigationController,
			exposureSubmissionService: exposureSubmissionService,
			delegate: delegate
		)

		coordinator.start(with: nil)
		coordinator.showOverviewScreen()

		// Get navigation controller and make sure to load view.
		let navigationController = getNavigationController(from: coordinator)
		// _ = navigationController?.view
		sleep(3)

		XCTAssertNotNil(navigationController)
		XCTAssertNotNil(navigationController?.topViewController)
		guard let vc = navigationController?.topViewController as? ExposureSubmissionOverviewViewController else {
			XCTFail("Could not load presented view controller.")
			return
		}

		XCTAssertNotNil(vc.coordinator)
		XCTAssertNotNil(vc.service)
	}

	func testShowTestResultScreen() {
		let result = TestResult.negative
		let coordinator = createCoordinator(
			parentNavigationController: parentNavigationController,
			exposureSubmissionService: exposureSubmissionService,
			delegate: delegate
		)

		coordinator.start(with: nil)
		coordinator.showTestResultScreen(with: result)

		// Get navigation controller and make sure to load view.
		let navigationController = getNavigationController(from: coordinator)
		_ = navigationController?.view

		XCTAssertNotNil(navigationController)
		XCTAssertNotNil(navigationController?.topViewController)
		guard let vc = navigationController?.topViewController as? ExposureSubmissionTestResultViewController else {
			XCTFail("Could not load presented view controller.")
			return
		}

		XCTAssertNotNil(vc.coordinator)
		XCTAssertNotNil(vc.exposureSubmissionService)
		XCTAssertEqual(vc.testResult, result)
	}

	func testShowHotlineScreen() {
		let coordinator = createCoordinator(
			parentNavigationController: parentNavigationController,
			exposureSubmissionService: exposureSubmissionService,
			delegate: delegate
		)

		coordinator.start(with: nil)
		coordinator.showHotlineScreen()

		// Get navigation controller and make sure to load view.
		let navigationController = getNavigationController(from: coordinator)
		_ = navigationController?.view

		XCTAssertNotNil(navigationController)
		XCTAssertNotNil(navigationController?.topViewController)
		guard let vc = navigationController?.topViewController as? ExposureSubmissionHotlineViewController else {
			XCTFail("Could not load presented view controller.")
			return
		}

		XCTAssertNotNil(vc.coordinator)
	}

	func testShowTanScreen() {
		let coordinator = createCoordinator(
			parentNavigationController: parentNavigationController,
			exposureSubmissionService: exposureSubmissionService,
			delegate: delegate
		)

		coordinator.start(with: nil)
		coordinator.showTanScreen()

		// Get navigation controller and make sure to load view.
		let navigationController = getNavigationController(from: coordinator)
		_ = navigationController?.view

		XCTAssertNotNil(navigationController)
		XCTAssertNotNil(navigationController?.topViewController)
		guard let vc = navigationController?.topViewController as? ExposureSubmissionTanInputViewController else {
			XCTFail("Could not load presented view controller.")
			return
		}

		XCTAssertNotNil(vc.coordinator)
		XCTAssertNotNil(vc.exposureSubmissionService)
	}

	func showWarnOthersScreen() {
		let coordinator = createCoordinator(
			parentNavigationController: parentNavigationController,
			exposureSubmissionService: exposureSubmissionService,
			delegate: delegate
		)

		coordinator.start(with: nil)
		coordinator.showWarnOthersScreen()

		// Get navigation controller and make sure to load view.
		let navigationController = getNavigationController(from: coordinator)
		_ = navigationController?.view

		XCTAssertNotNil(navigationController)
		XCTAssertNotNil(navigationController?.topViewController)
		guard let vc = navigationController?.topViewController as? ExposureSubmissionWarnOthersViewController else {
			XCTFail("Could not load presented view controller.")
			return
		}

		XCTAssertNotNil(vc.coordinator)
		XCTAssertNotNil(vc.exposureSubmissionService)
	}

	func showThankYouScreen() {
		let coordinator = createCoordinator(
			parentNavigationController: parentNavigationController,
			exposureSubmissionService: exposureSubmissionService,
			delegate: delegate
		)

		coordinator.start(with: nil)
		coordinator.showThankYouScreen()

		// Get navigation controller and make sure to load view.
		let navigationController = getNavigationController(from: coordinator)
		_ = navigationController?.view

		XCTAssertNotNil(navigationController)
		XCTAssertNotNil(navigationController?.topViewController)
		guard let vc = navigationController?.topViewController as? ExposureSubmissionSuccessViewController else {
			XCTFail("Could not load presented view controller.")
			return
		}

		XCTAssertNotNil(vc.coordinator)
	}

}
