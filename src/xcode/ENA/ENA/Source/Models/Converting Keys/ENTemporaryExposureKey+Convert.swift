//
//  ENTemporaryExposureKey+Convert.swift
//  ENA
//
//  Created by Kienle, Christian on 15.05.20.
//  Copyright © 2020 SAP SE. All rights reserved.
//

import ExposureNotification

extension ENTemporaryExposureKey {
    var sapKey: SAP_TemporaryExposureKey {
        SAP_TemporaryExposureKey.with {
            $0.keyData = self.keyData
            $0.rollingPeriod = 144  // Temporarily set to magic number
            $0.rollingStartIntervalNumber = Int32(self.rollingStartNumber)
            $0.transmissionRiskLevel = 1  // Temporarily set to magic number (No config provided by RKI, yet)
        }
    }
}
