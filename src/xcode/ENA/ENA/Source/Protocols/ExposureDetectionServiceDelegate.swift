//
//  ExposureDetectionServiceDelegate.swift
//  ENA
//
//  Created by Bormeth, Marc on 29.04.20.
//  Copyright © 2020 SAP SE. All rights reserved.
//

import ExposureNotification

enum ExposureDetectionError {
    case foo  // tbc..
}

struct ExposureDetectionResult {
    let userHasBeenExposed: Bool
    let daysSinceLastExposure: Date?
    let numberOfExposures: Int?
}

/// All delegate methods will be called on the main queue.
protocol ExposureDetectionServiceDelegate: class {
    func didFinish(_ sender: ExposureDetectionService, result: ENExposureDetectionSummary)
    func didFailWithError(_ sender: ExposureDetectionService, error: Error)
}
