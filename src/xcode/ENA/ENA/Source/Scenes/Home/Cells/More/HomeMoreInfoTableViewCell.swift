//
// 🦠 Corona-Warn-App
//

import UIKit

class HomeMoreInfoTableViewCell: UITableViewCell {
	
	// MARK: - Overrides
	
	override func awakeFromNib() {
		super.awakeFromNib()
		
		accessibilityIdentifier = AccessibilityIdentifiers.Home.MoreInfoCell.moreCell
		isAccessibilityElement = false


	}
	
	// MARK: - Internal
	
	func configure(onItemTap: @escaping ((MoreInfoItem) -> Void)) {
		guard !isCellConfigured else {
			return
		}

		titleLabel.text = AppStrings.Home.MoreInfoCard.title

		for item in MoreInfoItem.allCases {
			let nibName = String(describing: MoreActionItemView.self)
			let nib = UINib(nibName: nibName, bundle: .main)

			if let actionItemView = nib.instantiate(withOwner: self, options: nil).first as? MoreActionItemView {
				actionItemView.configure(actionItem: item) { selectedItem in
					onItemTap(selectedItem)
				}
				stackView.addArrangedSubview(actionItemView)
			}
		}

		accessibilityElements = [titleLabel as Any] + stackView.arrangedSubviews

		isCellConfigured = true
	}
	
	// MARK: - Private

	private var isCellConfigured = false
	
	@IBOutlet private weak var homeCardView: HomeCardView!
	@IBOutlet private weak var titleLabel: ENALabel!
	@IBOutlet private weak var stackView: UIStackView!
}
