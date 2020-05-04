//
//  HomeRiskCellConfigurator.swift
//  ENA
//
//  Created by Tikhonov, Aleksandr on 04.05.20.
//  Copyright © 2020 SAP SE. All rights reserved.
//

import UIKit

struct HomeRiskCellConfigurator: CollectionViewCellConfigurator {
    
    func configure(cell: RiskCollectionViewCell) {
        
        cell.iconImageView.image = UIImage(named: "onboarding_ipad")
        cell.chevronImageView.image = UIImage(systemName: "chevron.right")
        cell.titleLabel.text = "Geringes Risiko"
        cell.bodyLabel.text = "Es wurde kein Kontakt mit COVID-19 erkannt."
        cell.dateLabel.text = "Letzte Überprüfung: 09:32, 28.04.2020"
        cell.contactButton.setTitle("Kontakte überprüfen", for: .normal)
        
    }
}
