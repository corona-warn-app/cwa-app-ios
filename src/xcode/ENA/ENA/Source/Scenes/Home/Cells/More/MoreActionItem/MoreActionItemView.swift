//
// 🦠 Corona-Warn-App
//

import UIKit

class MoreActionItemView: UIView {
	
	// MARK: - Overrides

	override func awakeFromNib() {
		super.awakeFromNib()
		
		longPressGestureRecognizer.minimumPressDuration = 0.1
		
		configureHighlightView()
	}
	
	// MARK: - Internal
	
	func configure(
		actionItem: MoreInfoItem,
		completion: @escaping ((MoreInfoItem) -> Void)
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
	@IBOutlet private weak var separatorView: UIView!
	@IBOutlet private weak var longPressGestureRecognizer: UILongPressGestureRecognizer!
	
	private var actionItem: MoreInfoItem?
	private var completion: ((MoreInfoItem) -> Void)?
	private let highlightView = UIView()
	
	@IBAction private func didTap(_ sender: Any) {
		guard let item = actionItem else {
			return
		}
		completion?(item)
	}
	
	@IBAction private func didHighlight(_ sender: UILongPressGestureRecognizer) {
		if sender.state == .began {
			highlightView.backgroundColor = .enaColor(for: .listHighlight)
		} else if sender.state == .ended {
			highlightView.backgroundColor = .clear
			guard let item = actionItem else {
				return
			}
			completion?(item)
		}
	}
	
	private func configureHighlightView() {
		highlightView.backgroundColor = .clear
		highlightView.isUserInteractionEnabled = false

		addSubview(highlightView)
		highlightView.translatesAutoresizingMaskIntoConstraints = false

		NSLayoutConstraint.activate([
			highlightView.leadingAnchor.constraint(equalTo: leadingAnchor),
			highlightView.topAnchor.constraint(equalTo: topAnchor),
			highlightView.trailingAnchor.constraint(equalTo: trailingAnchor),
			highlightView.bottomAnchor.constraint(equalTo: bottomAnchor)
		])
	}
}
