//
// 🦠 Corona-Warn-App
//

import UIKit

final class DMNotificationCell: UITableViewCell {
	
	// MARK: - Init
	
	override init(style _: UITableViewCell.CellStyle, reuseIdentifier: String?) {
		super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
		textLabel?.lineBreakMode = .byTruncatingMiddle
	}

	@available(*, unavailable)
	required init?(coder _: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	// MARK: - Internal
	
	static var reuseIdentifier = "DMNotificationCell"

	
}
