//
//  ActivateCollectionViewCell.swift
//  ENA
//
//  Created by Tikhonov, Aleksandr on 03.05.20.
//  Copyright © 2020 SAP SE. All rights reserved.
//

import UIKit

class ActivateCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet var iconImageView: UIImageView!
    @IBOutlet var titleTextView: UITextView!
    @IBOutlet var chevronImageView: UIImageView!
    @IBOutlet var constraint: NSLayoutConstraint!
    
    private let iconTitleDistance: CGFloat = 10.0
    
    override func awakeFromNib() {
        super.awakeFromNib()
        layer.cornerRadius = 15.0
        layer.masksToBounds = true
        titleTextView.textContainerInset = .zero
        titleTextView.textContainer.lineFragmentPadding = 0
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        wrapImage()
    }
    
    private func wrapImage() {
        guard let lineHieght = titleTextView.font?.lineHeight else { return }
        
        var iconImageFrame = convert(iconImageView.frame, to: titleTextView)
        let lineHieghtRounded = lineHieght
        let offset: CGFloat = (lineHieghtRounded - iconImageFrame.height ) / 2.0
        
        constraint.constant = max( offset.rounded(), 0)

        
        iconImageFrame.size = CGSize(width: iconImageFrame.width + iconTitleDistance, height: iconImageFrame.height)
        let bezierPath = UIBezierPath(rect: iconImageFrame)
        titleTextView.textContainer.exclusionPaths = [bezierPath]
    }
}
