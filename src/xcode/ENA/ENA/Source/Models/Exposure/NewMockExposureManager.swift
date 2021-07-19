////
// 🦠 Corona-Warn-App
//

import ExposureNotification

/// The idea is to define this mock as close as possible to the original interface of ENManager (iOS API), but to the minimum required in cwa (which is Manager)
final class NewMockExposureManager: NSObject {
	typealias MockDiagnosisKeysResult = ([ENTemporaryExposureKey]?, Error?)

	// MARK: Properties

	let defaultError: ENError?
	let diagnosisKeysResult: MockDiagnosisKeysResult?
	var enabled: Bool = true
	var lastCall: Date?
	let minDistanceBetweenCalls: TimeInterval = 4 * 3600

	// MARK: Creating a Mocked Manager

	init(
		defaultError: ENError?,
		diagnosisKeysResult: MockDiagnosisKeysResult?
	) {
		self.defaultError = defaultError
		self.diagnosisKeysResult = diagnosisKeysResult

		#if RELEASE
		// This whole class would/should be wrapped in a DEBUG block. However, there were some
		// issues with the handling of community and debug builds so we chose this way to prevent
		// malicious usage
		preconditionFailure("Don't use this mock in production!")
		#endif
	}
	
	// MARK: - Activating the Manager

	func activate(completionHandler: @escaping ENErrorHandler) {
		DispatchQueue.main.async {
			completionHandler(nil)
		}
	}

	func setExposureNotificationEnabled(_ enabled: Bool, completionHandler: @escaping ENErrorHandler) {
		self.enabled = enabled
		DispatchQueue.main.async {
			completionHandler(nil)
		}
	}

	// MARK: - Obtaining Exposure Information

	func detectExposures(configuration: ENExposureConfiguration, diagnosisKeyURLs: [URL], completionHandler: @escaping ENDetectExposuresHandler) -> Progress {
		
		let now = Date()
        var error = defaultError
		if let last = lastCall {
			if now.timeIntervalSince(last) < minDistanceBetweenCalls {
				error = ENError(.rateLimited)
			}
		}
		lastCall = now
		dispatchQueue.async {
			if error == nil {
				// assuming successfull execution and no exposures
				completionHandler(ENExposureDetectionSummary(), error)
			} else {
				// error case
				completionHandler(nil, error)
			}
		}
		return Progress()
	}

	func getExposureWindows(from summary: ENExposureDetectionSummary, completionHandler: @escaping ENGetExposureWindowsHandler) -> Progress {
		dispatchQueue.async {
			// assuming successfull execution and empty list of exposure windows
			completionHandler([], nil)
		}
		return Progress()
	}

	// MARK: - Obtaining Exposure Keys

	func getDiagnosisKeys(completionHandler: @escaping ENGetDiagnosisKeysHandler) {
		dispatchQueue.async {
			// swiftlint:disable:next force_unwrapping
			completionHandler(self.diagnosisKeysResult!.0, self.diagnosisKeysResult!.1)
		}
	}

	func getTestDiagnosisKeys(completionHandler: @escaping ENGetDiagnosisKeysHandler) {
		dispatchQueue.async {
			// swiftlint:disable:next force_unwrapping
			completionHandler(self.diagnosisKeysResult!.0, self.diagnosisKeysResult!.1)
		}
	}

	// MARK: - Configuring the Manager

	var exposureNotificationStatus: ENStatus {
		if enabled {
			return ENStatus.active
		} else {
			return ENStatus.disabled
		}
	}
	var exposureNotificationEnabled: Bool {
		return enabled
	}
	static var authorizationStatus: ENAuthorizationStatus {
		return ENAuthorizationStatus.authorized
	}
	var dispatchQueue = DispatchQueue.main

	// MARK: - Preauthorizing Exposure Keys

	@available(iOS 14.4, *)
	func preAuthorizeKeys(completion: @escaping  ENErrorHandler) {
		dispatchQueue.async {
			completion(nil)
		}
	}

	// MARK: - Invalidating the Manager

	func invalidate() {
		if let handler = invalidationHandler {
			dispatchQueue.async {
				handler()
			}
		}
	}
	var invalidationHandler: (() -> Void)?

}

extension NewMockExposureManager: Manager {
}
