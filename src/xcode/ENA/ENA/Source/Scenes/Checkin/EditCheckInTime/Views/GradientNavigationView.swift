////
// 🦠 Corona-Warn-App
//

import UIKit

class GradientNavigationView: UIView {

	// MARK: - Init

	init(
		didTapCloseButton: @escaping () -> Void
	) {
		self.didTapCloseButton = didTapCloseButton
		super.init(frame: .zero)
		setupView()
	}

	@available(*, unavailable)
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	// MARK: - Internal

	let closeButton = UIButton(type: .custom)

	// MARK: - Private

	private let didTapCloseButton: () -> Void

	private func setupView() {
		backgroundColor = .clear

		let logoImage = UIImage(imageLiteralResourceName: "Corona-Warn-App").withRenderingMode(.alwaysTemplate)
		let logoImageView = UIImageView(image: logoImage)
		logoImageView.tintColor = .enaColor(for: .textContrast)
		logoImageView.contentMode = .left

		closeButton.setImage(UIImage(named: "Icons - Close - Contrast"), for: .normal)
		closeButton.setImage(UIImage(named: "Icons - Close - Tap"), for: .highlighted)
		closeButton.accessibilityLabel = AppStrings.AccessibilityLabel.close
		closeButton.accessibilityIdentifier = AccessibilityIdentifiers.AccessibilityLabel.close
		closeButton.addTarget(self, action: #selector(didTapCloseButtonAction), for: .touchUpInside)

		let stackView = UIStackView(arrangedSubviews: [logoImageView, closeButton])
		stackView.translatesAutoresizingMaskIntoConstraints = false
		stackView.axis = .horizontal
		stackView.distribution = .fill
		stackView.alignment = .center
		addSubview(stackView)

		NSLayoutConstraint.activate(
			[
				stackView.topAnchor.constraint(equalTo: topAnchor),
				stackView.leadingAnchor.constraint(equalTo: leadingAnchor),
				stackView.trailingAnchor.constraint(equalTo: trailingAnchor),
				stackView.bottomAnchor.constraint(equalTo: bottomAnchor)
			]
		)
	}

	@objc
	private func didTapCloseButtonAction() {
		didTapCloseButton()
	}

}
