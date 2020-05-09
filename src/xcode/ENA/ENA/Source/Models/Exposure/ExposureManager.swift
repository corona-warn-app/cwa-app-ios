//
//  ExposureManager.swift
//  ENA
//
//  Created by Steinmetz, Conrad on 01.05.20.
//

import ExposureNotification
import Foundation

enum ExposureNotificationError: Error {
    case exposureNotificationRequired
    case exposureNotificationAuthorization
}

struct Preconditions: OptionSet {
    let rawValue: Int

    static let authorized = Preconditions(rawValue: 1 << 0)
    static let enabled = Preconditions(rawValue: 1 << 1)
    static let active = Preconditions(rawValue: 1 << 2)

    static let all: Preconditions = [.authorized, .enabled, .active]
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

/**
*   @brief    Wrapper for ENManager to avoid code duplication and to abstract error handling
*/
final class ExposureManager: NSObject {

    typealias CompletionHandler = ((ExposureNotificationError?) -> Void)

    @objc private let manager: Manager

    private var exposureNotificationEnabledObserver: NSObject?
    private var exposureNotificationStatus: NSObject?

    init(manager: Manager = ENManager()) {
        self.manager = manager
        super.init()

        observeENFramework()
    }

    // MARK: Observers

    private func observeENFramework() {
        // TODO: Add delegate, etc. here to update changes
        exposureNotificationEnabledObserver = observe(\.manager.exposureNotificationEnabled, options: [.new]) {_, _ in
            _ = self.preconditions()
        }
        exposureNotificationStatus = observe(\.manager.exposureNotificationStatus, options: [.new]) {_, _ in
            _ = self.preconditions()
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
        self.manager.setExposureNotificationEnabled(status) { error in
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
    func preconditions() -> Preconditions {
        var preconditions = Preconditions()
        if type(of: manager).authorizationStatus == ENAuthorizationStatus.authorized {
            preconditions.insert(.authorized)
        }
        if manager.exposureNotificationEnabled {
            preconditions.insert(.enabled)
        }
        if manager.exposureNotificationStatus == .active {
            preconditions.insert(.active)
        }

        let message = """
        New status of EN framework:
            Authorized: \(ENManager.authorizationStatus.description())
            enabled: \(manager.exposureNotificationEnabled)
            status: \(manager.exposureNotificationStatus.description())
        """
        log(message: message)

        if preconditions == Preconditions.all {
            log(message: "Enabled")
        }

        return preconditions
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
            default:
                // TODO: Add missing cases
                let error = "[ExposureManager] Not implemented \(error.localizedDescription)"
                logError(message: error)
                fatalError(error)
            }
        } else {
            let error = "[ExposureManager] Not implemented \(error.localizedDescription)"
            logError(message: error)
            fatalError(error)
        }
    }

    deinit {
        manager.invalidate()
    }
}

// MARK: Pretty print (Only for debugging)

fileprivate extension ENStatus {
    func description() -> String {
        switch self.rawValue {
        case ENStatus.unknown.rawValue:
            return "unknown"
        case ENStatus.active.rawValue:
            return "active"
        case ENStatus.disabled.rawValue:
            return "disabled"
        case ENStatus.bluetoothOff.rawValue:
            return "bluetoothOff"
        case ENStatus.restricted.rawValue:
            return "restricted"
        default:
            return ""
        }
    }
}

fileprivate extension ENAuthorizationStatus {
    func description() -> String {
        switch self.rawValue {
        case ENAuthorizationStatus.unknown.rawValue:
            return "unknown"
        case ENAuthorizationStatus.restricted.rawValue:
            return "restricted"
        case ENAuthorizationStatus.authorized.rawValue:
            return "authorized"
        case ENAuthorizationStatus.notAuthorized.rawValue:
            return "not authorized"
        default:
            return ""
        }
    }
}
