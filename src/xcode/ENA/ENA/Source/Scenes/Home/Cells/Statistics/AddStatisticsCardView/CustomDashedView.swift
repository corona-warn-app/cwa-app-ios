////
// 🦠 Corona-Warn-App
//

import UIKit

class CustomDashedView: UIView {

	enum Mode {
		case add, modify
	}
	
	// MARK: - Internal

	let label: ENALabel = {
		let label = ENALabel()
		// configure
		return label
	}()
	
	@IBInspectable var cornerRadius: CGFloat = 15 {
		didSet {
			layer.cornerRadius = cornerRadius
			layer.masksToBounds = cornerRadius > 0
		}
	}
	@IBInspectable var dashWidth: CGFloat = 2
	@IBInspectable var dashColor: UIColor = .enaColor(for: .riskNeutral)

	/// Dash pattern - dash length
	@IBInspectable var dashLength: CGFloat = 5
	/// Dash pattern - gap length
	@IBInspectable var betweenDashesSpace: CGFloat = 5

	var dashBorder: CAShapeLayer?

	required init(mode: Mode) {
		super.init(frame: .zero)

		configure(for: mode)
	}

	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	override func layoutSubviews() {
		super.layoutSubviews()

		// simple way to handle layer resizing
		dashBorder?.removeFromSuperlayer()
		let dashBorder = CAShapeLayer()
		dashBorder.lineWidth = dashWidth
		dashBorder.strokeColor = dashColor.cgColor
		dashBorder.lineDashPattern = [dashLength, betweenDashesSpace] as [NSNumber]
		dashBorder.frame = bounds
		dashBorder.fillColor = nil
		if cornerRadius > 0 {
			dashBorder.path = UIBezierPath(roundedRect: bounds, cornerRadius: cornerRadius).cgPath
		} else {
			dashBorder.path = UIBezierPath(rect: bounds).cgPath
		}
		layer.addSublayer(dashBorder)
		self.dashBorder = dashBorder
	}

	private func configure(for mode: Mode) {
		switch mode {
		case .add:
			backgroundColor = .green
		case .modify:
			backgroundColor = .orange
		}
	}
}
