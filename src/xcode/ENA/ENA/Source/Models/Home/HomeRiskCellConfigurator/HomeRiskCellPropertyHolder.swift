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
    let color: UIColor
    let chevronTintColor: UIColor
    let chevronImage: UIImage?
    let buttonTitle: String
    let isButtonEnabled: Bool
    let itemCellConfigurators: [HomeRiskItemViewConfigurator]
    
    init(title: String, titleColor: UIColor, color: UIColor, chevronTintColor: UIColor, chevronImage: UIImage?, buttonTitle: String, isButtonEnabled: Bool, itemCellConfigurators: [HomeRiskItemViewConfigurator]) {
        self.title = title
        self.titleColor = titleColor
        self.color = color
        self.chevronTintColor = chevronTintColor
        self.chevronImage = chevronImage
        self.buttonTitle = buttonTitle
        self.isButtonEnabled = isButtonEnabled
        self.itemCellConfigurators = itemCellConfigurators
    }
    
        
    static func propertyHolder(for riskLevel: RiskLevel, dateString: String?) -> HomeRiskCellPropertyHolder {
        
        switch riskLevel {
        case .unknown:
            let titleColor = UIColor.white
            let color = UIColor.preferredColor(for: .unknownRisk)
            return HomeRiskCellPropertyHolder(
                title: AppStrings.Home.riskCardUnknownTitle,
                titleColor: titleColor,
                color: color,
                chevronTintColor: .preferredColor(for: .chevron),
                chevronImage: UIImage(systemName: "chevron.right"),
                buttonTitle: AppStrings.Home.riskCardButton,
                isButtonEnabled: false,
                itemCellConfigurators: []
            )
        case .inactive:
            let titleColor = UIColor.white
            let color = UIColor.preferredColor(for: .inactive)
            let item1 = HomeRiskItemViewConfigurator(title: "1 Kontakt", titleColor: titleColor, iconImageName: "InfizierteKontakte", color: color)
            let item2 = HomeRiskItemViewConfigurator(title: "12 Tage seit letztem Kontakt", titleColor: titleColor, iconImageName: "Calendar", color: color)
            let item3 = HomeRiskItemViewConfigurator(title: "Letzte Prüfung: Heute, 9:32 Uhr", titleColor: titleColor, iconImageName: "LetztePruefung", color: color)
            return HomeRiskCellPropertyHolder(
                title: AppStrings.Home.riskCardInactiveTitle,
                titleColor: titleColor,
                color: color,
                chevronTintColor: .white,
                chevronImage: UIImage(systemName: "chevron.right"),
                buttonTitle: AppStrings.Home.riskCardButton,
                isButtonEnabled: true,
                itemCellConfigurators: [item1, item2, item3]
            )
        case .low:
            let titleColor = UIColor.white
            let color = UIColor.preferredColor(for: .positive)
            let item1 = HomeRiskItemViewConfigurator(title: "Bisher keine Kontakte", titleColor: titleColor, iconImageName: "InfizierteKontakte", color: color)
            let item2 = HomeRiskItemViewConfigurator(title: "Letzte Prüfung: Heute, 9:32 Uhr", titleColor: titleColor, iconImageName: "LetztePruefung", color: color)
            return HomeRiskCellPropertyHolder(
                title: AppStrings.Home.riskCardLowTitle,
                titleColor: titleColor,
                color: color,
                chevronTintColor: .white,
                chevronImage: UIImage(systemName: "chevron.right"),
                buttonTitle: AppStrings.Home.riskCardButton,
                isButtonEnabled: true,
                itemCellConfigurators: [item1, item2]
            )
        case .high:
            let titleColor = UIColor.white
            let color = UIColor.preferredColor(for: .negative)
            let item1 = HomeRiskItemViewConfigurator(title: "8 Kontakte mit erhöhtem Risiko", titleColor: titleColor, iconImageName: "InfizierteKontakte", color: color)
            let item2 = HomeRiskItemViewConfigurator(title: "2 Tage seit letztem Kontakt", titleColor: titleColor, iconImageName: "Calendar", color: color)
            let item3 = HomeRiskItemViewConfigurator(title: "Letzte Prüfung: Heute, 9:32 Uhr", titleColor: titleColor, iconImageName: "LetztePruefung", color: color)
            return HomeRiskCellPropertyHolder(
                title: AppStrings.Home.riskCardHighTitle,
                titleColor: titleColor,
                color: color,
                chevronTintColor: .white,
                chevronImage: UIImage(systemName: "chevron.right"),
                buttonTitle: AppStrings.Home.riskCardButton,
                isButtonEnabled: true,
                itemCellConfigurators: [item1, item2, item3]
            )
        }
    }
}
