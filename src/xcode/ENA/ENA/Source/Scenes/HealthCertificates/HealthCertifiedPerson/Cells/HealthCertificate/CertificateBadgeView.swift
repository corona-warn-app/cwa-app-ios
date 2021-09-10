//
// 🦠 Corona-Warn-App
//

import UIKit

class CertificateBadgeView: UIView {

	// MARK: - Init

	required init?(coder: NSCoder) {
		super.init(coder: coder)

		setup()
	}

	override init(frame: CGRect) {
		super.init(frame: frame)

		setup()
	}

	// MARK: - Overrides

	override var bounds: CGRect {
		didSet {
			let path = UIBezierPath(
				roundedRect: bounds,
				cornerRadius: bounds.height / 2
			)

			let mask = CAShapeLayer()
			mask.path = path.cgPath
			layer.mask = mask

			borderShapeLayer.frame = bounds
			borderShapeLayer.path = path.cgPath
		}
	}

	override var backgroundColor: UIColor? {
		didSet {
			borderShapeLayer.fillColor = backgroundColor?.cgColor
		}
	}

	override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
		super.traitCollectionDidChange(previousTraitCollection)

		borderShapeLayer.strokeColor = borderColor.cgColor
		borderShapeLayer.fillColor = backgroundColor?.cgColor
	}

	// MARK: - Internal

	@IBInspectable var borderWidth: CGFloat = 2 {
		didSet {
			borderShapeLayer.lineWidth = borderWidth * 2
		}
	}

	@IBInspectable var borderColor: UIColor = .enaColor(for: .cellBackground2) {
		didSet {
			borderShapeLayer.strokeColor = borderColor.cgColor
		}
	}

	// MARK: - Private

	private let borderShapeLayer = CAShapeLayer()

	func setup() {
		layer.addSublayer(borderShapeLayer)

		borderShapeLayer.lineWidth = borderWidth * 2
		borderShapeLayer.strokeColor = borderColor.cgColor
	}

}
