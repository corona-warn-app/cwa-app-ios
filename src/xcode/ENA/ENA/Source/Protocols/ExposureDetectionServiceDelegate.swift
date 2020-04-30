//
//  ExposureDetectionServiceDelegate.swift
//  ENA
//
//  Created by Bormeth, Marc on 29.04.20.
//  Copyright © 2020 SAP SE. All rights reserved.
//

import Foundation

enum ExposureDetectionError {
    case foo  // tbc..
}

struct ExposureDetectionResult {
    let userHasBeenExposed: Bool
    let daysSinceLastExposure: Date?
    let numberOfExposures: Int?
}

protocol ExposureDetectionServiceDelegate: class {
    func didFailWithError(error: ExposureDetectionError)  // TODO: Add sender
    func didFinish(result: ExposureDetectionResult)  // TODO: Add sender
}
