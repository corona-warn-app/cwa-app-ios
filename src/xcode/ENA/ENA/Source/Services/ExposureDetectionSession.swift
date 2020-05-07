//
//  ExposureDetectionSession.swift
//  ENA
//
//  Created by Kienle, Christian on 06.05.20.
//  Copyright © 2020 SAP SE. All rights reserved.
//

import ExposureNotification

/// A protocol that mimics a real `ENExposureDetectionSession`.
protocol ExposureDetectionSession: class {
    var configuration: ENExposureConfiguration { get set }
    var dispatchQueue: DispatchQueue { get set }
    var maximumKeyCount: Int { get }
    func activate(completionHandler: @escaping ENErrorHandler)
    func addDiagnosisKeys(_ keys: [ENTemporaryExposureKey], completionHandler: @escaping ENErrorHandler)
    func finishedDiagnosisKeys(completionHandler: @escaping ENExposureDetectionFinishCompletion)
    func getExposureInfo(withMaximumCount maximumCount: Int, completionHandler: @escaping ENGetExposureInfoCompletion)
}

/// The default implementation provided by Apple.
extension ENExposureDetectionSession : ExposureDetectionSession {
    /* intentionally left blank */
}
