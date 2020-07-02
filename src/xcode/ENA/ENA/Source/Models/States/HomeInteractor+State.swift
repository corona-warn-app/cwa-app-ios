//
// Created by Hu, Hao on 08.06.20.
// Copyright (c) 2020 SAP SE. All rights reserved.
//

import Foundation
extension HomeInteractor {
	struct State {
		var detectionMode: DetectionMode
		var exposureManagerState: ExposureManagerState
		var enState: ENStateHandler.State

		var risk: Risk?
		var riskLevel: RiskLevel { risk?.level ?? .unknownInitial }
		var numberRiskContacts: Int {
			risk?.details.numberOfExposures ?? 0
		}

		var daysSinceLastExposure: Int? {
			risk?.details.daysSinceLastExposure
		}

		init(detectionMode: DetectionMode, exposureManagerState: ExposureManagerState, enState: ENStateHandler.State, risk: Risk?) {
			self.detectionMode = detectionMode
			self.exposureManagerState = exposureManagerState
			self.enState = enState
			self.risk = risk
		}
	}
}
