// Corona-Warn-App
//
// SAP SE and all other contributors
// copyright owners license this file to you under the Apache
// License, Version 2.0 (the "License"); you may not use this
// file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing,
// software distributed under the License is distributed on an
// "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
// KIND, either express or implied.  See the License for the
// specific language governing permissions and limitations
// under the License.

import ExposureNotification
import Foundation
import UserNotifications
import UIKit

enum ExposureNotificationError: Error {
	case exposureNotificationRequired
	case exposureNotificationAuthorization
	case exposureNotificationUnavailable
	/// Typically occurs when `activate()` is called more than once.
	case apiMisuse
}

struct ExposureManagerState {
	// MARK: Creating a State

	init(
		authorized: Bool = false,
		enabled: Bool = false,
		status: ENStatus = .unknown
	) {
		self.authorized = authorized
		self.enabled = enabled
		self.status = status
	}

	// MARK: Properties

	let authorized: Bool
	let enabled: Bool
	let status: ENStatus
	var isGood: Bool { authorized && enabled && status == .active }
}

@objc protocol Manager: NSObjectProtocol {
	static var authorizationStatus: ENAuthorizationStatus { get }
	func detectExposures(configuration: ENExposureConfiguration, diagnosisKeyURLs: [URL], completionHandler: @escaping ENDetectExposuresHandler) -> Progress
	func activate(completionHandler: @escaping ENErrorHandler)
	func invalidate()
	@objc dynamic var exposureNotificationEnabled: Bool { get }
	func setExposureNotificationEnabled(_ enabled: Bool, completionHandler: @escaping ENErrorHandler)
	@objc dynamic var exposureNotificationStatus: ENStatus { get }
	func getDiagnosisKeys(completionHandler: @escaping ENGetDiagnosisKeysHandler)
	func getTestDiagnosisKeys(completionHandler: @escaping ENGetDiagnosisKeysHandler)
}

extension ENManager: Manager {}

protocol ExposureManagerLifeCycle {
	typealias CompletionHandler = ((ExposureNotificationError?) -> Void)
	func invalidate()
	func activate(completion: @escaping CompletionHandler)
	func enable(completion: @escaping CompletionHandler)
	func disable(completion: @escaping CompletionHandler)
	func preconditions() -> ExposureManagerState
	func requestUserNotificationsPermissions(completionHandler: @escaping (() -> Void))
}


protocol DiagnosisKeysRetrieval {
	func getTestDiagnosisKeys(completionHandler: @escaping ENGetDiagnosisKeysHandler)
	func accessDiagnosisKeys(completionHandler: @escaping ENGetDiagnosisKeysHandler)
}


protocol ExposureDetector {
	func detectExposures(configuration: ENExposureConfiguration, diagnosisKeyURLs: [URL], completionHandler: @escaping ENDetectExposuresHandler) -> Progress
}

protocol ExposureManagerObserving {
	func resume(observer: ENAExposureManagerObserver)
	func alertForBluetoothOff(completion: @escaping () -> Void) -> UIAlertController?
}


typealias ExposureManager = ExposureManagerLifeCycle &
	DiagnosisKeysRetrieval &
	ExposureDetector & ExposureManagerObserving


protocol ENAExposureManagerObserver: AnyObject {
	func exposureManager(
		_ manager: ENAExposureManager,
		didChangeState newState: ExposureManagerState
	)
}

/// Wrapper for ENManager to avoid code duplication and to abstract error handling
final class ENAExposureManager: NSObject, ExposureManager {
	// MARK: Properties

	private weak var observer: ENAExposureManagerObserver?
	private var enabledObservation: NSKeyValueObservation?
	private var statusObservation: NSKeyValueObservation?
	@objc private let manager: Manager

	// MARK: Creating a Manager

	init(
		manager: Manager = ENManager()
	) {
		self.manager = manager
		super.init()
	}

	func resume(observer: ENAExposureManagerObserver) {
		precondition(
			self.observer == nil,
			"Cannot resume an exposure manager that is already resumed."
		)

		self.observer = observer

		enabledObservation = observe(\.manager.exposureNotificationEnabled, options: .new) { [weak self] _, _ in
			guard let self = self else { return }
			DispatchQueue.main.async {
				observer.exposureManager(self, didChangeState: self.preconditions())
			}
		}

		statusObservation = observe(\.manager.exposureNotificationStatus, options: .new) { [weak self] _, _ in
			guard let self = self else { return }
			DispatchQueue.main.async {
				observer.exposureManager(self, didChangeState: self.preconditions())
			}
		}
	}

	// MARK: Activation

	/// Activates `ENManager`
	/// Needs to be called before `ExposureManager.enable()`
	func activate(completion: @escaping CompletionHandler) {
		manager.activate { activationError in
			if let activationError = activationError {
				logError(message: "Failed to activate ENManager: \(activationError.localizedDescription)")
				self.handleENError(error: activationError, completion: completion)
				return
			}
			completion(nil)
		}
	}

	// MARK: Enable

	/// Asks user for permission to enable ExposureNotification and enables it, if the user grants permission
	/// Expects the callee to invoke `ExposureManager.activate` prior to this function call
	func enable(completion: @escaping CompletionHandler) {
		changeEnabled(to: true, completion: completion)
	}

	/// Disables the ExposureNotification framework
	/// Expects the callee to invoke `ExposureManager.activate` prior to this function call
	func disable(completion: @escaping CompletionHandler) {
		changeEnabled(to: false, completion: completion)
	}

