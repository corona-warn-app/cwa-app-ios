//
//  HomeRiskCellPropertyHolder.swift
//  ENA
//
//  Created by Tikhonov, Aleksandr on 12.05.20.
//  Copyright © 2020 SAP SE. All rights reserved.
//

import UIKit

protocol RiskVVView: UIView { }

protocol HomeRiskViewConfiguratorAny {
    var viewAnyType: UIView.Type { get }
    
    func configureAny(riskView: UIView)
}

protocol HomeRiskViewConfigurator: HomeRiskViewConfiguratorAny {
    associatedtype ViewType: UIView
    func configure(riskView: ViewType)
}

extension HomeRiskViewConfigurator {
    
    var viewAnyType: UIView.Type {
        ViewType.self
    }
    
    func configureAny(riskView: UIView) {
        if let riskView = riskView as? ViewType {
            configure(riskView: riskView)
        } else {
            let error = "\(riskView) isn't conformed ViewType"
            logError(message: error)
            fatalError(error)
        }
    }
}

final class HomeRiskCellPropertyHolder {
    
    let title: String
    let titleColor: UIColor
    let color: UIColor
    let chevronTintColor: UIColor
    let chevronImage: UIImage?
    let buttonTitle: String
    let isButtonEnabled: Bool
    let cellConfigurators: [HomeRiskViewConfiguratorAny]
    
    init(title: String, titleColor: UIColor, color: UIColor, chevronTintColor: UIColor, chevronImage: UIImage?, buttonTitle: String, isButtonEnabled: Bool, itemCellConfigurators: [HomeRiskViewConfiguratorAny]) {
        self.title = title
        self.titleColor = titleColor
        self.color = color
        self.chevronTintColor = chevronTintColor
        self.chevronImage = chevronImage
        self.buttonTitle = buttonTitle
        self.isButtonEnabled = isButtonEnabled
        self.cellConfigurators = itemCellConfigurators
    }
    
    // swiftlint:disable:next function_body_length
    static func propertyHolder(riskLevel: RiskLevel, lastUpdateDateString: String?, numberRiskContacts: String, lastContactDateString: String, isLoading: Bool) -> HomeRiskCellPropertyHolder {
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
            var itemCellConfigurator: [HomeRiskViewConfiguratorAny] = []
            if isLoading {
                let isLoadingItem = HomeRiskLoadingItemViewConfigurator(title: AppStrings.Home.riskCardStatusCheckBody, titleColor: titleColor, isLoading: true, color: color)
                itemCellConfigurator.append(isLoadingItem)
            } else {
                itemCellConfigurator.append(item1)
                itemCellConfigurator.append(item2)
            }
            let title: String = isLoading ? AppStrings.Home.riskCardStatusCheckTitle : AppStrings.Home.riskCardLowTitle
            let buttonTitle: String = isLoading ? AppStrings.Home.riskCardStatusCheckButton : AppStrings.Home.riskCardLowButton
            return HomeRiskCellPropertyHolder(
                title: title,
                titleColor: titleColor,
                color: color,
                chevronTintColor: .preferredColor(for: .chevron),
                chevronImage: UIImage(systemName: "chevron.right"),
                buttonTitle: buttonTitle,
                isButtonEnabled: true,
                itemCellConfigurators: itemCellConfigurator
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
