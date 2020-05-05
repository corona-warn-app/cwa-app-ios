//
//  HomeSubmitCellConfigurator.swift
//  ENA
//
//  Created by Tikhonov, Aleksandr on 04.05.20.
//  Copyright © 2020 SAP SE. All rights reserved.
//

import UIKit

class HomeSubmitCellConfigurator: CollectionViewCellConfigurator {
    
    var submitAction: (() -> Void)?
    
    func configure(cell: SubmitCollectionViewCell) {
        cell.delegate = self
        cell.iconImageView.image = UIImage(named: "onboarding_phone")
        cell.titleLabel.text = "Ich wurde getestet"
        cell.bodyLabel.text = "Melden Sie Ihren Befund annonym, damit Kontaktpersonnen informiert werden können"
        cell.contactButton.setTitle("Befund melden", for: .normal)
        
    }
}

extension HomeSubmitCellConfigurator: SubmitCollectionViewCellDelegate {
    func submitButtonTapped(cell: SubmitCollectionViewCell) {
        submitAction?()
    }
}
