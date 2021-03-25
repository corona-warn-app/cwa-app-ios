////
// 🦠 Corona-Warn-App
//

import UIKit

class GradientBackgroundView: UIView {

	// MARK: - Init
	init() {
		super.init(frame: .zero)
		setupView()
	}

	@available(*, unavailable)
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	// MARK: - Public

	// MARK: - Internal

	var topLayoutConstraint: NSLayoutConstraint!

	func updatedTopLayout(with offset: CGFloat, limit: CGFloat) {
		let height = gradientView.bounds.size.height
		topLayoutConstraint.constant = max(-offset, -(height - limit))
	}

	// MARK: - Private

	private let gradientView = GradientView()

	private func setupView() {
		backgroundColor = .clear

		let backgroundViewContainer = UIView()
		backgroundViewContainer.translatesAutoresizingMaskIntoConstraints = false
		backgroundViewContainer.backgroundColor = .enaColor(for: .cellBackground)
		addSubview(backgroundViewContainer)

		gradientView.translatesAutoresizingMaskIntoConstraints = false
		addSubview(gradientView)
		topLayoutConstraint = gradientView.topAnchor.constraint(equalTo: topAnchor)

		NSLayoutConstraint.activate(
			[
				topLayoutConstraint,
				gradientView.leadingAnchor.constraint(equalTo: leadingAnchor),
				gradientView.trailingAnchor.constraint(equalTo: trailingAnchor),
				gradientView.heightAnchor.constraint(equalTo: heightAnchor, multiplier: 1.0 / 2.5),
				backgroundViewContainer.topAnchor.constraint(equalTo: gradientView.bottomAnchor),
				backgroundViewContainer.leadingAnchor.constraint(equalTo: leadingAnchor),
				backgroundViewContainer.trailingAnchor.constraint(equalTo: trailingAnchor),
				backgroundViewContainer.bottomAnchor.constraint(equalTo: bottomAnchor)
			]
		)
	}

}
