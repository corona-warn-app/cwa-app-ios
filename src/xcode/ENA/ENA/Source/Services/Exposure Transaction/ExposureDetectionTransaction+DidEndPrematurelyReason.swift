//
//  ExposureDetectionTransaction+DidEndPrematurelyReason.swift
//  ENA
//
//  Created by Kienle, Christian on 15.05.20.
//  Copyright © 2020 SAP SE. All rights reserved.
//

import Foundation

extension ExposureDetectionTransaction {
    enum DidEndPrematurelyReason {
        /// Delegate was unable to provide an exposure manager to the transaction.
        case noExposureManager
        /// The actual exposure summary detection was started but did either produce an error
        /// or no summary.
        case noSummary(Error?)
        /// It was not possible to determine the remote days and/or hours that can be loaded.
        case noDaysAndHours
        /// Unable to get exposure configuration
        case noExposureConfiguration
        /// Unable to write diagnosis keys
        case unableToDiagnosisKeys
    }
}
