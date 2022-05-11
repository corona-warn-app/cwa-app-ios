//
// 🦠 Corona-Warn-App
//

import Foundation
import UIKit
import OpenCombine

final class HomeTestResultTableViewCell: UITableViewCell {

	// MARK: - Overrides

	override func prepareForInterfaceBuilder() {
		super.prepareForInterfaceBuilder()

		setup()
	}

	override func awakeFromNib() {
		super.awakeFromNib()

		setup()
	}

	override func setHighlighted(_ highlighted: Bool, animated: Bool) {
		super.setHighlighted(highlighted, animated: animated)
		
		// going optional here to prevent a crash if this gets loaded before a model is assigned
		guard cellModel?.isCellTappable ?? false else {
			return
		}

		cardView.setHighlighted(highlighted, animated: animated)
	}

	override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
		super.traitCollectionDidChange(previousTraitCollection)

		updateIllustration(for: traitCollection)
	}
	
	override func prepareForReuse() {
		super.prepareForReuse()
		clearSubscriptions()
	}

	// MARK: - Internal

	func configure(with cellModel: HomeTestResultCellModel, onPrimaryAction: @escaping () -> Void) {
		
		// clear all previous subscriptions
		clearSubscriptions()
		
		cellModel.$title
			.assign(to: \.text, on: titleLabel)
			.store(in: &subscriptions)

		cellModel.$subtitle
			.sink { [weak self] in
				self?.subtitleLabel.text = $0
				self?.subtitleLabel.isHidden = (nil == $0)
			}
			.store(in: &subscriptions)

		cellModel.$description
			.assign(to: \.text, on: descriptionLabel)
			.store(in: &subscriptions)

		cellModel.$footnote
			.sink { [weak self] in
				self?.footnoteLabel.text = $0
				self?.footnoteLabel.isHidden = (nil == $0)
			}
			.store(in: &subscriptions)

		cellModel.$image
			.assign(to: \.image, on: illustrationView)
			.store(in: &subscriptions)

		cellModel.$buttonTitle
			.sink { [weak self] buttonTitle in
				self?.button.setTitle(buttonTitle, for: .normal)
			}
			.store(in: &subscriptions)

		cellModel.$isDisclosureIndicatorHidden
			.assign(to: \.isHidden, on: disclosureIndicatorView)
			.store(in: &subscriptions)

		cellModel.$isNegativeDiagnosisHidden
			.assign(to: \.isHidden, on: negativeDiagnosisStackView)
			.store(in: &subscriptions)

		cellModel.$isActivityIndicatorHidden
			.assign(to: \.isHidden, on: activityIndicator)
			.store(in: &subscriptions)
		cellModel.$isActivityIndicatorHidden
			.map({ !$0 })
			.assign(to: \.isHidden, on: illustrationView)
			.store(in: &subscriptions)

		cellModel.$isUserInteractionEnabled
			.assign(to: \.isUserInteractionEnabled, on: self)
			.store(in: &subscriptions)
		cellModel.$isUserInteractionEnabled
			.assign(to: \.isEnabled, on: button)
			.store(in: &subscriptions)

		cellModel.$accessibilityIdentifier
			.assign(to: \.accessibilityIdentifier, on: button)
			.store(in: &subscriptions)

		self.onPrimaryAction = onPrimaryAction

		self.cellModel = cellModel
	}

	// MARK: - Private

	@IBOutlet private weak var cardView: HomeCardView!
	@IBOutlet private weak var titleLabel: ENALabel!
	@IBOutlet private weak var disclosureIndicatorView: UIView!
	@IBOutlet private weak var subtitleLabel: ENALabel!

	@IBOutlet private weak var negativeDiagnosisStackView: UIStackView!
	@IBOutlet private weak var negativeDiagnosisCaptionLabel: ENALabel!
	@IBOutlet private weak var negativeDiagnosisVirusLabel: ENALabel!
	@IBOutlet private weak var negativeDiagnosisLabel: ENALabel!

	@IBOutlet private weak var activityIndicator: UIActivityIndicatorView!
	@IBOutlet private weak var illustrationView: UIImageView!

	@IBOutlet private weak var descriptionLabel: ENALabel!
	@IBOutlet private weak var footnoteLabel: ENALabel!

	@IBOutlet private weak var button: ENAButton!

	private var subscriptions = Set<AnyCancellable>()
	private var cellModel: HomeTestResultCellModel!

	private var onPrimaryAction: (() -> Void)?

	private func setup() {
		updateIllustration(for: traitCollection)

		negativeDiagnosisCaptionLabel.text = AppStrings.Home.TestResult.Negative.caption
		negativeDiagnosisVirusLabel.text = AppStrings.Home.TestResult.Negative.title
		negativeDiagnosisLabel.text = AppStrings.Home.TestResult.Negative.titleNegative

		accessibilityTraits = .button
	}

	private func updateIllustration(for traitCollection: UITraitCollection) {
		if traitCollection.preferredContentSizeCategory >= .accessibilityLarge {
			illustrationView.superview?.isHidden = true
		} else {
			illustrationView.superview?.isHidden = false
		}
	}
	
	private func clearSubscriptions() {
		subscriptions.forEach({ $0.cancel() })
		subscriptions.removeAll()
	}

	@IBAction func primaryActionTriggered() {
		onPrimaryAction?()
	}

}
