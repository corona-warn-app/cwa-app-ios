//
//  ExposureDetectionViewControllerState.swift
//  ENA
//
//  Created by Marc-Peter Eisinger on 24.05.20.
//  Copyright © 2020 SAP SE. All rights reserved.
//

import Foundation
import UIKit


class ExposureDetectionViewControllerState {
	var isTracingEnabled: Bool = false
	var riskLevel: RiskLevel = .unknown
	var nextRefresh: Date? =  Date().addingTimeInterval(3600)
	var summary: ExposureDetectionViewControllerSummary?
	
	
	var actualRiskText: String {
		riskLevel.text
	}
	
	var riskText: String {
		isTracingEnabled ? riskLevel.text : AppStrings.ExposureDetection.off
	}
	
	var riskTintColor: UIColor {
		return isTracingEnabled ? riskLevel.tintColor : .preferredColor(for: .backgroundBase)
	}
	
	var riskContrastColor: UIColor {
		return isTracingEnabled ? riskLevel.contrastColor : .preferredColor(for: .textPrimary1)
	}
}


private extension RiskLevel {
	var text: String {
		switch self {
		case .unknown: return AppStrings.ExposureDetection.unknown
		case .inactive: return AppStrings.ExposureDetection.inactive
		case .low: return AppStrings.ExposureDetection.low
		case .high: return AppStrings.ExposureDetection.high
		}
	}
	
	var tintColor: UIColor {
		switch self {
		case .unknown: return .preferredColor(for: .unknownRisk)
		case .inactive: return .preferredColor(for: .inactive)
		case .low: return .preferredColor(for: .positive)
		case .high: return .preferredColor(for: .negative)
		}
	}
	
	var contrastColor: UIColor {
		switch self {
		case .unknown: return .white
		case .inactive: return .white
		case .low: return .white
		case .high: return .white
		}
	}
}
