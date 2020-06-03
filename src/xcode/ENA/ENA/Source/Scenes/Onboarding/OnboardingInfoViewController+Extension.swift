//
// Corona-Warn-App
//
// SAP SE and all other contributors /
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

extension OnboardingInfoViewController {

	func addPanel(title: String, body: String) {

		let titleLabel = UILabel()
		titleLabel.translatesAutoresizingMaskIntoConstraints = false
		titleLabel.text = title
		titleLabel.font = UIFont.boldSystemFont(ofSize: UIFont.preferredFont(forTextStyle: .headline).pointSize)
		titleLabel.textColor = UIColor.preferredColor(for: ColorStyle.textPrimary1, interface: .light)
		titleLabel.lineBreakMode = .byWordWrapping
		titleLabel.numberOfLines = 0

		let textLabel = UILabel()
		textLabel.translatesAutoresizingMaskIntoConstraints = false
		textLabel.text = body
		textLabel.font = UIFont.systemFont(ofSize: UIFont.preferredFont(forTextStyle: .body).pointSize)
		textLabel.textColor = UIColor.preferredColor(for: ColorStyle.textPrimary2, interface: .light)
		textLabel.lineBreakMode = .byWordWrapping
		textLabel.numberOfLines = 0

		let labelStackView = UIStackView(arrangedSubviews: [titleLabel, textLabel])
		labelStackView.translatesAutoresizingMaskIntoConstraints = false
		labelStackView.axis = .vertical
		labelStackView.alignment = .fill
		labelStackView.distribution = .equalSpacing
		labelStackView.spacing = 10

		let containerView = UIView()
		containerView.translatesAutoresizingMaskIntoConstraints = false
		containerView.addSubview(labelStackView)
		containerView.layer.cornerRadius = 14.0
		containerView.backgroundColor = UIColor.preferredColor(for: ColorStyle.backgroundSecondary, interface: .light)

		let parentContainerView = UIView()
		parentContainerView.translatesAutoresizingMaskIntoConstraints = false
		parentContainerView.addSubview(containerView)

		stackView.addArrangedSubview(parentContainerView)

		NSLayoutConstraint.activate([
			containerView.topAnchor.constraint(equalTo: parentContainerView.topAnchor, constant: 16),
			containerView.bottomAnchor.constraint(equalTo: parentContainerView.bottomAnchor, constant: -16),
			containerView.leadingAnchor.constraint(equalTo: parentContainerView.leadingAnchor, constant: 16),
			containerView.trailingAnchor.constraint(equalTo: parentContainerView.trailingAnchor, constant: -16),

			labelStackView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 16),
			labelStackView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -16),
			labelStackView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
			labelStackView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16)
		])

	}

}
