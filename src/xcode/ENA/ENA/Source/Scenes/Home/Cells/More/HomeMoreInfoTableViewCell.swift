//
// 🦠 Corona-Warn-App
//

import UIKit

class HomeMoreInfoTableViewCell: UITableViewCell {
	
	// MARK: - Overrides
	
	override func awakeFromNib() {
		super.awakeFromNib()
		
		self.accessibilityIdentifier = AccessibilityIdentifiers.Home.MoreInfoCell.moreCell
	}
	
	// MARK: - Internal
	
	func configure(completion: @escaping ((MoreInfoItem) -> Void)) {
		if !isCellConfigured {
			for item in MoreInfoItem.allCases {
				let nibName = String(describing: MoreActionItemView.self)
				let nib = UINib(nibName: nibName, bundle: .main)
				
				if let actionItemView = nib.instantiate(withOwner: self, options: nil).first as? MoreActionItemView {
					actionItemView.configure(actionItem: item) { selectedItem in
						completion(selectedItem)
					}
					stackView.addArrangedSubview(actionItemView)
				}
			}
			isCellConfigured = true
		}
	}
	
	// MARK: - Private

	private var isCellConfigured = false
	
	@IBOutlet private weak var homeCardView: HomeCardView!
	@IBOutlet private weak var titleLabel: ENALabel!
	@IBOutlet private weak var stackView: UIStackView!
}
