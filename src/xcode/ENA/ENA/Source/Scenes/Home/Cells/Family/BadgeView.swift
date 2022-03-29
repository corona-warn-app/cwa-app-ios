//
// 🦠 Corona-Warn-App
//

import UIKit

final class BadgeView: UIView {

	// MARK: - Init

	init(
		_ badgeCount: String?,
		fillColor: UIColor = .red,
		textColor: UIColor = .white
	) {
		self.fillColor = fillColor
		self.textColor = textColor
		self.badgeCount = badgeCount
		super.init(frame: .zero)
		setupView()
	}

	@available(*, unavailable)
	required init?(coder: NSCoder) {
		fatalError("do not use")
	}

	// MARK: - Internal

	func setBadge(_ text: String?, animated: Bool) {
		let futureIsHidden = text == nil
		let animator = UIViewPropertyAnimator(duration: animated ? 0.45 : 0.0, curve: .easeInOut) { [weak self] in
			self?.badgeLabel.text = text
			self?.roundedRectView?.alpha = futureIsHidden ? 0.0 : 1.0
		}
		animator.startAnimation()
	}

	// MARK: - Private

	private let badgeCount: String?
	private let fillColor: UIColor
	private let textColor: UIColor

	private let badgeLabel: ENALabel = ENALabel(style: .badge)
	private var roundedRectView: RoundedRectView?

	private func setupView() {
		let roundedRectView = RoundedRectView(lineWidth: 1.0, fillColor: fillColor, strokeColor: textColor)
		roundedRectView.translatesAutoresizingMaskIntoConstraints = false
		addSubview(roundedRectView)
		self.roundedRectView = roundedRectView

		badgeLabel.translatesAutoresizingMaskIntoConstraints = false
		badgeLabel.textAlignment = .center
		badgeLabel.textColor = textColor
		roundedRectView.addSubview(badgeLabel)

		NSLayoutConstraint.activate(
			[
				roundedRectView.leadingAnchor.constraint(equalTo: leadingAnchor),
				roundedRectView.topAnchor.constraint(equalTo: topAnchor),
				roundedRectView.trailingAnchor.constraint(equalTo: trailingAnchor),
				roundedRectView.bottomAnchor.constraint(equalTo: bottomAnchor),

				roundedRectView.centerXAnchor.constraint(equalTo: badgeLabel.centerXAnchor),
				roundedRectView.centerYAnchor.constraint(equalTo: badgeLabel.centerYAnchor),
				roundedRectView.widthAnchor.constraint(equalTo: badgeLabel.widthAnchor, constant: 4.0),
				roundedRectView.heightAnchor.constraint(equalTo: badgeLabel.heightAnchor, constant: 4.0),
				roundedRectView.widthAnchor.constraint(greaterThanOrEqualTo: roundedRectView.heightAnchor)
			]
		)

		badgeLabel.text = badgeCount
		roundedRectView.alpha = badgeCount == nil ? 0.0 : 1.0
	}
}
