/*
See LICENSE folder for this sample’s licensing information.

Abstract:
A text label with a custom tint color.
*/

import UIKit

class TintLabel: UILabel {

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.textColor = tintColor
    }

    override func tintColorDidChange() {
        self.textColor = tintColor
    }
}
