//
// 🦠 Corona-Warn-App
//

import UIKit

class HomeMoreTableViewCell: UITableViewCell {
	
	// MARK: - Overrides
	
	override func awakeFromNib() {
		super.awakeFromNib()
		
		self.accessibilityIdentifier = AccessibilityIdentifiers.Home.MoreCell.moreCell
	}
	
	// MARK: - Internal
	
	func configure(completion: @escaping ((MoreActionItem) -> Void)) {
		if !isConfigerd {
			for item in MoreActionItem.allCases {
				let nibName = String(describing: MoreActionItemView.self)
				let nib = UINib(nibName: nibName, bundle: .main)
				
				if let actionItemView = nib.instantiate(withOwner: self, options: nil).first as? MoreActionItemView {
					actionItemView.configure(actionItem: item) { selectedItem in
						completion(selectedItem)
					}
					stackView.addArrangedSubview(actionItemView)
				}
			}
			isConfigerd = true
		}
	}
	
	// MARK: - Private

	private var isConfigerd = false
	
	@IBOutlet private weak var homeCardView: HomeCardView!
	@IBOutlet private weak var titleLabel: ENALabel!
	@IBOutlet private weak var stackView: UIStackView!
}
