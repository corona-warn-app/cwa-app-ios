//
//  ExposureDetectionTransactionDelegate.swift
//  ENA
//
//  Created by Kienle, Christian on 15.05.20.
//  Copyright © 2020 SAP SE. All rights reserved.
//

import Foundation
import ExposureNotification

/// Methods required to move an exposure detection transaction forward and for consuming
/// the results of a transaction.
protocol ExposureDetectionTransactionDelegate: AnyObject {
    typealias ContinueHandler = (ExposureManager) -> Void
    typealias AbortHandler = (Error?) -> Void

    func exposureDetectionTransaction(
        _ transaction: ExposureDetectionTransaction,
        continueWithExposureManager: @escaping ContinueHandler,
        abort: @escaping AbortHandler
    )

    func exposureDetectionTransaction(
        _ transaction: ExposureDetectionTransaction,
        didEndPrematurely reason: ExposureDetectionTransaction.DidEndPrematurelyReason
    )

    func exposureDetectionTransaction(
        _ transaction: ExposureDetectionTransaction,
        didDetectSummary summary: ENExposureDetectionSummary
    )

    func exposureDetectionTransactionRequiresFormattedToday(
        _ transaction: ExposureDetectionTransaction
    ) -> String
}
