//
//  HomeRiskItemViewConfigurator.swift
//  ENA
//
//  Created by Tikhonov, Aleksandr on 14.05.20.
//  Copyright © 2020 SAP SE. All rights reserved.
//

import UIKit

final class HomeRiskItemViewConfigurator: HomeRiskViewConfigurator {
    
    func configure(riskView: RiskVVView) {
        
    }
    
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
    
    func configure(riskItemView: RiskItemView) {
        let iconTintColor = titleColor
        riskItemView.iconImageView?.image = UIImage(named: iconImageName)?.withTintColor(iconTintColor)
        riskItemView.titleTextView?.text = title
        riskItemView.titleTextView?.textColor = titleColor
        riskItemView.separatorView?.backgroundColor = UIColor.white.withAlphaComponent(0.15)
        riskItemView.backgroundColor = color
    }
}
