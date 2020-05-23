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
	var position: CellConfiguratorPositionInSection
	var accessibilityIdentifier: String?
	
	init(title: String, body: String?, position: CellConfiguratorPositionInSection, accessibilityIdentifier: String?) {
        self.title = title
        self.body = body
        self.position = position
		self.accessibilityIdentifier = accessibilityIdentifier
    }
    
    func configure(cell: InfoCollectionViewCell) {
		cell.backgroundColor = UIColor.preferredColor(for: .backgroundBase)
        cell.chevronImageView.image = UIImage(systemName: "chevron.right")
        cell.titleLabel.text = title
		cell.bodyLabel.text = body
		cell.bodyLabel.textColor = UIColor.preferredColor(for: .textPrimary2)
		cell.bodyLabel.isHidden = (body == nil)

		cell.topDividerView.backgroundColor = UIColor.secondaryLabel.withAlphaComponent(0.3)
		cell.bottomDividerView.backgroundColor = UIColor.secondaryLabel.withAlphaComponent(0.3)

		configureBorders(in: cell)
		setupAccessibility(for: cell)
	}
	
	func configureBorders(in cell: InfoCollectionViewCell) {
		switch position {
		case .first:
			cell.topDividerView.isHidden = false
			cell.bottomDividerLeadingConstraint.constant = 15.0
		case .other:
			cell.topDividerView.isHidden = true
			cell.bottomDividerLeadingConstraint.constant = 15.0
		case .last:
			cell.topDividerView.isHidden = true
			cell.bottomDividerLeadingConstraint.constant = 0.0
		}
	}
		
	func setupAccessibility(for cell: InfoCollectionViewCell) {
		cell.isAccessibilityElement = false
		cell.chevronImageView.isAccessibilityElement = false
		cell.titleLabel.isAccessibilityElement = true
		cell.bodyLabel.isAccessibilityElement = false
		cell.titleLabel.accessibilityIdentifier = accessibilityIdentifier
	}
}
