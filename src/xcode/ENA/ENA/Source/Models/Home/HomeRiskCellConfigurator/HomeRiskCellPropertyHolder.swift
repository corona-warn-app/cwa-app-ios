//
//  HomeRiskCellPropertyHolder.swift
//  ENA
//
//  Created by Tikhonov, Aleksandr on 12.05.20.
//  Copyright © 2020 SAP SE. All rights reserved.
//

import UIKit

final class HomeRiskCellPropertyHolder {
    
    let title: String
    let titleColor: UIColor
    let body: String
    let date: String?
    let color: UIColor
    let chevronTintColor: UIColor
    let chevronImage: UIImage?
    let iconImage: UIImage?
    
    init(title: String, titleColor: UIColor, body: String, date: String?, color: UIColor, chevronTintColor: UIColor, chevronImage: UIImage?, iconImage: UIImage?) {
        self.title = title
        self.titleColor = titleColor
        self.body = body
        self.date = date
        self.color = color
        self.chevronTintColor = chevronTintColor
        self.chevronImage = chevronImage
        self.iconImage = iconImage
    }
    
    // swiftlint:disable:next function_body_length
    static func propertyHolder(for riskLevel: RiskLevel, dateString: String?) -> HomeRiskCellPropertyHolder {
        switch riskLevel {
        case .unknown:
            return HomeRiskCellPropertyHolder(
                title: AppStrings.Home.riskCardUnknownTitle,
                // swiftlint:disable:next discouraged_object_literal
                titleColor: #colorLiteral(red: 0.501960814, green: 0.501960814, blue: 0.501960814, alpha: 1),
                body: AppStrings.RiskView.unknownRiskDetail,
                date: dateString,
                color: UIColor.preferredColor(for: .unknownRisk),
                chevronTintColor: .systemBlue,
                chevronImage: UIImage(systemName: "chevron.right"),
                iconImage: UIImage(named: "onboarding_ipad")
            )
        case .low:
            return HomeRiskCellPropertyHolder(
                title: AppStrings.Home.riskCardLowTitle,
                // swiftlint:disable:next discouraged_object_literal
                titleColor: #colorLiteral(red: 0.9090440273, green: 1, blue: 0.8056635857, alpha: 1),
                body: AppStrings.RiskView.lowRiskDetail,
                date: dateString,
                color: UIColor.preferredColor(for: .positive),
                // swiftlint:disable:next discouraged_object_literal
                chevronTintColor: #colorLiteral(red: 0.9090440273, green: 1, blue: 0.8056635857, alpha: 1),
                chevronImage: UIImage(systemName: "chevron.right"),
                iconImage: UIImage(named: "onboarding_ipad")
            )
        case .high:
            return HomeRiskCellPropertyHolder(
                title: AppStrings.Home.riskCardHighTitle,
                // swiftlint:disable:next discouraged_object_literal
                titleColor: #colorLiteral(red: 0.06978602707, green: 0.1870820522, blue: 0.3886224329, alpha: 1),
                body: AppStrings.RiskView.highRiskDetail,
                date: dateString,
                color: UIColor.preferredColor(for: .negative),
                // swiftlint:disable:next discouraged_object_literal
                chevronTintColor: #colorLiteral(red: 1, green: 0.8961167932, blue: 0.8636761308, alpha: 1),
                chevronImage: UIImage(systemName: "chevron.right"),
                iconImage: UIImage(named: "onboarding_ipad")
            )
        case .moderate:
            return HomeRiskCellPropertyHolder(
                title: AppStrings.Home.riskCardModerateTitle,
                titleColor: .white,
                body: AppStrings.RiskView.moderateRiskDetail,
                date: dateString,
                color: UIColor.preferredColor(for: .medium),
                chevronTintColor: .white,
                chevronImage: UIImage(systemName: "chevron.right"),
                iconImage: UIImage(named: "onboarding_ipad")
            )
        }
    }
}
