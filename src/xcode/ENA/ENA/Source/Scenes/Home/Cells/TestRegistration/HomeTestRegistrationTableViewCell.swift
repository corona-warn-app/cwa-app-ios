//
// 🦠 Corona-Warn-App
//

import UIKit
import OpenCombine

final class HomeTestRegistrationTableViewCell: UITableViewCell {

	// MARK: - Overrides

	override func prepareForInterfaceBuilder() {
		super.prepareForInterfaceBuilder()

		setup()
	}

	override func awakeFromNib() {
		super.awakeFromNib()

		setup()
	}
	
	override func layoutSubviews() {
		super.layoutSubviews()
		
		gradientView.roundCorners(corners: [.topLeft, .topRight], radius: 16)
	}

	override func setHighlighted(_ highlighted: Bool, animated: Bool) {
		super.setHighlighted(highlighted, animated: animated)

		cardView.setHighlighted(highlighted, animated: animated)
	}

	override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
		super.traitCollectionDidChange(previousTraitCollection)

		updateIllustration(for: traitCollection)
	}

	// MARK: - Internal

	func configure(with cellModel: HomeTestRegistrationCellModel, onPrimaryAction: @escaping () -> Void) {
		gradientView.type = cellModel.gradientViewType
		titleLabel.text = cellModel.title
		subtitleLabel.text = cellModel.subtitle
		descriptionLabel.text = cellModel.description
		illustrationView.image = cellModel.image

		button.setTitle(cellModel.buttonTitle, for: .normal)
		button.accessibilityIdentifier = cellModel.buttonAccessibilityIdentifier

		self.tintColor = tintColor

		self.onPrimaryAction = onPrimaryAction
	}

	// MARK: - Private

	
	@IBOutlet private var gradientView: GradientView!
	@IBOutlet private var titleLabel: ENALabel!
	@IBOutlet private var subtitleLabel: ENALabel!
	@IBOutlet private var descriptionLabel: ENALabel!
	@IBOutlet private var illustrationView: UIImageView!
	@IBOutlet private var button: ENAButton!
	@IBOutlet weak var cardView: HomeCardView!

	private var onPrimaryAction: (() -> Void)?

	private func setup() {
		updateIllustration(for: traitCollection)
		clipsToBounds = false

		setupAccessibility()
	}

	private func updateIllustration(for traitCollection: UITraitCollection) {
		if traitCollection.preferredContentSizeCategory >= .accessibilityLarge {
			illustrationView.isHidden = true
		} else {
			illustrationView.isHidden = false
		}
	}

	private func setupAccessibility() {
		cardView.accessibilityElements = [titleLabel as Any, descriptionLabel as Any, button as Any]

		titleLabel.accessibilityTraits = [.header, .button]
	}

	@IBAction private func primaryActionTriggered() {
		onPrimaryAction?()
	}

}

extension UIView {
   func roundCorners(corners: UIRectCorner, radius: CGFloat) {
		let path = UIBezierPath(
			roundedRect: bounds,
			byRoundingCorners: corners,
			cornerRadii: CGSize(width: radius, height: radius)
		)
		let mask = CAShapeLayer()
		mask.path = path.cgPath
		layer.mask = mask
	}
}
