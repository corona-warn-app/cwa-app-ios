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
		setupStars()
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
		case green
		case lightBlueWithStars
		case greenWithStars

		var starImage: UIImage? {
			switch self {
			case .lightBlueWithStars:
				return UIImage(imageLiteralResourceName: "stars")
			case .greenWithStars:
				return UIImage(imageLiteralResourceName: "green-stars")
			default:
				return nil
			}
		}

	}

	var type: GradientType = .blueRedTilted {
		didSet {
			setupLayer()
			setupStars()
		}
	}

	// MARK: - Private

	private var withStars: Bool = false
	private var starImageView: UIImageView = UIImageView()

	private func setupStars() {
		guard let image = type.starImage else {
			starImageView.removeFromSuperview()
			return
		}

		starImageView = UIImageView(image: image)
		starImageView.contentMode = .scaleAspectFit
		starImageView.translatesAutoresizingMaskIntoConstraints = false
		addSubview(starImageView)

		NSLayoutConstraint.activate(
			[
				starImageView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -33),
				starImageView.topAnchor.constraint(equalTo: topAnchor, constant: 11)
			]
		)
	}

	private func setupLayer() {
		guard let gradientLayer = self.layer as? CAGradientLayer else {
			return
		}

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
				UIColor(red: 0 / 255, green: 147 / 255, blue: 200 / 255, alpha: 1).cgColor,
				UIColor(red: 0 / 255, green: 127 / 255, blue: 173 / 255, alpha: 1).cgColor
			]
			gradientLayer.locations = [0.0, 1.0]
			gradientLayer.startPoint = CGPoint(x: 0.0, y: 0.0)
			gradientLayer.endPoint = CGPoint(x: 1.0, y: 1.0)
		case .green:
			gradientLayer.colors = [
				UIColor(red: 40 / 255, green: 132 / 255, blue: 71 / 255, alpha: 1).cgColor,
				UIColor(red: 53 / 255, green: 181 / 255, blue: 95 / 255, alpha: 1).cgColor
			]
			gradientLayer.locations = [0.0, 1.0]
			gradientLayer.startPoint = CGPoint(x: 0.0, y: 0.0)
			gradientLayer.endPoint = CGPoint(x: 1.0, y: 1.0)
		case .lightBlueWithStars:
			gradientLayer.colors = [
				UIColor(red: 0 / 255, green: 147 / 255, blue: 200 / 255, alpha: 1).cgColor,
				UIColor(red: 0 / 255, green: 127 / 255, blue: 173 / 255, alpha: 1).cgColor
			]
			gradientLayer.locations = [0.0, 1.0]
			gradientLayer.startPoint = CGPoint(x: 0.0, y: 0.0)
			gradientLayer.endPoint = CGPoint(x: 1.0, y: 1.0)
		case .greenWithStars:
			gradientLayer.colors = [
				UIColor(red: 40 / 255, green: 132 / 255, blue: 71 / 255, alpha: 1).cgColor,
				UIColor(red: 53 / 255, green: 181 / 255, blue: 95 / 255, alpha: 1).cgColor
			]
			gradientLayer.locations = [0.0, 1.0]
			gradientLayer.startPoint = CGPoint(x: 0.0, y: 0.0)
			gradientLayer.endPoint = CGPoint(x: 1.0, y: 1.0)
		}
		setupStars()
	}
}
