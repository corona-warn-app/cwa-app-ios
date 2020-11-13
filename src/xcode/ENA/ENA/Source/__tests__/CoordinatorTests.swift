//
// 🦠 Corona-Warn-App
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
		coordinator.showHome(enStateHandler: enStateHandler, state: .init(exposureManager: .init(), detectionMode: .automatic, risk: nil, riskDetectionFailed: false))
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
		let state = HomeInteractor.State(detectionMode: .automatic, exposureManagerState: .init(), enState: .unknown, risk: nil, riskDetectionFailed: false)
		coordinator.showExposureDetection(state: state, activityState: .idle)
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
