////
// 🦠 Corona-Warn-App
//

import UIKit

class CustomDashedView: UIView {
	
	// MARK: - Overrides

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
		layer.cornerRadius = cornerRadius
		self.dashBorder = dashBorder
	}
	
	// MARK: - Internal

	enum Mode {
		case add, modify
	}
	
	@IBOutlet weak var label: ENALabel!

	var tapHandler: (() -> Void)?

	class func instance(for mode: Mode, isEnabled: Bool) -> CustomDashedView {
		let nibName = String(describing: Self.self)

		guard let view = UINib(nibName: nibName, bundle: nil).instantiate(withOwner: nil, options: nil)[0] as? CustomDashedView else {
			fatalError("Could not initialize CustomDashedView")
		}
		view.configure(for: mode, isEnabled: isEnabled)
		return view
	}
	
	// MARK: - Private
	
	@IBOutlet private weak var icon: UIImageView!
	
	@IBInspectable private var cornerRadius: CGFloat = 15 {
		didSet {
			layer.cornerRadius = cornerRadius
			layer.masksToBounds = cornerRadius > 0
		}
	}
	@IBInspectable private var dashWidth: CGFloat = 2
	@IBInspectable private var dashColor: UIColor = .enaColor(for: .dashedCardBorder)

	/// Dash pattern - dash length
	@IBInspectable private var dashLength: CGFloat = 5
	/// Dash pattern - gap length
	@IBInspectable private var betweenDashesSpace: CGFloat = 5

	private var dashBorder: CAShapeLayer?
	private lazy var tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(onTap))

	private func configure(for mode: Mode, isEnabled: Bool) {
		switch mode {
		case .add:
			if isEnabled {
				tapRecognizer.isEnabled = true
				label.text = AppStrings.Statistics.AddCard.sevenDayIncidence
				icon.image = UIImage(named: "Icon_Add")
			} else {
				tapRecognizer.isEnabled = false
				label.text = AppStrings.Statistics.AddCard.disabledAddTitle
				icon.image = UIImage(named: "Icon_Add_Grey")
			}
			label.accessibilityIdentifier = AccessibilityIdentifiers.LocalStatistics.addLocalIncidenceLabel
			self.accessibilityIdentifier = AccessibilityIdentifiers.LocalStatistics.addLocalIncidencesButton
		case .modify:
			label.text = AppStrings.Statistics.AddCard.modify
			label.accessibilityIdentifier = AccessibilityIdentifiers.LocalStatistics.modifyLocalIncidenceLabel

			icon.image = UIImage(named: "Icon_Modify")
			self.accessibilityIdentifier = AccessibilityIdentifiers.LocalStatistics.modifyLocalIncidencesButton
		}
		backgroundColor = .enaColor(for: .backgroundLightGray)

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
