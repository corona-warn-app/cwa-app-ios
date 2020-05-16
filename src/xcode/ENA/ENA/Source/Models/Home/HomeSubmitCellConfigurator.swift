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
        cell.iconImageView.image = UIImage(named: "Hand_with_phone")
        cell.titleLabel.text = AppStrings.Home.submitCardTitle
        cell.bodyLabel.text = AppStrings.Home.submitCardBody
        let buttonTitle = AppStrings.Home.submitCardButton
        cell.contactButton.setTitle(buttonTitle, for: .normal)
    }
}

extension HomeSubmitCellConfigurator: SubmitCollectionViewCellDelegate {
    func submitButtonTapped(cell: SubmitCollectionViewCell) {
        submitAction?()
    }
}
