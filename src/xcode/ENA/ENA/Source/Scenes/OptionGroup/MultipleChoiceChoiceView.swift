//
// 🦠 Corona-Warn-App
//

import UIKit
import OpenCombine

class MultipleChoiceChoiceView: UIControl {

	// MARK: - Init

	@available(*, unavailable)
	override init(frame: CGRect) {
		fatalError("init(frame:) has not been implemented")
	}

	@available(*, unavailable)
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	init(iconImage: UIImage?, title: String, accessibilityIdentifier: String? = nil, onTap: @escaping () -> Void) {
		self.onTap = onTap

		super.init(frame: .zero)

		setUp(iconImage: iconImage, title: title)
		self.accessibilityIdentifier = accessibilityIdentifier
	}

	// MARK: - Overrides

	override var isSelected: Bool {
		didSet {
			updateForSelectionState()
		}
	}

	override func endTracking(_ touch: UITouch?, with event: UIEvent?) {
		super.endTracking(touch, with: event)

		onTap()
	}

	override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
		super.traitCollectionDidChange(previousTraitCollection)

		updateForCurrentTraitCollection()
	}

	// MARK: - Private

	private let onTap: () -> Void

	private let checkmarkImageView = UIImageView()
	private let iconImageView = UIImageView()

	private func setUp(iconImage: UIImage?, title: String) {
		backgroundColor = UIColor.enaColor(for: .background)

		let contentStackView = UIStackView()
		contentStackView.axis = .horizontal
		contentStackView.alignment = .center
		contentStackView.translatesAutoresizingMaskIntoConstraints = false
		addSubview(contentStackView)

		NSLayoutConstraint.activate([
			contentStackView.leadingAnchor.constraint(equalTo: leadingAnchor),
			contentStackView.trailingAnchor.constraint(equalTo: trailingAnchor),
			contentStackView.topAnchor.constraint(equalTo: topAnchor, constant: 11),
			contentStackView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -11)
		])

		checkmarkImageView.adjustsImageSizeForAccessibilityContentSizeCategory = true
		checkmarkImageView.setContentHuggingPriority(.required, for: .horizontal)
		checkmarkImageView.setContentCompressionResistancePriority(.required, for: .horizontal)

		contentStackView.addArrangedSubview(checkmarkImageView)
		contentStackView.setCustomSpacing(21, after: checkmarkImageView)

		if let iconImage = iconImage {
			iconImageView.image = iconImage
			iconImageView.contentMode = .scaleAspectFit

			NSLayoutConstraint.activate([
				iconImageView.widthAnchor.constraint(equalToConstant: 24),
				iconImageView.heightAnchor.constraint(equalToConstant: 16)
			])

			contentStackView.addArrangedSubview(iconImageView)
			contentStackView.setCustomSpacing(15, after: iconImageView)
		}

		let label = ENALabel()
		label.numberOfLines = 0
		label.text = title
		label.style = .body

		contentStackView.addArrangedSubview(label)

		let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(viewTapped))
		addGestureRecognizer(tapGestureRecognizer)

		updateForSelectionState()
		updateForCurrentTraitCollection()

		isAccessibilityElement = true
		accessibilityLabel = title
	}

	@objc
	private func viewTapped() {
		onTap()
	}

	private func updateForSelectionState() {
		checkmarkImageView.image = isSelected ? UIImage(named: "Checkmark_Selected") : UIImage(named: "Checkmark_Unselected")

		accessibilityTraits = isSelected ? [.button, .selected] : [.button]
	}

	private func updateForCurrentTraitCollection() {
		iconImageView.isHidden = traitCollection.preferredContentSizeCategory.isAccessibilityCategory
	}

}
