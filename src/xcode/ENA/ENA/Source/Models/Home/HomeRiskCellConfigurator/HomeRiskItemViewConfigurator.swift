//
//  HomeRiskItemViewConfigurator.swift
//  ENA
//
//  Created by Tikhonov, Aleksandr on 14.05.20.
//  Copyright © 2020 SAP SE. All rights reserved.
//

import UIKit

final class HomeRiskItemViewConfigurator {
    
    var title: String
    var titleColor: UIColor?
    var iconImageName: String
    var color: UIColor?
    
    init(title: String, titleColor: UIColor?, iconImageName: String, color: UIColor?) {
        self.title = title
        self.titleColor = titleColor
        self.iconImageName = iconImageName
        self.color = color
    }
    
    func configure(riskItemView: RiskItemView) {
        let iconTintColor: UIColor = titleColor ?? .white
        riskItemView.imageView?.image = UIImage(named: iconImageName)?.withTintColor(iconTintColor)
        riskItemView.insetTextLabel?.text = title
        riskItemView.insetTextLabel?.textColor = titleColor
        riskItemView.separatorView?.backgroundColor = iconTintColor
        riskItemView.backgroundColor = color
    }
}
