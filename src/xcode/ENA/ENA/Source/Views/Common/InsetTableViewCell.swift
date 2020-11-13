//
// 🦠 Corona-Warn-App
//

import Foundation
import UIKit

class InsetTableViewCell: UITableViewCell {
	@IBOutlet var insetContentView: InsetTableViewCellContentView!

	override func prepareForReuse() {
		super.prepareForReuse()
		insetContentView.primaryAction = nil
	}
}

@IBDesignable
class InsetTableViewCellContentView: UIView {
	var primaryAction: (() -> Void)?

	override func prepareForInterfaceBuilder() {
		super.prepareForInterfaceBuilder()
		awakeFromNib()
	}

	override func awakeFromNib() {
		super.awakeFromNib()

		layer.cornerRadius = 16
		layer.shadowRadius = 36
		layer.shadowColor = UIColor.black.cgColor
		layer.shadowOpacity = 0.15
		layer.shadowOffset = CGSize(width: 0, height: 10)
	}

	@IBAction func triggerPrimaryAction() {
		primaryAction?()
	}
}
