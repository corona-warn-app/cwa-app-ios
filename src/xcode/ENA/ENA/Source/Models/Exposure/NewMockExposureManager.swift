////
// 🦠 Corona-Warn-App
//

import ExposureNotification

/// The idea is to define this mock as close as possible to the original interface of ENManager (iOS API), but to the minimum required in cwa (which is Manager)
final class NewMockExposureManager: NSObject {
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

		self.exposureNotificationStatus = ENStatus.unknown
		self.exposureNotificationEnabled = false
		self.dispatchQueue = DispatchQueue.main

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
		exposureNotificationEnabled = enabled
		DispatchQueue.main.async {
			completionHandler(nil)
		}
	}

	// MARK: - Obtaining Exposure Information

	func detectExposures(configuration: ENExposureConfiguration, diagnosisKeyURLs: [URL], completionHandler: @escaping ENDetectExposuresHandler) -> Progress {
		dispatchQueue.async {
			// assuming successfull execution and no exposures
			completionHandler(ENExposureDetectionSummary(), nil)
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

	var exposureNotificationStatus: ENStatus
	var exposureNotificationEnabled: Bool
	static var authorizationStatus: ENAuthorizationStatus = ENAuthorizationStatus.unknown
	var dispatchQueue: DispatchQueue

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
