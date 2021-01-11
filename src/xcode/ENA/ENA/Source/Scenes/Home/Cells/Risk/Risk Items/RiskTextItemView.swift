//
// 🦠 Corona-Warn-App
//

import UIKit

final class RiskTextItemView: UIView, RiskItemView, RiskItemViewSeparatorable {
	@IBOutlet var titleLabel: ENALabel!
	@IBOutlet var separatorView: UIView!

	private let titleTopPadding: CGFloat = 8.0

	override func awakeFromNib() {
		super.awakeFromNib()
		layoutMargins = .init(top: titleTopPadding, left: 0, bottom: titleTopPadding, right: 0)
	}

	func hideSeparator() {
		separatorView.isHidden = true
	}
}
