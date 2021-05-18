////
// 🦠 Corona-Warn-App
//

import UIKit

class GradientBackgroundView: UIView {

	// MARK: - Init

	init(type: GradientView.GradientType = .blueRedTilted) {
		self.type = type
		super.init(frame: .zero)
		setupView()
	}

	@available(*, unavailable)
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	// MARK: - Internal

	var gradientHeightConstraint: NSLayoutConstraint!
	var type: GradientView.GradientType {
		didSet {
			gradientView.type = type
		}
	}

	func updatedTopLayout(with offset: CGFloat, limit: CGFloat) {
		let height = gradientView.bounds.size.height
		topLayoutConstraint.constant = max(min(-offset, 0), min(-(height - limit), 0))
	}

	// MARK: - Private

	private let gradientView = GradientView()
	private var topLayoutConstraint: NSLayoutConstraint!

	private func setupView() {
		backgroundColor = .clear

		let backgroundViewContainer = UIView()
		backgroundViewContainer.translatesAutoresizingMaskIntoConstraints = false
		backgroundViewContainer.backgroundColor = .enaColor(for: .cellBackground)
		addSubview(backgroundViewContainer)

		gradientView.translatesAutoresizingMaskIntoConstraints = false
		addSubview(gradientView)
		gradientView.type = type

		topLayoutConstraint = gradientView.topAnchor.constraint(equalTo: topAnchor)
		gradientHeightConstraint = gradientView.heightAnchor.constraint(equalToConstant: 150)
		gradientHeightConstraint.priority = .defaultHigh
		
		NSLayoutConstraint.activate(
			[
				topLayoutConstraint,
				gradientView.leadingAnchor.constraint(equalTo: leadingAnchor),
				gradientView.trailingAnchor.constraint(equalTo: trailingAnchor),
				gradientHeightConstraint,

				backgroundViewContainer.topAnchor.constraint(equalTo: gradientView.bottomAnchor),
				backgroundViewContainer.topAnchor.constraint(equalTo: gradientView.bottomAnchor),
				backgroundViewContainer.leadingAnchor.constraint(equalTo: leadingAnchor),
				backgroundViewContainer.trailingAnchor.constraint(equalTo: trailingAnchor),
				backgroundViewContainer.bottomAnchor.constraint(equalTo: bottomAnchor)
			]
		)
	}

}
