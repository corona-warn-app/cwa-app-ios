//
//  HomeActivateCellConfigurator.swift
//  ENA
//
//  Created by Tikhonov, Aleksandr on 04.05.20.
//  Copyright © 2020 SAP SE. All rights reserved.
//

import UIKit

final class HomeActivateCellConfigurator: CollectionViewCellConfigurator {
    // MARK: Configuring a Cell
    func configure(cell: ActivateCollectionViewCell) {
        cell.iconImageView.image = UIImage(named: "onboarding_note")
        cell.titleLabel.text = AppStrings.Home.activateTitle
        cell.chevronImageView.image = UIImage(systemName: "chevron.right")
		setupAccessibility(for: cell)
    }
	
	func setupAccessibility(for cell: ActivateCollectionViewCell) {
		cell.titleLabel.accessibilityIdentifier = Accessibility.StaticText.homeActivateTitle
	}
}
