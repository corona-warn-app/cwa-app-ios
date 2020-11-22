//
// 🦠 Corona-Warn-App
//

@testable import ENA

class MockExposureSubmissionCoordinator: ExposureSubmissionCoordinating {

	// MARK: - Attributes.

	weak var delegate: ExposureSubmissionCoordinatorDelegate?

	// MARK: - ExposureSubmissionCoordinator methods.

	func start(with: TestResult? = nil) { }

	func dismiss() { }

	func showOverviewScreen() { }

	func showTestResultScreen(with result: TestResult) { }

	func showHotlineScreen() { }

	func showTanScreen() { }

	func showThankYouScreen() { }
	
}
