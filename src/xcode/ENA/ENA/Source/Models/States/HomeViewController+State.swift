//
// Created by Hu, Hao on 08.06.20.
// Copyright (c) 2020 SAP SE. All rights reserved.
//

import Foundation

extension HomeViewController {
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
			guard let date = risk?.details.exposureDetectionDate else {
				return nil
			}
			return Calendar.current.dateComponents([.day], from: date, to: Date()).day
		}
	}
}

extension HomeViewController.State {
	mutating func mergeWith(
		detectionMode: DetectionMode? = nil,
		exposureManagerState: ExposureManagerState? = nil,
		enState: ENStateHandler.State? = nil,
		risk: Risk?
	) {
		if let detectionMode = detectionMode {
			self.detectionMode = detectionMode
		}

		if let exposureManagerState = exposureManagerState {
			self.exposureManagerState = exposureManagerState
		}

		if let enState = enState {
			self.enState = enState
		}

		if let risk = risk {
			self.risk = risk
		}
	}
}
