////
// 🦠 Corona-Warn-App
//

import UIKit
import OpenCombine

class HomeStatisticsCardView: UIView {

	// MARK: - Internal

	@IBOutlet weak var titleLabel: ENALabel!
	@IBOutlet weak var illustrationImageView: UIImageView!

	@IBOutlet weak var primaryTitleLabel: ENALabel!
	@IBOutlet weak var primaryValueLabel: ENALabel!
	@IBOutlet weak var primaryTrendImageView: UIImageView!

	@IBOutlet weak var secondaryTitleLabel: ENALabel!
	@IBOutlet weak var secondaryValueLabel: ENALabel!
	@IBOutlet weak var secondaryTrendImageView: UIImageView!

	@IBOutlet weak var tertiaryTitleLabel: ENALabel!
	@IBOutlet weak var tertiaryValueLabel: ENALabel!

	@IBOutlet weak var footnoteLabel: ENALabel!

	func configure(
		viewModel: HomeStatisticsCardViewModel,
		onInfoButtonTap: @escaping () -> Void
	) {
		viewModel.$title
			.sink { [weak self] in
				self?.titleLabel.isHidden = $0 == nil
				self?.titleLabel.text = $0
			}
			.store(in: &subscriptions)

		viewModel.$illustrationImage
			.sink { [weak self] in
				self?.illustrationImageView.isHidden = $0 == nil
				self?.illustrationImageView.image = $0
			}
			.store(in: &subscriptions)

		viewModel.$primaryTitle
			.sink { [weak self] in
				self?.primaryTitleLabel.isHidden = $0 == nil
				self?.primaryTitleLabel.text = $0
			}
			.store(in: &subscriptions)

		viewModel.$primaryValue
			.sink { [weak self] in
				self?.primaryValueLabel.isHidden = $0 == nil
				self?.primaryValueLabel.text = $0
			}
			.store(in: &subscriptions)

		viewModel.$primaryTrendImage
			.sink { [weak self] in
				self?.primaryTrendImageView.isHidden = $0 == nil
				self?.primaryTrendImageView.image = $0
			}
			.store(in: &subscriptions)

		viewModel.$secondaryTitle
			.sink { [weak self] in
				self?.secondaryTitleLabel.isHidden = $0 == nil
				self?.secondaryTitleLabel.text = $0
			}
			.store(in: &subscriptions)

		viewModel.$secondaryValue
			.sink { [weak self] in
				self?.secondaryValueLabel.isHidden = $0 == nil
				self?.secondaryValueLabel.text = $0
			}
			.store(in: &subscriptions)

		viewModel.$secondaryTrendImage
			.sink { [weak self] in
				self?.secondaryTrendImageView.isHidden = $0 == nil
				self?.secondaryTrendImageView.image = $0
			}
			.store(in: &subscriptions)

		viewModel.$tertiaryTitle
			.sink { [weak self] in
				self?.tertiaryTitleLabel.isHidden = $0 == nil
				self?.tertiaryTitleLabel.text = $0
			}
			.store(in: &subscriptions)

		viewModel.$tertiaryValue
			.sink { [weak self] in
				self?.tertiaryValueLabel.isHidden = $0 == nil
				self?.tertiaryValueLabel.text = $0
			}
			.store(in: &subscriptions)

		viewModel.$footnote
			.sink { [weak self] in
				self?.footnoteLabel.isHidden = $0 == nil
				self?.footnoteLabel.text = $0
			}
			.store(in: &subscriptions)

		// Retaining view model so it gets updated
		self.viewModel = viewModel

		self.onInfoButtonTap = onInfoButtonTap
	}

	// MARK: - Private

	private var onInfoButtonTap: (() -> Void)?

	private var subscriptions = Set<AnyCancellable>()
	private var viewModel: HomeStatisticsCardViewModel?

	@IBAction private func infoButtonTapped(_ sender: Any) {
		onInfoButtonTap?()
	}

}
