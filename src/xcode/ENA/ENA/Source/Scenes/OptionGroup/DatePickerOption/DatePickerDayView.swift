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

	override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
		super.traitCollectionDidChange(previousTraitCollection)

		// Update selection state for dark mode (CGColors are not changed automatically)
		updateForSelectionState()
	}

	// MARK: - Internal

	// MARK: - Private

	private let viewModel: DatePickerDayViewModel

	private var subscriptions = [AnyCancellable]()

	private let titleLabel = ENALabel()

	private func setUp() {
		titleLabel.numberOfLines = 0
		titleLabel.style = .headline
		titleLabel.text = viewModel.dayString
		titleLabel.textAlignment = .center

		titleLabel.translatesAutoresizingMaskIntoConstraints = false
		addSubview(titleLabel)

		NSLayoutConstraint.activate([
			titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor),
			titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor),
			titleLabel.topAnchor.constraint(equalTo: topAnchor),
			titleLabel.bottomAnchor.constraint(equalTo: bottomAnchor),
			titleLabel.heightAnchor.constraint(equalTo: titleLabel.widthAnchor)
		])

		setUpBindings()
	}

	func setUpBindings() {
		subscriptions = [
			viewModel.$textColor.assign(to: \.textColor, on: titleLabel)
		]
	}

	private func updateForSelectionState() {

	}

}
