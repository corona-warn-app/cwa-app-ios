//
// 🦠 Corona-Warn-App
//

import Foundation
import UIKit

@IBDesignable
class ExposureSubmissionImageCardCell: UITableViewCell {

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

	func configure(title: String, description: String, attributedDescription: NSAttributedString? = nil, image: UIImage?, accessibilityIdentifier: String?) {
		titleLabel.text = title
		descriptionLabel.text = description
		illustrationView?.image = image

		if let attributedDescription = attributedDescription {
			let attributedText = NSMutableAttributedString(attributedString: attributedDescription)
			descriptionLabel.attributedText = attributedText
		}

		cardView.accessibilityLabel = "\(title)\n\n\(description) \(attributedDescription?.string ?? "")"
		cardView.accessibilityIdentifier = accessibilityIdentifier
	}

	// MARK: - Private

	@IBOutlet private var cardView: UIView!
	@IBOutlet private var titleLabel: ENALabel!
	@IBOutlet private var descriptionLabel: ENALabel!
	@IBOutlet private var illustrationView: UIImageView!

	private var highlightView: UIView!

	private func setup() {
		selectionStyle = .none

		cardView.layer.cornerRadius = 16
		backgroundColor = .clear

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

}
