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
        cell.titleLabel.text = NSLocalizedString("home_submit_card_title", comment: "")
        cell.bodyLabel.text = NSLocalizedString("home_submit_card_body", comment: "")
        let buttonTitle = NSLocalizedString("home_submit_card_button", comment: "")
        cell.contactButton.setTitle(buttonTitle, for: .normal)
    }
}

extension HomeSubmitCellConfigurator: SubmitCollectionViewCellDelegate {
    func submitButtonTapped(cell: SubmitCollectionViewCell) {
        submitAction?()
    }
}
