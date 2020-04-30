//
//  ExposureVerificationServiceDelegate.swift
//  ENA
//
//  Created by Bormeth, Marc on 29.04.20.
//  Copyright © 2020 SAP SE. All rights reserved.
//

import Foundation

enum ExposureVerificationError {
    case foo  // tbc..
}

struct ExposureVerificationResult {
    let userHasBeenExposed: Bool
    let daysSinceLastExposure: Date?
    let numberOfExposures: Int?
}

protocol ExposureVerificationServiceDelegate: class {
    func didFailWithError(error: ExposureVerificationError)  // TODO: Add sender
    func didFinish(result: ExposureVerificationResult)  // TODO: Add sender
}
