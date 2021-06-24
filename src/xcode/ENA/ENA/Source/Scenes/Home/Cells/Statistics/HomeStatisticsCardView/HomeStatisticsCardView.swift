////
// 🦠 Corona-Warn-App
//

import UIKit
import OpenCombine

class HomeStatisticsCardView: UIView {

	// MARK: - Overrides

	override func awakeFromNib() {
		super.awakeFromNib()

		let adjustsFontSizeToFitWidth = false
		let allowsDefaultTighteningForTruncation = true

		titleLabel.adjustsFontSizeToFitWidth = adjustsFontSizeToFitWidth
		titleLabel.allowsDefaultTighteningForTruncation = allowsDefaultTighteningForTruncation
		titleLabel.onAccessibilityFocus = { [weak self] in
			self?.onAccessibilityFocus?()
		}

		primaryTitleLabel.style = .body
		primaryTitleLabel.textColor = .enaColor(for: .textPrimary2)
		primaryTitleLabel.numberOfLines = 0
		primaryTitleLabel.adjustsFontSizeToFitWidth = adjustsFontSizeToFitWidth
		primaryTitleLabel.allowsDefaultTighteningForTruncation = allowsDefaultTighteningForTruncation
		primaryTitleLabel.onAccessibilityFocus = { [weak self] in
			self?.onAccessibilityFocus?()
		}

		primaryValueLabel.style = .title1
		primaryValueLabel.numberOfLines = 0
		primaryValueLabel.adjustsFontSizeToFitWidth = adjustsFontSizeToFitWidth
		primaryValueLabel.allowsDefaultTighteningForTruncation = allowsDefaultTighteningForTruncation
		primaryValueLabel.onAccessibilityFocus = { [weak self] in
			self?.onAccessibilityFocus?()
		}
		primarySubtitleLabel.style = .body
		primarySubtitleLabel.textColor = .enaColor(for: .textPrimary2)
		primarySubtitleLabel.numberOfLines = 0
		primarySubtitleLabel.adjustsFontSizeToFitWidth = adjustsFontSizeToFitWidth
		primarySubtitleLabel.allowsDefaultTighteningForTruncation = allowsDefaultTighteningForTruncation
		primarySubtitleLabel.onAccessibilityFocus = { [weak self] in
			self?.onAccessibilityFocus?()
		}

		secondaryTitleLabel.style = .body
		secondaryTitleLabel.textColor = .enaColor(for: .textPrimary2)
		secondaryTitleLabel.numberOfLines = 0
		secondaryTitleLabel.adjustsFontSizeToFitWidth = adjustsFontSizeToFitWidth
		secondaryTitleLabel.allowsDefaultTighteningForTruncation = allowsDefaultTighteningForTruncation
		secondaryTitleLabel.onAccessibilityFocus = { [weak self] in
			self?.onAccessibilityFocus?()
		}

		secondaryValueLabel.style = .headline
		secondaryValueLabel.numberOfLines = 0
		secondaryValueLabel.adjustsFontSizeToFitWidth = adjustsFontSizeToFitWidth
		secondaryValueLabel.allowsDefaultTighteningForTruncation = allowsDefaultTighteningForTruncation
		secondaryValueLabel.onAccessibilityFocus = { [weak self] in
			self?.onAccessibilityFocus?()
		}

		tertiaryTitleLabel.style = .body
		tertiaryTitleLabel.textColor = .enaColor(for: .textPrimary2)
		tertiaryTitleLabel.numberOfLines = 0
		tertiaryTitleLabel.adjustsFontSizeToFitWidth = adjustsFontSizeToFitWidth
		tertiaryTitleLabel.allowsDefaultTighteningForTruncation = allowsDefaultTighteningForTruncation
		tertiaryTitleLabel.onAccessibilityFocus = { [weak self] in
			self?.onAccessibilityFocus?()
		}

		tertiaryValueLabel.style = .headline
		tertiaryValueLabel.numberOfLines = 0
		tertiaryValueLabel.adjustsFontSizeToFitWidth = adjustsFontSizeToFitWidth
		tertiaryValueLabel.allowsDefaultTighteningForTruncation = allowsDefaultTighteningForTruncation
		tertiaryValueLabel.onAccessibilityFocus = { [weak self] in
			self?.onAccessibilityFocus?()
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
				titleLabel.accessibilityTraits = UIAccessibilityTraits.header
				accessibilityElements.append(titleLabel)
			}

			if let infoButton = self.infoButton {
				accessibilityElements.append(infoButton)
				infoButton.accessibilityTraits = UIAccessibilityTraits.button
				infoButton.accessibilityIdentifier = viewModel?.infoButtonAccessibilityIdentifier
			}

			if viewModel?.primaryTitle != nil, let primaryTitleLabel = self.primaryTitleLabel {
				var primaryAccessibilityLabel = primaryTitleLabel.text
				if viewModel?.primaryValue != nil, let primaryValueLabel = self.primaryValueLabel {
					primaryAccessibilityLabel?.append(" ")
					primaryAccessibilityLabel?.append(primaryValueLabel.text ?? "")
				}

				primaryTitleLabel.accessibilityLabel = primaryAccessibilityLabel
				accessibilityElements.append(primaryTitleLabel)
			}

			if viewModel?.primaryTrendImage != nil, let primaryTrendImageView = self.primaryTrendImageView {
				accessibilityElements.append(primaryTrendImageView)
			}

			if viewModel?.secondaryTitle != nil, let secondaryTitleLabel = self.secondaryTitleLabel {
				var secondaryAccessibilityLabel = secondaryTitleLabel.text
				if viewModel?.secondaryValue != nil, let secondaryValueLabel = self.secondaryValueLabel {
					secondaryAccessibilityLabel?.append(" ")
					secondaryAccessibilityLabel?.append(secondaryValueLabel.text ?? "")
				}
				secondaryTitleLabel.accessibilityLabel = secondaryAccessibilityLabel
				accessibilityElements.append(secondaryTitleLabel)
			}

			if viewModel?.secondaryTrendImage != nil, let secondaryTrendImageView = self.secondaryTrendImageView {
				accessibilityElements.append(secondaryTrendImageView)
			}

			if viewModel?.tertiaryTitle != nil, let tertiaryTitleLabel = self.tertiaryTitleLabel {
				var tertiaryAccessibilityLabel = tertiaryTitleLabel.text
				if viewModel?.tertiaryValue != nil, let tertiaryValueLabel = self.tertiaryValueLabel {
					tertiaryAccessibilityLabel?.append(" ")
					tertiaryAccessibilityLabel?.append(tertiaryValueLabel.text ?? "")
				}
				tertiaryTitleLabel.accessibilityLabel = tertiaryAccessibilityLabel
				accessibilityElements.append(tertiaryTitleLabel)
			}

			if viewModel?.subtitle != nil, let subtitleLabel = self.subtitleLabel {
				subtitleLabel.accessibilityTraits = UIAccessibilityTraits.link
				accessibilityElements.append(subtitleLabel)
			}
			if viewModel?.primarySubtitle != nil, let primarySubtitleLabel = self.primarySubtitleLabel {
				primarySubtitleLabel.accessibilityTraits = UIAccessibilityTraits.link
				accessibilityElements.append(primarySubtitleLabel)
			}

			return accessibilityElements
		}
		// swiftlint:disable:next unused_setter_value
		set { }
	}

	// MARK: - Internal

	@IBOutlet weak var titleLabel: ENALabel!
	@IBOutlet weak var subtitleLabel: ENALabel!
	@IBOutlet weak var infoButton: UIButton!

	@IBOutlet weak var illustrationImageView: UIImageView!

	@IBOutlet weak var primaryTitleLabel: StackViewLabel!
	@IBOutlet weak var primaryValueLabel: StackViewLabel!
	@IBOutlet weak var primarySubtitleLabel: StackViewLabel!
	@IBOutlet weak var primaryTrendImageView: UIImageView!

	@IBOutlet weak var secondaryTitleLabel: StackViewLabel!
	@IBOutlet weak var secondaryValueLabel: StackViewLabel!
	@IBOutlet weak var secondaryTrendImageView: UIImageView!

	@IBOutlet weak var tertiaryTitleLabel: StackViewLabel!
	@IBOutlet weak var tertiaryValueLabel: StackViewLabel!

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
				self?.titleLabel.accessibilityIdentifier = viewModel.titleAccessibilityIdentifier
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

		viewModel.$primarySubtitle
			.sink { [weak self] in
				self?.primarySubtitleLabel.isHidden = $0 == nil
				self?.primarySubtitleLabel.text = $0
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

		viewModel.$subtitle
			.sink { [weak self] in
				self?.subtitleLabel.isHidden = $0 == nil
				self?.subtitleLabel.text = $0
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
