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

import Foundation
import UIKit
import Combine

/// - NOTE: The implementation may raise a 'kCFRunLoopCommonModes' warning that is a known UIKit bug: https://developer.apple.com/forums/thread/132035
class SwitchCell: UITableViewCell {

	typealias ToggleHandler = (Bool) -> Void

	// MARK: - Private attributes.

	private let uiSwitch: UISwitch
	private var onToggleAction: ToggleHandler?
	private var subscriptions = Set<AnyCancellable>()

	// MARK: - Initializers.

	override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
		uiSwitch = UISwitch()
		super.init(style: style, reuseIdentifier: reuseIdentifier)
		self.selectionStyle = .none
		setUpSwitch()
	}

	@available(*, unavailable)
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	// MARK: - Helpers.

	private func setUpSwitch() {
		accessoryView = uiSwitch
		uiSwitch.onTintColor = .enaColor(for: .tint)
		uiSwitch.addTarget(self, action: #selector(onToggle), for: .touchUpInside)
		imageView?.contentMode = .scaleAspectFit
	}

	@objc
	private func onToggle() {
		onToggleAction?(uiSwitch.isOn)
	}

	// MARK: - Public API.

	func configure(text: String, icon: UIImage? = nil, isOn: Bool = false, onSwitchSubject: Published<Bool>.Publisher? = nil, onToggle: ToggleHandler? = nil) {
		imageView?.image = icon
		textLabel?.text = text
		uiSwitch.isOn = isOn
		onToggleAction = onToggle
		onSwitchSubject?
			.sink { self.uiSwitch.setOn($0, animated: true) }
			.store(in: &subscriptions)
	}

	override func layoutSubviews() {
		super.layoutSubviews()
		self.imageView?.bounds = CGRect(x: 0, y: 0, width: 32, height: 32)
	}
}
