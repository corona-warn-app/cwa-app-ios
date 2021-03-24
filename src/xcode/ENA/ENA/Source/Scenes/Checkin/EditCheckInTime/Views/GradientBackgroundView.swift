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

	// MARK: - Private

	private func setupView() {
		backgroundColor = .clear

		let backgroundViewContainer = UIView()
		backgroundViewContainer.translatesAutoresizingMaskIntoConstraints = false
		backgroundViewContainer.backgroundColor = .enaColor(for: .cellBackground)
		addSubview(backgroundViewContainer)

		let gradientView = GradientView()
		gradientView.translatesAutoresizingMaskIntoConstraints = false
		addSubview(gradientView)

		NSLayoutConstraint.activate(
			[
				gradientView.topAnchor.constraint(equalTo: topAnchor),
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
