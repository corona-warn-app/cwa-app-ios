//
// 🦠 Corona-Warn-App
//

import UIKit
import OpenCombine

class HomeAppClosureNoticeTableViewCell: UITableViewCell {

	// MARK: - Overrides

	override func awakeFromNib() {
		super.awakeFromNib()

		isAccessibilityElement = false
		cardView.isAccessibilityElement = true
		cardView.accessibilityTraits = .button
	}

	override func setHighlighted(_ highlighted: Bool, animated: Bool) {
		super.setHighlighted(highlighted, animated: animated)

		cardView.setHighlighted(highlighted, animated: animated)
	}

	// MARK: - Internal

	func configure(with cellModel: HomeAppClosureNoticeCellModel) {
		cellModel.$title.assign(to: \.text, on: titleLabel).store(in: &subscriptions)
		cellModel.$title.assign(to: \.accessibilityLabel, on: cardView).store(in: &subscriptions)
		cellModel.$subtitle.assign(to: \.text, on: subtitleLabel).store(in: &subscriptions)
		cellModel.$subtitle.assign(to: \.accessibilityLabel, on: cardView).store(in: &subscriptions)
		cellModel.$icon.assign(to: \.image, on: iconImageView).store(in: &subscriptions)
		cellModel.$accessibilityIdentifier.assign(to: \.accessibilityIdentifier, on: self).store(in: &subscriptions)

		// Retaining cell model so it gets updated
		self.cellModel = cellModel
	}

	// MARK: - Private

	@IBOutlet private var iconImageView: UIImageView!
	@IBOutlet private var titleLabel: UILabel!
	@IBOutlet private var subtitleLabel: UILabel!
	@IBOutlet private var cardView: HomeCardView!

	private var subscriptions = Set<AnyCancellable>()
	private var cellModel: HomeAppClosureNoticeCellModel?

}
