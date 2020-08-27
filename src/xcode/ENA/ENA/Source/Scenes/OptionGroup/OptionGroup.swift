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

class OptionGroup: UIView {

	enum Option {
		case option(title: String)
		case multipleChoice([(icon: UIImage, title: String)], initiallySelectedChoices: [Int])
//		case datePicker(title: String, initiallySelectedDaysFromToday: Int)
	}

	enum Selection {
		case option(index: Int)
		case multipleChoice(index: Int, selectedChoices: [Int])
//		case datePicker(index: Int, selectedDaysFromToday: Int)
	}

	// MARK: - Init

	@available(*, unavailable)
	override init(frame: CGRect) {
		fatalError("init(frame:) has not been implemented")
	}

	@available(*, unavailable)
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	init(options: [Option], initialSelection: Selection? = nil) {
		self.options = options
		self.selection = initialSelection

		super.init(frame: .zero)

		setUp()
	}

	// MARK: - Internal

	@Published private(set) var selection: Selection?

	// MARK: - Private

	private var options: [OptionGroup.Option]
	private var optionViews: [UIControl] = []

	private var contentStackView = UIStackView()

	func setUp() {
		contentStackView.axis = .vertical
		contentStackView.spacing = 14

		contentStackView.translatesAutoresizingMaskIntoConstraints = false
		addSubview(contentStackView)

		NSLayoutConstraint.activate([
			contentStackView.leadingAnchor.constraint(equalTo: leadingAnchor),
			contentStackView.trailingAnchor.constraint(equalTo: trailingAnchor),
			contentStackView.topAnchor.constraint(equalTo: topAnchor),
			contentStackView.bottomAnchor.constraint(equalTo: bottomAnchor)
		])

		for optionIndex in 0..<options.count {
			let option = options[optionIndex]

			let optionView: UIControl
			switch option {
			case .option(title: let title):
				optionView = OptionView(title: title, onTap: {
					self.selection = .option(index: optionIndex)
					for viewIndex in 0..<self.optionViews.count {
						self.optionViews[viewIndex].isSelected = viewIndex == optionIndex
					}
				})
			default:
				optionView = OptionView(title: "", onTap: {})
			}

			contentStackView.addArrangedSubview(optionView)
			optionViews.append(optionView)
		}
	}

}
