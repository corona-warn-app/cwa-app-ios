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
	var lastCall: Date?
	let minDistanceBetweenCalls: TimeInterval = 4 * 3600
	private let store: Store

	// MARK: Creating a Mocked Manager

	init(
		exposureNotificationError: ExposureNotificationError?,
		diagnosisKeysResult: MockDiagnosisKeysResult?,
		store: Store
	) {
		self.exposureNotificationError = exposureNotificationError
		self.diagnosisKeysResult = diagnosisKeysResult
		self.store = store

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

	func detectExposures(configuration _: ENExposureConfiguration, diagnosisKeyURLs _: [URL], completionHandler: @escaping ENDetectExposuresHandler) -> Progress {
		store.exposureDetectionDate = Date()

		let now = Date()
		if let last = lastCall {
			if now.timeIntervalSince(last) < minDistanceBetweenCalls {
				DispatchQueue.main.async {
					completionHandler(nil, ENError(.rateLimited))
				}
			}
		}
		lastCall = now

		if let error = exposureNotificationError {
			DispatchQueue.main.async {
				// assuming failed execution
				completionHandler(nil, error)
			}
		} else {
			DispatchQueue.main.async {
				// assuming successfull execution and no exposures
				completionHandler(ENExposureDetectionSummary(), nil)
			}
		}
		return Progress()
	}

	func getExposureWindows(summary: ENExposureDetectionSummary, completionHandler: @escaping ENGetExposureWindowsHandler) -> Progress {
		DispatchQueue.main.async {
			// assuming successfull execution and empty list of exposure windows
			completionHandler([], nil)
		}
		return Progress()
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

	func alertForBluetoothOff(completion: @escaping () -> Void) -> UIAlertController? {
		return nil
	}

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
	
	@available(iOS 14.4, *)
	func preAuthorizeKeys(completion: @escaping ENErrorHandler) {
		completion(nil)
	}
}
