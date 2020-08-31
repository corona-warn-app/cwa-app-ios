//
// Corona-Warn-App
//
// SAP SE and all other contributors
// copyright owners license this file to you under the Apache
// License, Version 2.0 (the "License"); you may not use this
// file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing,
// software distributed under the License is distributed on an
// "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
// KIND, either express or implied.  See the License for the
// specific language governing permissions and limitations
// under the License.
//

import UIKit
import Combine

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

	init(title: String, choices: [(iconImage: UIImage?, title: String)], onTapOnChoice: @escaping (Int) -> Void) {
		self.onTapOnChoice = onTapOnChoice
		self.choices = choices

		super.init(frame: .zero)

		setUp(title: title)
	}
	// MARK: - Overrides

	override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
		super.traitCollectionDidChange(previousTraitCollection)

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
	private let choices: [(iconImage: UIImage?, title: String)]

	private var choiceViews: [MultipleChoiceChoiceView] = []
	private let contentStackView = UIStackView()

	private func setUp(title: String) {
		backgroundColor = UIColor.enaColor(for: .background)

		layer.cornerRadius = 10

		layer.shadowColor = UIColor.enaColor(for: .shadow).cgColor
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

		updateForSelectionState()
	}

	private func updateForSelectionState() {
		for choiceIndex in 0..<choices.count {
			choiceViews[choiceIndex].isSelected = selectedChoices.contains(choiceIndex)
		}

		let isSelected = !selectedChoices.isEmpty
		layer.borderWidth = isSelected ? 2 : 1
		layer.borderColor = isSelected ? UIColor.enaColor(for: .buttonPrimary).cgColor : UIColor.enaColor(for: .hairline).cgColor
	}

}
