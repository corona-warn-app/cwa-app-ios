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

final class DynamicTableViewBulletPointCell: UITableViewCell {
	
	
	// Spacing will get divded by two and applied to top and bottom
	enum Spacing: CGFloat {
		case large = 16
		case normal = 6
	}
	
	// MARK: - Init
	
	override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
		super.init(style: style, reuseIdentifier: reuseIdentifier)
		
		setUp()
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	// MARK: - Internal

	func configure(text: String, spacing: Spacing, accessibilityTraits: UIAccessibilityTraits, accessibilityIdentifier: String? = nil) {
		contentLabel.text = text
		self.accessibilityIdentifier = accessibilityIdentifier
		self.accessibilityTraits = accessibilityTraits
		accessibilityLabel = text
		stackViewBottomSpacingConstraint?.constant = -(spacing.rawValue / 2)
		stackViewTopSpacingConstraint?.constant = spacing.rawValue / 2
		layoutIfNeeded()
	}

	// MARK: - Private

	private var stackView = UIStackView()
	private var contentLabel = ENALabel()
	private var stackViewTopSpacingConstraint: NSLayoutConstraint?
	private var stackViewBottomSpacingConstraint: NSLayoutConstraint?

	private func setUp() {
		stackView.axis = .horizontal
		stackView.alignment = .firstBaseline
		stackView.distribution = .fill
		stackView.spacing = 16
		
		stackView.translatesAutoresizingMaskIntoConstraints = false
		contentView.addSubview(stackView)
		
		
		stackViewBottomSpacingConstraint = stackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
		stackViewTopSpacingConstraint = stackView.topAnchor.constraint(equalTo: contentView.topAnchor)

		NSLayoutConstraint.activate([
			stackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -24),
			stackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24),
			stackViewBottomSpacingConstraint,
			stackViewTopSpacingConstraint
			].compactMap { $0 }
		)
		
		let pointLabel = ENALabel()
		pointLabel.textColor = .enaColor(for: .textPrimary1)
		pointLabel.style = .body
		pointLabel.numberOfLines = 1
		pointLabel.text = "•"
		pointLabel.setContentHuggingPriority(.required, for: .horizontal)
		stackView.addArrangedSubview(pointLabel)
		
		contentLabel.textColor = .enaColor(for: .textPrimary1)
		contentLabel.style = .body
		contentLabel.numberOfLines = 0
		stackView.addArrangedSubview(contentLabel)
	}
	
}
