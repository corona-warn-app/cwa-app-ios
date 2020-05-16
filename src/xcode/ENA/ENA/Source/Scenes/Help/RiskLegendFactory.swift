//
//  RiskLegendFactory.swift
//  ENA
//
//  Created by Steinmetz, Conrad on 12.05.20.
//  Copyright © 2020 SAP SE. All rights reserved.
//

import Foundation
import UIKit

class RiskLegendFactory {

    struct RiskLegendEntry {
        var riskLevel: RiskLevel
        var backgroundColor: UIColor
        var imageName: String
        var title: String
        var description: String
    }

    private static var sharedRiskLegendFactory = RiskLegendFactory()

    class func getSharedRiskLegendFactory() -> RiskLegendFactory {
        return sharedRiskLegendFactory
    }

    func getRiskLegend() -> [RiskLegendEntry] {
        return [
            RiskLegendEntry(
                riskLevel: .unknown,
                backgroundColor: .preferredColor(for: .unknownRisk),
                imageName: "sun.min",
                title: AppStrings.RiskView.unknownRisk,
                description: AppStrings.RiskView.unknownRiskDetailHelp
            ),
            RiskLegendEntry(
                riskLevel: .inactive,
                backgroundColor: .preferredColor(for: .medium),
                imageName: "cloud.rain",
                title: AppStrings.RiskView.inactiveRisk,
                description: AppStrings.RiskView.inactiveRiskDetailHelp
            ),
            RiskLegendEntry(
                riskLevel: .low,
                backgroundColor: .preferredColor(for: .positive),
                imageName: "sun.dust",
                title: AppStrings.RiskView.lowRisk,
                description: AppStrings.RiskView.lowRiskDetailHelp
            ),
            RiskLegendEntry(
                riskLevel: .high,
                backgroundColor: .preferredColor(for: .negative),
                imageName: "cloud.bolt",
                title: AppStrings.RiskView.highRisk,
                description: AppStrings.RiskView.highRiskDetailHelp
            )
        ]
    }
}
