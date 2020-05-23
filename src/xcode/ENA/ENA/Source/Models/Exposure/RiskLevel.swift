//
//  RiskLevel.swift
//  ENA
//
//  Created by Tikhonov, Aleksandr on 10.05.20.
//  Copyright © 2020 SAP SE. All rights reserved.
//

import Foundation
import ExposureNotification

enum RiskLevel {
    case unknown
    case inactive
    case low
    case high
    
    init?(riskScore: ENRiskScore) {
        self = riskScore.riskLevel
    }
}

extension ENRiskScore {
    var riskLevel: RiskLevel {
        switch self {
        case 0...100: return .low
        case 100...UInt8.max: return .high
        default: return .unknown
        }
    }
}
