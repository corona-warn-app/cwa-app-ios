//
//  HomeCardCollectionViewCell.swift
//  ENA
//
//  Created by Tikhonov, Aleksandr on 15.05.20.
//  Copyright © 2020 SAP SE. All rights reserved.
//

import UIKit

class HomeCardCollectionViewCell: UICollectionViewCell {
    
    private let cornerRadius: CGFloat = 14.0
    
    override func awakeFromNib() {
        super.awakeFromNib()
        contentView.layer.cornerRadius = cornerRadius
        contentView.layer.masksToBounds = true
        
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOffset = .init(width: 0.0, height: 10.0)
        layer.shadowRadius = 10.0
        layer.shadowOpacity = 0.15
        layer.cornerRadius = cornerRadius
        layer.masksToBounds = false
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let path = UIBezierPath(roundedRect: bounds, cornerRadius: cornerRadius).cgPath
        layer.shadowPath = path
    }
}
