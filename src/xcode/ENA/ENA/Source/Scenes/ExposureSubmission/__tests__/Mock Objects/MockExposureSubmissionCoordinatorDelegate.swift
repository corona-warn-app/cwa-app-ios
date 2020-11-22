//
// 🦠 Corona-Warn-App
//

@testable import ENA

class MockExposureSubmissionCoordinatorDelegate: ExposureSubmissionCoordinatorDelegate {

	// MARK: - Callback handlers.

	var onExposureSubmissionCoordinatorWillDisappear: ((ExposureSubmissionCoordinating) -> Void)?

	// MARK: - ExposureSubmissionCoordinatorDelegate methods.

	func exposureSubmissionCoordinatorWillDisappear(_ coordinator: ExposureSubmissionCoordinating) {
		onExposureSubmissionCoordinatorWillDisappear?(coordinator)
	}

}
