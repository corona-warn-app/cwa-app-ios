//
//  HomeSubmitCellConfigurator.swift
//  ENA
//
//  Created by Tikhonov, Aleksandr on 04.05.20.
//  Copyright © 2020 SAP SE. All rights reserved.
//

import UIKit

struct HomeSubmitCellConfigurator: CollectionViewCellConfigurator {
    
    func configure(cell: SubmitCollectionViewCell) {
        cell.iconImageView.image = UIImage(named: "onboarding_phone")
        cell.titleLabel.text = "Ich wurde getestet"
        cell.bodyLabel.text = "Melden Sie Ihren Befund annonym, damit Kontaktpersonnen informiert werden können"
        cell.contactButton.setTitle("Befund melden", for: .normal)
    }
}
