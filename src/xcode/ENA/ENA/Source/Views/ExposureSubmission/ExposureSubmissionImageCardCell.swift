//
// 🦠 Corona-Warn-App
//

import Foundation
import UIKit

@IBDesignable
class ExposureSubmissionImageCardCell: UITableViewCell {

	enum ImageLayout {
		case right
		case center
	}
	
	// MARK: - Overrides

	override func setHighlighted(_ highlighted: Bool, animated: Bool) {
		super.setHighlighted(highlighted, animated: animated)

		highlightView?.isHidden = !highlighted
	}

	override func prepareForInterfaceBuilder() {
		super.prepareForInterfaceBuilder()

		guard nil != cardView else { return }
		setup()
	}

	override func awakeFromNib() {
		super.awakeFromNib()

		setup()
	}

	override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
		super.traitCollectionDidChange(previousTraitCollection)

		updateIllustration(for: traitCollection)
	}

	// MARK: - Internal

	func configure(
		title: String,
		description: String,
		attributedDescription: NSAttributedString? = nil,
		image: UIImage?,
		imageLayout: ImageLayout = .right,
		backgroundView bgView: UIView? = nil,
		textColor: UIColor? = nil,
		accessibilityIdentifier: String?
	) {
		titleLabel.text = title
		descriptionLabel.text = description
		illustrationView?.image = image

		titleLabel.textColor = textColor ?? .enaColor(for: .textPrimary1)
		descriptionLabel.textColor = textColor ?? .enaColor(for: .textPrimary1)

		if let bgView = bgView {
			addBackgroundView(bgView)
		} else {
			removeBackgrundView()
		}

		if let attributedDescription = attributedDescription {
			let attributedText = NSMutableAttributedString(attributedString: attributedDescription)
			descriptionLabel.attributedText = attributedText
		}

		switch imageLayout {
		case .right:
			imageAndDescriptionStackView.addArrangedSubview(descriptionLabelContainer)
			imageAndDescriptionStackView.addArrangedSubview(illustrationContainer)
			imageAndDescriptionStackView.axis = .horizontal
		case .center:
			imageAndDescriptionStackView.addArrangedSubview(illustrationContainer)
			imageAndDescriptionStackView.addArrangedSubview(descriptionLabelContainer)
			imageAndDescriptionStackView.axis = .vertical
		}

		cardView.accessibilityLabel = "\(title)\n\n\(description) \(attributedDescription?.string ?? "")"
		cardView.accessibilityIdentifier = accessibilityIdentifier
	}

	// MARK: - Private

	@IBOutlet private var cardView: UIView!
	@IBOutlet private var titleLabel: ENALabel!
	@IBOutlet private var descriptionLabel: ENALabel!
	@IBOutlet private var illustrationView: UIImageView!
	@IBOutlet private var cardBackgroundContainer: UIView!
	@IBOutlet private var imageAndDescriptionStackView: UIStackView!
	@IBOutlet private var descriptionLabelContainer: UIView!
	@IBOutlet private var illustrationContainer: UIView!

	private var highlightView: UIView!

	private func setup() {
		selectionStyle = .none

		cardView.layer.cornerRadius = 16
		backgroundColor = .enaColor(for: .background)

		highlightView?.removeFromSuperview()
		highlightView = UIView(frame: bounds)
		highlightView.isHidden = !isHighlighted
		highlightView.backgroundColor = .enaColor(for: .listHighlight)
		highlightView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
		cardView.addSubview(highlightView)

		updateIllustration(for: traitCollection)

		isAccessibilityElement = false
		cardView.isAccessibilityElement = true
		cardView.accessibilityTraits = .button
	}

	private func updateIllustration(for traitCollection: UITraitCollection) {
		if traitCollection.preferredContentSizeCategory >= .accessibilityLarge {
			illustrationView.superview?.isHidden = true
		} else {
			illustrationView.superview?.isHidden = false
		}
	}
	
	private func removeBackgrundView() {
		cardBackgroundContainer.subviews.forEach { $0.removeFromSuperview() }
	}

	private func addBackgroundView(_ bgView: UIView) {
		removeBackgrundView()
		cardBackgroundContainer.addSubview(bgView)

		bgView.translatesAutoresizingMaskIntoConstraints = false
		NSLayoutConstraint.activate([
			bgView.leadingAnchor.constraint(equalTo: cardBackgroundContainer.leadingAnchor),
			bgView.topAnchor.constraint(equalTo: cardBackgroundContainer.topAnchor),
			bgView.trailingAnchor.constraint(equalTo: cardBackgroundContainer.trailingAnchor),
			bgView.bottomAnchor.constraint(equalTo: cardBackgroundContainer.bottomAnchor)
		])
	}
}
