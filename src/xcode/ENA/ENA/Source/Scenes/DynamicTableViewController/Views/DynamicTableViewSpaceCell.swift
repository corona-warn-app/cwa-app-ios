//
// 🦠 Corona-Warn-App
//

import Foundation
import UIKit

class DynamicTableViewSpaceCell: UITableViewCell {
	private lazy var heightConstraint: NSLayoutConstraint = self.contentView.heightAnchor.constraint(equalToConstant: 0)

	override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
		super.init(style: style, reuseIdentifier: reuseIdentifier)
		setupView()
	}

	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

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

	private func setupView() {
		selectionStyle = .none
	}

	override func prepareForReuse() {
		super.prepareForReuse()

		height = UITableView.automaticDimension
		backgroundColor = nil
	}

	override func accessibilityElementCount() -> Int { 0 }

}
