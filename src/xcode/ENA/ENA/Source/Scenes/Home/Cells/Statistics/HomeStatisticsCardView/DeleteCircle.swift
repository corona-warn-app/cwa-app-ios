////
// 🦠 Corona-Warn-App
//

import UIKit

class DeleteCircle: UIView {

	override init(frame: CGRect) {
		super.init(frame: frame)
		clipsToBounds = false
		isOpaque = false
		layer.shouldRasterize = true
	}

	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

    override func draw(_ rect: CGRect) {
		let context = UIGraphicsGetCurrentContext()
		context?.addEllipse(in: rect)
		context?.setFillColor(UIColor.red.cgColor)
		context?.fillPath()

		context?.setLineCap(.round)
		context?.setLineWidth(3.0)
		context?.setStrokeColor(UIColor.white.cgColor)
		context?.addLines(between: [
			CGPoint(x: rect.minX + rect.width / 5, y: rect.midY),
			CGPoint(x: rect.maxX - rect.width / 5, y: rect.midY)
		])
		context?.strokePath()
    }

}
