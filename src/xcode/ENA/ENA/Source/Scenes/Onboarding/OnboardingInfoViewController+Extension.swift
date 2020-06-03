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

		let titleLabel = ENALabel()
		titleLabel.style = .headline
		titleLabel.text = title
		titleLabel.translatesAutoresizingMaskIntoConstraints = false
		titleLabel.textColor = UIColor.preferredColor(for: .textPrimary1)
		titleLabel.lineBreakMode = .byWordWrapping
		titleLabel.numberOfLines = 0

		let textLabel = ENALabel()
		textLabel.style = .body
		textLabel.text = body
		textLabel.translatesAutoresizingMaskIntoConstraints = false
		textLabel.textColor = UIColor.preferredColor(for: .textPrimary2)
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
		containerView.backgroundColor = UIColor.preferredColor(for: .backgroundSecondary)

		stackView.addArrangedSubview(containerView)

		NSLayoutConstraint.activate([
			labelStackView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 16),
			labelStackView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -16),
			labelStackView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
			labelStackView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16)
		])

	}

}
