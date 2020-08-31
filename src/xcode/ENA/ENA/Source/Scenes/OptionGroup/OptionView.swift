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

class OptionView: UIControl {

	// MARK: - Init

	@available(*, unavailable)
	override init(frame: CGRect) {
		fatalError("init(frame:) has not been implemented")
	}

	@available(*, unavailable)
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	init(title: String, onTap: @escaping () -> Void) {
		self.onTap = onTap

		super.init(frame: .zero)

		setUp(title: title)

		isSelected = false
	}

	// MARK: - Overrides

	override var isSelected: Bool {
		didSet {
			updateForSelectionState()
		}
	}

	override func endTracking(_ touch: UITouch?, with event: UIEvent?) {
		super.endTracking(touch, with: event)

		onTap()
	}

	override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
		super.traitCollectionDidChange(previousTraitCollection)

		updateForSelectionState()
	}

	// MARK: - Private

	private let onTap: () -> Void

	private let checkmarkImageView = UIImageView()

	private func setUp(title: String) {
		backgroundColor = UIColor.enaColor(for: .background)

		layer.cornerRadius = 10

		layer.shadowColor = UIColor.enaColor(for: .shadow).cgColor
		layer.shadowOffset = CGSize(width: 0, height: 2)
		layer.shadowRadius = 2
		layer.shadowOpacity = 1

		layer.masksToBounds = false

		checkmarkImageView.translatesAutoresizingMaskIntoConstraints = false
		addSubview(checkmarkImageView)

		let label = ENALabel()
		label.numberOfLines = 0
		label.style = .headline
		label.text = title

		label.translatesAutoresizingMaskIntoConstraints = false
		addSubview(label)

		NSLayoutConstraint.activate([
			label.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
			label.topAnchor.constraint(equalTo: topAnchor, constant: 33),
			label.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -33),
			checkmarkImageView.leadingAnchor.constraint(greaterThanOrEqualTo: label.trailingAnchor, constant: 16),
			checkmarkImageView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
			checkmarkImageView.widthAnchor.constraint(equalToConstant: 22),
			checkmarkImageView.heightAnchor.constraint(equalToConstant: 22),
			checkmarkImageView.centerYAnchor.constraint(equalTo: label.centerYAnchor)
		])
	}

	private func updateForSelectionState() {
		layer.borderWidth = isSelected ? 2 : 1
		layer.borderColor = isSelected ? UIColor.enaColor(for: .buttonPrimary).cgColor : UIColor.enaColor(for: .hairline).cgColor

		checkmarkImageView.image = isSelected ? UIImage(named: "Checkmark_Selected") : UIImage(named: "Checkmark_Unselected")
	}

}
