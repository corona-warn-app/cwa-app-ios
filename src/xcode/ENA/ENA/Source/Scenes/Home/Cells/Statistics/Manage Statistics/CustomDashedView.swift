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
		let borderLayer = CAShapeLayer()
		borderLayer.lineWidth = dashWidth
		borderLayer.strokeColor = dashColor.cgColor
		borderLayer.lineDashPattern = [dashLength, betweenDashesSpace] as [NSNumber]
		borderLayer.frame = bounds
		borderLayer.fillColor = nil
		if cornerRadius > 0 {
			borderLayer.path = UIBezierPath(roundedRect: bounds, cornerRadius: cornerRadius).cgPath
		} else {
			borderLayer.path = UIBezierPath(rect: bounds).cgPath
		}
		layer.addSublayer(borderLayer)
		layer.cornerRadius = cornerRadius
		self.dashBorder = borderLayer
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
	
	@IBOutlet private weak var button: UIButton!
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

	@IBAction private func buttonPressed(_ sender: Any) {
		tapHandler?()
	}
	private func configure(for mode: Mode, isEnabled: Bool) {
		#if DEBUG
		if isUITesting {
			tapRecognizer.isEnabled = false
		}
		#endif
		button.accessibilityIdentifier = AccessibilityIdentifiers.LocalStatistics.button
		
		switch mode {
		case .add:
			if isEnabled {
				tapRecognizer.isEnabled = true
				label.text = AppStrings.Statistics.AddCard.sevenDayIncidence
				button.setImage(UIImage(named: "Icon_Add"), for: .normal)
			} else {
				tapRecognizer.isEnabled = false
				label.text = AppStrings.Statistics.AddCard.disabledAddTitle
				button.setImage(UIImage(named: "Icon_Add_Grey"), for: .normal)
			}
			label.accessibilityIdentifier = AccessibilityIdentifiers.LocalStatistics.addLocalIncidenceLabel

			accessibilityIdentifier = AccessibilityIdentifiers.LocalStatistics.addLocalIncidencesButton
			
			
		case .modify:
			label.text = AppStrings.Statistics.AddCard.modify
			label.accessibilityIdentifier = AccessibilityIdentifiers.LocalStatistics.modifyLocalIncidenceLabel
			button.setImage(UIImage(named: "Icon_Modify"), for: .normal)
			accessibilityIdentifier = AccessibilityIdentifiers.LocalStatistics.modifyLocalIncidencesButton
		}
		backgroundColor = .enaColor(for: .backgroundLightGray)
		accessibilityTraits = [.button, .staticText]

		// ensure we don't assign this one multiple times
		gestureRecognizers?.forEach { rec in
			removeGestureRecognizer(rec)
		}
		// add tap recognizer
		addGestureRecognizer(tapRecognizer)
	}

	@objc
	private func onTap(_ sender: UITapGestureRecognizer) {
		tapHandler?()
	}
}
