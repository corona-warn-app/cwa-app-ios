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

import Foundation
import UIKit

class HomeTestResultLoadingCell: HomeCardCollectionViewCell {

	// MARK: - Attributes.

	@IBOutlet weak var containerView: UIView!
	private var vStack = UIStackView()
	private var hStack = UIStackView()
	private let loadingIndicator = UIActivityIndicatorView()

	let title = ENALabel()
	let body = ENALabel()
	let button = ENAButton()

	func setupCell() {
		setupView()
		setupConstraints()
	}

	private func setupView() {
		vStack.axis = .vertical
		vStack.spacing = 16

		hStack.axis = .horizontal
		hStack.alignment = .center
		hStack.distribution = .fill
		hStack.spacing = 8

		loadingIndicator.startAnimating()

		title.style = .title2
		title.numberOfLines = 0

		body.style = .body
		body.numberOfLines = 0
		body.textColor = .enaColor(for: .textPrimary2)
	}

	override func prepareForReuse() {
		super.prepareForReuse()
		containerView.subviews.forEach { $0.removeFromSuperview() }

		vStack = UIStackView()
		hStack = UIStackView()
	}

	private func setupConstraints() {
		// No auto constraints.
		vStack.translatesAutoresizingMaskIntoConstraints = false
		button.translatesAutoresizingMaskIntoConstraints = false
		loadingIndicator.translatesAutoresizingMaskIntoConstraints = false

		// Add loading view constraints.
		loadingIndicator.widthAnchor.constraint(equalToConstant: 50).isActive = true
		loadingIndicator.heightAnchor.constraint(equalToConstant: 50).isActive = true

		// Fill stacks.
		containerView.addSubview(vStack)
		vStack.addArrangedSubview(title)
		vStack.addArrangedSubview(hStack)
		hStack.addArrangedSubview(loadingIndicator)
		hStack.addArrangedSubview(body)

		containerView.addSubview(button)

		// VStack constraints.
		vStack.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 16).isActive = true
		vStack.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16).isActive = true
		vStack.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16).isActive = true

		// Button constraints.
		button.topAnchor.constraint(equalTo: vStack.bottomAnchor, constant: 16).isActive = true
		button.heightAnchor.constraint(equalToConstant: 50).isActive = true
		button.leadingAnchor.constraint(equalTo: vStack.leadingAnchor).isActive = true
		button.trailingAnchor.constraint(equalTo: vStack.trailingAnchor).isActive = true
		button.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -16).isActive = true
	}
}
