//
// 🦠 Corona-Warn-App
//

import UIKit
import OpenCombine

class MultipleChoiceOptionView: UIView {

	// MARK: - Init

	@available(*, unavailable)
	override init(frame: CGRect) {
		fatalError("init(frame:) has not been implemented")
	}

	@available(*, unavailable)
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	init(title: String, choices: [OptionGroupViewModel.Choice], onTapOnChoice: @escaping (Int) -> Void) {
		self.onTapOnChoice = onTapOnChoice
		self.choices = choices

		super.init(frame: .zero)

		setUp(title: title)
	}
	// MARK: - Overrides

	override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
		super.traitCollectionDidChange(previousTraitCollection)

		// Update selection state for dark mode (CGColors are not changed automatically)
		updateForSelectionState()
	}

	// MARK: - Internal

	var selectedChoices: Set<Int> = [] {
		didSet {
			updateForSelectionState()
		}
	}

	// MARK: - Private

	private let onTapOnChoice: (Int) -> Void
	private let choices: [OptionGroupViewModel.Choice]

	private var choiceViews: [MultipleChoiceChoiceView] = []
	private let contentStackView = UIStackView()

	private func setUp(title: String) {
		backgroundColor = UIColor.enaColor(for: .background)

		layer.cornerRadius = 10

		layer.shadowOffset = CGSize(width: 0, height: 2)
		layer.shadowRadius = 2
		layer.shadowOpacity = 1

		layer.masksToBounds = false

		contentStackView.axis = .vertical
		contentStackView.isLayoutMarginsRelativeArrangement = true
		contentStackView.translatesAutoresizingMaskIntoConstraints = false
		addSubview(contentStackView)

		NSLayoutConstraint.activate([
			contentStackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
			contentStackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
			contentStackView.topAnchor.constraint(equalTo: topAnchor, constant: 26),
			contentStackView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -20)
		])

		let titleLabel = ENALabel()
		titleLabel.numberOfLines = 0
		titleLabel.style = .headline
		titleLabel.text = title

		contentStackView.addArrangedSubview(titleLabel)
		contentStackView.setCustomSpacing(23, after: titleLabel)

		for choiceIndex in 0..<choices.count {
			let choice = choices[choiceIndex]

			let choiceView = MultipleChoiceChoiceView(
				iconImage: choice.iconImage,
				title: choice.title,
				accessibilityIdentifier: choice.accessibilityIdentifier,
				onTap: { [weak self] in
					self?.onTapOnChoice(choiceIndex)
				}
			)

			contentStackView.addArrangedSubview(choiceView)
			choiceViews.append(choiceView)

			if choiceIndex != choices.count - 1 {
				let separatorView = UIView()
				separatorView.backgroundColor = UIColor.enaColor(for: .hairline)
				separatorView.heightAnchor.constraint(equalToConstant: 1).isActive = true

				contentStackView.addArrangedSubview(separatorView)
			}
		}

		accessibilityElements = [titleLabel] + choiceViews

		updateForSelectionState()
	}

	private func updateForSelectionState() {
		for choiceIndex in 0..<choices.count {
			choiceViews[choiceIndex].isSelected = selectedChoices.contains(choiceIndex)
		}

		layer.shadowColor = UIColor.enaColor(for: .shadow).cgColor

		let isSelected = !selectedChoices.isEmpty
		layer.borderWidth = isSelected ? 2 : 1
		layer.borderColor = isSelected ? UIColor.enaColor(for: .buttonPrimary).cgColor : UIColor.enaColor(for: .hairline).cgColor
	}

}
