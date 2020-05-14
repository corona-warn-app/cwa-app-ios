//
//  HomeRiskItemCellConfigurator.swift
//  ENA
//
//  Created by Tikhonov, Aleksandr on 14.05.20.
//  Copyright © 2020 SAP SE. All rights reserved.
//

import UIKit

class HomeRiskItemCellConfigurator: TableViewCellConfigurator {
    
    var title: String
    var iconImageName: String
    
    init(title: String, iconImageName: String) {
        self.title = title
        self.iconImageName = iconImageName
    }
    
    func configure(cell: RiskItemTableViewCell) {
        cell.imageView?.image = UIImage(systemName: iconImageName)
        cell.textLabel?.text = title
    }
}
