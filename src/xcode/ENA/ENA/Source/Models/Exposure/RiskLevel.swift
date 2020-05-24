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
        self <= 100 ? .low : .high
    }
}
