//
//  HomeRiskCellConfigurator.swift
//  ENA
//
//  Created by Tikhonov, Aleksandr on 04.05.20.
//  Copyright © 2020 SAP SE. All rights reserved.
//

import UIKit
import ExposureNotification

final class HomeRiskCellConfigurator {
    // MARK: Creating a Home Risk Cell Configurator
    init(homeViewController: HomeViewController) {
        self.homeViewController = homeViewController
    }
    
    // MARK: Properties
    unowned var homeViewController: HomeViewController
    var contactAction: (() -> Void)?
}

extension HomeRiskCellConfigurator: CollectionViewCellConfigurator {
    func configure(cell: RiskCollectionViewCell) {
        let summary = homeViewController.summary
        let level = summary?.riskLevel ?? .unknown
        let risk = RiskCollectionViewCell.Risk(level: level, date: Date())
        let model = RiskCollectionViewCell.Model(risk: risk)
        
        // The delegate will be called back when the cell's primary action is triggered
        cell.configure(with: model, delegate: self)
    }
}

extension HomeRiskCellConfigurator: RiskCollectionViewCellDelegate {
    func contactButtonTapped(cell: RiskCollectionViewCell) {
        contactAction?()
    }
}

extension ENExposureDetectionSummary {
    var riskLevel: RiskCollectionViewCell.RiskLevel {
        // The mapping between the maximum risk score and the `RiskCollectionViewCell.RiskLevel`
        // is simply our best guess for the moment. If you see this and have more information about the
        // mapping to use don't hesitate to change the following code.
        switch maximumRiskScore {
        case 1, 2, 3:
            return .low
        case 4, 5, 6:
            return .moderate
        case 7, 8:
            return .high
        default:
            return .unknown
        }
    }
}
