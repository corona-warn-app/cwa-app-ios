//
//  HomeRiskItemViewConfigurator.swift
//  ENA
//
//  Created by Tikhonov, Aleksandr on 14.05.20.
//  Copyright © 2020 SAP SE. All rights reserved.
//

import UIKit

final class HomeRiskItemViewConfigurator: HomeRiskViewConfigurator {
    
    var title: String
    var titleColor: UIColor
    var iconImageName: String
    var color: UIColor
    
    init(title: String, titleColor: UIColor, iconImageName: String, color: UIColor) {
        self.title = title
        self.titleColor = titleColor
        self.iconImageName = iconImageName
        self.color = color
    }
    
    func configure(riskView: RiskImageItemView) {
        let iconTintColor = titleColor
        riskView.iconImageView?.image = UIImage(named: iconImageName)?.withTintColor(iconTintColor)
        riskView.titleTextView?.text = title
        riskView.titleTextView?.textColor = titleColor
        riskView.separatorView?.backgroundColor = UIColor.white.withAlphaComponent(0.15)
        riskView.backgroundColor = color
    }
}
