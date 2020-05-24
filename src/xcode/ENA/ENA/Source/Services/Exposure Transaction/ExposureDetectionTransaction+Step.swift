//
//  ExposureDetectionTransaction+Step.swift
//  ENA
//
//  Created by Kienle, Christian on 24.05.20.
//  Copyright © 2020 SAP SE. All rights reserved.
//

import Foundation

extension ExposureDetectionTransaction {
    enum Step {
        /// Initial state. Waiting to be started.
        case ready

        /// Determine what the app has to download in order to be up to date.
        case determiningWhatToLoad

        /// Load the actual diagnosis keys from the backend.
        case loadingKeys

        /// Store the downloaded keys.
        case storingKeys

        /// Ensure that we have the latest configuration parameters from the Robert Koch Institute.
        case loadingConfiguration

        /// Writes diagnosis keys in unencrypted files.
        case writingFiles

        /// Performs an actual exposure detection.
        case gettingExposureSummary

        /// Delelets previously created files.
        ///
        /// Deleting files will happen in the following cases:
        /// - Error during `.writingFiles`
        /// - Error during `.gettingExposureSummary`
        /// - After `.gettingExposureSummary`
        /// We have to do that in order to remove any data previously written.
        case deletingFiles

        case done
    }
}

extension ExposureDetectionTransaction.Step {
    var next: ExposureDetectionTransaction.Step {
        switch self {
        case .ready:
            return .determiningWhatToLoad
        case .determiningWhatToLoad:
            return .loadingKeys
        case .loadingKeys:
            return .storingKeys
        case .storingKeys:
            return .loadingConfiguration
        case .loadingConfiguration:
            return .writingFiles
        case .writingFiles:
            return .gettingExposureSummary
        case .gettingExposureSummary:
            return .deletingFiles
        case .deletingFiles:
            return .done
        case .done:
            fatalError("there is nothing after .done: Done is done. Relax.")
        }
    }
}
