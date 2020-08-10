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

#if !RELEASE

class DMFakeRequestCell: UITableViewCell {

	let button = ENAButton(type: .roundedRect)

	static var reuseIdentifier = "FakeRequestCell"
	override init(style _: UITableViewCell.CellStyle, reuseIdentifier: String?) {
		super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
		setupViews()
	}

	@available(*, unavailable)
	required init?(coder _: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	private func setupViews() {
		self.contentView.addSubview(button)
		let margin = self.contentView.layoutMarginsGuide
		button.translatesAutoresizingMaskIntoConstraints = false
		button.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
		// swiftlint:disable force_unwrapping
		button.leadingAnchor.constraint(equalTo: self.textLabel!.trailingAnchor, constant: 20).isActive = true
		button.trailingAnchor.constraint(equalTo: margin.trailingAnchor).isActive = true
		button.topAnchor.constraint(equalTo: margin.topAnchor).isActive = true
		button.bottomAnchor.constraint(equalTo: margin.bottomAnchor).isActive = true
		button.setTitle("Send", for: .normal)
	}

	func addButtonAction(target: Any?, action: Selector) {
		button.addTarget(target, action: action, for: .touchUpInside)
	}
}

#endif
