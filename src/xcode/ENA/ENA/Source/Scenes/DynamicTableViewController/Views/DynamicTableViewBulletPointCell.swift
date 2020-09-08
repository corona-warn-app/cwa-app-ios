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

class DynamicTableViewBulletPointCell: UITableViewCell {

	// MARK: - Overrides

	override func awakeFromNib() {
		super.awakeFromNib()

		
		setUp()
	}
	
	override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
		super.init(style: style, reuseIdentifier: reuseIdentifier)
		setUp()
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	// MARK: - Internal

	func configure(text: String, textColor: UIColor? = nil, accessibilityTraits: UIAccessibilityTraits, accessibilityIdentifier: String? = nil) {
		contentLabel.text = text
//		contentLabel.textColor = textColor
		self.accessibilityIdentifier = accessibilityIdentifier
		self.accessibilityTraits = accessibilityTraits
		accessibilityLabel = text
	}

	// MARK: - Private

	private var stackView = UIStackView()
	private var contentLabel = ENALabel()

	private func setUp() {
		
		stackView.axis = .horizontal
		stackView.alignment = .firstBaseline
		stackView.distribution = .fill
		stackView.spacing = 16
		stackView.translatesAutoresizingMaskIntoConstraints = false
		
		contentLabel.textColor = .enaColor(for: .textPrimary1)
		contentLabel.style = .body
		contentLabel.numberOfLines = 0
		
	
		let pointLabel = ENALabel()
		pointLabel.textColor = .enaColor(for: .textPrimary1)
		pointLabel.style = .body
		pointLabel.numberOfLines = 1
		pointLabel.text = "•"
		pointLabel.setContentHuggingPriority(.required, for: .horizontal)
		
		stackView.addArrangedSubview(pointLabel)
		stackView.addArrangedSubview(contentLabel)
		
		contentView.addSubview(stackView)
		NSLayoutConstraint.activate([
			stackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 3),
			stackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -24),
			stackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -3),
			stackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24)
		])
		
	}


}
