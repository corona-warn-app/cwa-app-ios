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

class DynamicTableViewOptionGroupCell: UITableViewCell {

	// MARK: - Overrides

	override func awakeFromNib() {
		super.awakeFromNib()

		self.autoresizingMask = .flexibleHeight
	}

	// MARK: - Internal

	@Published private(set) var selection: OptionGroupViewModel.Selection?

	func configure(options: [OptionGroupViewModel.Option], initialSelection: OptionGroupViewModel.Selection? = nil) {
		if optionGroupView != nil {
			optionGroupView.removeFromSuperview()
		}

		let viewModel = OptionGroupViewModel(options: options, initialSelection: initialSelection)
		optionGroupView = OptionGroupView(viewModel: viewModel)
		setUp()

		selectionSubscription = viewModel.$selection.assign(to: \.selection, on: self)
	}

	// MARK: - Private

	private var optionGroupView: OptionGroupView!
	private var selectionSubscription: AnyCancellable?

	private func setUp() {
		selectionStyle = .none
		backgroundColor = .enaColor(for: .background)

		optionGroupView.translatesAutoresizingMaskIntoConstraints = false
		addSubview(optionGroupView)

		NSLayoutConstraint.activate([
			optionGroupView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
			optionGroupView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
			optionGroupView.topAnchor.constraint(equalTo: topAnchor, constant: 16),
			optionGroupView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -16)
		])
	}

}
