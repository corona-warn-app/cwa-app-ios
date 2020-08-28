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

class MultipleChoiceChoiceView: UIControl {

	// MARK: - Init

	@available(*, unavailable)
	override init(frame: CGRect) {
		fatalError("init(frame:) has not been implemented")
	}

	@available(*, unavailable)
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	init(iconImage: UIImage?, title: String, onTap: @escaping () -> Void) {
		self.onTap = onTap

		super.init(frame: .zero)

		setUp(iconImage: iconImage, title: title)

		isSelected = false
	}

	// MARK: - Overrides

	override var isSelected: Bool {
		didSet {
			checkmarkImageView.image = isSelected ? UIImage(named: "Checkmark_Selected") : UIImage(named: "Checkmark_Unselected")
		}
	}

	override func endTracking(_ touch: UITouch?, with event: UIEvent?) {
		super.endTracking(touch, with: event)

		onTap()
	}

	// MARK: - Private

	private let onTap: () -> Void

	private let checkmarkImageView = UIImageView()

	private func setUp(iconImage: UIImage?, title: String) {
		backgroundColor = UIColor.enaColor(for: .background)

		let contentStackView = UIStackView()
		contentStackView.axis = .horizontal
		contentStackView.translatesAutoresizingMaskIntoConstraints = false
		addSubview(contentStackView)

		NSLayoutConstraint.activate([
			contentStackView.leadingAnchor.constraint(equalTo: leadingAnchor),
			contentStackView.trailingAnchor.constraint(equalTo: trailingAnchor),
			contentStackView.topAnchor.constraint(equalTo: topAnchor, constant: 11),
			contentStackView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -11),
			checkmarkImageView.widthAnchor.constraint(equalToConstant: 22),
			checkmarkImageView.heightAnchor.constraint(equalToConstant: 22)
		])

		contentStackView.addArrangedSubview(checkmarkImageView)
		contentStackView.setCustomSpacing(21, after: checkmarkImageView)

		if let iconImage = iconImage {
			let iconImageView = UIImageView(image: iconImage)

			NSLayoutConstraint.activate([
				iconImageView.widthAnchor.constraint(equalToConstant: 24),
				iconImageView.heightAnchor.constraint(equalToConstant: 16)
			])

			contentStackView.addArrangedSubview(iconImageView)
			contentStackView.setCustomSpacing(15, after: iconImageView)
		}

		let label = ENALabel()
		label.text = title

		contentStackView.addArrangedSubview(label)

		let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(viewTapped))
		addGestureRecognizer(tapGestureRecognizer)
	}

	@objc
	private func viewTapped() {
		onTap()
	}

}
