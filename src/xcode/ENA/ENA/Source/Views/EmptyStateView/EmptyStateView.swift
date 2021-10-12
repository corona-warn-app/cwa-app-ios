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

	init(viewModel: EmptyStateViewModel, additionalTopPadding: CGFloat = 0) {
		self.viewModel = viewModel
		self.additionalTopPadding = additionalTopPadding

		super.init(frame: .zero)

		setUp()
	}

	// MARK: - Internal

	// MARK: - Private

	private let viewModel: EmptyStateViewModel
	private let additionalTopPadding: CGFloat

	private func setUp() {
		backgroundColor = .clear

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

		// We take a number for that the image is not too big and not too small and fits for big and small devices for all five occurrences of the EmptyStateView
		// (in CertificatesOverview, CheckinOverview, TraceLocationsOverview, ContactDiaryDay, OnBehalfWarning).
		// The result was 3.
		let percentageWidth = UIScreen.main.bounds.width / 3

		// layout strategy:
		// stack view with full width (with margin) for effective horizontal centered alignment.
		// top-aligned (with margin) to align the appearance of this view across pages.
		// the view controller can configure its position with the additionalTopPadding.
		// multiline text box (descriptionLabel) with width 280.
		// image: 1/3 of the screen width if possible, but else shrink it to avoid that the layout exceeds the visible page.
		NSLayoutConstraint.activate([
			imageView.widthAnchor.constraint(equalTo: imageView.heightAnchor),
			imageView.widthAnchor.constraint(lessThanOrEqualToConstant: percentageWidth),
			descriptionLabel.widthAnchor.constraint(lessThanOrEqualToConstant: 280),
			stackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
			stackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
			stackView.topAnchor.constraint(equalTo: topAnchor, constant: additionalTopPadding + 16),
			stackView.bottomAnchor.constraint(lessThanOrEqualTo: bottomAnchor, constant: -16)
		])
		// break the following constraints in case of conflicts
		let descriptionWidthConstraint = descriptionLabel.widthAnchor.constraint(equalToConstant: 280)
		descriptionWidthConstraint.priority = UILayoutPriority(998)
		descriptionWidthConstraint.isActive = true

		let imageSizeConstraint = imageView.widthAnchor.constraint(equalToConstant: percentageWidth)
		imageSizeConstraint.priority = UILayoutPriority(999)
		imageSizeConstraint.isActive = true
	}

}
