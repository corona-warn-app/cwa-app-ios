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

	// MARK: - Private

	private let badgeCount: String?
	private let fillColor: UIColor
	private let textColor: UIColor

	private func setupView() {
		let roundedRectView = RoundedRectView(lineWidth: 1.0, fillColor: fillColor, strokeColor: textColor)
		roundedRectView.translatesAutoresizingMaskIntoConstraints = false
		addSubview(roundedRectView)

		let label = UILabel()
		label.translatesAutoresizingMaskIntoConstraints = false
		label.textAlignment = .center
		label.font = .systemFont(ofSize: 17.0)
		label.text = badgeCount
		label.textColor = textColor

		roundedRectView.addSubview(label)
		NSLayoutConstraint.activate(
			[
				roundedRectView.centerXAnchor.constraint(equalTo: label.centerXAnchor),
				roundedRectView.centerYAnchor.constraint(equalTo: label.centerYAnchor),
				roundedRectView.widthAnchor.constraint(equalTo: label.widthAnchor, constant: 8.0),
				roundedRectView.heightAnchor.constraint(equalTo: label.heightAnchor, constant: 8.0),
				roundedRectView.widthAnchor.constraint(greaterThanOrEqualTo: roundedRectView.heightAnchor)
			]
		)
	}
}
