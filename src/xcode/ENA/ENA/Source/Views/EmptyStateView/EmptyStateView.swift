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

	init(viewModel: EmptyStateViewModel, safeInsetTop: CGFloat = 0, safeInsetBottom: CGFloat = 0, alignmentPadding: CGFloat = 0) {
		self.viewModel = viewModel
		self.safeInsetTop = safeInsetTop
		self.safeInsetBottom = safeInsetBottom
		self.alignmentPadding = alignmentPadding

		super.init(frame: .zero)

		setUp()
	}

	// MARK: - Internal

	// MARK: - Private

	private let viewModel: EmptyStateViewModel
	private let safeInsetTop: CGFloat
	private let safeInsetBottom: CGFloat
	private let alignmentPadding: CGFloat

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
		titleLabel.numberOfLines = 1
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
		let maxImageWidth = UIScreen.main.bounds.width / 3
		let minImageWidth = UIScreen.main.bounds.width / 10

		// layout strategy / required constraints:
		// stack view with full width (with margin) for effective horizontal centered alignment.
		// keep the text on the visible page (this visible page is configurable by the caller).
		// limit size of title
		// keep aspect ratio of the image; shrink it if needed, or push it above visible page
		NSLayoutConstraint.activate([
			stackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
			stackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
			stackView.bottomAnchor.constraint(lessThanOrEqualTo: bottomAnchor, constant: -(safeInsetBottom + 16)),
			titleLabel.topAnchor.constraint(greaterThanOrEqualTo: topAnchor, constant: safeInsetTop + 16),
			titleLabel.widthAnchor.constraint(lessThanOrEqualToConstant: 280),
			imageView.widthAnchor.constraint(equalTo: imageView.heightAnchor),
			imageView.widthAnchor.constraint(lessThanOrEqualToConstant: maxImageWidth),
			imageView.widthAnchor.constraint(greaterThanOrEqualToConstant: minImageWidth)
		])

		// additional layout strategy for a pleasant layout:
		// break these constraints for extreme screen or extreme font sizes (a11y).

		// align the appearance of this view across pages.
		let topAlignmentConstraint = stackView.topAnchor.constraint(equalTo: topAnchor, constant: alignmentPadding + 16)
		topAlignmentConstraint.priority = UILayoutPriority(997)
		topAlignmentConstraint.isActive = true

		// image: 1/3 of the screen width
		let imageSizeConstraint = imageView.widthAnchor.constraint(equalToConstant: maxImageWidth)
		imageSizeConstraint.priority = UILayoutPriority(998)
		imageSizeConstraint.isActive = true

		// if it really doesn't fit on the visible page, then sacrifice the image
		let topAnchorConstraint = stackView.topAnchor.constraint(greaterThanOrEqualTo: topAnchor, constant: safeInsetTop + 16)
		topAnchorConstraint.priority = UILayoutPriority(999)
		topAnchorConstraint.isActive = true
	}
}
