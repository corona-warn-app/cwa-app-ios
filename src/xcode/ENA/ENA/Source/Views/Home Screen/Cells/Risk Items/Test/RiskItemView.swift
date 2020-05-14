//
//  RiskItemView.swift
//  ENA
//
//  Created by Tikhonov, Aleksandr on 14.05.20.
//  Copyright © 2020 SAP SE. All rights reserved.
//

import UIKit

final class RiskItemView: UIView {
    
    @IBOutlet var imageView: UIImageView!
    // it should be replaced on textview
    @IBOutlet var textLabel: UILabel!
    @IBOutlet var separatorView: UIView!
    @IBOutlet var separatorHeightConstraint: NSLayoutConstraint!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        separatorHeightConstraint.constant = 0.5
        
    }
    
    func hideSeparator() {
        separatorView.isHidden = true
    }
}
