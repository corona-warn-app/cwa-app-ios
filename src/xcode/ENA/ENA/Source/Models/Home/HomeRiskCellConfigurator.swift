//
//  HomeRiskCellConfigurator.swift
//  ENA
//
//  Created by Tikhonov, Aleksandr on 04.05.20.
//  Copyright © 2020 SAP SE. All rights reserved.
//

import UIKit

class HomeRiskCellConfigurator: CollectionViewCellConfigurator {
    
    var contactAction: (() -> Void)?
    
    let dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        return dateFormatter
    }()
    
    func configure(cell: RiskCollectionViewCell) {
        cell.delegate = self
        cell.iconImageView.image = UIImage(named: "onboarding_ipad")
        cell.chevronImageView.image = UIImage(systemName: "chevron.right")
        cell.titleLabel.text = NSLocalizedString("home_risk_card_title", comment: "")
        cell.bodyLabel.text = NSLocalizedString("home_risk_card_body", comment: "")
        
        let date = Date()
        let dateString = dateFormatter.string(from: date) // or DateFormatter.localizedString(from:, dateStyle:, timeStyle:)
        let dateKey = NSLocalizedString("home_risk_card_date", comment: "")
        cell.dateLabel.text = String(format: dateKey, dateString)
        let buttonTile = NSLocalizedString("home_risk_card_button", comment: "")
        cell.contactButton.setTitle(buttonTile, for: .normal)
    }
}

extension HomeRiskCellConfigurator: RiskCollectionViewCellDelegate {
    func contactButtonTapped(cell: RiskCollectionViewCell) {
        contactAction?()
    }
}
