//
//  HomeRiskLoadingItemViewConfigurator.swift
//  ENA
//
//  Created by Tikhonov, Aleksandr on 20.05.20.
//  Copyright © 2020 SAP SE. All rights reserved.
//

import UIKit

final class HomeRiskLoadingItemViewConfigurator: HomeRiskViewConfigurator {
    
    var title: String
    var titleColor: UIColor
    var isLoading: Bool
    var color: UIColor
    
    init(title: String, titleColor: UIColor, isLoading: Bool, color: UIColor) {
        self.title = title
        self.titleColor = titleColor
        self.isLoading = isLoading
        self.color = color
    }
    
    func configure(riskView: RiskLoadingItemView) {
        let iconTintColor = titleColor
        // riskItemView.iconImageView?.image = UIImage(named: iconImageName)?.withTintColor(iconTintColor)
        riskView.titleTextView?.text = title
        riskView.titleTextView?.textColor = titleColor
        riskView.separatorView?.backgroundColor = UIColor.white.withAlphaComponent(0.15)
        riskView.backgroundColor = color
    }
}
