////
// 🦠 Corona-Warn-App
//

import UIKit

class SeperatorLineLayer: CAShapeLayer {
	
	override init() {
		super.init()
		lineWidth = 1
		strokeColor = UIColor.enaColor(for: .hairline).cgColor
	}
	
	@available(*, unavailable)
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
}
