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
import Foundation

private class MockNavigationController: UINavigationController {

	var setViewControllersWasCalled = false
	var presentWasCalled = false
	var pushViewControllerWasCalled = false

	override func setViewControllers(_ viewControllers: [UIViewController], animated: Bool) {
		setViewControllersWasCalled = true
	}

	override func present(_ viewControllerToPresent: UIViewController, animated flag: Bool, completion: (() -> Void)? = nil) {
		presentWasCalled = true
	}

	override func pushViewController(_ viewController: UIViewController, animated: Bool) {
		pushViewControllerWasCalled = true
	}
}

private class MockCoordinatorDelegate: CoordinatorDelegate {
	func coordinatorUserDidRequestReset() { }
}

class MockCoordinator: Coordinator {

	fileprivate var mockNavigationController: MockNavigationController
	// swiftlint:disable:next weak_delegate
	fileprivate var  mockDelegate: MockCoordinatorDelegate

	init() {
		mockNavigationController = MockNavigationController()
		mockDelegate = MockCoordinatorDelegate()
		super.init(mockDelegate, mockNavigationController)
	}
}

class CoordinatorTests: XCTestCase {

	var coordinator: MockCoordinator!

    override func setUpWithError() throws {
        coordinator = MockCoordinator()
    }

    override func tearDownWithError() throws {
        coordinator = nil
    }

	func test_coordinator_shouldShowHome() {
		let delegate = MockStateHandlerObserverDelegate()
		let enStateHandler = ENStateHandler(initialExposureManagerState: .init(), delegate: delegate)
		coordinator.showHome(enStateHandler: enStateHandler, state: .init(exposureManager: .init(), detectionMode: .automatic, risk: nil))
		let setViewControllersWasCalled = coordinator.mockNavigationController.setViewControllersWasCalled
		XCTAssertTrue(setViewControllersWasCalled)
	}

	func test_coordinator_shouldShowOnboarding() {
		coordinator.showOnboarding()
		let setViewControllersWasCalled = coordinator.mockNavigationController.setViewControllersWasCalled
		XCTAssertTrue(setViewControllersWasCalled)
	}

	func test_coordinator_shouldShowRiskLegend() {
		coordinator.showRiskLegend()
		let presentWasCalled = coordinator.mockNavigationController.presentWasCalled
		XCTAssertTrue(presentWasCalled)
	}

	func test_coordinator_shouldShowExposureNotificationSetting() {
		coordinator.showExposureNotificationSetting(enState: .unknown)
		let pushViewControllerWasCalled = coordinator.mockNavigationController.pushViewControllerWasCalled
		XCTAssertTrue(pushViewControllerWasCalled)
	}

	func test_coordinator_shouldShowExposureDetection() {
		let state = HomeInteractor.State(detectionMode: .automatic, exposureManagerState: .init(), enState: .unknown, risk: nil)
		coordinator.showExposureDetection(state: state, isRequestRiskRunning: false)
		let presentWasCalled = coordinator.mockNavigationController.presentWasCalled
		XCTAssertTrue(presentWasCalled)
	}

	func test_coordinator_shouldShowExposureSubmission() {
		coordinator.showExposureSubmission()
		let presentWasCalled = coordinator.mockNavigationController.presentWasCalled
		XCTAssertTrue(presentWasCalled)
	}

	func test_coordinator_shouldShowInviteFriends() {
		coordinator.showInviteFriends()
		let pushViewControllerWasCalled = coordinator.mockNavigationController.pushViewControllerWasCalled
		XCTAssertTrue(pushViewControllerWasCalled)
	}

	func test_coordinator_shouldShowAppInformation() {
		coordinator.showAppInformation()
		let pushViewControllerWasCalled = coordinator.mockNavigationController.pushViewControllerWasCalled
		XCTAssertTrue(pushViewControllerWasCalled)
	}

	func test_coordinator_shouldShowSettings() {
		coordinator.showSettings(enState: .unknown)
		let pushViewControllerWasCalled = coordinator.mockNavigationController.pushViewControllerWasCalled
		XCTAssertTrue(pushViewControllerWasCalled)
	}

}