	private func changeEnabled(to status: Bool, completion: @escaping CompletionHandler) {
		manager.setExposureNotificationEnabled(status) { error in
			if let error = error {
				logError(message: "Failed to change ENManager.setExposureNotificationEnabled to \(status): \(error.localizedDescription)")
				self.handleENError(error: error, completion: completion)
				return
			}
			completion(nil)
		}
	}

	/// Returns an instance of the OptionSet `Preconditions`
	/// Only if `Preconditions.all()`
	func preconditions() -> ExposureManagerState {
		.init(
			authorized: type(of: manager).authorizationStatus == .authorized,
			enabled: manager.exposureNotificationEnabled,
			status: manager.exposureNotificationStatus
		)
	}

	// MARK: Detect Exposures

	/// Wrapper for `ENManager.detectExposures`
	/// `ExposureManager` needs to be activated and enabled
	func detectExposures(configuration: ENExposureConfiguration, diagnosisKeyURLs: [URL], completionHandler: @escaping ENDetectExposuresHandler) -> Progress {
		manager.detectExposures(configuration: configuration, diagnosisKeyURLs: diagnosisKeyURLs, completionHandler: completionHandler)
	}

	// MARK: Diagnosis Keys

	func getTestDiagnosisKeys(completionHandler: @escaping ENGetDiagnosisKeysHandler) {
		manager.getTestDiagnosisKeys(completionHandler: completionHandler)
	}

	/// Wrapper for `ENManager.getDiagnosisKeys`
	/// `ExposureManager` needs to be activated and enabled
	func accessDiagnosisKeys(completionHandler: @escaping ENGetDiagnosisKeysHandler) {
		if !manager.exposureNotificationEnabled {
			let error = ENError(.notEnabled)
			logError(message: error.localizedDescription)
			completionHandler(nil, error)
			return
		}
		// see: https://github.com/corona-warn-app/cwa-app-ios/issues/169
		manager.getDiagnosisKeys(completionHandler: completionHandler)
	}

	// MARK: Error Handling

	private func handleENError(error: Error, completion: @escaping CompletionHandler) {
		if let error = error as? ENError {
			switch error.code {
			case .notAuthorized:
				completion(ExposureNotificationError.exposureNotificationAuthorization)
			case .notEnabled:
				completion(ExposureNotificationError.exposureNotificationRequired)
			case .restricted:
				completion(ExposureNotificationError.exposureNotificationUnavailable)
			case .apiMisuse:
				completion(ExposureNotificationError.apiMisuse)
			default:
				let error = "[ExposureManager] Not implemented \(error.localizedDescription)"
				logError(message: error)
				// fatalError(error)
			}
		}
	}

	// MARK: Invalidate

	func invalidate() {
		manager.invalidate()
	}

	// MARK: Memory

	deinit {
		manager.invalidate()
	}

	// MARK: User Notifications

	public func requestUserNotificationsPermissions(completionHandler: @escaping (() -> Void)) {
		let options: UNAuthorizationOptions = [.alert, .sound, .badge]
		let notificationCenter = UNUserNotificationCenter.current()
		notificationCenter.requestAuthorization(options: options) { _, error in
			if let error = error {
				// handle error
				log(message: "Notification authorization request error: \(error.localizedDescription)", level: .error)
			}
			DispatchQueue.main.async {
				completionHandler()
			}
		}
	}

}

// MARK: Pretty print (Only for debugging)

extension ENStatus: CustomDebugStringConvertible {
	public var debugDescription: String {
		switch self {
		case .unknown:
			return "unknown"
		case .active:
			return "active"
		case .disabled:
			return "disabled"
		case .bluetoothOff:
			return "bluetoothOff"
		case .restricted:
			return "restricted"
		default:
			return "not handled"
		}
	}
}

extension ENAuthorizationStatus: CustomDebugStringConvertible {
	public var debugDescription: String {
		switch self {
		case .unknown:
			return "unknown"
		case .restricted:
			return "restricted"
		case .authorized:
			return "authorized"
		case .notAuthorized:
			return "not authorized"
		default:
			return "not handled"
		}
	}
}

extension ENAExposureManager {

	func alertForBluetoothOff(completion: @escaping () -> Void) -> UIAlertController? {
		if ENManager.authorizationStatus == .authorized && self.manager.exposureNotificationStatus == .bluetoothOff {
			let alert = UIAlertController(title: AppStrings.Common.alertTitleBluetoothOff,
										  message: AppStrings.Common.alertDescriptionBluetoothOff,
										  preferredStyle: .alert)
			let completionHandler: (UIAlertAction, @escaping () -> Void) -> Void = { action, completion in
				switch action.style {
				case .default:
					guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else {
						return
					}
					if UIApplication.shared.canOpenURL(settingsUrl) {
						UIApplication.shared.open(settingsUrl, completionHandler: nil)
					}
				case .cancel, .destructive:
					completion()
				@unknown default:
					fatalError("Not all cases of actions covered when handling the bluetooth")
				}
			}
			alert.addAction(UIAlertAction(title: AppStrings.Common.alertActionOpenSettings, style: .default, handler: { action in completionHandler(action, completion) }))
			alert.addAction(UIAlertAction(title: AppStrings.Common.alertActionLater, style: .cancel, handler: { action in completionHandler(action, completion) }))
			return alert
		}
		return nil
	}
}
