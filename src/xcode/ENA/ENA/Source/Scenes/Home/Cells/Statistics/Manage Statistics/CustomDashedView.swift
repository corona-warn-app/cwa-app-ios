////
// 🦠 Corona-Warn-App
//

import UIKit

class CustomDashedView: UIControl {
	
	// MARK: - Overrides

	override var isEnabled: Bool {
		didSet {
			// design for add-card is based on this state
			// using accessibility identifier to prevent yet another `mode` property
			guard accessibilityIdentifier == AccessibilityIdentifiers.LocalStatistics.addLocalIncidencesButton else {
				return
			}

			if isEnabled {
				label.text = AppStrings.Statistics.AddCard.sevenDayIncidence
				icon.image = UIImage(named: "Icon_Add")
				accessibilityTraits = [.button]
			} else {
				label.text = AppStrings.Statistics.AddCard.disabledAddTitle
				icon.image = UIImage(named: "Icon_Add_Grey")
				accessibilityTraits = [.button, .notEnabled]
			}
			
			accessibilityLabel = label.text
		}
	}

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

	override var accessibilityElements: [Any]? {
		get { [label, icon].compactMap { $0 } }
		set { }
	}

	override func accessibilityElementDidBecomeFocused() {
		super.accessibilityElementDidBecomeFocused()

		onAccessibilityFocus?()
	}

	override func accessibilityActivate() -> Bool {
		guard isEnabled else {
			return false
		}

		tapHandler?()

		return true
	}
	
	// MARK: - Internal

	enum Mode {
		case add, modify
	}

	var tapHandler: (() -> Void)?
	var onAccessibilityFocus: (() -> Void)?

	class func instance(for mode: Mode) -> CustomDashedView {
		let nibName = String(describing: Self.self)
		guard let view = UINib(nibName: nibName, bundle: nil).instantiate(withOwner: nil, options: nil)[0] as? CustomDashedView else {
			fatalError("Could not initialize CustomDashedView")
		}
		view.configure(for: mode)
		return view
	}
	
	// MARK: - Private

	@IBOutlet private weak var label: ENALabel!
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

	private func configure(for mode: Mode) {
		switch mode {
		case .add:
			label.accessibilityIdentifier = AccessibilityIdentifiers.LocalStatistics.addLocalIncidenceLabel
			accessibilityIdentifier = AccessibilityIdentifiers.LocalStatistics.addLocalIncidencesButton
			isEnabled = true // explicit call to trigger design adjustment
			// HACK: it's important to call isEnabled after setting the accessibilityIdentifier!
		case .modify:
			label.text = AppStrings.Statistics.AddCard.modify
			label.accessibilityIdentifier = AccessibilityIdentifiers.LocalStatistics.modifyLocalIncidenceLabel

			icon.image = UIImage(named: "Icon_Modify")
			accessibilityIdentifier = AccessibilityIdentifiers.LocalStatistics.modifyLocalIncidencesButton
		}
		backgroundColor = .enaColor(for: .backgroundLightGray)
		accessibilityTraits = [.button]
		accessibilityLabel = label.text
		isAccessibilityElement = true

		// user interaction
		addTarget(self, action: #selector(onTap(_:)), for: .touchUpInside)
	}

	@objc
	private func onTap(_ sender: Any?) {
		tapHandler?()
	}
}
