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
    
    // MARK: ViewModel
    
    class ViewModel {
        let title: String
        let titleColor: UIColor
        let body: String
        let date: String?
        let color: UIColor
        let chevronTintColor: UIColor
        let chevronImage: UIImage?
        let iconImage: UIImage?
        
        init(title: String, titleColor: UIColor, body: String, date: String?, color: UIColor, chevronTintColor: UIColor, chevronImage: UIImage?, iconImage: UIImage?) {
            self.title = title
            self.titleColor = titleColor
            self.body = body
            self.date = date
            self.color = color
            self.chevronTintColor = chevronTintColor
            self.chevronImage = chevronImage
            self.iconImage = iconImage
        }
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
    @IBOutlet var viewContainer: UIView!

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
    func configure(with viewModel: ViewModel, delegate: RiskCollectionViewCellDelegate) {
        self.delegate = delegate
        
        //riskIndicatorContainer?.backgroundColor = level.backgroundColor
        titleLabel.text = viewModel.title
        titleLabel.textColor = viewModel.titleColor
        bodyLabel.text = viewModel.body
        dateLabel.text = viewModel.date
        dateLabel.isHidden = viewModel.date == nil
        viewContainer.backgroundColor = viewModel.color
        chevronImageView.tintColor = viewModel.chevronTintColor
        chevronImageView.image = viewModel.chevronImage
        iconImageView.image = viewModel.iconImage
        contactButton.setTitle(AppStrings.Home.riskCardButton, for: .normal)
    }
}
