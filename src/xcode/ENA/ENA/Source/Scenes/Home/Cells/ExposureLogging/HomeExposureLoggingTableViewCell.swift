//
// 🦠 Corona-Warn-App
//

import UIKit
import OpenCombine

class HomeExposureLoggingTableViewCell: UITableViewCell {

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

	func configure(with cellModel: HomeExposureLoggingCellModel) {
		cellModel.$title.assign(to: \.text, on: titleLabel).store(in: &subscriptions)
		cellModel.$title.assign(to: \.accessibilityLabel, on: cardView).store(in: &subscriptions)
		cellModel.$icon.assign(to: \.image, on: iconImageView).store(in: &subscriptions)
		cellModel.$accessibilityIdentifier.assign(to: \.accessibilityIdentifier, on: self).store(in: &subscriptions)

		cellModel.$animationImages
			.sink { [weak self] animationImages in
				guard let self = self else { return }

				if let animationImages = animationImages {
					self.iconImageView.animationImages = animationImages
					self.iconImageView.animationDuration = Double(animationImages.count) / 30

					if !self.iconImageView.isAnimating {
						self.iconImageView.startAnimating()
					}
				} else if self.iconImageView.isAnimating {
					self.iconImageView.stopAnimating()
				}
			}
			.store(in: &subscriptions)

		// Retaining cell model so it gets updated
		self.cellModel = cellModel
	}

	// MARK: - Private

	@IBOutlet private var iconImageView: UIImageView!
	@IBOutlet private var titleLabel: UILabel!
	@IBOutlet private var cardView: HomeCardView!

	private var subscriptions = Set<AnyCancellable>()
	private var cellModel: HomeExposureLoggingCellModel?

}
