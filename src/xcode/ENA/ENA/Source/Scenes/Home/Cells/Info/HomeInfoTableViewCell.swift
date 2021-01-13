//
// 🦠 Corona-Warn-App
//

import UIKit

class HomeInfoTableViewCell: UITableViewCell {

	// MARK: - Overrides

	override func awakeFromNib() {
		super.awakeFromNib()

		backgroundColor = .enaColor(for: .background)

		topDividerView.backgroundColor = ColorCompatibility.secondaryLabel.withAlphaComponent(0.3)
		bottomDividerView.backgroundColor = ColorCompatibility.secondaryLabel.withAlphaComponent(0.3)

		setupAccessibility()
	}

	// MARK: - Internal

	@IBOutlet var topDividerView: UIView!
	@IBOutlet var bottomDividerView: UIView!
	@IBOutlet var bottomDividerLeadingConstraint: NSLayoutConstraint!

	func configure(with cellModel: HomeInfoCellModel) {
		titleLabel.text = cellModel.title
		bodyLabel.text = cellModel.description

		bodyLabel.isHidden = cellModel.description == nil

		if let description = cellModel.description {
			accessibilityLabel = "\(cellModel.title)\n\n\(description)"
		} else {
			accessibilityLabel = "\(cellModel.title)"
		}

		self.accessibilityIdentifier = cellModel.accessibilityIdentifier

		configureBorders(for: cellModel.position)
	}

	// MARK: - Private

	@IBOutlet private var chevronImageView: UIImageView!
	@IBOutlet private var titleLabel: UILabel!
	@IBOutlet private var bodyLabel: UILabel!

	private func setupAccessibility() {
		isAccessibilityElement = true
		accessibilityTraits = .button
	}

	private func configureBorders(for position: CellPositionInSection) {
		switch position {
		case .first:
			topDividerView.isHidden = false
			bottomDividerLeadingConstraint.constant = 15.0
		case .other:
			topDividerView.isHidden = true
			bottomDividerLeadingConstraint.constant = 15.0
		case .last:
			topDividerView.isHidden = true
			bottomDividerLeadingConstraint.constant = 0.0
		}
	}

}
