//
//  Exposure.swift
//  ENA
//
//  Created by Kienle, Christian on 04.05.20.
//  Copyright © 2020 SAP SE. All rights reserved.
//

import Foundation
import ExposureNotification

struct Exposure: Codable {
    let date: Date
    let duration: TimeInterval
    let totalRiskScore: ENRiskScore
    let transmissionRiskLevel: ENRiskLevel.RawValue

    init(exposureInfo: ENExposureInfo) {
        date = exposureInfo.date
        duration = exposureInfo.duration
        totalRiskScore = exposureInfo.totalRiskScore
        transmissionRiskLevel = exposureInfo.transmissionRiskLevel.rawValue
    }

    // For simulation only
    init(date: Date, duration: TimeInterval, totalRiskScore: ENRiskScore, transmissionRiskLevel: ENRiskLevel.RawValue) {
        self.date = date
        self.duration = duration
        self.totalRiskScore = totalRiskScore
        self.transmissionRiskLevel = transmissionRiskLevel
    }
}
