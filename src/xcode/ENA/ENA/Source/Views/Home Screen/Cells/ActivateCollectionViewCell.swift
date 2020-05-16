//
//  ActivateCollectionViewCell.swift
//  ENA
//
//  Created by Tikhonov, Aleksandr on 03.05.20.
//  Copyright © 2020 SAP SE. All rights reserved.
//

import UIKit

class ActivateCollectionViewCell: HomeCardCollectionViewCell {

    @IBOutlet var iconImageView: UIImageView!
    @IBOutlet var titleTextView: UITextView!
    @IBOutlet var chevronImageView: UIImageView!
    @IBOutlet var constraint: NSLayoutConstraint!
    
    private let iconTitleDistance: CGFloat = 10.0
    
    override func awakeFromNib() {
        super.awakeFromNib()
        titleTextView.textContainerInset = .zero
        titleTextView.textContainer.lineFragmentPadding = 0
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        wrapImage()
    }
    
    private func wrapImage() {
        guard let lineHeight = titleTextView.font?.lineHeight else { return }
        
        var iconImageFrame = convert(iconImageView.frame, to: titleTextView)
        let lineHeightRounded = lineHeight
        let offset: CGFloat = (lineHeightRounded - iconImageFrame.height ) / 2.0

        constraint.constant = max(offset.rounded(), 0)
        
        iconImageFrame.size = CGSize(width: iconImageFrame.width + iconTitleDistance, height: iconImageFrame.height)
        let bezierPath = UIBezierPath(rect: iconImageFrame)
        titleTextView.textContainer.exclusionPaths = [bezierPath]
    }
}
