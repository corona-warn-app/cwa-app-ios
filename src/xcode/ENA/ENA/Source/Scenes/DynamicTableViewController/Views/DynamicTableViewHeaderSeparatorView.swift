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

import Foundation
import UIKit

class DynamicTableViewHeaderSeparatorView: UITableViewHeaderFooterView {
	private var separatorView: UIView!
	private var heightConstraint: NSLayoutConstraint!

	var color: UIColor? {
		set { separatorView.backgroundColor = newValue }
		get { separatorView.backgroundColor }
	}

	var height: CGFloat {
		set { heightConstraint.constant = newValue }
		get { heightConstraint.constant }
	}

	@available(*, unavailable)
	required init?(coder _: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	override init(reuseIdentifier: String?) {
		super.init(reuseIdentifier: reuseIdentifier)
		setup()
	}

	override func prepareForReuse() {
		super.prepareForReuse()

		layoutMargins = .zero
	}

	private func setup() {
		preservesSuperviewLayoutMargins = false
		insetsLayoutMarginsFromSafeArea = false
		layoutMargins = .zero

		separatorView = UIView()
		separatorView.translatesAutoresizingMaskIntoConstraints = false

		addSubview(separatorView)

		separatorView.leadingAnchor.constraint(equalTo: layoutMarginsGuide.leadingAnchor).isActive = true
		separatorView.trailingAnchor.constraint(equalTo: layoutMarginsGuide.trailingAnchor).isActive = true
		separatorView.topAnchor.constraint(equalTo: layoutMarginsGuide.topAnchor).isActive = true
		let bottomConstraint = separatorView.bottomAnchor.constraint(equalTo: layoutMarginsGuide.bottomAnchor)
		bottomConstraint.priority = .defaultHigh
		bottomConstraint.isActive = true

		heightConstraint = separatorView.heightAnchor.constraint(equalToConstant: 1)
		heightConstraint.isActive = true
	}
}
