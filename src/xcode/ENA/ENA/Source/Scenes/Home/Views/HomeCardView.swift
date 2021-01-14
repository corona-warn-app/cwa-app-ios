//
// 🦠 Corona-Warn-App
//

import UIKit

class HomeCardView: UIView {

	// MARK: - Overrides

	override func awakeFromNib() {
		super.awakeFromNib()

		clipsToBounds = false
		layer.cornerRadius = cornerRadius

		layer.shadowColor = UIColor.enaColor(for: .shadow).cgColor
		layer.shadowOffset = .init(width: 0.0, height: 10.0)
		layer.shadowRadius = 36.0
		layer.shadowOpacity = 1

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
	}

	override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
		super.traitCollectionDidChange(previousTraitCollection)

		layer.shadowColor = UIColor.enaColor(for: .shadow).cgColor
	}

	// MARK: - Internal

	func setHighlighted(_ highlighted: Bool, animated: Bool) {
		highlightView.backgroundColor = highlighted ? .enaColor(for: .listHighlight) : .clear
	}

	// MARK: - Private

	private let cornerRadius: CGFloat = 14.0

	private let highlightView = UIView()

}
