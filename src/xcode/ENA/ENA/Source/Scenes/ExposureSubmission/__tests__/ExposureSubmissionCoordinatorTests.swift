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
	private var store: Store!
	private var coronaTestService: CoronaTestService!

	// MARK: - Setup and teardown methods.

	override func setUpWithError() throws {
		store = MockTestStore()
		parentNavigationController = UINavigationController()
		exposureSubmissionService = MockExposureSubmissionService()
		coronaTestService = CoronaTestService(client: ClientMock(), store: store)
	}

	// MARK: - Helper methods.

	private func createCoordinator(
		parentNavigationController: UINavigationController,
		exposureSubmissionService: ExposureSubmissionService
	) -> ExposureSubmissionCoordinator {
		ExposureSubmissionCoordinator(
			parentNavigationController: parentNavigationController,
			exposureSubmissionService: exposureSubmissionService,
			coronaTestService: coronaTestService
		)
	}

	private func getNavigationController(from coordinator: ExposureSubmissionCoordinator) -> UINavigationController? {
		guard let navigationController = coordinator.navigationController else {
			XCTFail("Could not load navigation controller from coordinator.")
			return nil
		}

		return navigationController
	}

	// MARK: - Navigation tests.

	func testStart_default() {
		let coordinator = createCoordinator(
			parentNavigationController: parentNavigationController,
			exposureSubmissionService: exposureSubmissionService
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
		
		
		let section2 = vc.dynamicTableViewModel.section(1)
		XCTAssertNotNil(section2)
		XCTAssertEqual(section2.cells.count, 4)

	}

	func testStart_withNegativeResult() {
		let coordinator = createCoordinator(
			parentNavigationController: parentNavigationController,
			exposureSubmissionService: exposureSubmissionService
		)

		coronaTestService.pcrTest = PCRTest.mock(registrationToken: "asdf", testResult: .negative)

		coordinator.start(with: .pcr)

		// Get navigation controller and make sure to load view.
		let navigationController = getNavigationController(from: coordinator)
		navigationController?.loadViewIfNeeded()

		XCTAssertNotNil(navigationController)
		XCTAssertNotNil(navigationController?.topViewController)
		XCTAssertNotNil(navigationController?.topViewController as? TopBottomContainerViewController<ExposureSubmissionTestResultViewController, FooterViewController>)
	}

	func testStart_withPositiveResult() {
		let coordinator = createCoordinator(
			parentNavigationController: parentNavigationController,
			exposureSubmissionService: exposureSubmissionService
		)

		coronaTestService.pcrTest = PCRTest.mock(registrationToken: "asdf", testResult: .positive)

		coordinator.start(with: .pcr)

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
			exposureSubmissionService: exposureSubmissionService
		)

		XCTAssertNil(parentNavigationController.presentedViewController)
		coordinator.start(with: nil)
		XCTAssertNotNil(parentNavigationController.presentedViewController)

		coordinator.dismiss {
			XCTAssertNil(self.parentNavigationController.presentedViewController)
		}
	}

	func testInitialViewController() throws {
		let coordinator = createCoordinator(
			parentNavigationController: parentNavigationController,
			exposureSubmissionService: exposureSubmissionService
		)

		coronaTestService.pcrTest = PCRTest.mock(testResult: .positive, positiveTestResultWasShown: false)

		coordinator.start(with: .pcr)

		let unknown = coordinator.getInitialViewController()
		XCTAssertTrue(unknown is TopBottomContainerViewController<TestResultAvailableViewController, FooterViewController>)

		coronaTestService.pcrTest?.positiveTestResultWasShown = true

		let positive = coordinator.getInitialViewController()
		XCTAssertTrue(positive is TopBottomContainerViewController<ExposureSubmissionWarnOthersViewController, FooterViewController>)
	}
}
