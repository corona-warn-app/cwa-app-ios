//
//  RiskCollectionViewCell.swift
//  ENA
//
//  Created by Tikhonov, Aleksandr on 03.05.20.
//  Copyright © 2020 SAP SE. All rights reserved.
//

import UIKit

protocol RiskCollectionViewCellDelegate: AnyObject {
    func contactButtonTapped(cell: RiskCollectionViewCell)
}

/// A cell that visualizes the current risk and allows the user to calculate he/his current risk.
final class RiskCollectionViewCell: UICollectionViewCell {
    // MARK: Helpers
    private static let dateFormatter: DateFormatter = {
          let dateFormatter = DateFormatter()
          dateFormatter.dateStyle = .medium
          return dateFormatter
    }()
    
    // MARK: Model related Types
    struct Risk {
        let level: RiskLevel
        let date: Date?
    }
    
    enum RiskLevel {
        case unknown, low, high, moderate
    }
    
    struct Model {
        let risk: Risk
    }
    
    // MARK: Properties
    weak var delegate: RiskCollectionViewCellDelegate?

    // MARK: Outlets
    @IBOutlet var iconImageView: UIImageView!
    @IBOutlet var chevronImageView: UIImageView!
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var bodyLabel: UILabel!
    @IBOutlet var dateLabel: UILabel!
    @IBOutlet var contactButton: UIButton!
    @IBOutlet var riskIndicatorContainer: UIView!

    // MARK: Nib Loading
    override func awakeFromNib() {
        super.awakeFromNib()
        layer.cornerRadius = 10.0
        layer.masksToBounds = true
    }
    
    // MARK: Actions
    @IBAction func contactButtonTapped(_ sender: UIButton) {
        delegate?.contactButtonTapped(cell: self)
    }
    
    // MARK: Configuring the UI
    func configure(with model: Model, delegate: RiskCollectionViewCellDelegate) {
        self.delegate = delegate
        
        let risk = model.risk
        let level = risk.level
        
        riskIndicatorContainer?.backgroundColor = level.backgroundColor
        titleLabel.text = level.localizedString
        titleLabel.textColor = level.textColor
        chevronImageView.tintColor = level.accessoryTintColor
        iconImageView.image = UIImage(named: "onboarding_ipad")
        chevronImageView.image = UIImage(systemName: "chevron.right")
        bodyLabel.text = level.localizedStringBody
        dateLabel.text = risk.localizedDateLabelText
        dateLabel.isHidden = risk.localizedDateLabelText == nil
        contactButton.setTitle(AppStrings.Home.riskCardButton, for: .normal)
    }
}

extension RiskCollectionViewCell.RiskLevel {
    var localizedString: String {
        let key: String
        switch self {
        case .unknown:
            key = "Risk_Unknown_Button_Title"
        case .low:
            key = "Risk_Low_Button_Title"
        case .high:
            key = "Risk_High_Button_Title"
        case .moderate:
            key = "Risk_Moderate_Button_Title"
        }
        return key.localized(tableName: "LocalizableRisk")
    }

    var localizedStringBody: String {
        let key: String
        switch self {
        case .unknown:
            key = "Es wurde kein Kontakt mit COVID 19 erkannt"
        case .low:
            key = "Es wurde ein geringes Risiko erkannt"
        case .high:
            key = "Es wurde ein hohes Risiko erkannt"
        case .moderate:
            key = "Es wurde ein moderates Risiko erkannt"
        }
        return key
    }

    
    var backgroundColor: UIColor {
        switch self {
        case .unknown:
            return .clear
        case .low:
            return .green
        case .high:
            return .red
        case .moderate:
            return .orange
        }
    }
    
    var accessoryTintColor: UIColor {
        if case .unknown = self {
            return .systemBlue
        }
        return textColor
    }
    
    var textColor: UIColor {
        switch self {
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

private extension RiskCollectionViewCell.Risk {
    var localizedDateLabelText: String? {
        guard let formattedDate = formattedDate else {
            return nil
        }
        let localizedFormat = AppStrings.Home.riskCardDate.localized()
        return String(format: localizedFormat, formattedDate)
    }
    
    var formattedDate: String? {
        if let date = date {
            return RiskCollectionViewCell.dateFormatter.string(from: date)
        }
        return nil
    }
}
