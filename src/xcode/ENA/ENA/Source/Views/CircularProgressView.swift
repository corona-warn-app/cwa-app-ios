//
// 🦠 Corona-Warn-App
//

import UIKit

@IBDesignable
class CircularProgressView: UIView {
	let circleLayer = CAShapeLayer()
	let progressLayer = CAShapeLayer()
	let textLayer = CATextLayer()

	@IBInspectable var maxValue: CGFloat = 14
	@IBInspectable var minValue: CGFloat = 0
	@IBInspectable var fontSize: CGFloat = 15
	@IBInspectable var lineWidth: CGFloat = 10
	@IBInspectable var progressBarColor: UIColor = UIColor.green {
		didSet {
			updateLayers()
		}
	}

	@IBInspectable var circleColor: UIColor = UIColor.red {
		didSet {
			updateLayers()
		}
	}

	@IBInspectable var fontColor: UIColor = UIColor.gray

	@IBInspectable var progress: CGFloat = 4.0 {
		didSet {
			progressLayer.updateProgress(progressValue: progress, minValue: minValue, maxValue: maxValue)
			let text = "\(Int(progress))/\(Int(maxValue))"
			textLayer.updateText(text)
		}
	}

	override init(frame: CGRect) {
		super.init(frame: frame)
		addLayers()
	}

	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
		addLayers()
	}

	func addLayers() {
		layer.addSublayer(circleLayer)
		layer.addSublayer(progressLayer)
		layer.addSublayer(textLayer)
	}

	override func layoutSubviews() {
		super.layoutSubviews()
		updateLayers()
	}
}

extension CircularProgressView {
	private func bezierPath(with center: CGPoint) -> UIBezierPath {
		let circularPath = UIBezierPath(
			arcCenter: center,
			radius: frame.width / 2 - lineWidth / 2,
			startAngle: -.pi / 2,
			endAngle: 3 * .pi / 2,
			clockwise: true
		)
		return circularPath
	}

	private func updateLayers() {
		let center = CGPoint(x: bounds.midX, y: bounds.midY)
		let circularPath = bezierPath(with: center)
		circleLayer.configLayer(with: circularPath, lineWidth: lineWidth)
		circleLayer.strokeColor = circleColor.cgColor
		progressLayer.configLayer(with: circularPath, lineWidth: lineWidth)
		progressLayer.strokeColor = progressBarColor.cgColor
		configTextLayer(center)
	}

	private func configTextLayer(_ center: CGPoint) {
		textLayer.setScaleForDevice()
		textLayer.foregroundColor = fontColor.cgColor
		textLayer.fontSize = fontSize
		let sizeOfTextBox = textLayer.preferredFrameSize()
		let newX = center.x - sizeOfTextBox.width / 2
		let newY = center.y - sizeOfTextBox.height / 2
		textLayer.frame = CGRect(origin: CGPoint(x: newX, y: newY), size: sizeOfTextBox)
	}
}

private extension CALayer {
	func setScaleForDevice() {
		contentsScale = UIScreen.main.scale
		shouldRasterize = true
		rasterizationScale = UIScreen.main.scale
	}
}

private extension CAShapeLayer {
	func updateProgress(progressValue: CGFloat, minValue: CGFloat, maxValue: CGFloat) {
		let progress = max(minValue, min(maxValue, progressValue))
		let range = maxValue - minValue
		strokeEnd = progress / CGFloat(range)
	}

	func configLayer(with path: UIBezierPath, lineWidth: CGFloat) {
		setScaleForDevice()
		self.path = path.cgPath
		fillColor = UIColor.clear.cgColor
		lineCap = .round
		self.lineWidth = lineWidth
	}
}

private extension CATextLayer {
	func updateText(_ text: String) {
		string = text
		let size = preferredFrameSize()
		bounds = CGRect(origin: CGPoint.zero, size: size)
	}
}
