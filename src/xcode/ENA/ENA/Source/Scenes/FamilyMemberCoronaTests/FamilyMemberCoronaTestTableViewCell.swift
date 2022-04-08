//
// 🦠 Corona-Warn-App
//

import Foundation
import UIKit
import OpenCombine

final class FamilyMemberCoronaTestTableViewCell: UITableViewCell {

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

	override func layoutSubviews() {
		super.layoutSubviews()

		cardView.layer.shadowOffset = .init(width: 0.0, height: 1.0)
		cardView.layer.shadowRadius = 3
		cardView.layer.borderColor = UIColor.enaColor(for: .cardBorder).cgColor
		cardView.layer.borderWidth = 1
	}

	// MARK: - Internal

	func configure(
		with cellModel: FamilyMemberCoronaTestCellModel,
		onPrimaryAction: @escaping () -> Void
	) {
		// clear all previous subscriptions
		clearSubscriptions()
		
		cellModel.$name
			.receive(on: DispatchQueue.main.ocombine)
			.assign(to: \.text, on: nameLabel)
			.store(in: &subscriptions)

		cellModel.$caption
			.receive(on: DispatchQueue.main.ocombine)
			.assign(to: \.text, on: captionLabel)
			.store(in: &subscriptions)

		cellModel.$topDiagnosis
			.receive(on: DispatchQueue.main.ocombine)
			.assign(to: \.text, on: topDiagnosisLabel)
			.store(in: &subscriptions)

		cellModel.$bottomDiagnosis
			.receive(on: DispatchQueue.main.ocombine)
			.sink { [weak self] in
				self?.bottomDiagnosisLabel.text = $0
				self?.bottomDiagnosisLabel.isHidden = ($0 == nil)
			}
			.store(in: &subscriptions)
		cellModel.$bottomDiagnosisColor
			.receive(on: DispatchQueue.main.ocombine)
			.assign(to: \.textColor, on: bottomDiagnosisLabel)
			.store(in: &subscriptions)

		cellModel.$description
			.receive(on: DispatchQueue.main.ocombine)
			.sink { [weak self] in
				self?.descriptionLabel.text = $0
				self?.descriptionLabel.isHidden = ($0 == nil)
			}
			.store(in: &subscriptions)

		cellModel.$footnote
			.receive(on: DispatchQueue.main.ocombine)
			.sink { [weak self] in
				self?.footnoteLabel.text = $0
				self?.footnoteLabel.isHidden = ($0 == nil)
			}
			.store(in: &subscriptions)

		cellModel.$image
			.receive(on: DispatchQueue.main.ocombine)
			.assign(to: \.image, on: illustrationView)
			.store(in: &subscriptions)

		cellModel.$buttonTitle
			.receive(on: DispatchQueue.main.ocombine)
			.sink { [weak self] in
				self?.button.setTitle($0, for: .normal)
				self?.button.isHidden = ($0 == nil)
			}
			.store(in: &subscriptions)

		cellModel.$isUnseenNewsIndicatorHidden
			.receive(on: DispatchQueue.main.ocombine)
			.assign(to: \.isHidden, on: unseenNewsIndicator)
			.store(in: &subscriptions)

		cellModel.$isDisclosureIndicatorHidden
			.receive(on: DispatchQueue.main.ocombine)
			.assign(to: \.isHidden, on: disclosureIndicatorView)
			.store(in: &subscriptions)

		cellModel.$isUserInteractionEnabled
			.receive(on: DispatchQueue.main.ocombine)
			.assign(to: \.isUserInteractionEnabled, on: self)
			.store(in: &subscriptions)
		cellModel.$isUserInteractionEnabled
			.receive(on: DispatchQueue.main.ocombine)
			.assign(to: \.isEnabled, on: button)
			.store(in: &subscriptions)

		cellModel.$accessibilityIdentifier
			.receive(on: DispatchQueue.main.ocombine)
			.assign(to: \.accessibilityIdentifier, on: button)
			.store(in: &subscriptions)

		self.onPrimaryAction = onPrimaryAction

		self.cellModel = cellModel
	}

	// MARK: - Private

	@IBOutlet private weak var cardView: HomeCardView!
	@IBOutlet private weak var nameLabel: ENALabel!
	@IBOutlet private weak var unseenNewsIndicator: UIView!
	@IBOutlet private weak var disclosureIndicatorView: UIView!

	@IBOutlet private weak var captionLabel: ENALabel!
	@IBOutlet private weak var topDiagnosisLabel: ENALabel!
	@IBOutlet private weak var bottomDiagnosisLabel: ENALabel!

	@IBOutlet private weak var illustrationView: UIImageView!

	@IBOutlet private weak var descriptionLabel: ENALabel!
	@IBOutlet private weak var footnoteLabel: ENALabel!

	@IBOutlet private weak var button: ENAButton!

	private var subscriptions = Set<AnyCancellable>()
	private var cellModel: FamilyMemberCoronaTestCellModel?

	private var onPrimaryAction: (() -> Void)?

	private func setup() {
		updateIllustration(for: traitCollection)
		accessibilityIdentifier = AccessibilityIdentifiers.FamilyMemberCoronaTestCell.Overview.testCell
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
