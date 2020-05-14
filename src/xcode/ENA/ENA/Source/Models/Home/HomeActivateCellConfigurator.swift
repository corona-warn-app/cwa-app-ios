//
//  HomeActivateCellConfigurator.swift
//  ENA
//
//  Created by Tikhonov, Aleksandr on 04.05.20.
//  Copyright © 2020 SAP SE. All rights reserved.
//

import UIKit

final class HomeActivateCellConfigurator: CollectionViewCellConfigurator {
    
    private var isActivate = false
    
    init(isActivate: Bool) {
        self.isActivate = isActivate
    }
    
    // MARK: Configuring a Cell
    func configure(cell: ActivateCollectionViewCell) {
        
        let iconImage: UIImage? = isActivate ? UIImage(named: "onboarding_note") : UIImage(named: "onboarding_ipad")
        
        cell.iconImageView.image = iconImage
        cell.titleTextView.text = AppStrings.Home.activateTitle
        cell.chevronImageView.image = UIImage(systemName: "chevron.right")
    }
}
