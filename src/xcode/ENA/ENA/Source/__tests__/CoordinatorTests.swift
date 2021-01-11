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
	func coordinatorUserDidRequestReset(exposureSubmissionService: ExposureSubmissionService) { }
}

class MockCoordinator: Coordinator {

	fileprivate var mockNavigationController: MockNavigationController
	// swiftlint:disable:next weak_delegate
	fileprivate var  mockDelegate: MockCoordinatorDelegate

	init() {
		mockNavigationController = MockNavigationController()
		mockDelegate = MockCoordinatorDelegate()
		super.init(mockDelegate, mockNavigationController, contactDiaryStore: MockDiaryStore())
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
		coordinator.showHome(enStateHandler: enStateHandler)
		let setViewControllersWasCalled = coordinator.mockNavigationController.setViewControllersWasCalled
		XCTAssertTrue(setViewControllersWasCalled)
	}

	func test_coordinator_shouldShowOnboarding() {
		coordinator.showOnboarding()
		let setViewControllersWasCalled = coordinator.mockNavigationController.setViewControllersWasCalled
		XCTAssertTrue(setViewControllersWasCalled)
	}

}
