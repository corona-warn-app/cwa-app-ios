//
//  HomeActivateCellConfigurator.swift
//  ENA
//
//  Created by Tikhonov, Aleksandr on 04.05.20.
//  Copyright © 2020 SAP SE. All rights reserved.
//

import UIKit

final class HomeActivateCellConfigurator: CollectionViewCellConfigurator {
    
    private var isActivated = false
    
    init(isActivated: Bool) {
        self.isActivated = isActivated
    }
    
    // MARK: Configuring a Cell
    func configure(cell: ActivateCollectionViewCell) {
        
        var iconImage: UIImage? = isActivated ? UIImage(named: "UmfeldaufnahmeAktiv_Primary1") : UIImage(named: "UmfeldaufnahmeNichtAktiv_Primary1")
        let iconColor: UIColor = isActivated ? UIColor.preferredColor(for: .tintColor) : UIColor.preferredColor(for: .brandRed)
        iconImage = iconImage?.withTintColor(iconColor)
        
        cell.iconImageView.image = iconImage
        cell.titleTextView.text = AppStrings.Home.activateTitle
        
        let chevronImage = UIImage(systemName: "chevron.right.circle.fill")
        cell.chevronImageView.image = chevronImage

		setupAccessibility(for: cell)
    }
	
    func toggle() {
        isActivated.toggle()
    }
    
    func setActivate(isActivated: Bool) {
        self.isActivated = isActivated
    }
    
	func setupAccessibility(for cell: ActivateCollectionViewCell) {
		cell.isAccessibilityElement = true
		cell.accessibilityIdentifier = Accessibility.StaticText.homeActivateTitle
	}
}
