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

class DatePickerOptionView: UIView {

	// MARK: - Init

	@available(*, unavailable)
	override init(frame: CGRect) {
		fatalError("init(frame:) has not been implemented")
	}

	@available(*, unavailable)
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	init(title: String, today: Date, onTapOnDate: @escaping (Date) -> Void) {
		self.onTapOnDate = onTapOnDate
		self.viewModel = DatePickerOptionViewModel(today: today)

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

	var selectedDate: Date? {
		didSet {
			updateForSelectionState()
		}
	}

	// MARK: - Private

	private let onTapOnDate: (Date) -> Void
	private let viewModel: DatePickerOptionViewModel

	private var dateViews: [UIView] = []
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

		let dayStackViews: [UIStackView] = [dayStackView(), dayStackView(), dayStackView(), dayStackView()]
		dayStackViews.forEach { contentStackView.addArrangedSubview($0) }

		for (index, datePickerDay) in viewModel.datePickerDays.enumerated() {
			let datePickerDayView = DatePickerDayView(
				viewModel: DatePickerDayViewModel(
					datePickerDay: datePickerDay,
					onTapOnDate: { date in
						// Update selected state
					}
				)
			)

			dayStackViews[index / 7].addArrangedSubview(datePickerDayView)
			print(index / 7)
		}

		accessibilityElements = [titleLabel]

		updateForSelectionState()
	}

	private func dayStackView() -> UIStackView {
		let stackView = UIStackView()
		stackView.axis = .horizontal
		stackView.alignment = .center
		stackView.distribution = .fillEqually

		return stackView
	}

	private func updateForSelectionState() {
		// Update selection state of date views

		layer.shadowColor = UIColor.enaColor(for: .shadow).cgColor

		let isSelected = selectedDate != nil
		layer.borderWidth = isSelected ? 2 : 1
		layer.borderColor = isSelected ? UIColor.enaColor(for: .buttonPrimary).cgColor : UIColor.enaColor(for: .hairline).cgColor
	}

}
