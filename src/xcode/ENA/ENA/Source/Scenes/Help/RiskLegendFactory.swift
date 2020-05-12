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
        var riskLevel: RiskCollectionViewCell.RiskLevel
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
            RiskLegendEntry(riskLevel: .unknown,
                            backgroundColor: UIColor.preferredColor(for: ColorStyle.lightText),
                            imageName: "sun.min",
                            title: AppStrings.RiskView.unknownRisk,
                            description: AppStrings.RiskView.unknownRiskDetailHelp),
            RiskLegendEntry(riskLevel: .low,
                            backgroundColor: UIColor.preferredColor(for: ColorStyle.positive),
                            imageName: "sun.dust",
                            title: AppStrings.RiskView.lowRisk,
                            description: AppStrings.RiskView.lowRiskDetailHelp),
            RiskLegendEntry(riskLevel: .moderate,
                            backgroundColor: UIColor.preferredColor(for: ColorStyle.critical),
                            imageName: "cloud.rain",
                            title: AppStrings.RiskView.moderateRisk,
                            description: AppStrings.RiskView.moderateRiskDetailHelp),
            RiskLegendEntry(riskLevel: .high,
                            backgroundColor: UIColor.preferredColor(for: ColorStyle.negative),
                            imageName: "cloud.bolt",
                            title: AppStrings.RiskView.highRisk,
                            description: AppStrings.RiskView.highRiskDetailHelp)
        ]
    }
}
