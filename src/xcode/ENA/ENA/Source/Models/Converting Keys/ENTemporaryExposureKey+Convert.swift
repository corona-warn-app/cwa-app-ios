//
//  ENTemporaryExposureKey+Convert.swift
//  ENA
//
//  Created by Kienle, Christian on 15.05.20.
//  Copyright © 2020 SAP SE. All rights reserved.
//

import ExposureNotification

extension ENTemporaryExposureKey {
    var sapKey: Sap_Key {
        Sap_Key.with {
            $0.keyData = self.keyData
            $0.rollingPeriod = self.rollingPeriod
            $0.rollingStartNumber = self.rollingStartNumber
            $0.transmissionRiskLevel = Int32(self.transmissionRiskLevel)
        }
    }
}
