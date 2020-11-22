//
// 🦠 Corona-Warn-App
//

import Foundation
@testable import ENA

class MockExposureDetectionViewControllerDelegate: ExposureDetectionViewControllerDelegate {
	func exposureDetectionViewController(
		_ controller: ExposureDetectionViewController,
		setExposureManagerEnabled enabled: Bool,
		completionHandler completion: @escaping (ExposureNotificationError?) -> Void) {
		completion(nil)
	}

	func didStartLoading(exposureDetectionViewController: ExposureDetectionViewController) {
		return
	}

	func didFinishLoading(exposureDetectionViewController: ExposureDetectionViewController) {
		return
	}
}
