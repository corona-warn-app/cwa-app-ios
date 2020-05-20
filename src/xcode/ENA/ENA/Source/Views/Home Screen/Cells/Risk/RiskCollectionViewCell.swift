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
    @IBOutlet var stackView: UIStackView!
    
    // MARK: Nib Loading
    override func awakeFromNib() {
        super.awakeFromNib()
        contactButton.titleLabel?.adjustsFontForContentSizeCategory = true
        contactButton.titleLabel?.lineBreakMode = .byWordWrapping
        contactButton.layer.cornerRadius = 10.0
        contactButton.layer.masksToBounds = true
        contactButton.contentEdgeInsets = .init(top: 14.0, left: 8.0, bottom: 14.0, right: 8.0)
        let containerInsets = UIEdgeInsets(top: 16.0, left: 16.0, bottom: 16.0, right: 16.0)
        [topContainer, bottomContainer].forEach {
            $0?.layoutMargins = containerInsets
        }
        middleContainer?.layoutMargins = UIEdgeInsets(top: 0.0, left: 16.0, bottom: 0.0, right: 16.0)
    }
    
    // Ignore touches on the button when it's disabled
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let buttonPoint = convert(point, to: contactButton)
        let containsPoint = contactButton.bounds.contains(buttonPoint)
        if containsPoint && !contactButton.isEnabled {
            return nil
        }
        return super.hitTest(point, with: event)
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
        UIView.performWithoutAnimation {
            contactButton.setTitle(propertyHolder.buttonTitle, for: .normal)
            contactButton.layoutIfNeeded()
        }
        let buttonTitleColor = UIColor.preferredColor(for: .textPrimary1)
        contactButton.setTitleColor(buttonTitleColor, for: .normal)
        contactButton.setTitleColor(buttonTitleColor.withAlphaComponent(0.3), for: .disabled)
        contactButton.backgroundColor = UIColor.preferredColor(for: .backgroundBase)
        contactButton.isEnabled = propertyHolder.isButtonEnabled
        
        stackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        for itemConfigurator in propertyHolder.cellConfigurators {
            let nibName = itemConfigurator.viewAnyType.stringName()
            let nib = UINib(nibName: nibName, bundle: .main)
            if let riskView = nib.instantiate(withOwner: self, options: nil).first as? UIView {
                stackView.addArrangedSubview(riskView)
                itemConfigurator.configureAny(riskView: riskView)
            }
        }
        if let riskItemView = stackView.arrangedSubviews.last as? RiskItemView {
            riskItemView.hideSeparator()
        }
    }
}
