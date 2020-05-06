//
//  CodableDiagnosisKey.swift
//  ENA
//
//  Created by Kienle, Christian on 05.05.20.
//  Copyright © 2020 SAP SE. All rights reserved.
//

import ExposureNotification

struct CMCodableDiagnosisKey: Codable, Equatable {
    let keyData: Data
    let rollingStartNumber: ENIntervalNumber
    let transmissionRiskLevel: ENRiskLevel.RawValue
}
