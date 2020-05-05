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

class RiskCollectionViewCell: UICollectionViewCell {

    @IBOutlet var iconImageView: UIImageView!
    @IBOutlet var chevronImageView: UIImageView!
    
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var bodyLabel: UILabel!
    @IBOutlet var dateLabel: UILabel!
    
    @IBOutlet var contactButton: UIButton!
    
    weak var delegate: RiskCollectionViewCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        layer.cornerRadius = 10.0
        layer.masksToBounds = true
    }
    
    @IBAction func contactButtonTapped(_ sender: UIButton) {
        delegate?.contactButtonTapped(cell: self)
    }
    
}
