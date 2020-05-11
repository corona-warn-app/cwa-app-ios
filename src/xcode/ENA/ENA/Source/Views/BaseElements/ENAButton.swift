//
//  ENAButton.swift
//  ENA
//
//  Created by Hu, Hao on 11.05.20.
//  Copyright © 2020 SAP SE. All rights reserved.
//

import UIKit
import QuartzCore

/// A Button which has the same behavior of UIButton, but with different tint color.
@IBDesignable
class ENAButton: UIButton {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        customizeButton()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        customizeButton()
    }
    
    private func customizeButton() {
        setButtonColors()
        setRoundCorner(radius: 8.0)
    }
    
    
    private func setButtonColors() {
        backgroundColor = UIColor.preferredColor(for: .tintColor)
        setTitleColor(UIColor.white, for: .normal)
    }
    
    private func setRoundCorner(radius: CGFloat) {
        layer.cornerRadius = radius
        layer.cornerCurve = .continuous
        clipsToBounds = true
    }
    
    
    override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        customizeButton()
    }

}
