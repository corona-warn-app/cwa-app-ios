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

class DynamicTypeTableViewCell: UITableViewCell, DynamicTableViewTextCell {
	required init?(coder: NSCoder) {
		super.init(coder: coder)
	}

	override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
		super.init(style: style, reuseIdentifier: reuseIdentifier)
		setup()
	}

	override func awakeFromNib() {
		super.awakeFromNib()
		setup()
	}

	private func setup() {
		selectionStyle = .none

		backgroundColor = .enaColor(for: .background)

		if let label = textLabel {
			label.translatesAutoresizingMaskIntoConstraints = false
			label.topAnchor.constraint(equalTo: contentView.layoutMarginsGuide.topAnchor).isActive = true
			label.bottomAnchor.constraint(equalTo: contentView.layoutMarginsGuide.bottomAnchor).isActive = true
			label.leadingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.leadingAnchor).isActive = true
			label.trailingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.trailingAnchor).isActive = true
		}

		resetMargins()
		configureDynamicType()
		configure(text: "", color: .enaColor(for: .textPrimary1))
	}

	override func prepareForReuse() {
		super.prepareForReuse()
		
		resetMargins()
		configureDynamicType()
		configure(text: "", color: .enaColor(for: .textPrimary1))
	}

	private func resetMargins() {
		contentView.layoutMargins = UIEdgeInsets(top: 8, left: 16, bottom: 8, right: 16)
		contentView.insetsLayoutMarginsFromSafeArea = false
	}

	func configureDynamicType(size: CGFloat = 17, weight: UIFont.Weight = .regular, style: UIFont.TextStyle = .body) {
		textLabel?.font = UIFont.preferredFont(forTextStyle: style).scaledFont(size: size, weight: weight)
		textLabel?.adjustsFontForContentSizeCategory = true
		textLabel?.numberOfLines = 0
	}

	func configure(text: String, color: UIColor? = nil) {
		textLabel?.text = text
		textLabel?.textColor = color ?? .enaColor(for: .textPrimary1)
	}

	func configureAccessibility(label: String? = nil, identifier: String? = nil, traits: UIAccessibilityTraits = .staticText) {
		textLabel?.accessibilityLabel = label
		textLabel?.accessibilityIdentifier = identifier
		accessibilityTraits = traits
	}
}
