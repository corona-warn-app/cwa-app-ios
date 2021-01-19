//
// 🦠 Corona-Warn-App
//

import Foundation
import UIKit

class DynamicTableViewIconCell: UITableViewCell {

	enum Text {
		case string(String)
		case attributedString(NSAttributedString)
	}

	// MARK: - Internal

	func configure(
		image: UIImage?,
		text: Text,
		customTintColor: UIColor?,
		style: ENAFont,
		iconWidth: CGFloat,
		selectionStyle: UITableViewCell.SelectionStyle,
		alignment: UIStackView.Alignment
	) {
		stackView.alignment = alignment

		if let customTintColor = customTintColor {
			imageView?.tintColor = customTintColor
			imageView?.image = image?.withRenderingMode(.alwaysTemplate)
		} else {
			imageView?.tintColor = tintColor
			imageView?.image = image?.withRenderingMode(.alwaysOriginal)
		}

		imageViewWidthConstraint.constant = iconWidth

		contentTextLabel.style = style.labelStyle

		switch text {
		case .string(let string):
			contentTextLabel.text = string
		case .attributedString(let attributedString):
			contentTextLabel.attributedText = attributedString
		}

		self.selectionStyle = selectionStyle
	}

	// MARK: - Private

	@IBOutlet private weak var stackView: UIStackView!
	@IBOutlet private weak var imageViewWidthConstraint: NSLayoutConstraint!
	@IBOutlet private weak var iconImageView: UIImageView!
	@IBOutlet private weak var contentTextLabel: ENALabel!

	override func prepareForReuse() {
		super.prepareForReuse()
		// hinding a stack views subview forces the stack view to update its layout
		// this is how we solve the layout bug when reusing stack views in table view cells
		iconImageView.isHidden = true
		contentTextLabel.isHidden = true
		stackView.setNeedsLayout()
		stackView.layoutIfNeeded()
		iconImageView.isHidden = false
		contentTextLabel.isHidden = false
	}
}
