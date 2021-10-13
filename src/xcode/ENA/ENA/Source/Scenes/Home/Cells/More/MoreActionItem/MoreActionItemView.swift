//
// 🦠 Corona-Warn-App
//

import UIKit

class MoreActionItemView: UIView {
	
	// MARK: - Overrides

	override func awakeFromNib() {
		super.awakeFromNib()
		
		longPressGestureRecognizer.minimumPressDuration = 0.1
	}
	
	// MARK: - Internal
	
	func configure(
		actionItem: MoreActionItem,
		completion: @escaping ((MoreActionItem) -> Void)
	) {
		self.imageView.image = actionItem.image
		self.titleLabel.text = actionItem.title
		self.titleLabel.accessibilityIdentifier = actionItem.accessibilityIdentifier
		self.separatorView.isHidden = actionItem == .share
		self.actionItem = actionItem
		self.completion = completion
	}
	
	// MARK: - Private
	
	@IBOutlet private weak var titleLabel: ENALabel!
	@IBOutlet private weak var imageView: UIImageView!
	@IBOutlet weak var separatorView: UIView!
	@IBOutlet private weak var longPressGestureRecognizer: UILongPressGestureRecognizer!
	
	private var actionItem: MoreActionItem?
	private var completion: ((MoreActionItem) -> Void)?
}
