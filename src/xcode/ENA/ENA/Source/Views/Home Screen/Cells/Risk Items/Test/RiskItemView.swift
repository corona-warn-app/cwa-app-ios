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
    @IBOutlet var insetTextLabel: InsetLabel!
    @IBOutlet var separatorView: UIView!
    @IBOutlet var separatorHeightConstraint: NSLayoutConstraint!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        separatorHeightConstraint.constant = 0.5
        insetTextLabel.contentInsets = .init(top: 8.0, left: 0.0, bottom: 8.0, right: 0.0)
    }
    
    func hideSeparator() {
        separatorView.isHidden = true
    }
}
