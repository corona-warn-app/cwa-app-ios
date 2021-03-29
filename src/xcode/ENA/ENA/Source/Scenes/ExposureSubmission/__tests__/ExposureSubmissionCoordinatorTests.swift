//
// 🦠 Corona-Warn-App
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

	private var store: Store!
	
	override func setUpWithError() throws {
		store = MockTestStore()
		parentNavigationController = UINavigationController()
		exposureSubmissionService = MockExposureSubmissionService()
		delegate = MockExposureSubmissionCoordinatorDelegate()
	}

	// MARK: - Helper methods.

	private func createCoordinator(
		parentNavigationController: UINavigationController,
		exposureSubmissionService: ExposureSubmissionService,
		delegate: ExposureSubmissionCoordinatorDelegate) -> ExposureSubmissionCoordinator {

		return ExposureSubmissionCoordinator(
			warnOthersReminder: WarnOthersReminder(store: self.store),
			parentNavigationController: parentNavigationController,
			exposureSubmissionService: exposureSubmissionService,
			store: self.store,
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
		navigationController?.loadViewIfNeeded()

		XCTAssertNotNil(navigationController)
		XCTAssertNotNil(navigationController?.topViewController)
		guard let vc = navigationController?.topViewController as? ExposureSubmissionIntroViewController else {
			XCTFail("Could not load presented view controller.")
			return
		}

		vc.viewDidLoad()
		XCTAssertNotNil(vc.dynamicTableViewModel)
		XCTAssertEqual(vc.dynamicTableViewModel.numberOfSection, 2)
		
		let section1 = vc.dynamicTableViewModel.section(0)
		XCTAssertNotNil(section1)
		XCTAssertEqual(section1.cells.count, 2)
		
		let section2 = vc.dynamicTableViewModel.section(1)
		XCTAssertNotNil(section2)
		XCTAssertEqual(section2.cells.count, 4)

	}

	func testStart_withNegativeResult() {
		let result = TestResult.negative
		exposureSubmissionService.hasRegistrationToken = true
		let coordinator = createCoordinator(
			parentNavigationController: parentNavigationController,
			exposureSubmissionService: exposureSubmissionService,
			delegate: delegate
		)

		coordinator.start(with: result)

		// Get navigation controller and make sure to load view.
		let navigationController = getNavigationController(from: coordinator)
		navigationController?.loadViewIfNeeded()

		XCTAssertNotNil(navigationController)
		XCTAssertNotNil(navigationController?.topViewController)
		XCTAssertNotNil(navigationController?.topViewController as? TopBottomContainerViewController<ExposureSubmissionTestResultViewController, FooterViewController>)
	}

	func testStart_withPositiveResult() {
		let result = TestResult.positive
		exposureSubmissionService.hasRegistrationToken = true
		let coordinator = createCoordinator(
			parentNavigationController: parentNavigationController,
			exposureSubmissionService: exposureSubmissionService,
			delegate: delegate
		)

		coordinator.start(with: result)

		// Get navigation controller and make sure to load view.
		let navigationController = getNavigationController(from: coordinator)
		navigationController?.loadViewIfNeeded()

		XCTAssertNotNil(navigationController)
		XCTAssertNotNil(navigationController?.topViewController)
		XCTAssertNotNil(navigationController?.topViewController as? TopBottomContainerViewController<TestResultAvailableViewController, FooterViewController>)
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
		waitForExpectations(timeout: .medium)
	}

	func testInitialViewController() throws {
		// dummy
		exposureSubmissionService.hasRegistrationToken = true
		let coordinator = createCoordinator(
			parentNavigationController: parentNavigationController,
			exposureSubmissionService: exposureSubmissionService,
			delegate: delegate
		)

		let unknown = coordinator.getInitialViewController(with: .positive)
		XCTAssertTrue(unknown is TopBottomContainerViewController<TestResultAvailableViewController, FooterViewController>)

		// [CAR] work in progress!
		store.positiveTestResultWasShown = true

		let positive = coordinator.getInitialViewController(with: .positive)
		XCTAssertTrue(positive is TopBottomContainerViewController<ExposureSubmissionWarnOthersViewController, FooterViewController>)
	}
}
