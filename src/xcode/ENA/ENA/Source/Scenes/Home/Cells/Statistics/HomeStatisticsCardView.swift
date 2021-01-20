////
// 🦠 Corona-Warn-App
//

import UIKit
import OpenCombine

class HomeStatisticsCardView: UIView {

	// MARK: - Overrides

	override func awakeFromNib() {
		super.awakeFromNib()

		let focusableLabels = [
			titleLabel as ENALabel,
			primaryTitleLabel as ENALabel,
			primaryValueLabel as ENALabel,
			secondaryTitleLabel as ENALabel,
			secondaryValueLabel as ENALabel,
			tertiaryTitleLabel as ENALabel,
			tertiaryValueLabel as ENALabel,
			footnoteLabel as ENALabel
		]

		focusableLabels.forEach {
			$0.onAccessibilityFocus = { [weak self] in
				self?.onAccessibilityFocus?()
			}
		}

		primaryTrendImageView.layer.cornerRadius = primaryTrendImageView.bounds.width / 2
		secondaryTrendImageView.layer.cornerRadius = secondaryTrendImageView.bounds.width / 2
	}

	override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
		super.traitCollectionDidChange(previousTraitCollection)

		updateIllustration(for: traitCollection)
	}

	override var accessibilityElements: [Any]? {
		get {
			var accessibilityElements = [Any]()

			if viewModel?.title != nil, let titleLabel = self.titleLabel {
				accessibilityElements.append(titleLabel)
			}

			if let infoButton = self.infoButton {
				accessibilityElements.append(infoButton)
				infoButton.accessibilityIdentifier = viewModel?.infoButtonAccessiblityIdentifier
			}

			if viewModel?.primaryTitle != nil, let primaryTitleLabel = self.primaryTitleLabel {
				accessibilityElements.append(primaryTitleLabel)
			}

			if viewModel?.primaryValue != nil, let primaryValueLabel = self.primaryValueLabel {
				accessibilityElements.append(primaryValueLabel)
			}

			if viewModel?.primaryTrendImage != nil, let primaryTrendImageView = self.primaryTrendImageView {
				accessibilityElements.append(primaryTrendImageView)
			}

			if viewModel?.secondaryTitle != nil, let secondaryTitleLabel = self.secondaryTitleLabel {
				accessibilityElements.append(secondaryTitleLabel)
			}

			if viewModel?.secondaryValue != nil, let secondaryValueLabel = self.secondaryValueLabel {
				accessibilityElements.append(secondaryValueLabel)
			}

			if viewModel?.secondaryTrendImage != nil, let secondaryTrendImageView = self.secondaryTrendImageView {
				accessibilityElements.append(secondaryTrendImageView)
			}

			if viewModel?.tertiaryTitle != nil, let tertiaryTitleLabel = self.tertiaryTitleLabel {
				accessibilityElements.append(tertiaryTitleLabel)
			}

			if viewModel?.tertiaryValue != nil, let tertiaryValueLabel = self.tertiaryValueLabel {
				accessibilityElements.append(tertiaryValueLabel)
			}

			if viewModel?.footnote != nil, let footnoteLabel = self.footnoteLabel {
				accessibilityElements.append(footnoteLabel)
			}

			return accessibilityElements
		}
		// swiftlint:disable:next unused_setter_value
		set { }
	}

	// MARK: - Internal

	@IBOutlet weak var titleLabel: ENALabel!
	@IBOutlet weak var infoButton: UIButton!

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
		onInfoButtonTap: @escaping () -> Void,
		onAccessibilityFocus: @escaping () -> Void
	) {
		viewModel.$title
			.sink { [weak self] in
				self?.titleLabel.isHidden = $0 == nil
				self?.titleLabel.text = $0
				self?.titleLabel.accessibilityIdentifier = viewModel.titleAccessiblityIdentifier
			}
			.store(in: &subscriptions)

		viewModel.$illustrationImage
			.assign(to: \.image, on: illustrationImageView)
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

		viewModel.$primaryTrendImageTintColor
			.assign(to: \.backgroundColor, on: primaryTrendImageView)
			.store(in: &subscriptions)

		viewModel.$primaryTrendAccessibilityLabel
			.assign(to: \.accessibilityLabel, on: primaryTrendImageView)
			.store(in: &subscriptions)

		viewModel.$primaryTrendAccessibilityValue
			.assign(to: \.accessibilityValue, on: primaryTrendImageView)
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

		viewModel.$secondaryTrendImageTintColor
			.assign(to: \.backgroundColor, on: secondaryTrendImageView)
			.store(in: &subscriptions)

		viewModel.$secondaryTrendAccessibilityLabel
			.assign(to: \.accessibilityLabel, on: secondaryTrendImageView)
			.store(in: &subscriptions)

		viewModel.$secondaryTrendAccessibilityValue
			.assign(to: \.accessibilityValue, on: secondaryTrendImageView)
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
		self.onAccessibilityFocus = onAccessibilityFocus

		updateIllustration(for: traitCollection)
	}

	// MARK: - Private

	private var onInfoButtonTap: (() -> Void)?
	private var onAccessibilityFocus: (() -> Void)?

	private var subscriptions = Set<AnyCancellable>()
	private var viewModel: HomeStatisticsCardViewModel?

	@IBAction private func infoButtonTapped(_ sender: Any) {
		onInfoButtonTap?()
	}

	private func updateIllustration(for traitCollection: UITraitCollection) {
		if traitCollection.preferredContentSizeCategory >= .accessibilityLarge {
			illustrationImageView.isHidden = true
		} else {
			illustrationImageView.isHidden = false
		}
	}

}
