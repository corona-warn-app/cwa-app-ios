//
// 🦠 Corona-Warn-App
//

import UIKit

class CardView: UIView {

	// MARK: - Init

	required init?(coder: NSCoder) {
		super.init(coder: coder)
		setup()
	}

	// MARK: - Overrides

	override init(frame: CGRect) {
		super.init(frame: frame)
		setup()
	}

	override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
		super.traitCollectionDidChange(previousTraitCollection)

		setLayerColors()
	}

	// MARK: - Internal

	@IBInspectable var hasBorder: Bool = true {
		didSet {
			setBorderWidth()
		}
	}

	func setHighlighted(_ highlighted: Bool, animated: Bool) {
		highlightView.backgroundColor = highlighted ? .enaColor(for: .listHighlight) : .clear
	}

	// MARK: - Private

	private let cornerRadius: CGFloat = 14.0
	private let highlightView = UIView()

	private func setup() {
		translatesAutoresizingMaskIntoConstraints = false
		clipsToBounds = false
		layer.cornerRadius = cornerRadius

		layer.shadowOffset = .init(width: 0.0, height: 1.0)
		layer.shadowRadius = 3.0
		layer.shadowOpacity = 1

		setBorderWidth()
		setLayerColors()

		highlightView.backgroundColor = .clear
		highlightView.layer.cornerRadius = cornerRadius

		highlightView.isUserInteractionEnabled = false

		addSubview(highlightView)
		highlightView.translatesAutoresizingMaskIntoConstraints = false

		NSLayoutConstraint.activate([
			highlightView.leadingAnchor.constraint(equalTo: leadingAnchor),
			highlightView.topAnchor.constraint(equalTo: topAnchor),
			highlightView.trailingAnchor.constraint(equalTo: trailingAnchor),
			highlightView.bottomAnchor.constraint(equalTo: bottomAnchor)
		])

		if #available(iOS 13.0, *) {
			layer.cornerCurve = .continuous
			highlightView.layer.cornerCurve = .continuous
		}
	}

	private func setLayerColors() {
		layer.shadowColor = UIColor.enaColor(for: .cardShadow).cgColor
		layer.borderColor = UIColor.enaColor(for: .cardShadow).cgColor
	}

	private func setBorderWidth() {
		layer.borderWidth = hasBorder ? 1 : 0
	}

}
