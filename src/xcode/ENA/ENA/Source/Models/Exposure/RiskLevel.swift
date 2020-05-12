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
    
    init(riskScore: ENRiskScore) {
        switch riskScore {
        case 1, 2, 3:
            self = .low
        case 4, 5, 6:
            self = .moderate
        case 7, 8:
            self = .high
        default:
            self = .unknown
        }
    }
}
