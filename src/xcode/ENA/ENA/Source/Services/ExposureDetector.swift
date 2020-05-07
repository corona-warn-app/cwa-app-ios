//
//  ExposureDetector.swift
//  ENA
//
//  Created by Bormeth, Marc on 29.04.20.
//  Copyright © 2020 SAP SE. All rights reserved.
//

import Foundation
import ExposureNotification

protocol ExposureDetectorDelegate: class {
    /// Called shortly after `resume` has been called.
    func exposureDetectorDidStart(_ detector: ExposureDetector) -> Void

    /// Called if a detector was able to successfully finish a detection session. If anything did not work this will not be called.
    func exposureDetectorDidFinish(_ detector: ExposureDetector, summary: ENExposureDetectionSummary) -> Void
    
    /// Called if an error occurred after calling `resume`. If `exposureDetectorDidFail` is called `exposureDetectorDidFinish` will not.
    /// Those two delegate methods exclude each other. For sanity.
    func exposureDetectorDidFail(_ detector: ExposureDetector, error: Error) -> Void
}

/// Allows to detect exposures.
///
/// In order to work properly, `ExposureDetector` needs several things:
/// - A configuration object: see `ENExposureConfiguration` for more details.
/// - A set of new diagnosis keys to consider for the detection: see `ENTemporaryExposureKey` for more details.
/// - A newly created `ExposureDetectionSession`. The `ExposureDetector` will configure that session accordingly and use it to perform the actual detection.
/// - A delegate that will be informed about the progress of the detection.
///
/// By default, an `ExposureDetector` is not doing anything after it has been created. You have to call `resume` in order to start the actual detection. It is considered a programmer error to call `resume` more than once.
final class ExposureDetector {
    // MARK: Properties
    private let configuration: ENExposureConfiguration
    private let newKeys: [ENTemporaryExposureKey]
    private let session: ExposureDetectionSession
    private var queue: DispatchQueue
    private var sessionStartTime: Date?
    private weak var delegate: ExposureDetectorDelegate?

    fileprivate static let numberCountExposureInfo = 100

    // MARK: Creating an Exposure Detector

    /// Creates an exposure detector that can be used to determine the risk of the current user.
    ///
    /// Parameters:
    /// - configuration: The `ENExposureConfiguration` used to weight the risk parameters.
    /// - newKeys: A set of new diagosis keys that will be added to the session.
    /// - session: A fresh instance of anything that conforms to `ExposureDetectionSession`. In practice this will simply be an instance of `ENExposureDetectionSession` created with the designated initializer.
    /// - delegate: The delegate will be informed about the current state of the detection.
    init(configuration: ENExposureConfiguration, newKeys: [ENTemporaryExposureKey], session: ExposureDetectionSession, delegate: ExposureDetectorDelegate) {
        self.configuration = configuration
        self.session = session
        self.newKeys = newKeys
        self.delegate = delegate
        queue = DispatchQueue(label: "com.sap.ExposureDetector")
    }

    /// Resumes the exposure detector.
    ///
    /// Calling this method will have the following effects:
    /// - The underlying session will be configured and activated.
    /// - `newKeys` will be added to the session
    /// - An exposure summary (see `ENExposureDetectionSummary`) will be passed to the `delegate`.
    ///
    /// Once a detector has been resumed it cannot be stoped – yet. TODO
    func resume() {
        delegate?.exposureDetectorDidStart(self)
        sessionStartTime = Date()  // will be used once the session succeeded
        configureAndActivateSession { [weak self] session in
            guard let self = self else {
                return
            }
            self.queue.async {
                let result = self.addAllNewKeysSync()
                DispatchQueue.main.async {
                    switch result {
                    case .failure(let error):
                        self.failWith(error: error)
                        return
                    case .success(_):
                        // Get result from session
                        session.finishedDiagnosisKeys { (summary, finishError) in
                            // This is called on the main queue
                            if let finishError = finishError {
                                self.failWith(error: finishError)
                                return
                            }

                            guard let summary = summary else {
                                fatalError("how can this happen apple?")
                            }

                            self.delegate?.exposureDetectorDidFinish(self, summary: summary)

                            self.session.getExposureInfo(withMaximumCount: type(of: self).numberCountExposureInfo) { (info, done, exposureError) in
                                if let exposureError = exposureError {
                                    print("getExposureInfo failed: \(exposureError)")
                                    return
                                }
                                print("got getExposureInfo: \(String(describing: info))")
                            }

                            // Update timestamp of last successfull session
                            if self.sessionStartTime != nil {
                                PersistenceManager.shared.dateLastExposureDetection = self.sessionStartTime!
                            }

                            // TODO: Send exposures / summary to PersistenceManager
                        }
                    }
                }
            }
        }
    }

    private typealias ConfiguredAndActivatedHandler = (ExposureDetectionSession) -> Void
    /// Configures and activates the underlying session.
    ///
    /// If something went wrong the delegate is informed about that. If everything happened without any errors `successHandler` is called with the configured and activated session.
    /// Parameters:
    /// - successHandler: Called if no errors happened. Will be called on the main queue with the configured and activated session.
    private func configureAndActivateSession(successHandler: @escaping ConfiguredAndActivatedHandler) {
        let session = self.session
        session.configuration = configuration
        session.dispatchQueue = .main
        session.activate { [weak self] error in
            if let error = error {
                self?.failWith(error: error)
                return
            }
            successHandler(session)
        }
    }
}

// MARK: Helper
private extension ExposureDetector {
    private func failWith(error: Error) {
        delegate?.exposureDetectorDidFail(self, error: error)
    }

    /// Synchronously adds all new keys to the underlying detection session.
    private func addAllNewKeysSync() -> Result<Void, Error> {
        var index = 0
        var resultError: Error?
        while index < newKeys.count {
            let semaphore = DispatchSemaphore(value: 0)
            let endIndex = index + session.maximumKeyCount > newKeys.count ? newKeys.count : index + session.maximumKeyCount
            let slice = newKeys[index..<endIndex]

            session.addDiagnosisKeys(Array(slice)) { (error) in
                // This is called on the main queue
                guard error == nil else {
                    resultError = error
                    semaphore.signal()
                    return
                }
                semaphore.signal()
            }
            semaphore.wait()
            if let resultError = resultError {
                return .failure(resultError)
            }
            index += session.maximumKeyCount
        }
        return .success(Void())
    }
}
