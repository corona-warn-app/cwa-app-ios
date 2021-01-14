////
// 🦠 Corona-Warn-App
//

import UIKit

class HomeStatisticsTableViewCell: UITableViewCell {

	// MARK: - Overrides

    override func awakeFromNib() {
        super.awakeFromNib()

		self.addGestureRecognizer(scrollView.panGestureRecognizer)
    }

	// MARK: - Internal

	func configure(onInfoButtonTap: @escaping () -> Void, onAccessibilityFocus: @escaping () -> Void) {
		guard !isConfigured else { return }

		stackView.arrangedSubviews.forEach { $0.removeFromSuperview() }

		for index in 0...3 {
			let nibName = String(describing: HomeStatisticsCardView.self)
			let nib = UINib(nibName: nibName, bundle: .main)

			if let statisticsCardView = nib.instantiate(withOwner: self, options: nil).first as? HomeStatisticsCardView, let card = HomeStatisticsCardViewModel.Card(rawValue: index) {
				stackView.addArrangedSubview(statisticsCardView)

				statisticsCardView.widthAnchor.constraint(equalTo: scrollView.widthAnchor).isActive = true
				statisticsCardView.configure(
					viewModel: HomeStatisticsCardViewModel(for: card),
					onInfoButtonTap: {
						onInfoButtonTap()
					},
					onAccessibilityFocus: { [weak self] in
						self?.scrollView.scrollRectToVisible(statisticsCardView.frame, animated: false)
						onAccessibilityFocus()
						UIAccessibility.post(notification: .layoutChanged, argument: nil)
					}
				)

				let cardViewCount = stackView.arrangedSubviews.count
				if cardViewCount > 1, let previousCardView = stackView.arrangedSubviews[cardViewCount - 2] as? HomeStatisticsCardView {
					NSLayoutConstraint.activate([
						statisticsCardView.titleLabel.firstBaselineAnchor.constraint(equalTo: previousCardView.titleLabel.firstBaselineAnchor),
						statisticsCardView.primaryTitleLabel.firstBaselineAnchor.constraint(equalTo: previousCardView.primaryTitleLabel.firstBaselineAnchor),
						statisticsCardView.secondaryTitleLabel.firstBaselineAnchor.constraint(equalTo: previousCardView.secondaryTitleLabel.firstBaselineAnchor),
						statisticsCardView.tertiaryTitleLabel.firstBaselineAnchor.constraint(equalTo: previousCardView.tertiaryTitleLabel.firstBaselineAnchor),
						statisticsCardView.footnoteLabel.firstBaselineAnchor.constraint(equalTo: previousCardView.footnoteLabel.firstBaselineAnchor)
					])
				}
			}
		}

		accessibilityElements = stackView.arrangedSubviews

		isConfigured = true
	}

	// MARK: - Private

	@IBOutlet private weak var scrollView: UIScrollView!
	@IBOutlet private weak var stackView: UIStackView!

	private var isConfigured: Bool = false

}
