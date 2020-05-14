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
        self.riskLevel = .moderate// riskLevel
        self.date = date
    }
    
    var parent: UIViewController!
    
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
    
    func updateCell(_ cell: RiskCollectionViewCell) {
        cell.layoutIfNeeded()
        cell.heightConstraint.constant = itemVC?.tableView.contentSize.height ?? 15
        // print(#function, heightConstraint.constant)
    }
    var itemVC: RiskItemTableViewController?
    
    
    func aa() {
        
//        if self.itemVC == nil {
//            let itemVC = RiskItemTableViewController.initiate(for: .home)
//            itemVC.titleColor = propertyHolder.titleColor
//            itemVC.color = propertyHolder.color
//            if let itemVCView = itemVC.view {
//                parent.addChild(itemVC)
//                itemVCView.translatesAutoresizingMaskIntoConstraints = false
//                middleContainer.addSubview(itemVCView)
//                NSLayoutConstraint.activate(
//                    [
//                        itemVCView.leadingAnchor.constraint(equalTo: middleContainer.layoutMarginsGuide.leadingAnchor),
//                        itemVCView.topAnchor.constraint(equalTo: middleContainer.topAnchor),
//                        itemVCView.trailingAnchor.constraint(equalTo: middleContainer.layoutMarginsGuide.trailingAnchor),
//                        itemVCView.bottomAnchor.constraint(equalTo: middleContainer.bottomAnchor)
//                    ]
//                )
//                itemVC.didMove(toParent: parent)
//                self.itemVC = itemVC
//            }
//        }
        //
        
    }
}


extension HomeRiskCellConfigurator: RiskCollectionViewCellDelegate {
    func contactButtonTapped(cell: RiskCollectionViewCell) {
        contactAction?()
    }
}
