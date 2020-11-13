//
// 🦠 Corona-Warn-App
//

import UIKit

class InfoBoxView: UIView {

	// MARK: - Init

	override init(frame: CGRect) {
		super.init(frame: frame)

		loadViewFromNib()
	}
	
	required init?(coder: NSCoder) {
		super.init(coder: coder)

		loadViewFromNib()
	}

	override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
		super.traitCollectionDidChange(previousTraitCollection)

		updateConstraintsForCurrentTraitCollection()
	}
	
	// MARK: - Internal
	
	func update(with viewModel: InfoBoxViewModel) {
		infoBoxTitle.text = viewModel.titleText
		infoBoxText.text = viewModel.descriptionText
		shareButton.setTitle(viewModel.shareText, for: .normal)
		settingsButton.setTitle(viewModel.settingsText, for: .normal)
		
		settingsAction = viewModel.settingsAction
		shareAction = viewModel.shareAction

		instructionsStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
		nonAccessibilityConstraints.removeAll()
		accessibilityConstraints.removeAll()

		for instruction in viewModel.instructions {
			let titleLabel = ENALabel()
			titleLabel.text = instruction.title
			titleLabel.numberOfLines = 0
			titleLabel.style = .headline

			instructionsStackView.addArrangedSubview(titleLabel)

			for index in 0..<instruction.steps.count {
				instructionsStackView.addArrangedSubview(view(for: instruction.steps[index], index: index))
			}
		}

		updateConstraintsForCurrentTraitCollection()
	}
	
	// MARK: - Private

	@IBOutlet private weak var infoBoxTitle: ENALabel!
	@IBOutlet private weak var infoBoxText: ENALabel!
	@IBOutlet private weak var instructionsStackView: UIStackView!
	@IBOutlet private weak var settingsButton: UIButton!
	@IBOutlet private weak var shareButton: UIButton!

	private var nonAccessibilityConstraints = [NSLayoutConstraint]()
	private var accessibilityConstraints = [NSLayoutConstraint]()
	
	private var shareAction: () -> Void = { }
	private var settingsAction: () -> Void = { }
	
	private func loadViewFromNib() {
		let nib = UINib(nibName: "InfoBoxView", bundle: nil)
		guard let view = nib.instantiate(withOwner: self, options: nil).first as? UIView else {
			return
		}
		
		view.translatesAutoresizingMaskIntoConstraints = false
		addSubview(view)

		NSLayoutConstraint.activate([
			view.topAnchor.constraint(equalTo: topAnchor),
			view.trailingAnchor.constraint(equalTo: trailingAnchor),
			view.bottomAnchor.constraint(equalTo: bottomAnchor),
			view.leadingAnchor.constraint(equalTo: leadingAnchor)
		])
	}
	
	private func view(for step: InfoBoxViewModel.InstructionStep, index: Int) -> UIView {
		let containerView = UIView()
		containerView.isAccessibilityElement = true
		containerView.accessibilityLabel = "\(index + 1). \(step.text)"

		let iconImageView = UIImageView(image: step.icon)

		iconImageView.translatesAutoresizingMaskIntoConstraints = false
		containerView.addSubview(iconImageView)

		NSLayoutConstraint.activate([
			iconImageView.widthAnchor.constraint(equalToConstant: 28),
			iconImageView.heightAnchor.constraint(equalToConstant: 28),
			iconImageView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
			iconImageView.topAnchor.constraint(greaterThanOrEqualTo: containerView.topAnchor)
		])

		let enumerationLabel = ENALabel()
		enumerationLabel.text = "\(index + 1)."
		enumerationLabel.numberOfLines = 1
		enumerationLabel.style = .headline
		enumerationLabel.setContentCompressionResistancePriority(.required, for: .horizontal)

		enumerationLabel.translatesAutoresizingMaskIntoConstraints = false
		containerView.addSubview(enumerationLabel)

		NSLayoutConstraint.activate([
			enumerationLabel.leadingAnchor.constraint(equalTo: iconImageView.trailingAnchor, constant: 16),
			enumerationLabel.topAnchor.constraint(greaterThanOrEqualTo: containerView.topAnchor),
			enumerationLabel.centerYAnchor.constraint(equalTo: iconImageView.centerYAnchor)
		])

		let stepLabel = ENALabel()
		stepLabel.text = step.text
		stepLabel.numberOfLines = 0
		stepLabel.style = .headline

		stepLabel.translatesAutoresizingMaskIntoConstraints = false
		containerView.addSubview(stepLabel)

		nonAccessibilityConstraints.append(contentsOf: [
			stepLabel.leadingAnchor.constraint(equalTo: enumerationLabel.trailingAnchor, constant: 10),
			stepLabel.firstBaselineAnchor.constraint(equalTo: enumerationLabel.firstBaselineAnchor)
		])

		accessibilityConstraints.append(contentsOf: [
			stepLabel.topAnchor.constraint(equalTo: enumerationLabel.bottomAnchor, constant: 8),
			stepLabel.leadingAnchor.constraint(equalTo: iconImageView.leadingAnchor)
		])

		NSLayoutConstraint.activate([
			stepLabel.bottomAnchor.constraint(lessThanOrEqualTo: containerView.bottomAnchor),
			stepLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor)
		])
		
		return containerView
	}

	private func updateConstraintsForCurrentTraitCollection() {
		if traitCollection.preferredContentSizeCategory.isAccessibilityCategory {
			NSLayoutConstraint.deactivate(nonAccessibilityConstraints)
			NSLayoutConstraint.activate(accessibilityConstraints)
		} else {
			NSLayoutConstraint.deactivate(accessibilityConstraints)
			NSLayoutConstraint.activate(nonAccessibilityConstraints)
		}
	}
	
	@IBAction private func onShare() {
		shareAction()
	}
	
	@IBAction private func onSettings() {
		settingsAction()
	}

}
