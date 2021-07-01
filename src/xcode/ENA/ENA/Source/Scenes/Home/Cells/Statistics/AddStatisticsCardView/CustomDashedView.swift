////
// 🦠 Corona-Warn-App
//

import UIKit

class CustomDashedView: UIView {

	enum Mode {
		case add, modify
	}
	
	// MARK: - Internal

	@IBOutlet weak var label: ENALabel!
	@IBOutlet weak var icon: UIImageView!
	
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

	var tapHandler: (() -> Void)?

	private var dashBorder: CAShapeLayer?
	private lazy var tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(onTap))

	class func instance(for mode: Mode) -> CustomDashedView {
		let nibName = String(describing: Self.self)
		// swiftlint:disable:next force_cast
		let view = UINib(nibName: nibName, bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! CustomDashedView
		view.configure(for: mode)
		return view
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
			label.text = "add"
			icon.image = UIImage(named: "Icon_Add")
		case .modify:
			label.text = "modify"
			icon.image = UIImage(named: "Icon_Modify")
		}

		// ensure we don't assign this one multiple times
		gestureRecognizers?.forEach { rec in
			removeGestureRecognizer(rec)
		}
		// add tap recognizer
		self.addGestureRecognizer(tapRecognizer)
	}

	@objc
	private func onTap(_ sender: UITapGestureRecognizer) {
		tapHandler?()
	}
}
