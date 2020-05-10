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
    case low
    case high
    case moderate
    
    static func risk(riskScore: ENRiskScore) -> Self {
        switch riskScore {
        case 1, 2, 3:
            return .low
        case 4, 5, 6:
            return .moderate
        case 7, 8:
            return .high
        default:
            return .unknown
        }
    }
}
