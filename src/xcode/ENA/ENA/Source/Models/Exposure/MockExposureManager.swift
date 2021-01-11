//
// 🦠 Corona-Warn-App
//

import ExposureNotification
import UIKit

final class MockExposureManager {
	typealias MockDiagnosisKeysResult = ([ENTemporaryExposureKey]?, Error?)

	// MARK: Properties

	let exposureNotificationError: ExposureNotificationError?
	let diagnosisKeysResult: MockDiagnosisKeysResult?

	// MARK: Creating a Mocked Manager

	init(
		exposureNotificationError: ExposureNotificationError?,
		diagnosisKeysResult: MockDiagnosisKeysResult?
	) {
		self.exposureNotificationError = exposureNotificationError
		self.diagnosisKeysResult = diagnosisKeysResult

		#if RELEASE
		// This whole class would/should be wrapped in a DEBUG block. However, there were some
		// issues with the handling of cumminity and debug builds so we chose this way to prevent
		// malicious usage
		preconditionFailure("Don't use this mock in production!")
		#endif
	}
}

extension MockExposureManager: ExposureManager {
	func invalidate(handler: (() -> Void)?) {
		handler?()
	}

	func reset(handler: (() -> Void)?) {
		handler?()
	}


	func invalidate() {}

	
	func activate(completion: @escaping CompletionHandler) {
		completion(exposureNotificationError)
	}

	func enable(completion: @escaping CompletionHandler) {
		completion(exposureNotificationError)
	}

	func disable(completion: @escaping CompletionHandler) {
		completion(exposureNotificationError)
	}

	var exposureManagerState: ExposureManagerState {
		ExposureManagerState(authorized: true, enabled: true, status: .active)
	}

	func detectExposures(configuration _: ENExposureConfiguration, diagnosisKeyURLs _: [URL], completionHandler _: @escaping ENDetectExposuresHandler) -> Progress {
		Progress()
	}

	func getExposureWindows(summary: ENExposureDetectionSummary, completionHandler: @escaping ENGetExposureWindowsHandler) -> Progress {
		Progress()
	}

	func getTestDiagnosisKeys(completionHandler: @escaping ENGetDiagnosisKeysHandler) {
		// swiftlint:disable:next force_unwrapping
		completionHandler(diagnosisKeysResult!.0, diagnosisKeysResult!.1)
	}

	func accessDiagnosisKeys(completionHandler: @escaping ENGetDiagnosisKeysHandler) {
		// swiftlint:disable:next force_unwrapping
		completionHandler(diagnosisKeysResult!.0, diagnosisKeysResult!.1)
	}

	func observeExposureNotificationStatus(observer: ENAExposureManagerObserver) {
		
	}

	func alertForBluetoothOff(completion: @escaping () -> Void) -> UIAlertController? { return nil }

	func requestUserNotificationsPermissions(completionHandler: @escaping (() -> Void)) {
		#if COMMUNITY
		let options: UNAuthorizationOptions = [.alert, .sound, .badge]
		let notificationCenter = UNUserNotificationCenter.current()
		notificationCenter.requestAuthorization(options: options) { _, error in
			if let error = error {
				// handle error
				Log.error("Notification authorization request error", log: .default, error: error)
			}
			DispatchQueue.main.async {
				completionHandler()
			}
		}
		#else
		completionHandler()
		#endif
	}
}
