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
    
    private static var lowRange: ClosedRange<ENRiskScore> {
        1...4
    }
    
    private static var highRange: ClosedRange<ENRiskScore> {
        5...8
    }
    
    init?(riskScore: ENRiskScore) {
        switch riskScore {
        case let score where RiskLevel.lowRange ~= score:
            self = .low
        case let score where RiskLevel.highRange ~= score:
            self = .high
        default:
            return nil
        }
    }
}
