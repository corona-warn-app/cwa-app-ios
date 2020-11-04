import Foundation

protocol ExposureDetectionViewControllerDelegate: AnyObject {
	func exposureDetectionViewController(
		_ controller: ExposureDetectionViewController,
		setExposureManagerEnabled enabled: Bool,
		completionHandler completion: @escaping (ExposureNotificationError?) -> Void
	)
}
