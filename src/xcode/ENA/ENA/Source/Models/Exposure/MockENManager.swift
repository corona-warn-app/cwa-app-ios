////
// 🦠 Corona-Warn-App
//

import ExposureNotification

final class MockENManager: NSObject {
	typealias MockDiagnosisKeysResult = ([ENTemporaryExposureKey]?, Error?)

	// MARK: Creating a Mocked ENManager

	override init(
	) {
		super.init()
		self.diagnosisKeysResult = (keys, enError)

		#if RELEASE
		// This whole class would/should be wrapped in a DEBUG block. However, there were some
		// issues with the handling of community and debug builds so we chose this way to prevent
		// malicious usage
		preconditionFailure("Don't use this mock in production!")
		#endif
	}
	
	// MARK: - Activating

	func activate(completionHandler: @escaping ENErrorHandler) {
		dispatchQueue.async {
			completionHandler(nil)
		}
	}

	func setExposureNotificationEnabled(_ enabled: Bool, completionHandler: @escaping ENErrorHandler) {
		let dispatchQueue = self.dispatchQueue
		ownWorkerQueue.async {
			self.enabled = enabled
			dispatchQueue.async {
				completionHandler(nil)
			}
		}
	}

	// MARK: - Obtaining Exposure Information

	func detectExposures(configuration: ENExposureConfiguration, diagnosisKeyURLs: [URL], completionHandler: @escaping ENDetectExposuresHandler) -> Progress {
		let error = enError
		let now = Date()
		dispatchQueue.async {
			if error == nil {
				// assuming successfull execution and no exposures
				guard !self.wasCalledTooOftenTill(now) else {
					completionHandler(nil, ENError(.rateLimited))
					return
				}
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

	// MARK: - Private

	private let minDistanceBetweenCalls: TimeInterval = 4 * 3600
	private let ownWorkerQueue = DispatchQueue(label: "com.sap.MockENManager")
	
	private var enError: ENError?
	private var keys = [ENTemporaryExposureKey()]
	private var diagnosisKeysResult: MockDiagnosisKeysResult?

	private var enabled: Bool = true
	private var lastCall: Date?

	private func wasCalledTooOftenTill(_ now: Date) -> Bool {
		var tooOften = false
		if let last = lastCall {
			if now.timeIntervalSince(last) < minDistanceBetweenCalls {
				tooOften = true
			}
		}
		lastCall = now
		return tooOften
	}
}

extension MockENManager: Manager {
}
