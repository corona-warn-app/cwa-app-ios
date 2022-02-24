////
// 🦠 Corona-Warn-App
//

import UIKit
import OpenCombine

class AddButtonAsTableViewCell: UITableViewCell, ReuseIdentifierProviding {

	// MARK: - Overrides

	override func awakeFromNib() {
		super.awakeFromNib()

		isAccessibilityElement = false
		containerView.isAccessibilityElement = true
		containerView.accessibilityTraits = .button

		setCellBackgroundColor()
	}

	override func prepareForReuse() {
		super.prepareForReuse()

		subscriptions = []
		cellModel = nil
	}

	override func setHighlighted(_ highlighted: Bool, animated: Bool) {
		super.setHighlighted(highlighted, animated: animated)
		if highlighted {
			containerView.backgroundColor = .enaColor(for: .listHighlight)
		} else {
			containerView.backgroundColor = cellBackgroundColor
		}
	}

	// MARK: - Internal

	func configure(cellModel: AddButtonAsTableViewCelling) {
		label.text = cellModel.text
		containerView.accessibilityLabel = cellModel.text
		
		cellModel.iconImagePublisher
			.assign(to: \.image, on: iconImageView)
			.store(in: &subscriptions)

		cellModel.textColorPublisher
			.assign(to: \.textColor, on: label)
			.store(in: &subscriptions)

		cellModel.accessibilityTraitsPublisher
			.assign(to: \.accessibilityTraits, on: self)
			.store(in: &subscriptions)
		
		cellModel.isCustomAccessoryViewHiddenPublisher
			.assign(to: \.isHidden, on: customAccessoryView)
			.store(in: &subscriptions)
	
		// Retaining cell model so it gets updated
		self.cellModel = cellModel
	}

	// MARK: - Private

	@IBOutlet private weak var containerView: UIView!
	@IBOutlet private weak var iconImageView: UIImageView!
	@IBOutlet private weak var customAccessoryView: UIImageView!
	@IBOutlet private weak var label: ENALabel!

	private var subscriptions = Set<AnyCancellable>()

	private var cellModel: AddButtonAsTableViewCelling?
	private var cellBackgroundColor: UIColor = .enaColor(for: .cellBackground)

	private func setCellBackgroundColor() {
		if #available(iOS 13.0, *) {
			if traitCollection.userInterfaceLevel == .elevated {
				cellBackgroundColor = .enaColor(for: .cellBackground3)
			} else {
				cellBackgroundColor = .enaColor(for: .cellBackground)
			}
		}

		containerView.backgroundColor = cellBackgroundColor
	}
    
}
