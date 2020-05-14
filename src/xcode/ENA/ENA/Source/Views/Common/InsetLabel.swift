//
//  InsetLabel.swift
//  ENA
//
//  Created by Tikhonov, Aleksandr on 15.05.20.
//  Copyright © 2020 SAP SE. All rights reserved.
//

import UIKit

/// UILabel with insets
final class InsetLabel: UILabel {

    var contentInsets: UIEdgeInsets = .zero

    override var intrinsicContentSize: CGSize {
        addInsets(to: super.intrinsicContentSize)
    }
    
    override func drawText(in rect: CGRect) {
        let insetRect = rect.inset(by: contentInsets)
        super.drawText(in: insetRect)
    }

    override func sizeThatFits(_ size: CGSize) -> CGSize {
        addInsets(to: super.sizeThatFits(size))
    }

    private func addInsets(to size: CGSize) -> CGSize {
        let width = size.width + contentInsets.left + contentInsets.right
        let height = size.height + contentInsets.top + contentInsets.bottom
        return CGSize(width: width, height: height)
    }

}
