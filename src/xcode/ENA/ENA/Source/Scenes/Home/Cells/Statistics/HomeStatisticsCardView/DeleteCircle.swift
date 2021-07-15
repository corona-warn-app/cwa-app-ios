//
// 🦠 Corona-Warn-App
//

import UIKit

/// A red circle to indicate a delete action
@IBDesignable
class DeleteCircle: UIView {
	
	// MARK: - Init
	
	convenience init() {
		self.init(frame: CGRect(x: 0, y: 0, width: 24, height: 24))
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	// MARK: - Overrides
	
	override init(frame: CGRect) {
		super.init(frame: frame)
		clipsToBounds = false
		isOpaque = false
		layer.shouldRasterize = true

		isAccessibilityElement = true
		accessibilityIdentifier = AccessibilityIdentifiers.General.deleteButton
		accessibilityTraits = [.button]
	}

    override func draw(_ rect: CGRect) {
		let context = UIGraphicsGetCurrentContext()
		context?.addEllipse(in: rect)
		context?.setFillColor(UIColor.red.cgColor)
		context?.fillPath()

		context?.setLineCap(.round)
		context?.setLineWidth(rect.width / 8) // default: rect-width 24, line-width: 3
		context?.setStrokeColor(UIColor.white.cgColor)
		context?.addLines(between: [
			CGPoint(x: rect.minX + rect.width / 5, y: rect.midY),
			CGPoint(x: rect.maxX - rect.width / 5, y: rect.midY)
		])
		context?.strokePath()
    }
}
