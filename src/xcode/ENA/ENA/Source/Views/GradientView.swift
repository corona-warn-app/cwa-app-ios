////
// 🦠 Corona-Warn-App
//

import UIKit

@IBDesignable
class GradientView: UIView {

	// MARK: - Init

	init(
		type: GradientType = .solidGrey,
		withStars starsAreVisible: Bool = false,
		frame: CGRect = .zero
	) {
		super.init(frame: frame)

		setupView()

		self.type = type
		self.starsAreVisible = starsAreVisible

		updateLayer()
	}

	override init(frame: CGRect) {
		super.init(frame: frame)
		setupView()
		updateLayer()
	}

	required init?(coder: NSCoder) {
		super.init(coder: coder)
		setupView()
		updateLayer()
	}

	// MARK: - Overrides

	override class var layerClass: AnyClass {
		return CAGradientLayer.self
	}

	override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
		super.traitCollectionDidChange(previousTraitCollection)
		updateLayer()
	}

	// MARK: - Internal

	enum GradientType: Equatable {
		case blueRedTilted
		case blueOnly
		case solidGrey
		case lightBlue
		case mediumBlue
		case darkBlue
		case whiteToLightBlue

		var starsColor: UIColor? {
			switch self {
			case .solidGrey:
				return UIColor(red: 87.0 / 255.0, green: 103.0 / 255.0, blue: 120.0 / 255.0, alpha: 1.0)
			case .lightBlue:
				return UIColor(red: 1.0 / 255.0, green: 145.0 / 255.0, blue: 198.0 / 255.0, alpha: 1.0)
			case .mediumBlue:
				return UIColor(red: 7.0 / 255.0, green: 106.0 / 255.0, blue: 159.0 / 255.0, alpha: 1.0)
			case .darkBlue:
				return UIColor(red: 2.0 / 255.0, green: 90.0 / 255.0, blue: 143.0 / 255.0, alpha: 1.0)
			default:
				return nil
			}
		}
	}

	var type: GradientType = .blueRedTilted {
		didSet {
			updateLayer()
		}
	}

	var starsAreVisible: Bool = false {
		didSet {
			updateLayer()
		}
	}

	// MARK: - Private

	private let imageView: UIImageView = UIImageView()

	private func setupView() {
		imageView.translatesAutoresizingMaskIntoConstraints = false
		addSubview(imageView)
		NSLayoutConstraint.activate(
			[
				imageView.topAnchor.constraint(equalTo: topAnchor, constant: 10.0),
				imageView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -33.0)
			]
		)
	}

	private func updateStars() {
		// update stars view
		if let starsColor = type.starsColor, starsAreVisible {
			imageView.tintColor = starsColor
			imageView.tintAdjustmentMode = .normal
			imageView.image = UIImage(imageLiteralResourceName: "EUStarsGroup")
		} else {
			imageView.image = nil
		}
	}

	private func updateGradient() {
		guard let gradientLayer = self.layer as? CAGradientLayer else {
			Log.debug("Failed to create view with matching layer class", log: .default)
			return
		}
		// update gradient layer
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

		case .whiteToLightBlue:
			let lightColors = [
				UIColor(red: 255 / 255, green: 255 / 255, blue: 255 / 255, alpha: 1).cgColor,
				UIColor(red: 255 / 255, green: 255 / 255, blue: 255 / 255, alpha: 1).cgColor,
				UIColor(red: 235 / 255, green: 244 / 255, blue: 255 / 255, alpha: 1).cgColor
			]

			let darkColors = [
				UIColor(red: 25 / 255, green: 25 / 255, blue: 27 / 255, alpha: 1).cgColor,
				UIColor(red: 47 / 255, green: 65 / 255, blue: 77 / 255, alpha: 1).cgColor
			]

			var isDarkMode: Bool = false
			if #available(iOS 13.0, *) {
				isDarkMode = UITraitCollection.current.userInterfaceStyle == .dark
			}

			gradientLayer.colors = isDarkMode ? darkColors : lightColors
			gradientLayer.locations = [0.0, 0.6, 1.0]
			gradientLayer.startPoint = CGPoint(x: 0.0, y: 0.0)
			gradientLayer.endPoint = CGPoint(x: 1.0, y: 0.95)
		}
	}

	private func updateLayer() {
		updateStars()
		updateGradient()
	}

}
