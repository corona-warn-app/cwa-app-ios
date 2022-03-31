//
// 🦠 Corona-Warn-App
//

import Foundation
import UIKit

final class RoundedRectView: UIView {

	// MARK: - Init

	init(
		lineWidth: CGFloat,
		fillColor: UIColor,
		strokeColor: UIColor
	) {
		self.lineWidth = lineWidth
		self.fillColor = fillColor
		self.strokeColor = strokeColor
		super.init(frame: .zero)
		configure()
		layer.addSublayer(shapeLayer)
	}

	override init(frame: CGRect) {
		super.init(frame: frame)
		configure()
		layer.addSublayer(shapeLayer)
	}

	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
		configure()
		layer.addSublayer(shapeLayer)
	}

	// MARK: - Overrides

	override func layoutSubviews() {
		super.layoutSubviews()
		updatePath()
	}

	// MARK: - Internal

	var lineWidth: CGFloat = 3 {
		didSet {
			shapeLayer.lineWidth = lineWidth
		}
	}

	var fillColor: UIColor = .clear {
		didSet {
			shapeLayer.fillColor = fillColor.cgColor
		}
	}

	var strokeColor: UIColor = .black {
		didSet {
			shapeLayer.strokeColor = strokeColor.cgColor
		}
	}

	var rectCornerRadius: CGFloat {
		bounds.size.height / 2.0
	}

	// MARK: - Private

	private let shapeLayer = CAShapeLayer()

	private func configure() {
		shapeLayer.fillColor = fillColor.cgColor
		shapeLayer.strokeColor = strokeColor.cgColor
		shapeLayer.lineWidth = lineWidth
		shapeLayer.strokeStart = 0
		shapeLayer.strokeEnd = 1
	}

	private func updatePath() {
		shapeLayer.path = UIBezierPath(roundedRect: frame, cornerRadius: rectCornerRadius).cgPath
	}
}
