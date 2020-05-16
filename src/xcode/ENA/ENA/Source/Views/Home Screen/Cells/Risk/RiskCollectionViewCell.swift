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
final class RiskCollectionViewCell: HomeCardCollectionViewCell {
    
    // MARK: Properties
    weak var delegate: RiskCollectionViewCellDelegate?
    
    // MARK: Outlets
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var chevronImageView: UIImageView!
    @IBOutlet var contactButton: UIButton!
    
    @IBOutlet var viewContainer: UIView!
    @IBOutlet var topContainer: UIView!
    @IBOutlet var middleContainer: UIView!
    @IBOutlet var bottomContainer: UIView!
    @IBOutlet var heightConstraint: NSLayoutConstraint!
    @IBOutlet var stackView: UIStackView!
    
    // MARK: Nib Loading
    override func awakeFromNib() {
        super.awakeFromNib()
        contactButton.titleLabel?.adjustsFontForContentSizeCategory = true
        contactButton.layer.cornerRadius = 10.0
        contactButton.layer.masksToBounds = true
        contactButton.contentEdgeInsets = .init(top: 14.0, left: 8.0, bottom: 14.0, right: 8.0)
        let containerInsets = UIEdgeInsets(top: 16.0, left: 16.0, bottom: 16.0, right: 16.0)
        [topContainer, bottomContainer].forEach {
            $0?.layoutMargins = containerInsets
        }
        middleContainer?.layoutMargins = UIEdgeInsets(top: 0.0, left: 16.0, bottom: 0.0, right: 16.0)
    }
    
    // MARK: Actions
    @IBAction func contactButtonTapped(_ sender: UIButton) {
        delegate?.contactButtonTapped(cell: self)
    }
    
    // MARK: Configuring the UI
    func configure(with propertyHolder: HomeRiskCellPropertyHolder, delegate: RiskCollectionViewCellDelegate) {
        
        self.delegate = delegate
        
        titleLabel.text = propertyHolder.title
        titleLabel.textColor = propertyHolder.titleColor
        viewContainer.backgroundColor = propertyHolder.color
        chevronImageView.tintColor = propertyHolder.chevronTintColor
        chevronImageView.image = propertyHolder.chevronImage
        contactButton.setTitle(AppStrings.Home.riskCardButton, for: .normal)
        contactButton.setTitleColor(UIColor.preferredColor(for: .textPrimary1), for: .normal)
        contactButton.backgroundColor = UIColor.preferredColor(for: .backgroundBase)
        
        let nib = UINib(nibName: RiskItemView.stringName(), bundle: .main)
        for itemConfigurator in propertyHolder.itemCellConfigurators {
            if let riskView = nib.instantiate(withOwner: self, options: nil).first as? RiskItemView {
                stackView.addArrangedSubview(riskView)
                itemConfigurator.configure(riskItemView: riskView)
            }
        }
        if let riskItemView = stackView.arrangedSubviews.last as? RiskItemView {
            riskItemView.hideSeparator()
        }
    }
}
