//
//  HomeSettingsCellConfigurator.swift
//  ENA
//
//  Created by Tikhonov, Aleksandr on 04.05.20.
//  Copyright © 2020 SAP SE. All rights reserved.
//

import UIKit

class HomeSettingsCellConfigurator: CollectionViewCellConfigurator {

	var position: CellConfiguratorIndexPosition = .other
	
    func configure(cell: SettingsCollectionViewCell) {
		cell.backgroundColor = UIColor.systemBackground
        cell.chevronImageView.image = UIImage(systemName: "chevron.right")
        cell.titleLabel.text = AppStrings.Home.settingsCardTitle
		
		switch position {
		case .first:
			cell.setBorder(at: [.top], with: UIColor.systemGray5, thickness: 1.0)
			cell.setBorder(at: [.bottom], with: UIColor.systemGray5, thickness: 1.0, and: UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 0))
		case .other:
			cell.setBorder(at: [.bottom], with: UIColor.systemGray5, thickness: 1.0, and: UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 0))
		case .last:
			cell.setBorder(at: [.bottom], with: UIColor.systemGray5, thickness: 1.0)
		}
    }
}
