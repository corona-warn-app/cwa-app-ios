//
// Created by Hu, Hao on 08.06.20.
// Copyright (c) 2020 SAP SE. All rights reserved.
//

import Foundation
extension HomeInteractor {
	struct State {
		var detectionMode = DetectionMode.default
		var isLoading = false
		var exposureManagerState: ExposureManagerState
		var numberRiskContacts: Int {
			risk?.details.numberOfExposures ?? 0
		}

		var daysSinceLastExposure: Int? {
			guard let date = risk?.details.exposureDetectionDate else {
				return nil
			}
			return Calendar.current.dateComponents([.day], from: date, to: Date()).day
		}

		var risk: Risk?
		var riskLevel: RiskLevel { risk?.level ?? .unknownInitial }
	}
}