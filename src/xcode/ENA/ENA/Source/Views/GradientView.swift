////
// 🦠 Corona-Warn-App
//

import UIKit

@IBDesignable
class GradientView: UIView {

	// MARK: - Init

	init(
		type: GradientType = .solidGrey,
		frame: CGRect = .zero
	) {
		super.init(frame: frame)
		setupView()
		self.type = type
		updatedLayer()
	}

	override init(frame: CGRect) {
		super.init(frame: frame)
		setupView()
		updatedLayer()
	}

	required init?(coder: NSCoder) {
		super.init(coder: coder)
		setupView()
		updatedLayer()
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
		case lightBlue(withStars: Bool)
		case mediumBlue(withStars: Bool)
		case darkBlue(withStars: Bool)

		var starImage: UIImage? {
			switch self {
			case let .lightBlue(withStars):
				return withStars ? UIImage(imageLiteralResourceName: "lightBlueStars") : nil
			case let .mediumBlue(withStars):
				return withStars ? UIImage(imageLiteralResourceName: "mediumBlueStars") : nil
			case let .darkBlue(withStars):
				return withStars ? UIImage(imageLiteralResourceName: "darkBlueStars") : nil
			default:
				return nil
			}
		}
	}

	var type: GradientType = .blueRedTilted {
		didSet {
			updatedLayer()
		}
	}

	// MARK: - Private

	private let imageView: UIImageView = UIImageView()

	private func setupView() {
		imageView.translatesAutoresizingMaskIntoConstraints = false
		addSubview(imageView)
		NSLayoutConstraint.activate(
			[
				imageView.topAnchor.constraint(equalTo: topAnchor),
				imageView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -30)
			]
		)
	}

	private func updatedLayer() {
		guard let gradientLayer = self.layer as? CAGradientLayer else {
			Log.debug("Failed to create view with matching layer class", log: .default)
			return
		}
		Log.debug("\(type) - try to load image", log: .default)
		imageView.image = type.starImage

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
				UIColor(red: 0, green: 0.575, blue: 0.783, alpha: 1).cgColor,
				UIColor(red: 0, green: 0.499, blue: 0.679, alpha: 1).cgColor
			]
			gradientLayer.locations = [0.0, 1.0]
			gradientLayer.startPoint = CGPoint(x: 0.25, y: 0.5)
			gradientLayer.endPoint = CGPoint(x: 0.75, y: 0.5)

		case .mediumBlue:
			gradientLayer.colors = [
				UIColor(red: 25 / 255, green: 108 / 255, blue: 163 / 255, alpha: 1).cgColor,
				UIColor(red: 35 / 255, green: 118 / 255, blue: 169 / 255, alpha: 1).cgColor
			]
			gradientLayer.locations = [0.0, 1.0]
			gradientLayer.startPoint = CGPoint(x: 0.0, y: 0.0)
			gradientLayer.endPoint = CGPoint(x: 1.0, y: 0.5)

		case .darkBlue:
			gradientLayer.colors = [
				UIColor(red: 0 / 255, green: 93 / 255, blue: 147 / 255, alpha: 1).cgColor,
				UIColor(red: 4 / 255, green: 96 / 255, blue: 151 / 255, alpha: 1).cgColor
			]
			gradientLayer.locations = [0.25, 0.75]
			gradientLayer.startPoint = CGPoint(x: 0.0, y: 0.0)
			gradientLayer.endPoint = CGPoint(x: 1.0, y: 1.0)
		}
	}
}
