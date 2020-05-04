//
//  HomeActivateCellConfigurator.swift
//  ENA
//
//  Created by Tikhonov, Aleksandr on 04.05.20.
//  Copyright © 2020 SAP SE. All rights reserved.
//

import UIKit

struct HomeActivateCellConfigurator: CollectionViewCellConfigurator {
    
    func configure(cell: ActivateCollectionViewCell) {
        
        cell.iconImageView.image = UIImage(named: "onboarding_note")
        cell.titleLabel.text = "Tracing ist aktiv"
        cell.chevronImageView.image = UIImage(systemName: "chevron.right")
        
    }
}
