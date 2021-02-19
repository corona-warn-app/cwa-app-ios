////
// 🦠 Corona-Warn-App
//

import UIKit

class SeperatorLineLayer: CAShapeLayer {
	
	// MARK: - Init
	override init() {
		super.init()
		setup()
	}
	
	override init(layer: Any) {
		super.init(layer: layer)
		setup()
	}
	
	@available(*, unavailable)
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	// MARK: - Private functions
	
	private func setup() {
		lineWidth = 1
		strokeColor = UIColor.enaColor(for: .hairline).cgColor
	}
}
