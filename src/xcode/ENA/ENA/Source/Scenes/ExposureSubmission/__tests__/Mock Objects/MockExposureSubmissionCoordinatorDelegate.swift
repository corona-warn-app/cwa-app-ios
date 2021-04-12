//
// 🦠 Corona-Warn-App
//

@testable import ENA

class MockExposureSubmissionCoordinatorDelegate: ExposureSubmissionCoordinatorDelegate {

	// MARK: - Callback handlers.

	var onExposureSubmissionCoordinatorWillDisappear: ((ExposureSubmissionCoordinator) -> Void)?

	// MARK: - ExposureSubmissionCoordinatorDelegate methods.

	func exposureSubmissionCoordinatorWillDisappear(_ coordinator: ExposureSubmissionCoordinator) {
		onExposureSubmissionCoordinatorWillDisappear?(coordinator)
	}

}
