//
// 🦠 Corona-Warn-App
//

import Foundation
import UIKit

class DynamicTableViewSpaceCell: UITableViewCell {
	private lazy var heightConstraint: NSLayoutConstraint = self.contentView.heightAnchor.constraint(equalToConstant: 0)

	var height: CGFloat {
		get { heightConstraint.isActive ? heightConstraint.constant : UITableView.automaticDimension }
		set {
			if newValue == UITableView.automaticDimension {
				heightConstraint.isActive = false
			} else {
				if newValue <= 0 {
					heightConstraint.constant = .leastNonzeroMagnitude
				} else {
					heightConstraint.constant = newValue
				}
				heightConstraint.isActive = true
			}
		}
	}

	override func prepareForReuse() {
		super.prepareForReuse()

		height = UITableView.automaticDimension
		backgroundColor = nil
	}

	override func accessibilityElementCount() -> Int { 0 }

}
