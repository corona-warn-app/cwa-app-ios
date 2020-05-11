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
        self.riskLevel = riskLevel
        self.date = date
    }
    
    // MARK: Configuration
    func configure(cell: RiskCollectionViewCell) {
        
        let title: String = titleText(for: riskLevel)
        let titleColor: UIColor = titleTextColor(for: riskLevel)
        
        let body: String = bodyText(for: riskLevel)
        var dateString: String?
        if let date = date {
            let string = HomeRiskCellConfigurator.dateFormatter.string(from: date)
            let dateKey = AppStrings.Home.riskCardDate
            dateString = String(format: dateKey, string)
        }
        
        let color: UIColor = indicatorColor(for: riskLevel)
        
        let chevronTintColor: UIColor = chevronColor(for: riskLevel)
        let chevronImage: UIImage? = UIImage(systemName: "chevron.right")
        let iconImage: UIImage? = UIImage(named: "onboarding_ipad")
        
        let propertyHolder = RiskCollectionViewCell.PropertyHolder(
            title: title,
            titleColor: titleColor,
            body: body,
            date: dateString,
            color: color,
            chevronTintColor: chevronTintColor,
            chevronImage: chevronImage,
            iconImage: iconImage
        )
        
        // The delegate will be called back when the cell's primary action is triggered
        cell.configure(with: propertyHolder, delegate: self)
    }
}

extension HomeRiskCellConfigurator {
    
    // MARK: RiskLevel Properties
    
    func titleText(for riskLevel: RiskLevel) -> String {
        let key: String
        switch riskLevel {
        case .unknown:
            key = AppStrings.Home.riskCardUnknownTitle
        case .low:
            key = AppStrings.Home.riskCardLowTitle
        case .high:
            key = AppStrings.Home.riskCardHighTitle
        case .moderate:
            key = AppStrings.Home.riskCardModerateTitle
        }
        return key
    }
    
    func bodyText(for riskLevel: RiskLevel) -> String {
        let key: String
        switch riskLevel {
        case .unknown:
            key = AppStrings.RiskView.unknownRiskDetail
        case .low:
            key = AppStrings.RiskView.lowRiskDetail
        case .high:
            key = AppStrings.RiskView.highRiskDetail
        case .moderate:
            key = AppStrings.RiskView.moderateRiskDetail
        }
        return key
    }
    
    func indicatorColor(for riskLevel: RiskLevel) -> UIColor {
        switch riskLevel {
        case .unknown:
            return .white
        case .low:
            return .green
        case .high:
            return .red
        case .moderate:
            return .orange
        }
    }
    
    func chevronColor(for riskLevel: RiskLevel) -> UIColor {
        riskLevel == .unknown ? .systemBlue : titleTextColor(for: riskLevel)
    }
    
    func titleTextColor(for riskLevel: RiskLevel) -> UIColor {
        switch riskLevel {
        case .unknown:
            // swiftlint:disable:next discouraged_object_literal
            return #colorLiteral(red: 0.501960814, green: 0.501960814, blue: 0.501960814, alpha: 1)
        case .low:
            // swiftlint:disable:next discouraged_object_literal
            return #colorLiteral(red: 0.9090440273, green: 1, blue: 0.8056635857, alpha: 1)
        case .high:
            // swiftlint:disable:next discouraged_object_literal
            return #colorLiteral(red: 1, green: 0.8961167932, blue: 0.8636761308, alpha: 1)
        case .moderate:
            // swiftlint:disable:next discouraged_object_literal
            return #colorLiteral(red: 1, green: 0.9306703806, blue: 0.8244562745, alpha: 1)
        }
    }
}

extension HomeRiskCellConfigurator: RiskCollectionViewCellDelegate {
    func contactButtonTapped(cell: RiskCollectionViewCell) {
        contactAction?()
    }
}
