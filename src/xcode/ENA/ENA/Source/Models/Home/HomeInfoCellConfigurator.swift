//
//  HomeInfoCellConfigurator.swift
//  ENA
//
//  Created by Tikhonov, Aleksandr on 04.05.20.
//  Copyright © 2020 SAP SE. All rights reserved.
//

import UIKit

class HomeInfoCellConfigurator: CollectionViewCellConfigurator {
    
    var title: String
    var body: String?
	var position: CellConfiguratorIndexPosition
	
	init(title: String, body: String?, position: CellConfiguratorIndexPosition) {
        self.title = title
        self.body = body
        self.position = position
    }
    
    func configure(cell: InfoCollectionViewCell) {
		cell.backgroundColor = UIColor.systemBackground
        cell.chevronImageView.image = UIImage(systemName: "chevron.right")
        cell.titleLabel.text = title
		cell.bodyLabel.text = body
		if let body = body {
			cell.labelStackView.spacing = 8.0
		} else {
			cell.labelStackView.spacing = 0.0
		}
		cell.clearBorders()
		configureBorders(for: cell)
    }

	func configureBorders(for cell: InfoCollectionViewCell) {
		switch position {
		case .first:
			cell.setBorder(at: [.top], with: UIColor.systemGray5, thickness: 1.0, and: UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0))
			cell.setBorder(at: [.bottom], with: UIColor.systemGray5, thickness: 1.0, and: UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 0))
		case .other:
			cell.setBorder(at: [.bottom], with: UIColor.systemGray5, thickness: 1.0, and: UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 0))
		case .last:
			cell.setBorder(at: [.bottom], with: UIColor.systemGray5, thickness: 1.0)
		}
	}
}
