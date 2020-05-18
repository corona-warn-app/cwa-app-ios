//
//  HomeSettingsCellConfigurator.swift
//  ENA
//
//  Created by Tikhonov, Aleksandr on 04.05.20.
//  Copyright © 2020 SAP SE. All rights reserved.
//

import UIKit

class HomeAppInformationCellConfigurator: CollectionViewCellConfigurator {
    func configure(cell: SettingsCollectionViewCell) {
        cell.chevronImageView.image = UIImage(systemName: "chevron.right")
        cell.titleLabel.text = AppStrings.Home.appInformationCardTitle
    }
}
