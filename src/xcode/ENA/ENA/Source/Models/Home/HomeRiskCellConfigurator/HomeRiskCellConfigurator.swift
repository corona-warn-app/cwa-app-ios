//
//  HomeRiskCellConfigurator.swift
//  ENA
//
//  Created by Tikhonov, Aleksandr on 04.05.20.
//  Copyright © 2020 SAP SE. All rights reserved.
//

import UIKit
import ExposureNotification

final class HomeRiskCellConfigurator: CollectionViewCellConfigurator {
    
    // MARK: Properties
    var contactAction: (() -> Void)?
    
    private var date: Date?
    private var riskLevel: RiskLevel
    
    private static let dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        return dateFormatter
    }()
    
    // MARK: Creating a Home Risk Cell Configurator
    init(riskLevel: RiskLevel, date: Date?) {
        self.riskLevel = .low // riskLevel
        self.date = date
    }
    
    // MARK: Configuration
    func configure(cell: RiskCollectionViewCell) {
        
        var dateString: String?
        if let date = date {
            let string = HomeRiskCellConfigurator.dateFormatter.string(from: date)
            let dateKey = AppStrings.Home.riskCardDate
            dateString = String(format: dateKey, string)
        }
        let holder = HomeRiskCellPropertyHolder.propertyHolder(for: riskLevel, dateString: dateString)
        // The delegate will be called back when the cell's primary action is triggered
        cell.configure(with: holder, delegate: self)
    }
}


extension HomeRiskCellConfigurator: RiskCollectionViewCellDelegate {
    func contactButtonTapped(cell: RiskCollectionViewCell) {
        contactAction?()
    }
}
