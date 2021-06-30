////
// 🦠 Corona-Warn-App
//

import UIKit

class CustomDashedView: UIView {
	
	// MARK: - Internal
	
	@IBInspectable var cornerRadius: CGFloat = 15 {
		didSet {
			layer.cornerRadius = cornerRadius
			layer.masksToBounds = cornerRadius > 0
		}
	}
	@IBInspectable var dashWidth: CGFloat = 2
	@IBInspectable var dashColor: UIColor = UIColor.enaColor(for: .riskNeutral)
	@IBInspectable var dashLength: CGFloat = 5
	@IBInspectable var betweenDashesSpace: CGFloat = 5

	var dashBorder: CAShapeLayer!

	init() {
		super.init(frame: .zero)
		setup()
	}

	override init(frame: CGRect) {
		super.init(frame: frame)
		setup()
	}

	required init?(coder: NSCoder) {
		super.init(coder: coder)
		setup()
	}

	override func layoutSubviews() {
		super.layoutSubviews()

		updateBorder()
	}

	private func setup() {
		layer.cornerRadius = cornerRadius
		clipsToBounds = true

		updateBorder()
	}

	private func updateBorder() {
		self.dashBorder?.removeFromSuperlayer()

		let dashedBorder = CAShapeLayer()
		dashedBorder.lineWidth = dashWidth
		dashedBorder.strokeColor = dashColor.cgColor
		dashedBorder.lineDashPattern = [dashLength, betweenDashesSpace] as [NSNumber]
		dashedBorder.fillColor = UIColor.clear.cgColor
		if cornerRadius > 0 {
			dashedBorder.path = UIBezierPath(roundedRect: bounds, cornerRadius: cornerRadius).cgPath
		} else {
			dashedBorder.path = UIBezierPath(rect: bounds).cgPath
		}
		layer.addSublayer(dashedBorder)
		self.dashBorder = dashedBorder
	}
}
