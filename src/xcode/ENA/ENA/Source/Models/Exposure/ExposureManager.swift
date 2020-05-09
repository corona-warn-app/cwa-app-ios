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

    static let authorized   = Preconditions(rawValue: 1 << 0)
    static let enabled      = Preconditions(rawValue: 1 << 1)
    static let active       = Preconditions(rawValue: 1 << 2)

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
}

extension ENManager: Manager {}

//
//extension ENManager: Manager {}

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

    /// Activates `ENManager` and asks user for permission to enable ExposureNotification.
    /// If the user declines, completion handler will set the error to exposureNotificationRequired
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

    func enable(completion: @escaping CompletionHandler) {
        changeEnabled(to: true, completion: completion)
    }

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

    func preconditions() -> Preconditions {
        var preconditions = Preconditions()
        if type(of: manager).authorizationStatus == ENAuthorizationStatus.authorized { preconditions.insert(.authorized) }
        if manager.exposureNotificationEnabled { preconditions.insert(.enabled) }
        if manager.exposureNotificationStatus == .active { preconditions.insert(.active) }

        log(message: "\nAuthorized: \(ENManager.authorizationStatus.rawValue), enabled: \(manager.exposureNotificationEnabled), status: \(manager.exposureNotificationStatus.rawValue)")

        return preconditions
    }
    
    // MARK: Detect Exposures
    func detectExposures(configuration: ENExposureConfiguration, diagnosisKeyURLs: [URL], completionHandler: @escaping ENDetectExposuresHandler) -> Progress {
        return manager.detectExposures(configuration: configuration, diagnosisKeyURLs: diagnosisKeyURLs, completionHandler: completionHandler)
    }

    // MARK: Diagnosis Keys

    /// Wrapper for `ENManager.getDiagnosisKeys`. You have to call `ExposureManager.activate` before calling this method.
    func accessDiagnosisKeys(completionHandler: @escaping ENGetDiagnosisKeysHandler) {
        if !manager.exposureNotificationEnabled {
            let error = ENError(.notEnabled)
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
                fatalError("[ExposureManager] Not implemented \(error.localizedDescription)")
            }
        } else {
            fatalError("[ExposureManager] Not implemented \(error.localizedDescription)")
        }
    }

    deinit {
        manager.invalidate()
    }
}
