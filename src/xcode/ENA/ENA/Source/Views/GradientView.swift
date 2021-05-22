////
// 🦠 Corona-Warn-App
//

import UIKit

@IBDesignable
class GradientView: UIView {

	// MARK: - Init

	override init(frame: CGRect) {
		super.init(frame: frame)

		setupLayer()
	}

	required init?(coder: NSCoder) {
		super.init(coder: coder)
		setupLayer()
	}

	// MARK: - Overrides

	override class var layerClass: AnyClass {
		return CAGradientLayer.self
	}

	// MARK: - Internal

	enum GradientType {
		case blueRedTilted
		case blueOnly
		case solidGrey
		case lightBlue
	}

	var type: GradientType = .blueRedTilted { didSet { setupLayer() } }

	// MARK: - Private

	private func setupLayer() {
		guard let gradientLayer = self.layer as? CAGradientLayer else {
			Log.debug("Failed to create view with matching layer class", log: .default)
			return }
		switch type {
		case .blueRedTilted:
			// magic numbers to create the gradient colors in the right place
			gradientLayer.colors = [
				UIColor(red: 0.235, green: 0.547, blue: 0.733, alpha: 1).cgColor,
				UIColor(red: 0.424, green: 0.392, blue: 0.55, alpha: 1).cgColor,
				UIColor(red: 0.663, green: 0.246, blue: 0.271, alpha: 1).cgColor
			]
			gradientLayer.locations = [0.12, 0.48, 0.81]
			gradientLayer.startPoint = CGPoint(x: 0.0, y: 0.5)
			gradientLayer.endPoint = CGPoint(x: 1.0, y: 1.0)
		case .blueOnly:
			gradientLayer.colors = [
				UIColor(red: 43 / 255, green: 84 / 255, blue: 142 / 255, alpha: 1).cgColor,
				UIColor(red: 29 / 255, green: 78 / 255, blue: 125 / 255, alpha: 1).cgColor,
				UIColor(red: 16 / 255, green: 62 / 255, blue: 110 / 255, alpha: 1).cgColor
			]
			gradientLayer.locations = [0.0, 0.5, 1.0]
			gradientLayer.startPoint = CGPoint(x: 0.0, y: 0.0)
			gradientLayer.endPoint = CGPoint(x: 1.0, y: 1.0)
		case .solidGrey:
			gradientLayer.colors = [
				UIColor(red: 0.38, green: 0.435, blue: 0.494, alpha: 1).cgColor,
				UIColor(red: 0.38, green: 0.435, blue: 0.494, alpha: 1).cgColor
			]
			gradientLayer.locations = [0.0, 1.0]
			gradientLayer.startPoint = CGPoint(x: 0.0, y: 0.0)
			gradientLayer.endPoint = CGPoint(x: 1.0, y: 1.0)
		case .lightBlue:
			gradientLayer.colors = [
				UIColor(red: 46 / 255, green: 146 / 255, blue: 195 / 255, alpha: 1).cgColor,
				UIColor(red: 42 / 255, green: 135 / 255, blue: 181 / 255, alpha: 1).cgColor,
				UIColor(red: 39 / 255, green: 126 / 255, blue: 169 / 255, alpha: 1).cgColor
			]
			gradientLayer.locations = [0.0, 0.5, 1.0]
			gradientLayer.startPoint = CGPoint(x: 0.0, y: 0.0)
			gradientLayer.endPoint = CGPoint(x: 1.0, y: 1.0)
		}
	}
}
