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

class DynamicTableViewHeaderImageView: UITableViewHeaderFooterView {
	private(set) var imageView: UIImageView!
	private var heightConstraint: NSLayoutConstraint!

	var image: UIImage? {
		set { imageView.image = newValue }
		get { imageView.image }
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

	private func setup() {
		imageView = UIImageView()
		imageView.translatesAutoresizingMaskIntoConstraints = false
		imageView.contentMode = .scaleAspectFit

		addSubview(imageView)
		imageView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
		imageView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
		imageView.topAnchor.constraint(equalTo: topAnchor).isActive = true
		imageView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true

		heightConstraint = imageView.heightAnchor.constraint(equalToConstant: 100)
		heightConstraint.priority = .defaultHigh
		heightConstraint.isActive = true
	}
}
