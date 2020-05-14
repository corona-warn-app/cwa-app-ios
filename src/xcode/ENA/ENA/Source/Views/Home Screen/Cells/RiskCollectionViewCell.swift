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
    
    // MARK: Nib Loading
    override func awakeFromNib() {
        super.awakeFromNib()
        layer.cornerRadius = 14.0
        layer.masksToBounds = true
        contactButton.titleLabel?.adjustsFontForContentSizeCategory = true
        contactButton.layer.cornerRadius = 10.0
        contactButton.layer.masksToBounds = true
        contactButton.contentEdgeInsets = .init(top: 14, left: 8, bottom: 14, right: 8)
        
        let containerInsets = UIEdgeInsets(top: 16.0, left: 16.0, bottom: 16.0, right: 16.0)
        [topContainer, middleContainer, bottomContainer].forEach {
            $0?.layoutMargins = containerInsets
        }
    }
    
    // MARK: Actions
    @IBAction func contactButtonTapped(_ sender: UIButton) {
        delegate?.contactButtonTapped(cell: self)
    }
    
    
    func update() {
        layoutIfNeeded()
        heightConstraint.constant = itemVC?.tableView.contentSize.height ?? 15
        print(#function, heightConstraint.constant)
    }
    
    var parent: UIViewController!
    var itemVC: RiskItemTableViewController?
    
    // MARK: Configuring the UI
    func configure(with propertyHolder: HomeRiskCellPropertyHolder, delegate: RiskCollectionViewCellDelegate) {
        
        if self.itemVC == nil {
            let itemVC = RiskItemTableViewController.initiate(for: .home)
            itemVC.titleColor = propertyHolder.titleColor
            itemVC.color = propertyHolder.color
            if let itemVCView = itemVC.view {
                parent.addChild(itemVC)
                itemVCView.translatesAutoresizingMaskIntoConstraints = false
                middleContainer.addSubview(itemVCView)
                NSLayoutConstraint.activate(
                    [
                        itemVCView.leadingAnchor.constraint(equalTo: middleContainer.layoutMarginsGuide.leadingAnchor),
                        itemVCView.topAnchor.constraint(equalTo: middleContainer.topAnchor),
                        itemVCView.trailingAnchor.constraint(equalTo: middleContainer.layoutMarginsGuide.trailingAnchor),
                        itemVCView.bottomAnchor.constraint(equalTo: middleContainer.bottomAnchor)
                    ]
                )
                itemVC.didMove(toParent: parent)
                self.itemVC = itemVC
            }
        }
        //
        
        self.delegate = delegate
        
        titleLabel.text = propertyHolder.title
        titleLabel.textColor = propertyHolder.titleColor
        viewContainer.backgroundColor = propertyHolder.color
        chevronImageView.tintColor = propertyHolder.chevronTintColor
        chevronImageView.image = propertyHolder.chevronImage
        contactButton.setTitle(AppStrings.Home.riskCardButton, for: .normal)
        contactButton.setTitleColor(UIColor.preferredColor(for: .textPrimary1), for: .normal)
        contactButton.backgroundColor = UIColor.preferredColor(for: .backgroundBase)
    }
}
