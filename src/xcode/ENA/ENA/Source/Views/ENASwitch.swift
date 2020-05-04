//
//  ENASwitch.swift
//  ENA
//
//  Created by Hu, Hao on 04.05.20.
//  Copyright © 2020 SAP SE. All rights reserved.
//

import UIKit

class ENASwitch: UISwitch {
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
