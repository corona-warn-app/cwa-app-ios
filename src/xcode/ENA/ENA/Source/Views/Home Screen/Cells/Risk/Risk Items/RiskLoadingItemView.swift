//
//  RiskLoadingItemView.swift
//  ENA
//
//  Created by Tikhonov, Aleksandr on 20.05.20.
//  Copyright © 2020 SAP SE. All rights reserved.
//

import UIKit

final class RiskLoadingItemView: UIView, RiskVVView {
    
    @IBOutlet var activityIndicatorView: UIActivityIndicatorView!
    @IBOutlet var titleTextView: UITextView!
    @IBOutlet var separatorView: UIView!
    @IBOutlet var separatorHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet var topActivityIndicatorTopTextViewConstraint: NSLayoutConstraint!
    @IBOutlet var centerYActivityIndicatorCenterYTextViewConstraint: NSLayoutConstraint!
    
    @IBOutlet var leadingTextViewLeadingMarginConstraint: NSLayoutConstraint!
    @IBOutlet var leadingTextViewTrailingActivityIndicatorViewConstraint: NSLayoutConstraint!
    
    private let titleTopPadding: CGFloat = 8.0
    
    override func awakeFromNib() {
        super.awakeFromNib()
        separatorHeightConstraint.constant = 1
        titleTextView.textContainerInset = .zero
        titleTextView.textContainer.lineFragmentPadding = 0
        titleTextView.textContainerInset = .init(top: titleTopPadding, left: 0.0, bottom: titleTopPadding, right: 0.0)
        titleTextView.isUserInteractionEnabled = false
        activityIndicatorView.startAnimating()
        configureTextViewLayout()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        wrapActivityIndicator()
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        configureTextViewLayout()
        configureActivityIndicatorView()
    }

    private func configureTextViewLayout() {
        let greaterThanAccessibilityMedium = traitCollection.preferredContentSizeCategory >= .accessibilityMedium
        if greaterThanAccessibilityMedium {
            leadingTextViewLeadingMarginConstraint.isActive = true
            leadingTextViewTrailingActivityIndicatorViewConstraint.isActive = false
        } else {
            leadingTextViewLeadingMarginConstraint.isActive = false
            leadingTextViewTrailingActivityIndicatorViewConstraint.isActive = true
        }
    }
    
    private func configureActivityIndicatorView() {
        let greaterThanAccessibilityMedium = traitCollection.preferredContentSizeCategory >= .accessibilityMedium
        activityIndicatorView.style = greaterThanAccessibilityMedium ? .large : .medium
    }
    
    private func wrapActivityIndicator() {
        if traitCollection.preferredContentSizeCategory >= .accessibilityMedium {
            centerYActivityIndicatorCenterYTextViewConstraint.isActive = false
            topActivityIndicatorTopTextViewConstraint.isActive = true
            guard let lineHeight = titleTextView.font?.lineHeight else { return }
            
            var iconImageFrame = convert(activityIndicatorView.frame, to: titleTextView)
            let lineHeightRounded = lineHeight
            let offset: CGFloat = (lineHeightRounded - iconImageFrame.height ) / 2.0
            
            topActivityIndicatorTopTextViewConstraint.constant = max(offset.rounded(), 0) + titleTopPadding
            let iconTitleDistance = leadingTextViewTrailingActivityIndicatorViewConstraint.constant
            iconImageFrame.size = CGSize(width: iconImageFrame.width + iconTitleDistance, height: iconImageFrame.height)
            let bezierPath = UIBezierPath(rect: iconImageFrame)
            titleTextView.textContainer.exclusionPaths = [bezierPath]
        } else {
            centerYActivityIndicatorCenterYTextViewConstraint.isActive = true
            topActivityIndicatorTopTextViewConstraint.isActive = false
            titleTextView.textContainer.exclusionPaths.removeAll()
        }
        
    }
    
    func hideSeparator() {
        separatorView.isHidden = true
    }
    
}
