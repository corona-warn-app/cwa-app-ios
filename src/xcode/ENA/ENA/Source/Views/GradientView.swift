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

	// MARK: - Private

	private func setupLayer() {
		guard let gradientLayer = self.layer as? CAGradientLayer else {
			Log.debug("Failed to create view with matching layer class", log: .default)
			return }
		// magic numbers to create the gradient colors in the right place
		gradientLayer.colors = [
			UIColor(red: 0.235, green: 0.547, blue: 0.733, alpha: 1).cgColor,
			UIColor(red: 0.424, green: 0.392, blue: 0.55, alpha: 1).cgColor,
			UIColor(red: 0.663, green: 0.246, blue: 0.271, alpha: 1).cgColor
		]
		gradientLayer.locations = [0.12, 0.48, 0.81]
		gradientLayer.startPoint = CGPoint(x: 0.05, y: 0.5)
		gradientLayer.endPoint = CGPoint(x: 1.25, y: 0.5)
	}
}
