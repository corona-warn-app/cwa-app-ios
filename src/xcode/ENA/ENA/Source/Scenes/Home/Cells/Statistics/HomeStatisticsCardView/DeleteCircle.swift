//
// 🦠 Corona-Warn-App
//

import UIKit

/// A red circle to indicate a delete action
@IBDesignable
class DeleteCircle: UIControl {
	
	// MARK: - Init
	
	convenience init() {
		self.init(frame: CGRect(x: 0, y: 0, width: 44, height: 44))
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
		accessibilityLabel = AppStrings.Common.alertActionRemove
		accessibilityTraits = [.button]
	}

    override func draw(_ rect: CGRect) {
		assert(rect.width >= 24 && rect.height >= 24, "did not expect smaller bounds than 24x24")

		// handles a maximum circle size of 24x24
		let intersection = rect.intersection(CGRect(x: 0, y: 0, width: 24, height: 24))
		// x-alignment is due to design constraints
		let circleFrame = CGRect(x: 4, y: rect.midY - intersection.height / 2, width: intersection.width, height: intersection.height)

		let context = UIGraphicsGetCurrentContext()
		context?.addEllipse(in: circleFrame)
		context?.setFillColor(UIColor.red.cgColor)
		context?.fillPath()

		context?.setLineCap(.round)
		context?.setLineWidth(circleFrame.width / 8) // default: rect-width 24, line-width: 3
		context?.setStrokeColor(UIColor.white.cgColor)
		context?.addLines(between: [
			CGPoint(x: circleFrame.minX + circleFrame.width / 5, y: circleFrame.midY),
			CGPoint(x: circleFrame.maxX - circleFrame.width / 5, y: circleFrame.midY)
		])
		context?.strokePath()
    }

	override func accessibilityElementDidBecomeFocused() {
		super.accessibilityElementDidBecomeFocused()
		superview?.accessibilityElementDidBecomeFocused()
	}
}
