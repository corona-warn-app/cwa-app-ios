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
    
    // swiftlint:disable:next function_body_length
    static func propertyHolder(riskLevel: RiskLevel, lastUpdateDateString: String?, numberRiskContacts: String, lastContactDateString: String) -> HomeRiskCellPropertyHolder {
        switch riskLevel {
        case .unknown:
            let titleColor = UIColor.white
            let color = UIColor.preferredColor(for: .unknownRisk)
            let item = HomeRiskItemViewConfigurator(title: AppStrings.Home.riskCardUnknownItemTitle, titleColor: titleColor, iconImageName: "InfizierteKontakte", color: color)
            return HomeRiskCellPropertyHolder(
                title: AppStrings.Home.riskCardUnknownTitle,
                titleColor: titleColor,
                color: color,
                chevronTintColor: .preferredColor(for: .chevron),
                chevronImage: UIImage(systemName: "chevron.right"),
                buttonTitle: AppStrings.Home.riskCardUnknownButton,
                isButtonEnabled: false,
                itemCellConfigurators: [item]
            )
        case .inactive:
            let titleColor = UIColor.white
            let color = UIColor.preferredColor(for: .inactive)
            let item1 = HomeRiskItemViewConfigurator(title: AppStrings.Home.riskCardInactiveActivateItemTitle, titleColor: titleColor, iconImageName: "InfizierteKontakte", color: color)
            let dateTitle = String(format: AppStrings.Home.riskCardInactiveDateItemTitle, lastUpdateDateString ?? "-")
            let item2 = HomeRiskItemViewConfigurator(title: dateTitle, titleColor: titleColor, iconImageName: "LetztePruefung", color: color)
            return HomeRiskCellPropertyHolder(
                title: AppStrings.Home.riskCardInactiveTitle,
                titleColor: titleColor,
                color: color,
                chevronTintColor: .preferredColor(for: .chevron),
                chevronImage: UIImage(systemName: "chevron.right"),
                buttonTitle: AppStrings.Home.riskCardInactiveButton,
                isButtonEnabled: true,
                itemCellConfigurators: [item1, item2]
            )
        case .low:
            let titleColor = UIColor.white
            let color = UIColor.preferredColor(for: .positive)
            let item1 = HomeRiskItemViewConfigurator(title: AppStrings.Home.riskCardLowNoContactItemTitle, titleColor: titleColor, iconImageName: "InfizierteKontakte", color: color)
            let dateTitle = String(format: AppStrings.Home.riskCardLowDateItemTitle, lastUpdateDateString ?? "-")
            let item2 = HomeRiskItemViewConfigurator(title: dateTitle, titleColor: titleColor, iconImageName: "LetztePruefung", color: color)
            return HomeRiskCellPropertyHolder(
                title: AppStrings.Home.riskCardLowTitle,
                titleColor: titleColor,
                color: color,
                chevronTintColor: .preferredColor(for: .chevron),
                chevronImage: UIImage(systemName: "chevron.right"),
                buttonTitle: AppStrings.Home.riskCardLowButton,
                isButtonEnabled: true,
                itemCellConfigurators: [item1, item2]
            )
        case .high:
            let titleColor = UIColor.white
            let color = UIColor.preferredColor(for: .negative)
            let numberContactsTitle = String(format: AppStrings.Home.riskCardHighNumberContactsItemTitle, numberRiskContacts)
            let item1 = HomeRiskItemViewConfigurator(title: numberContactsTitle, titleColor: titleColor, iconImageName: "InfizierteKontakte", color: color)
            let lastContactTitle = String(format: AppStrings.Home.riskCardHighLastContactItemTitle, lastContactDateString)
            let item2 = HomeRiskItemViewConfigurator(title: lastContactTitle, titleColor: titleColor, iconImageName: "Calendar", color: color)
            let dateTitle = String(format: AppStrings.Home.riskCardHighDateItemTitle, lastUpdateDateString ?? "-")
            let item3 = HomeRiskItemViewConfigurator(title: dateTitle, titleColor: titleColor, iconImageName: "LetztePruefung", color: color)
            return HomeRiskCellPropertyHolder(
                title: AppStrings.Home.riskCardHighTitle,
                titleColor: titleColor,
                color: color,
                chevronTintColor: .preferredColor(for: .chevron),
                chevronImage: UIImage(systemName: "chevron.right"),
                buttonTitle: AppStrings.Home.riskCardHighButton,
                isButtonEnabled: true, // or false
                itemCellConfigurators: [item1, item2, item3]
            )
        }
    }
}
