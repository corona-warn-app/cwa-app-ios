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
		titleLabel.text = AppStrings.Home.MoreInfoCard.title

		var items: [MoreInfoItem] = []
		stackView.removeAllArrangedSubviews()
		
		if CWAHibernationProvider.shared.isHibernationState {
			items = MoreInfoItem.allCases.filter { $0 != .settings && $0 != .share }
		} else {
			items = MoreInfoItem.allCases
		}
		
		for item in items {
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
	}
	
	// MARK: - Private

	private var isCellConfigured = false
	
	@IBOutlet private weak var homeCardView: HomeCardView!
	@IBOutlet private weak var titleLabel: ENALabel!
	@IBOutlet private weak var stackView: UIStackView!
}
