//
// 🦠 Corona-Warn-App
//

import XCTest
@testable import ENA

class DeltaOnboardingCoordinatorTests: XCTestCase {

	func test_When_NoOnboardingIsCurrent_Then_NoDeltaOnboardingIsShown() {
		let mockStore = MockTestStore()
		mockStore.onboardingVersion = "1.0.0"

		let deltaViewControllerDummy = DeltaOnboardingViewControllerDummy()
		let deltaOnboardingSpy = DeltaOnboardingSpy(version: "1.0.0", store: mockStore, deltaViewController: deltaViewControllerDummy)

		let viewControllerPresentSpy = ViewControllerPresentSpy()

		let sut_DeltaOnboardingCoordinator = DeltaOnboardingCoordinator(rootViewController: viewControllerPresentSpy, onboardings: [deltaOnboardingSpy])

		let finishedExpectation = expectation(description: "Finished is called by DeltaOnboardingCoordinator.")

		sut_DeltaOnboardingCoordinator.finished = {
			finishedExpectation.fulfill()

			XCTAssertFalse(viewControllerPresentSpy.presentWasCalled)
		}

		sut_DeltaOnboardingCoordinator.startOnboarding()

		waitForExpectations(timeout: .medium)
	}

	func test_When_OneOnboardingIsCurrent_Then_DeltaOnboardingIsShown() {
		let mockStore = MockTestStore()
		mockStore.onboardingVersion = "1.9.0"

		let deltaViewControllerDummy = DeltaOnboardingViewControllerDummy()
		let deltaOnboardingSpy = DeltaOnboardingSpy(version: "1.10.0", store: mockStore, deltaViewController: deltaViewControllerDummy)

		let viewControllerPresentSpy = ViewControllerPresentSpy()

		let sut_DeltaOnboardingCoordinator = DeltaOnboardingCoordinator(rootViewController: viewControllerPresentSpy, onboardings: [deltaOnboardingSpy])

		let finishedExpectation = expectation(description: "Finished is called by DeltaOnboardingCoordinator.")

		sut_DeltaOnboardingCoordinator.finished = {
			finishedExpectation.fulfill()

			XCTAssertTrue(viewControllerPresentSpy.presentWasCalled)
		}

		sut_DeltaOnboardingCoordinator.startOnboarding()
		deltaViewControllerDummy.finished?()

		waitForExpectations(timeout: .medium)
	}

	func test_When_TwoOnboardingsAreCurrent_Then_DeltaOnboardingIsShownTwice() {

		let mockStore = MockTestStore()
		mockStore.onboardingVersion = "1.0.0"

		let deltaViewControllerDummy110 = DeltaOnboardingViewControllerDummy()
		let deltaOnboardingSpy110 = DeltaOnboardingSpy(version: "1.1.0", store: mockStore, deltaViewController: deltaViewControllerDummy110)

		let deltaViewControllerDummy120 = DeltaOnboardingViewControllerDummy()
		let deltaOnboardingSpy120 = DeltaOnboardingSpy(version: "1.2.0", store: mockStore, deltaViewController: deltaViewControllerDummy120)

		let viewControllerPresentSpy = ViewControllerPresentSpy()

		let sut_DeltaOnboardingCoordinator = DeltaOnboardingCoordinator(rootViewController: viewControllerPresentSpy, onboardings: [deltaOnboardingSpy110, deltaOnboardingSpy120])

		let finishedExpectation = expectation(description: "Finished is called by DeltaOnboardingCoordinator.")

		sut_DeltaOnboardingCoordinator.finished = {
			finishedExpectation.fulfill()

			XCTAssertEqual(viewControllerPresentSpy.numberOfPresentCalls, 2)
		}

		sut_DeltaOnboardingCoordinator.startOnboarding()
		deltaViewControllerDummy110.finished?()
		deltaViewControllerDummy120.finished?()

		waitForExpectations(timeout: .medium)
	}

	func test_When_OneOfTwoOnboardingsIsCurrent_Then_DeltaOnboardingIsShownOnce() {

		let mockStore = MockTestStore()
		mockStore.onboardingVersion = "1.0.0"

		let deltaViewControllerDummy100 = DeltaOnboardingViewControllerDummy()
		let deltaOnboardingSpy100 = DeltaOnboardingSpy(version: "1.0.0", store: mockStore, deltaViewController: deltaViewControllerDummy100)

		let deltaViewControllerDummy110 = DeltaOnboardingViewControllerDummy()
		let deltaOnboardingSpy110 = DeltaOnboardingSpy(version: "1.1.0", store: mockStore, deltaViewController: deltaViewControllerDummy110)

		let viewControllerPresentSpy = ViewControllerPresentSpy()

		let sut_DeltaOnboardingCoordinator = DeltaOnboardingCoordinator(rootViewController: viewControllerPresentSpy, onboardings: [deltaOnboardingSpy100, deltaOnboardingSpy110])

		let finishedExpectation = expectation(description: "Finished is called by DeltaOnboardingCoordinator.")

		sut_DeltaOnboardingCoordinator.finished = {
			finishedExpectation.fulfill()

			XCTAssertEqual(viewControllerPresentSpy.numberOfPresentCalls, 1)
		}

		sut_DeltaOnboardingCoordinator.startOnboarding()
		deltaViewControllerDummy100.finished?()
		deltaViewControllerDummy110.finished?()

		waitForExpectations(timeout: .medium)
	}
	
}

private class ViewControllerPresentSpy: UIViewController {
	var numberOfPresentCalls = 0
	var presentWasCalled = false

	override func present(_ viewControllerToPresent: UIViewController, animated flag: Bool, completion: (() -> Void)? = nil) {
		presentWasCalled = true
		numberOfPresentCalls += 1
	}
}

private class DeltaOnboardingViewControllerDummy: UIViewController, DeltaOnboardingViewControllerProtocol {
	var finished: (() -> Void)?
}

private class DeltaOnboardingSpy: DeltaOnboarding {
	let version: String
	let store: Store
	let deltaViewController: DeltaOnboardingViewControllerProtocol

	init(
		version: String,
		store: Store,
		deltaViewController: DeltaOnboardingViewControllerProtocol
	) {
		self.version = version
		self.store = store
		self.deltaViewController = deltaViewController
	}

	func makeViewController() -> DeltaOnboardingViewControllerProtocol {
		return deltaViewController
	}
}
