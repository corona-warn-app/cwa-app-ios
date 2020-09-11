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

import Foundation
import UIKit

class IconCell: UITableViewCell {

	// MARK: - View elements.

	lazy var title = ENALabel(frame: .zero)
	lazy var body = ENALabel(frame: .zero)
	lazy var iconView = UIImageView(frame: .zero)

	// MARK: - Initializer.

	required init?(coder: NSCoder) {
		super.init(coder: coder)
	}

	override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
		super.init(style: style, reuseIdentifier: reuseIdentifier)
	}

	private func setup(textStyle: ENAColor, backgroundStyle: ENAColor) {

		// MARK: - General cell setup.
		selectionStyle = .none
		backgroundColor = .enaColor(for: backgroundStyle)
		iconView.contentMode = .scaleAspectFit

		// MARK: - Title adjustment.
		title.style = .headline
		title.textColor = .enaColor(for: textStyle)
		title.lineBreakMode = .byWordWrapping
		title.numberOfLines = 0

		// MARK: - Body adjustment.
		body.style = .body
		body.textColor = .enaColor(for: textStyle)
		body.lineBreakMode = .byWordWrapping
		body.numberOfLines = 0

		UIView.translatesAutoresizingMaskIntoConstraints(for: [
			title,
			body,
			iconView
		], to: false)

		contentView.addSubview(title)
		contentView.addSubview(body)
		contentView.addSubview(iconView)
	}

	// MARK: - Constraint setting.

	private func setupConstraints() {
		title.sizeToFit()
		body.sizeToFit()

		let marginGuide = contentView.layoutMarginsGuide

		iconView.leadingAnchor.constraint(equalTo: marginGuide.leadingAnchor).isActive = true
		title.topAnchor.constraint(equalTo: marginGuide.topAnchor).isActive = true
		title.trailingAnchor.constraint(equalTo: marginGuide.trailingAnchor).isActive = true
		title.leadingAnchor.constraint(equalTo: iconView.trailingAnchor, constant: 16).isActive = true
		iconView.centerYAnchor.constraint(equalTo: title.centerYAnchor).isActive = true

		iconView.widthAnchor.constraint(equalToConstant: 32).isActive = true
		iconView.heightAnchor.constraint(equalToConstant: 32).isActive = true

		body.topAnchor.constraint(equalTo: title.bottomAnchor, constant: 8).isActive = true
		body.leadingAnchor.constraint(equalTo: title.leadingAnchor).isActive = true
		body.trailingAnchor.constraint(equalTo: title.trailingAnchor).isActive = true
		body.bottomAnchor.constraint(equalTo: marginGuide.bottomAnchor).isActive = true
	}

	// MARK: - Configurator for DynamicTableView integration.

	func configure(
		icon: UIImage? = nil,
		title: NSMutableAttributedString,
		body: NSMutableAttributedString,
		textStyle: ENAColor,
		backgroundStyle: ENAColor
	) {
		setup(textStyle: textStyle, backgroundStyle: backgroundStyle)
		self.title.attributedText = title
		self.body.attributedText = body
		if let iconImage = icon { iconView.image = iconImage }
		setupConstraints()
	}

}
