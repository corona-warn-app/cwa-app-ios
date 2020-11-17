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

	// MARK: - Overrides

	override func awakeFromNib() {
		super.awakeFromNib()
		imageView?.tintColor = tintColor
	}

	// MARK: - Internal

	func configure(image: UIImage?, text: Text, tintColor: UIColor?, style: ENAFont = .body, iconWidth: CGFloat, selectionStyle: UITableViewCell.SelectionStyle) {
		if let tintColor = tintColor {
			imageView?.tintColor = tintColor
			imageView?.image = image?.withRenderingMode(.alwaysTemplate)
		} else {
			imageView?.image = image?.withRenderingMode(.alwaysOriginal)
		}

		(textLabel as? ENALabel)?.style = style.labelStyle

		switch text {
		case .string(let string):
			textLabel?.text = string
		case .attributedString(let attributedString):
			textLabel?.attributedText = attributedString
		}

		imageViewWidthConstraint.constant = iconWidth

		self.selectionStyle = selectionStyle
	}

	// MARK: - Private

	@IBOutlet private weak var imageViewWidthConstraint: NSLayoutConstraint!

}
