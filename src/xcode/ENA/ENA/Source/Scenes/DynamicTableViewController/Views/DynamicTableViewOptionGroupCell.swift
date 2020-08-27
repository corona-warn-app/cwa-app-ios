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

	@Published private(set) var selection: OptionGroup.Selection?

	func configure(options: [OptionGroup.Option], initialSelection: OptionGroup.Selection? = nil) {
		if optionGroup != nil {
			optionGroup.removeFromSuperview()
		}

		optionGroup = OptionGroup(options: options, initialSelection: initialSelection)
		setUp()

		selectionSubscription = optionGroup.$selection.assign(to: \.selection, on: self)
	}

	// MARK: - Private

	private var optionGroup: OptionGroup!
	private var selectionSubscription: AnyCancellable?

	private func setUp() {
		selectionStyle = .none
		backgroundColor = .enaColor(for: .background)

		optionGroup.translatesAutoresizingMaskIntoConstraints = false
		addSubview(optionGroup)

		NSLayoutConstraint.activate([
			optionGroup.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
			optionGroup.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
			optionGroup.topAnchor.constraint(equalTo: topAnchor, constant: 16),
			optionGroup.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -16)
		])
	}

}
