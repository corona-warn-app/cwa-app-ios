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
		layer.addSublayer(trackLayer)
	}

	override init(frame: CGRect) {
		super.init(frame: frame)
		configure()
		layer.addSublayer(trackLayer)
	}

	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
		configure()
		layer.addSublayer(trackLayer)
	}

	// MARK: - Overrides

	override func layoutSubviews() {
		super.layoutSubviews()
		updatePath()
	}

	// MARK: - Internal

	var lineWidth: CGFloat = 3 {
		didSet {
			trackLayer.lineWidth = lineWidth
		}
	}

	var fillColor: UIColor = .clear {
		didSet {
			trackLayer.fillColor = fillColor.cgColor
		}
	}

	var strokeColor: UIColor = .black {
		didSet {
			trackLayer.strokeColor = strokeColor.cgColor
		}
	}

	var rectCornerRadius: CGFloat {
		bounds.size.height / 2.0
	}

	// MARK: - Private

	private let trackLayer = CAShapeLayer()

	private func configure() {
		trackLayer.fillColor   = fillColor.cgColor
		trackLayer.strokeColor = strokeColor.cgColor
		trackLayer.lineWidth = lineWidth
		trackLayer.strokeStart = 0
		trackLayer.strokeEnd   = 1
	}

	private func updatePath() {
		trackLayer.path = UIBezierPath(roundedRect: frame, cornerRadius: rectCornerRadius).cgPath
	}
}
