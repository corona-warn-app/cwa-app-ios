//
//  RiskItemView.swift
//  ENA
//
//  Created by Tikhonov, Aleksandr on 14.05.20.
//  Copyright © 2020 SAP SE. All rights reserved.
//

import UIKit

final class RiskItemView: UIView {
    
    @IBOutlet var iconImageView: UIImageView!
    @IBOutlet var titleTextView: UITextView!
    @IBOutlet var separatorView: UIView!
    @IBOutlet var separatorHeightConstraint: NSLayoutConstraint!
    @IBOutlet var topImageTopTextViewConstraint: NSLayoutConstraint!
    
    @IBOutlet var leadingTextViewLeadingMarginConstraint: NSLayoutConstraint!
    @IBOutlet var leadingTextViewTrailingImageViewConstraint: NSLayoutConstraint!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        separatorHeightConstraint.constant = 0.5
        titleTextView.textContainerInset = .zero
        titleTextView.textContainer.lineFragmentPadding = 0
        configureTextViewLayout()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        wrapImage()
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        configureTextViewLayout()
    }

    private func configureTextViewLayout() {
        if traitCollection.preferredContentSizeCategory >= .accessibilityMedium {
            leadingTextViewLeadingMarginConstraint.isActive = false
            leadingTextViewTrailingImageViewConstraint.isActive = true
        } else {
            leadingTextViewLeadingMarginConstraint.isActive = true
            leadingTextViewTrailingImageViewConstraint.isActive = false
        }
    }
    
    private func wrapImage() {
        guard let lineHeight = titleTextView.font?.lineHeight else { return }
        
        var iconImageFrame = convert(iconImageView.frame, to: titleTextView)
        let lineHeightRounded = lineHeight
        let offset: CGFloat = (lineHeightRounded - iconImageFrame.height ) / 2.0

        topImageTopTextViewConstraint.constant = max(offset.rounded(), 0)
        let iconTitleDistance = leadingTextViewLeadingMarginConstraint.constant
        iconImageFrame.size = CGSize(width: iconImageFrame.width + iconTitleDistance, height: iconImageFrame.height)
        let bezierPath = UIBezierPath(rect: iconImageFrame)
        titleTextView.textContainer.exclusionPaths = [bezierPath]
    }
    
    func hideSeparator() {
        separatorView.isHidden = true
    }
    
}
