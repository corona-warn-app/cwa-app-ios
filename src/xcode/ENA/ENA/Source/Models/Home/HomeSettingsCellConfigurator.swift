//
//  HomeSettingsCellConfigurator.swift
//  ENA
//
//  Created by Tikhonov, Aleksandr on 04.05.20.
//  Copyright © 2020 SAP SE. All rights reserved.
//

import UIKit

class HomeSettingsCellConfigurator: CollectionViewCellConfigurator {

    var title: String
	var position: CellConfiguratorIndexPosition
	
    init(title: String, position: CellConfiguratorIndexPosition) {
        self.title = title
        self.position = position
    }

    func configure(cell: SettingsCollectionViewCell) {
		cell.backgroundColor = UIColor.systemBackground
        cell.chevronImageView.image = UIImage(systemName: "chevron.right")
        cell.titleLabel.text = title
		
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
