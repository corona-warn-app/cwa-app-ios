////
// 🦠 Corona-Warn-App
//

import UIKit

class EmptyStateView: UIView {

	// MARK: - Init

	@available(*, unavailable)
	override init(frame: CGRect) {
		fatalError("init(frame:) has not been implemented")
	}

	@available(*, unavailable)
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	init(viewModel: EmptyStateViewModel) {
		self.viewModel = viewModel

		super.init(frame: .zero)

		setUp()
	}

	// MARK: - Internal

	var additionalTopPadding: CGFloat = 0 {
		didSet {
			topConstraint.constant = additionalTopPadding
		}
	}

	// MARK: - Private

	private let viewModel: EmptyStateViewModel

	private var topConstraint: NSLayoutConstraint!

	private func setUp() {
		backgroundColor = .clear

		let containerView = UIView()
		containerView.backgroundColor = .clear
		addSubview(containerView)
		containerView.translatesAutoresizingMaskIntoConstraints = false

		let stackView = UIStackView()
		stackView.axis = .vertical
		stackView.alignment = .center
		stackView.spacing = 12
		addSubview(stackView)
		stackView.translatesAutoresizingMaskIntoConstraints = false

		let imageView = UIImageView()
		imageView.image = viewModel.image
		imageView.accessibilityLabel = viewModel.imageDescription
		imageView.isAccessibilityElement = true
		stackView.addArrangedSubview(imageView)
		stackView.setCustomSpacing(30, after: imageView)

		let titleLabel = ENALabel()
		titleLabel.style = .headline
		titleLabel.textColor = .enaColor(for: .textPrimary1)
		titleLabel.textAlignment = .center
		titleLabel.numberOfLines = 0
		titleLabel.adjustsFontSizeToFitWidth = true
		titleLabel.setContentCompressionResistancePriority(.required, for: .vertical)
		titleLabel.text = viewModel.title
		stackView.addArrangedSubview(titleLabel)

		let descriptionLabel = ENALabel()
		descriptionLabel.style = .subheadline
		descriptionLabel.textColor = .enaColor(for: .textPrimary2)
		descriptionLabel.textAlignment = .center
		descriptionLabel.numberOfLines = 0
		descriptionLabel.adjustsFontSizeToFitWidth = true
		descriptionLabel.setContentCompressionResistancePriority(.required, for: .vertical)
		descriptionLabel.text = viewModel.description
		stackView.addArrangedSubview(descriptionLabel)

		topConstraint = containerView.topAnchor.constraint(greaterThanOrEqualTo: topAnchor)

		NSLayoutConstraint.activate([
			containerView.leadingAnchor.constraint(greaterThanOrEqualTo: leadingAnchor),
			topConstraint,
			containerView.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor),
			containerView.bottomAnchor.constraint(lessThanOrEqualTo: bottomAnchor),
			stackView.widthAnchor.constraint(lessThanOrEqualToConstant: 280),
			stackView.leadingAnchor.constraint(greaterThanOrEqualTo: containerView.leadingAnchor, constant: 16),
			stackView.topAnchor.constraint(greaterThanOrEqualTo: containerView.topAnchor, constant: 16),
			stackView.trailingAnchor.constraint(lessThanOrEqualTo: containerView.trailingAnchor, constant: -16),
			stackView.bottomAnchor.constraint(lessThanOrEqualTo: containerView.bottomAnchor, constant: -16),
			stackView.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
			stackView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
			imageView.widthAnchor.constraint(equalTo: imageView.heightAnchor),
			imageView.widthAnchor.constraint(lessThanOrEqualToConstant: 200)
		])
	}

}
