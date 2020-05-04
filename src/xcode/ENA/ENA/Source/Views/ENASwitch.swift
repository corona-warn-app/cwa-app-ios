//
//  ENASwitch.swift
//  ENA
//
//  Created by Hu, Hao on 04.05.20.
//  Copyright © 2020 SAP SE. All rights reserved.
//

import UIKit

/// A Switch UI control which has the same behavior of UISwitch, but with different tint color.
final class ENASwitch: UISwitch {
    override init(frame: CGRect) {
        super.init(frame: frame)
        customizeSwitch()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        customizeSwitch()
    }
    
    private func customizeSwitch() {
        self.onTintColor = UIColor.preferredColor(for: .tintColor)
    }
}
