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

class DatePickerDayView: UIView {

	// MARK: - Init

	@available(*, unavailable)
	override init(frame: CGRect) {
		fatalError("init(frame:) has not been implemented")
	}

	@available(*, unavailable)
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	init(viewModel: DatePickerDayViewModel) {
		self.viewModel = viewModel

		super.init(frame: .zero)

		setUp()
	}

	// MARK: - Overrides

	override func layoutSubviews() {
		super.layoutSubviews()

		layer.cornerRadius = bounds.width / 2
	}

	// MARK: - Private

	private let viewModel: DatePickerDayViewModel

	private var subscriptions = [AnyCancellable]()

	private let titleLabel = DynamicTypeLabel()

	private func setUp() {
		titleLabel.translatesAutoresizingMaskIntoConstraints = false
		addSubview(titleLabel)

		NSLayoutConstraint.activate([
			titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor),
			titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor),
			titleLabel.topAnchor.constraint(equalTo: topAnchor),
			titleLabel.bottomAnchor.constraint(equalTo: bottomAnchor),
			titleLabel.heightAnchor.constraint(equalTo: titleLabel.widthAnchor)
		])

		titleLabel.numberOfLines = 0
		titleLabel.font = UIFont.preferredFont(forTextStyle: .body)
		titleLabel.dynamicTypeSize = viewModel.fontSize
		titleLabel.text = viewModel.dayString
		titleLabel.textAlignment = .center
		titleLabel.adjustsFontSizeToFitWidth = true

		subscriptions = [
			viewModel.$backgroundColor.sink { [weak self] in self?.backgroundColor = $0 },
			viewModel.$textColor.assign(to: \.textColor, on: titleLabel),
			viewModel.$fontWeight.assign(to: \.dynamicTypeWeight, on: titleLabel),
			viewModel.$accessibilityTraits.assign(to: \.accessibilityTraits, on: self)
		]

		let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(viewTapped))
		addGestureRecognizer(tapGestureRecognizer)

		isAccessibilityElement = viewModel.isSelectable
		accessibilityLabel = viewModel.accessibilityLabel
		accessibilityIdentifier = AccessibilityIdentifiers.DatePickerOption.day
	}

	@objc
	private func viewTapped() {
		viewModel.onTap()
	}

}
