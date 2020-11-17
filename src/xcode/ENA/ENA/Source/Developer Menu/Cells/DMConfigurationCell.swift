//
// 🦠 Corona-Warn-App
//

import UIKit

#if !RELEASE

class DMConfigurationCell: UITableViewCell {
	static var reuseIdentifier = "DMConfigurationCell"
	override init(style _: UITableViewCell.CellStyle, reuseIdentifier: String?) {
		super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
	}

	@available(*, unavailable)
	required init?(coder _: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
}

#endif
